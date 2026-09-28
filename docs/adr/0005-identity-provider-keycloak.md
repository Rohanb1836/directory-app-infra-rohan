# ADR-0005: Keycloak is the identity provider from day one

- **Status:** Accepted
- **Date:** 2026-09-27
- **Supersedes:** The draft of ADR-05 from the Sprint 0 proposal, which had local authentication with Spring Security and a planned migration to Keycloak later
- **Related:** ADR-0006 (sessions), ADR-0007 (authorization), ADR-0016 (Keycloak deployment), `docs/architecture/identity-and-access.md`

## Context

BlackPages.io needs user registration, login, email verification, password reset, and MFA for staff. Social login and passkeys are expected later, as is single sign-on for future applications such as mobile or partner portals.

The team plans to standardize on Keycloak. An earlier draft built local authentication first and migrated to Keycloak afterwards. That would have meant building login, reset, and MFA ourselves, then converting password hashes and TOTP secrets, running both systems in parallel during a cutover, and finally deleting the local code. Starting on Keycloak removes that entire migration.

## Decision

1. **Keycloak (26.7 line, pinned to a patch version) is the only authentication system.** It runs as a Docker container backed by PostgreSQL, in a separate database from the application.
2. **Keycloak owns authentication:** credentials, the login and registration pages, email verification, password reset, brute-force protection, OTP, and later social login and passkeys.
3. **The application owns authorization and business identity data:** platform roles, location assignments, business account memberships, entitlements, and onboarding. Keycloak doesn't store any of these (see ADR-0007).
4. **The browser never holds Keycloak tokens.** The Spring Boot backend acts as the OIDC client for the browser (the backend-for-frontend pattern) and issues its own session cookie (see ADR-0006).
5. **One realm, `blackpages`, per environment**, with two clients:
   - `blackpages-bff` is a confidential client using the authorization code flow with PKCE. It's used for browser logins.
   - `blackpages-admin-api` is a service account restricted to `manage-users`, `view-users`, and `query-users`. The backend uses it to provision and disable users.
6. **Registration has two steps.** Keycloak creates the account (email, password, email verification). After the first login, the application runs **onboarding**: choosing shopper or business, a home location, a plan, and profile details.
7. **The application's admin UI is the system of record for user lifecycle.** Suspending, reinstating, deleting, inviting staff, and granting staff roles all happen in our admin UI, which updates Keycloak through the Admin API. The Keycloak admin console is for operations work only.
8. **Keycloak has exactly one realm role, `staff`.** It exists only so Keycloak's authentication policy can require MFA for staff. The application roles `ADMIN` and `SITE_OPERATOR` are stored in the application database.
9. **Login pages are themed with Keycloakify.** The frontend team builds them in React using the BlackPages design system, and they're packaged as a theme JAR inside the Keycloak image.
10. **Realm configuration is code.** Local development imports a realm JSON file. Staging and production are configured with `keycloak-config-cli` from the infra repo (see ADR-0016).

## Consequences

**Positive**
- There's no future migration. Password storage (Argon2 by default), brute-force protection, and OTP are maintained by the Keycloak project.
- Social login (identity brokering), passkeys (WebAuthn), and single sign-on for future applications become configuration rather than code.
- Less local authentication code to write, secure, and test to 95% coverage.

**Negative and risks**
- One more service to run, patch, and monitor, at about $29 a month on Fargate for one task (see ADR-0014).
- Keycloak's release model is "latest version only", so upgrades within the 26.x line need a regular schedule. Plan a quarterly upgrade window and apply security patches as they're released.
- Login pages are a separate theme build, and the web team needs to learn Keycloakify.
- User state exists in two systems, so we need synchronization plus a nightly reconciliation job (see the identity design document, section 9).
- Integration tests need a Keycloak Testcontainer, which makes CI slower.

## Alternatives considered

| Option | Reason rejected |
|---|---|
| Local authentication with Spring Security now, migrating to Keycloak later | Requires a migration epic (about 30–40 points), hash and TOTP conversion, and two systems running in parallel. |
| Amazon Cognito | Not the organization's chosen identity provider. Hosted pages are hard to customize, and moving users off it later is difficult. |
| Auth0 / Okta | Priced per monthly active user, which grows with every shopper. Vendor lock-in. |

## Follow-ups

- Confirm that the pinned Keycloak version supports `prompt=create` for starting registration. The fallback is a direct link to the registrations endpoint.
- Confirm that recovery codes are supported as a second-factor option in the pinned version.
- Decide whether staff MFA uses the default conditional OTP flow plus reconciliation (the MVP approach), or a custom browser flow keyed on the `staff` role (the hardened approach, Sprint 2).
