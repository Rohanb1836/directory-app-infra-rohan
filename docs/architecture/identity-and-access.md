# Identity and Access Design

- **Status:** Accepted
- **Version:** 2.2 (2026-09-30: Spring Boot 4.1, Spring Security 7, and Java 25 per ADR-0018. Earlier in v2.1: one user per business account.)
- **Date:** 2026-09-27
- **Decisions:** ADR-0005 (Keycloak), ADR-0006 (sessions), ADR-0007 (authorization), ADR-0016 (Keycloak deployment)
- **Replaces:** Version 1 (local authentication with Spring Security) and the Keycloak migration plan (the former epic E17, now cancelled)

---

## 1. Summary

BlackPages uses **Keycloak for authentication from day one**. The Spring Boot backend is the **only OIDC client for the browser**, and it gives the browser an opaque session cookie. Keycloak tokens never reach the browser.

**Authorization and all business identity data stay in the application.** That covers roles, locations, memberships, entitlements, and onboarding.

| Keycloak owns | The application owns |
|---|---|
| Credentials (passwords are hashed with Argon2 by default) | The `app_user` profile, status, and onboarding state |
| Login, registration, email verification, password reset | Platform roles: SHOPPER, BUSINESS, SITE_OPERATOR, ADMIN |
| Brute-force protection and lockout | Operator location assignments |
| OTP (TOTP) and, later, passkeys and social login | Business account ownership (exactly one OWNER per account in the MVP) |
| The SSO session and account console (password change, OTP devices, sessions) | Entitlements (by listing tier and account type) and every authorization decision |
| Login and admin event logs | Application sessions (Spring Session JDBC) |
| The `staff` realm role, used **only** for MFA policy | User lifecycle decisions: suspend, delete, invite, grant staff role |

---

## 2. Topology

### Local development
```
Browser ─► Next.js dev server :3000 ──(rewrites /api/*)──► Spring Boot (IDE) :8080
                                                              │
Browser ─► Keycloak :8081 (login pages) ◄────── OIDC ─────────┤
                                                              │
               Postgres + PostGIS :5432  ◄────────────────────┘
               ├─ database "blackpages" (role blackpages)
               └─ database "keycloak"   (role keycloak) ◄── Keycloak
               Mailpit :8025 (web UI) / :1025 (SMTP) ◄── app and Keycloak email
```
In local development, Next.js rewrites `/api/*` to `localhost:8080`, so the browser still sees a single origin, as it would in production.

### Staging and production
```
                 ┌── blackpages.io/api/*   ─► ECS: api (Spring Boot)
Browser ─► ALB ──┼── blackpages.io/*       ─► ECS: web (Next.js)
                 └── auth.blackpages.io/*  ─► ECS: keycloak   (/admin/* restricted by source IP)

api ──(Admin API, client credentials)──► keycloak
keycloak ──(back-channel logout, internal address)──► api
api, keycloak ──► RDS PostgreSQL (databases "blackpages" and "keycloak", separate roles)
```

---

## 3. Realm design (`blackpages`)

| Setting | Value | Notes |
|---|---|---|
| Login identifier | Email address, with `registrationEmailAsUsername` enabled | Usernames aren't shown anywhere |
| Self-registration | Enabled | Staff can't self-register; they're provisioned by the application |
| Email verification | Required | |
| Password policy | `length(12) and maxLength(128) and notEmail and notUsername and passwordHistory(3)` | Follows NIST 800-63B: a minimum length and no composition rules. A check against breached passwords is an optional extension (see section 13). |
| Brute-force protection | On. 10 failures cause a temporary lockout that grows by 60 seconds each time, up to 15 minutes | No permanent lockout, so attackers can't lock people out deliberately |
| OTP policy | TOTP, HmacSHA1, 6 digits, 30-second period | Works with standard authenticator apps |
| Remember-me | Enabled | The application applies its own session lifetimes (ADR-0006) |
| SSO session | 24-hour idle and 30-day maximum. Remember-me: 30 days | |
| Access token lifespan | 5 minutes | Stored only on the server and refreshed as needed |
| Account console | Enabled, with **account deletion turned off** | Deletion is done through the application so billing and reviews are cleaned up |
| Events | Login events kept for 90 days. Admin events enabled | |
| Themes | `login`, `email`, and `account` use `blackpages` (Keycloakify) | Until the theme is ready, local development uses the default theme |

### Clients

| Client | Type | Flows | Purpose |
|---|---|---|---|
| `blackpages-bff` | Confidential client with PKCE (S256) | Authorization code only. Direct password grants and implicit flow are **disabled**. | Browser login through the backend |
| `blackpages-admin-api` | Confidential client with a service account | Client credentials only | The backend's `UserProvisioningPort`. Roles: `realm-management` → `manage-users`, `view-users`, `query-users` |

On `blackpages-bff`:
- The redirect URI is `{APP_BASE_URL}/api/auth/oauth2/code/keycloak`.
- The post-logout redirect URI is `{APP_BASE_URL}/`.
- Back-channel logout is enabled, and the session ID is required.
- There are no web origins, because the browser never calls Keycloak with CORS.

### Roles and groups
- **Realm role `staff`:** assigned by the application when a user is granted ADMIN or SITE_OPERATOR, and removed when the last staff role is revoked. It drives MFA enforcement (section 5.4).
- **No other realm roles, client roles, or groups are used.**

---

## 4. Identity model

### Tables in the application database

| Table | Columns | Notes |
|---|---|---|
| `app_user` | id (UUID), email, email_verified, display_name, status (ACTIVE, SUSPENDED, DELETED), onboarding_status (PENDING, COMPLETE), created_at, last_login_at | Email and email_verified are **copied from Keycloak claims** at each login. They are never edited in the application. |
| `user_identity` | user_id, provider (`keycloak`), subject (Keycloak's user ID), created_at. Provider and subject are unique together. | Links an application user to Keycloak. Also ready for identity brokering later. |
| `user_role` | user_id, role | SHOPPER, BUSINESS, SITE_OPERATOR, ADMIN |
| `operator_location` | user_id, location_id | |
| `shopper_profile`, `business_account`, `business_account_member` | As in the Sprint 0 data model | In the MVP, `business_account_member` has **exactly one row per account, with role OWNER** (unique on `business_account_id`). The table is kept so more users can be added after the MVP. |
| `invitation` | id, kind (STAFF; BUSINESS_MEMBER is added after the MVP), email, target_id, role, token_hash, expires_at, accepted_at, invited_by | Tracks the application side of invites |
| `spring_session`, `spring_session_attributes` | The standard Spring Session schema | Managed by Flyway |

**Removed from version 1 of this design:** `local_credential`, `local_mfa_totp`, `mfa_recovery_code`, `auth_token`, and `login_event`. Keycloak now covers all of them.

### Rules
- **Every reference to a user uses `app_user.id`.** Keycloak's subject appears only in `user_identity`, and email addresses are never used as keys.
- **One person has one account.** The same user can hold a shopper profile, belong to business accounts, or both.

---

## 5. Flows

### 5.1 Registration and onboarding
1. The visitor clicks "Sign up". The browser goes to `/api/auth/register?returnTo=/onboarding`.
2. The backend starts the authorization code flow with PKCE, adding `prompt=create` so Keycloak shows its registration page. The fallback is Keycloak's registrations endpoint (see section 13).
3. On Keycloak's registration page (themed), the visitor enters an email and password. Keycloak then sends a verification email, and the visitor clicks the link.
4. Keycloak redirects to `/api/auth/oauth2/code/keycloak`, and the backend exchanges the authorization code for tokens.
5. **Just-in-time provisioning** (in `ProvisioningOidcUserService`):
   - Looks up `user_identity` by provider and subject.
   - If there's no match, creates `app_user` with `onboarding_status = PENDING`, plus the `user_identity` row, and publishes `UserRegistered`.
   - Copies `email` and `email_verified` from the claims.
6. The backend creates the application session and redirects to `returnTo`. Next.js middleware sees `onboardingStatus = PENDING` from `/api/auth/me` and sends the user to `/onboarding`.
7. **Onboarding** (screens in the application, calling the `/api/onboarding/*` endpoints):
   - The user chooses the account type (shopper or business) and a home location.
   - For a business, the user enters business account details, and the account's **default Silver listing** is created (SPEC-BILL-01, BR-PE-05).
   - This creates `shopper_profile`, or `business_account` with an OWNER membership, and grants the matching role.
   - The flow hands off to billing (E7) to collect the card and the first invoice (the $1 service fee, plus the default listing's tier price or the shopper account price).
   - Finally, `onboarding_status` becomes COMPLETE.

**Rules:**
- Users with an unverified email can't finish onboarding, publish a listing, pay, review, or send messages.
- Keycloak's `verifyEmail` setting normally blocks unverified logins. The application checks again anyway.

### 5.2 Login
1. The browser goes to `/api/auth/login?returnTo=<relative path>`. The backend validates `returnTo`, which must start with `/` and must not start with `//`, and stores it in the session.
2. The authorization code flow with PKCE runs against Keycloak, which shows its login page and, if needed, the OTP step.
3. On the callback, the backend:
   - runs the same just-in-time lookup and claim sync as registration;
   - **rejects the login if `app_user.status` isn't ACTIVE**;
   - issues a new session ID (session-fixation protection);
   - sets the session lifetime by role (ADR-0006);
   - updates `last_login_at`.
4. The backend redirects to `returnTo`.

### 5.3 Logout
- **Started by the user:** `POST /api/auth/logout` (with the CSRF token) ends the application session and redirects to Keycloak's end-session endpoint with `id_token_hint`. Keycloak then redirects back to `/`.
- **Started in Keycloak:** when a session ends in the admin console, or all sessions are ended after a password reset, Keycloak sends a logout token to `http://api.internal:8080/logout/connect/back-channel/keycloak`. Spring Security then ends the matching application sessions.

### 5.4 MFA for staff
**MVP approach:**
- When a staff role is granted:
  - the application adds the `staff` realm role in Keycloak;
  - it sets the required action `CONFIGURE_TOTP` if the user has no OTP credential;
  - it ends the user's current application sessions.
- Keycloak's default browser flow asks for an OTP code whenever the user has one configured.
- **Checks made by the application:**
  - At every staff login, the backend confirms through the Admin API that the user has an OTP credential. If not, the session gets no staff permissions and the user is sent to OTP setup.
  - The nightly reconciliation job (section 9) finds staff without OTP, adds the required action back, and ends their sessions.

**Hardened approach (story 2.21, Sprint 2):** a custom browser flow in `keycloak-config-cli` with a condition requiring OTP for anyone with the `staff` role. This stops a staff member from removing their OTP device and logging in without it.

**Recovery:** recovery codes, where the pinned Keycloak version supports them. Otherwise an admin resets the user's OTP through the application's admin UI, which ends the user's sessions and sets `CONFIGURE_TOTP` again.

### 5.5 Staff invite
1. An admin calls `POST /api/admin/staff/invites` with an email, a role, and locations (for an operator).
2. The application creates an `invitation` row, then calls `UserProvisioningPort.createUser(...)`. That uses the Admin API to create the user with `emailVerified = false`, the `staff` realm role, and the required actions `VERIFY_EMAIL`, `UPDATE_PASSWORD`, and `CONFIGURE_TOTP`. It then calls `execute-actions-email` with a lifespan of 72 hours.
3. The application creates `app_user` and `user_identity` straight away, and grants the role and locations. The status stays ACTIVE, but staff permissions stay inactive until the MFA check in 5.4 passes.
4. On the staff member's first login, the invitation is marked accepted.

### 5.6 Business team invites (after the MVP)
- **In the MVP, each business account has exactly one user, its owner.** There's no way to invite other people to a business account, and there's no EDITOR role.
- Team invites and an editor role are planned after the MVP (backlog P.11). The `business_account_member` and `invitation` tables are designed so they can be added without a migration of existing data.

### 5.7 Password reset and password change
- **Reset** happens on Keycloak's "Forgot password" page, and Keycloak sends the email. Keycloak's option to sign out other sessions after a reset triggers back-channel logout to the application.
- **Change** happens in Keycloak's account console, with the same sign-out behavior.

### 5.8 Email change
- The user changes their email in Keycloak's account console, and Keycloak verifies the new address (the "update email" feature).
- The application picks up the new `email` claim at the next login. A `UserEmailChanged` event lets billing update the Stripe customer's email.

### 5.9 Suspend and reinstate (admin or operator, within their scope)
- **Suspend:** the application sets `status = SUSPENDED` and ends all the user's application sessions. It then calls the Admin API to **disable** the user and log out their Keycloak sessions, and publishes `UserDisabled`.
- **Reinstate** reverses those steps.

### 5.10 Account deletion
- `DELETE /api/account` requires re-authentication within the last 5 minutes, checked with `max_age=300`, which forces a new login.
- The application:
  - publishes `UserDeleted`, which makes billing cancel subscriptions and makes the review module anonymize the user's reviews;
  - anonymizes `app_user` and sets `status = DELETED`;
  - deletes `user_identity`;
  - deletes the Keycloak user through the Admin API;
  - ends all the user's sessions.

### 5.11 Social login and passkeys (after the MVP)
- **Social login** uses Keycloak identity brokering (Google, Apple), with "first broker login" linking to an existing account only when the email is verified. The application needs no changes, because the `user_identity` lookup uses Keycloak's subject.
- **Passkeys** use Keycloak's WebAuthn passwordless support, enabled through the realm configuration.

---

## 6. Backend implementation

### 6.1 Dependencies
- `spring-boot-starter-security-oauth2-client` (the Spring Boot 4 name)
- `spring-boot-starter-security`
- `spring-boot-starter-security-test`, for the `oidcLogin()` test support
- `spring-session-jdbc`
- The **Keycloak Admin REST API is called with Spring's `RestClient`** inside `KeycloakUserProvisioningAdapter`, using client-credentials tokens for `blackpages-admin-api`. This keeps the backend on Jackson 3 (ADR-0018, decision 5).

### 6.2 Configuration (`application.yml`)
```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-id: blackpages-bff
            client-secret: ${KEYCLOAK_BFF_CLIENT_SECRET}
            authorization-grant-type: authorization_code
            scope: openid,profile,email
            redirect-uri: "{baseUrl}/api/auth/oauth2/code/{registrationId}"
        provider:
          keycloak:
            issuer-uri: ${KEYCLOAK_ISSUER_URI}   # e.g. https://auth.blackpages.io/realms/blackpages
  session:
    jdbc:
      initialize-schema: never                  # Flyway owns the Spring Session tables

server:
  forward-headers-strategy: framework          # behind the ALB
  servlet:
    session:
      timeout: 24h                             # overridden per role at login (ADR-0006)
      cookie:
        name: __Host-bp_session
        secure: true
        http-only: true
        same-site: lax
        path: /

blackpages:
  keycloak:
    admin-api:
      server-url: ${KEYCLOAK_INTERNAL_URL}     # e.g. http://keycloak.internal:8080
      realm: blackpages
      client-id: blackpages-admin-api
      client-secret: ${KEYCLOAK_ADMIN_API_CLIENT_SECRET}
  bootstrap:
    admin-emails: ${BOOTSTRAP_ADMIN_EMAILS:}   # users granted ADMIN on first login, to create the first admin
```

### 6.3 Security filter chain (outline)
```java
@Bean
SecurityFilterChain apiChain(HttpSecurity http,
                             OAuth2AuthorizationRequestResolver pkceAndPromptResolver,
                             ProvisioningOidcUserService provisioningUserService,
                             LogoutSuccessHandler keycloakLogoutHandler) throws Exception {
    http
        .securityMatcher("/api/**", "/logout/connect/back-channel/**")
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/public/**", "/api/auth/login", "/api/auth/register",
                             "/api/auth/oauth2/**", "/logout/connect/back-channel/**").permitAll()
            .anyRequest().authenticated())
        .oauth2Login(login -> login
            .authorizationEndpoint(a -> a.baseUri("/api/auth/oauth2/authorization")
                                         .authorizationRequestResolver(pkceAndPromptResolver))
            .redirectionEndpoint(r -> r.baseUri("/api/auth/oauth2/code/*"))
            .userInfoEndpoint(u -> u.oidcUserService(provisioningUserService))
            .successHandler(new ReturnToSuccessHandler()))
        .oidcLogout(logout -> logout.backChannel(Customizer.withDefaults()))
        .logout(logout -> logout.logoutUrl("/api/auth/logout")
                                .logoutSuccessHandler(keycloakLogoutHandler))
        .csrf(csrf -> csrf
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            .ignoringRequestMatchers("/logout/connect/back-channel/**"))
        .exceptionHandling(e -> e.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)));
    return http.build();
}
```
Notes:
- `pkceAndPromptResolver` wraps `DefaultOAuth2AuthorizationRequestResolver` and uses `OAuth2AuthorizationRequestCustomizers.withPkce()`. It adds `prompt=create` for `/api/auth/register`, and `max_age=300` for re-authentication before sensitive actions.
- `keycloakLogoutHandler` is an `OidcClientInitiatedLogoutSuccessHandler` with the post-logout redirect set to `{baseUrl}/`.
- Follow the **Spring Security 7** guidance on CSRF for single-page apps when choosing the CSRF request handler, since the frontend reads the token from its cookie. Check the whole filter chain outline against the Spring Security 7 reference documentation in Sprint 1 (ADR-0018).
- API calls without a session get **401**, not a redirect. The frontend handles the redirect to `/api/auth/login`.

### 6.4 Interfaces (in `io.blackpages.identity.api`)
```java
public record CurrentUser(UUID userId, Set<PlatformRole> roles, boolean emailVerified,
                          boolean staffMfaVerified, OnboardingStatus onboarding) {}

public interface CurrentUserProvider { Optional<CurrentUser> current(); }

public interface UserProvisioningPort {           // implemented by KeycloakUserProvisioningAdapter
    String createStaffUser(String email, Set<RequiredAction> actions);   // returns the Keycloak subject
    void assignStaffRealmRole(String subject, boolean staff);
    boolean hasOtpCredential(String subject);
    void disable(String subject);
    void enable(String subject);
    void logoutAllSessions(String subject);
    void delete(String subject);
    void resetOtp(String subject);
}
```
- No module outside `identity` imports Spring Security OAuth2 types or Keycloak types. An ArchUnit rule enforces this.
- `KeycloakUserProvisioningAdapter` calls the Admin REST API through Spring `RestClient`, with timeouts, retries, and a circuit breaker.
- **Changes that should happen in both systems use the outbox (ADR-0010).** The application writes its own change and an outbox event in one transaction, and a worker then calls Keycloak. This avoids half-finished changes when Keycloak isn't reachable.

---

## 7. Authorization
The four layers are described in ADR-0007. Keycloak tokens are never used for authorization decisions.

---

## 8. API surface

| Method and path | Kind | Notes |
|---|---|---|
| `GET /api/auth/login?returnTo=` | Browser redirect | Starts the authorization code flow |
| `GET /api/auth/register?returnTo=` | Browser redirect | Adds `prompt=create` |
| `POST /api/auth/logout` | Browser redirect | Requires the CSRF token; ends the Keycloak session too |
| `GET /api/auth/me` | JSON | User, roles, locations, memberships, entitlements, onboarding status, and whether staff MFA is verified |
| `GET /api/auth/account-settings-url` | JSON | Link to Keycloak's account console for password, OTP, and sessions |
| `POST /api/onboarding/shopper`, `POST /api/onboarding/business` | JSON | Onboarding step 2 |
| `POST /api/admin/staff/invites` | JSON | Admin only |
| `POST /api/admin/users/{id}/suspend`, `.../reinstate`, `.../reset-mfa` | JSON | Admin, or operator within their scope |
| `DELETE /api/account` | JSON | Requires re-authentication within the last 5 minutes |
| `POST /logout/connect/back-channel/keycloak` | Called by Keycloak | Internal only; not in the public contract |

---

## 9. Keeping the application and Keycloak consistent
- **Changes made in the application** (suspend, reinstate, delete, grant staff, reset MFA) are pushed to Keycloak through outbox events and the Admin API.
- **Changes made in Keycloak** (email change, password reset, OTP changes, sessions ended by an admin) reach the application through claims at the next login, back-channel logout, and reconciliation.
- **A nightly reconciliation job** (using ShedLock) checks every `user_identity` against Keycloak:
  - A Keycloak user that is missing or disabled while the application user is ACTIVE raises an alert. The application user is suspended if the Keycloak user was deleted.
  - Staff without an OTP credential get `CONFIGURE_TOTP` added back and their sessions ended.
  - The `staff` realm role is corrected to match the application roles.
  - Keycloak users with no `user_identity` (someone who registered but never logged in) are removed after 30 days.

---

## 10. Frontend integration (web team)
- **The `auth` feature adapter:**
  - `login(returnTo)` and `register(returnTo)` set `window.location` to `/api/auth/login` or `/api/auth/register`.
  - `logout()` submits a POST form to `/api/auth/logout` with the CSRF token.
  - `me()` calls the generated client.
- **Next.js middleware** protects the `(member)` and `(admin)` route groups:
  - A 401 from `/api/auth/me` redirects to login.
  - `onboarding = PENDING` redirects to `/onboarding`.
  - Admin routes require a staff role **and** `staffMfaVerified`.
- **During server rendering**, the incoming `Cookie` header is forwarded on backend calls.
- **The Keycloakify theme** (`directory-app-ui/keycloak-theme/`) covers the login, registration, OTP setup, OTP entry, password reset, required-action, and email templates. It's built into `blackpages-keycloak-theme-<version>.jar` and published as a CI artifact, which the infra repo pins.
- **The account settings page** in the member dashboard links to Keycloak's account console for password, OTP devices, and active sessions. It doesn't rebuild those features.

---

## 11. Local development
1. Run `cp infra/local/.env.example infra/local/.env`, then `docker compose -f infra/local/docker-compose.yml up -d`.
2. The Keycloak admin console is at http://localhost:8081/admin, using the bootstrap admin from `.env`. Mailpit is at http://localhost:8025.
3. Start the backend with `SPRING_PROFILES_ACTIVE=local`, which sets the issuer to `http://localhost:8081/realms/blackpages`, then start the frontend with `npm run dev`.
4. The first admin: set `BOOTSTRAP_ADMIN_EMAILS=you@example.com`, register through the application, verify the email in Mailpit, and log in. The application grants ADMIN, and on the next login you're asked to set up OTP.

**The `local` Spring profile** sets two things:
- The session cookie is `bp_session` with `secure: false`. The `__Host-` prefix needs HTTPS, and not every browser allows it on `http://localhost`.
- The redirect URI is set explicitly to `http://localhost:3000/api/auth/oauth2/code/keycloak`, which matches `APP_BASE_URL` in `.env`.

**Issuer hostname:** the backend and the browser must use the **same issuer URL**. Locally, both use `localhost:8081` because the backend runs on the host. In the full CI stack, where everything runs in containers, set `KC_HOSTNAME=http://keycloak:8080` and run Playwright inside the same Docker network.

---

## 12. Testing
| Level | Approach |
|---|---|
| Unit | Policies, provisioning logic, `returnTo` validation, claim sync, and the reconciliation rules. Keycloak is replaced with a fake `UserProvisioningPort`. |
| Web slice and MockMvc | Spring Security's `oidcLogin()` request post-processor with synthetic claims. This is fast, and it's what the **authorization matrix** uses (ADR-0007). |
| Integration | A Testcontainers Keycloak (`testcontainers-keycloak`) importing the realm JSON. Covers the real Admin API adapter, back-channel logout, and the full code flow with PKCE using an HTTP client. |
| Realm configuration | CI imports `blackpages-realm.json` into a Keycloak container and runs a smoke test covering discovery, both clients, the password policy, and the OTP policy. `keycloak-config-cli` runs in dry-run mode against staging on every infra pull request. |
| End-to-end (Playwright) | Register → verify email through the Mailpit API → onboard → log out → log in. Staff invite → OTP setup (the TOTP code is generated in the test) → admin access. Suspending a user ends their active session. |
| Mutation testing | The `identity` module is included in the PIT targets. |

---

## 13. Items to confirm in a spike (Sprint 0)
1. `prompt=create` works on the pinned Keycloak 26.7.x. The fallback is linking to `/realms/blackpages/protocol/openid-connect/registrations`.
2. Recovery codes are supported as a second factor on the pinned version.
3. Placeholder substitution from environment variables works during realm import for secrets and URLs. The fallback is `keycloak-config-cli` in local development too.
4. The Keycloakify version is compatible with Keycloak 26.7.
5. Optional: a community password policy that checks passwords against Have I Been Pwned. The MVP relies on Keycloak's built-in password blacklist policy with a common-password list.

---

## 14. Backlog impact

| ID | Story | Pts | Team | Sprint |
|---|---|---|---|---|
| 2.16 | Keycloak added to the local stack, realm JSON, and the configuration smoke test in CI | 5 | Backend/infra | 0 |
| 2.17 | Keycloakify theme for login, registration, OTP, reset, and emails | 8 | Web | 1–2 |
| 2.1/2.2 | *(Rewritten)* Registration through Keycloak, then onboarding for shoppers and businesses | 5 | Both | 1 |
| 2.3 | *(Rewritten)* OIDC login as the backend client, with sessions, `returnTo`, and status checks | 5 | Backend | 1 |
| 2.18 | Just-in-time provisioning and claim sync (`user_identity`) | 3 | Backend | 1 |
| 2.8 | *(Rewritten)* Staff MFA: `staff` realm role, OTP required action, and the check at login | 3 | Backend | 2 |
| 2.9 | *(Rewritten)* Staff invites through the Admin API | 3 | Backend | 2 |
| 2.19 | Lifecycle sync (suspend, reinstate, delete, reset MFA) through the outbox and the nightly reconciliation job | 5 | Backend | 2 |
| 2.20 | Back-channel and RP-initiated logout | 2 | Backend | 2 |
| 2.21 | Hardened staff flow (OTP required by role) in `keycloak-config-cli` | 3 | Infra | 2 (Should) |
| 2.22 | Keycloak on ECS, the ALB host rule and `/admin` restriction, and `keycloak-config-cli` in the pipeline | 5 | Infra | 1 |
| 2.11 | *(Changed)* Password policy set in the realm | 1 | Infra | 0 |
| 2.14, 2.15 | *(Kept)* Interfaces for the identity layer, and the `user_identity` table | 5 | Backend | 1 |
| ~~2.10~~ | Session management page: **dropped**, because Keycloak's account console provides it | −3 | — | — |
| ~~E17~~ | Keycloak migration epic: **cancelled** | −30 to −40 | — | — |
