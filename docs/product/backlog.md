# BlackPages.io: Product Backlog (MVP)

| | |
|---|---|
| **Version** | 1.0 |
| **Date** | 2026-09-27 |
| **Status** | Ready for sprint planning, subject to the open questions in section 7 |
| **Companion documents** | MVP Definition v1.4 (`docs/product/mvp.md`), ADR-0001 to ADR-0016, Identity and Access Design v2.0 |
| **Repositories** | `directory-app-svc` (backend), `directory-app-ui` (frontend), `directory-app-infra` (infrastructure) |

---

## 1. How to read this backlog

- **Story IDs** use the form `<epic>.<number>`. Gaps in the numbering are stories that were removed or merged (section 6).
- **Priority** uses MoSCoW: **M** = Must, **S** = Should, **C** = Could, **TBD** = waiting on a decision.
- **Points** use the Fibonacci scale and are relative estimates of effort.
- **Team** is who does the work: `svc` (backend), `ui` (frontend), `infra`, or `All`. When two teams are listed, the first leads.
- **Depends on** lists other stories or open questions (Q-numbers from the MVP definition) that must be resolved first.

### Definition of Ready
- The story has a clear user story and testable acceptance criteria.
- Any API changes are merged into `contract/openapi.yaml` before the sprint starts (ADR-0012).
- Blocking open questions are answered, or an assumption is agreed.
- The story is estimated and fits in one sprint.

### Definition of Done
- The acceptance criteria are met, and the code is reviewed and merged to `main`.
- Coverage gates pass: backend lines 95%+ and branches 90%+ (JaCoCo); frontend 95%+ (Vitest); PIT mutation score 80%+ on critical modules.
- New endpoints have an entry in the authorization matrix (2.12).
- The feature is deployed to staging, and the end-to-end smoke tests pass.
- Accessibility (WCAG 2.1 AA) and performance budgets are met.

---

## 2. Summary by epic

| Epic | Name | Stories | Must pts | Should pts | Could/TBD pts | Total pts |
|---|---|---|---|---|---|---|
| [E0](#e0) | Foundation (Sprint 0) | 6 | 23 | 0 | 0 | 23 |
| [E1](#e1) | Multi-Location Foundation | 5 | 23 | 0 | 0 | 23 |
| [E2](#e2) | Identity and Accounts | 20 | 69 | 11 | 0 | 80 |
| [E3](#e3) | Listing Management and Rich Profiles | 10 | 38 | 0 | 0 | 38 |
| [E4](#e4) | Categories and Browsing | 7 | 23 | 0 | 0 | 23 |
| [E5](#e5) | Search and Maps | 7 | 33 | 3 | 0 | 36 |
| [E6](#e6) | SEO Tools (Basic MVP) | 11 | 30 | 3 | 0 | 33 |
| [E7](#e7) | Subscriptions and Pricing | 12 | 41 | 3 | 5 | 49 |
| [E8](#e8) | Payment Processing | 4 | 13 | 6 | 0 | 19 |
| [E9](#e9) | Reviews | 5 | 15 | 3 | 0 | 18 |
| [E10](#e10) | Secret Shopper Program | 7 | 21 | 13 | 0 | 34 |
| [E11](#e11) | Activity Tracking | 4 | 16 | 2 | 0 | 18 |
| [E12](#e12) | Data Visualizations | 4 | 13 | 8 | 0 | 21 |
| [E13](#e13) | Home Page and Public UX | 4 | 10 | 0 | 0 | 10 |
| [E14](#e14) | Administration and Site Operations | 6 | 16 | 6 | 0 | 22 |
| [E15](#e15) | Non-Functional Requirements | 5 | 17 | 0 | 0 | 17 |
| [E16](#e16) | Messaging | 8 | 22 | 6 | 0 | 28 |
| | **Total** | **125** | **423** | **64** | **5** | **492** |

## 3. Sprint plan

Sprints are two weeks long. The plan runs about **24 weeks** from Sprint 0 to launch.

| Sprint | Theme | Stories | Points | Milestone |
|---|---|---|---|---|
| **0** | Foundation | 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 2.11, 2.16, 2.22 | 34 |  |
| **1** | Locations and identity | 1.1, 1.3, 2.1, 2.3, 2.4, 2.12, 2.14, 2.15, 2.17, 2.18 | 44 |  |
| **2** | Listings, taxonomy, and entitlements | 1.2, 1.5, 2.2, 2.17, 2.20, 3.1, 3.4, 3.5, 4.1, 4.6, 4.7, 7.10, 13.2 | 45 |  |
| **3** | Rich profiles, approval, and staff security | 1.4, 2.8, 2.9, 2.19, 3.6, 3.7, 3.8, 3.10, 4.2, 4.3, 4.4, 4.5 | 43 |  |
| **4** | SEO, search, and observability | 5.1, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8a, 15.4 | 46 | **R1: internal alpha** in Arizona |
| **5** | Monetization core | 7.1, 7.3, 7.6, 8.1, 8.2, 11.1, 13.1, 13.3 | 39 |  |
| **6** | Discounts, upgrades, and maps | 3.2, 3.3, 5.3, 5.7, 7.2, 7.4, 7.5, 7.7, 7.11, 7.12, 11.3 | 44 | **R2: paid beta** with Arizona businesses |
| **7** | Service areas and messaging | 2.6, 3.9, 5.8, 5.9, 11.2, 16.1, 16.2, 16.3, 16.4, 16.6 | 42 |  |
| **8** | Reviews and secret shopper | 6.8b, 9.1, 9.2, 9.3, 9.4, 10.1, 10.3, 10.4, 10.5 | 38 |  |
| **9** | Administration and analytics | 2.5, 12.1, 12.2, 13.4, 14.1, 14.2, 14.3, 14.5, 15.5, 16.8 | 39 |  |
| **10** | Should-have items | 2.7, 2.21, 6.9, 7.8, 8.3, 8.4, 9.5, 10.2, 10.6, 10.7, 12.3, 12.4, 14.4, 14.6, 16.5, 16.7 | 56 | Can move after the MVP (saves about 2 weeks) |
| **11** | Hardening and launch | 5.2, 6.12, 11.4, 15.1, 15.2, 15.3 | 17 | **R3: public MVP launch in Arizona** |

Story 2.17 (the Keycloak theme) spans Sprints 1 and 2, so its points are split between them. Story 7.13 (sales tax) isn't scheduled until Q12 is decided.

**Capacity note:** these totals combine both teams. With each team running at roughly 20–25 points a sprint, Sprints 1–9 sit at 38–46 combined points. Sprint 10 is intentionally overloaded because it contains only Should items, which can be trimmed or moved after the MVP.

### Sequencing rationale
- **Identity and the entitlement engine come first**, because profiles, messaging, analytics, and billing all depend on them.
- **Payments come before reviews and the secret shopper program**, because both require active subscriptions.
- **Tracking starts in Sprint 5**, and consent is live before the paid beta, so real data exists by the time dashboards are built in Sprint 9.
- **Service-area search comes after the base map**, because it reuses geocoding and map components.

---

## 4. Epics and user stories

<a id="e0"></a>

### E0: Foundation (Sprint 0)

**Goal:** Put the architecture, repositories, pipelines, and environments in place so that stories can start in Sprint 1.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 0.1 | Architecture decision records | M | 3 | 0 | All |
| 0.2 | Repository scaffolding | M | 5 | 0 | All |
| 0.3 | CI pipelines with coverage gates | M | 5 | 0 | svc, ui |
| 0.4 | Staging environment | M | 5 | 0 | infra |
| 0.5 | Analytics event taxonomy | M | 2 | 0 | All |
| 0.6 | Identity spike | M | 3 | 0 | svc |

#### 0.1 Architecture decision records
As the **delivery team**, I want the architecture decisions recorded and agreed so that both teams build on the same foundation.

**Acceptance criteria**
- ADR-0001 to ADR-0016 are merged in `directory-app-infra/docs/adr/`.
- The tech lead and product owner have reviewed and accepted each ADR marked Accepted.
- ADRs marked Proposed have a named owner and a decision date.

*Priority:* M · *Points:* 3 · *Sprint:* 0 · *Team:* All

#### 0.2 Repository scaffolding
As a **developer**, I want the three repositories scaffolded so that I can start on stories on day one.

**Acceptance criteria**
- `directory-app-svc` has the Spring Boot modular-monolith skeleton, `contract/openapi.yaml`, and Flyway migration V001.
- `directory-app-ui` has the Next.js app with the `(public)`, `(member)`, and `(admin)` route groups and the generated API client.
- `directory-app-infra` has the local docker-compose stack, Terraform layout, and Keycloak image build.
- Each repository's README explains how to run it locally in under 15 minutes.

*Priority:* M · *Points:* 5 · *Sprint:* 0 · *Team:* All

#### 0.3 CI pipelines with coverage gates
As the **delivery team**, I want every pull request checked automatically so that quality doesn't depend on manual review.

**Acceptance criteria**
- Backend CI enforces JaCoCo line coverage of 95% or more and branch coverage of 90% or more, and PIT mutation score of 80% or more on critical modules.
- Frontend CI enforces Vitest coverage of 95% or more on lines, statements, and functions, and 90% or more on branches.
- Both pipelines run CodeQL, dependency scanning, and the contract checks from ADR-0012.
- Branch protection on `main` requires all checks to pass.

*Priority:* M · *Points:* 5 · *Sprint:* 0 · *Team:* svc, ui

#### 0.4 Staging environment
As the **delivery team**, I want a staging environment deployed automatically so that finished work can be demonstrated and tested.

**Acceptance criteria**
- Terraform provisions staging (ECS, RDS with `blackpages` and `keycloak` databases, ALB, S3/CloudFront).
- Merges to `main` deploy to staging automatically.
- Staging runs only during business hours, per ADR-0014.

*Priority:* M · *Points:* 5 · *Sprint:* 0 · *Team:* infra

#### 0.5 Analytics event taxonomy
As the **product owner**, I want the analytics events defined up front so that tracking is consistent across features.

**Acceptance criteria**
- `docs/architecture/event-taxonomy.md` lists every event name, its properties, and the story that emits it.
- The taxonomy covers searches, page views, listing views, category views, map interactions, click-to-call, website clicks, and messages.

*Priority:* M · *Points:* 2 · *Sprint:* 0 · *Team:* All

#### 0.6 Identity spike
As the **tech lead**, I want the Keycloak details confirmed early so that identity stories aren't blocked in Sprint 1.

**Acceptance criteria**
- Confirmed on Keycloak 26.7.x: `prompt=create`, recovery codes, and environment-variable substitution during realm import.
- Keycloakify compatibility with the pinned Keycloak version is confirmed.
- Findings are recorded in section 13 of the identity design document.

*Priority:* M · *Points:* 3 · *Sprint:* 0 · *Team:* svc

---

<a id="e1"></a>

### E1: Multi-Location Foundation

**Goal:** Scope all directory data and features to as many as 50 locations, starting with Arizona.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 1.1 | Create and manage locations | M | 5 | 1 | svc, ui |
| 1.2 | Manage cities | M | 3 | 2 | svc, ui |
| 1.3 | Scope data by location | M | 8 | 1 | svc |
| 1.4 | Location selector | M | 5 | 3 | ui, svc |
| 1.5 | Arizona launch data | M | 2 | 2 | svc |

#### 1.1 Create and manage locations
As an **admin**, I want to create and manage locations so that I can launch a directory in a new state.

**Acceptance criteria**
- A location has a name, slug, state code, **IANA time zone**, and status (draft, active, inactive).
- Activating a 51st location is blocked with a clear message.
- Slugs are unique.

*Priority:* M · *Points:* 5 · *Sprint:* 1 · *Team:* svc, ui

#### 1.2 Manage cities
As an **admin or site operator**, I want to manage the cities in a location so that city-level directory pages exist.

**Acceptance criteria**
- Cities can be added, edited, and deactivated within a location.
- City slugs are unique across all locations (for example, `springfield-mo`).
- A city inherits its location's time zone and can override it (for example, `America/Denver` for Navajo Nation communities).

*Priority:* M · *Points:* 3 · *Sprint:* 2 · *Team:* svc, ui

#### 1.3 Scope data by location
As a **developer**, I want every listing, review, subscription, and event tied to a location so that data never leaks between locations.

**Acceptance criteria**
- Every location-scoped table has `location_id NOT NULL`.
- Queries are filtered through `LocationContext` and a Hibernate filter (ADR-0008).
- An ArchUnit rule fails the build if a location-scoped repository can be called without a `LocationContext`.
- Automated tests prove data isolation between two locations.

*Priority:* M · *Points:* 8 · *Sprint:* 1 · *Team:* svc

#### 1.4 Location selector
As a **visitor**, I want to choose my location, or have it suggested, so that I see relevant businesses.

**Acceptance criteria**
- A location selector is available on every public page.
- A default is suggested from the visitor's IP address.
- The choice is remembered in a cookie and reflected in the page context.

*Priority:* M · *Points:* 5 · *Sprint:* 3 · *Team:* ui, svc

#### 1.5 Arizona launch data
As the **product owner**, I want Arizona set up as the first active location so that the launch directory is ready.

**Acceptance criteria**
- A Flyway data migration creates location **Arizona (AZ)** with time zone `America/Phoenix`.
- The confirmed launch cities are seeded (proposed: Phoenix, Tucson, Mesa, Chandler, Scottsdale, Gilbert, Glendale, Tempe, Peoria, Flagstaff).
- The other location slots remain in draft.

*Priority:* M · *Points:* 2 · *Sprint:* 2 · *Team:* svc · *Depends on:* Q15

---

<a id="e2"></a>

### E2: Identity and Accounts

**Goal:** Registration, login, onboarding, staff security, and user lifecycle, using Keycloak for authentication.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 2.1 | Account registration through Keycloak | M | 3 | 1 | svc, ui |
| 2.2 | Onboarding for shoppers and businesses | M | 5 | 2 | svc, ui |
| 2.3 | Login through the backend (OIDC) | M | 5 | 1 | svc |
| 2.4 | Role-based access control | M | 8 | 1 | svc |
| 2.5 | Profile updates and account deletion | S | 3 | 9 | svc, ui |
| 2.6 | Member dashboard home | M | 5 | 7 | ui, svc |
| 2.7 | Business team invites | S | 5 | 10 | svc, ui |
| 2.8 | MFA required for staff | M | 3 | 3 | svc |
| 2.9 | Staff invites | M | 3 | 3 | svc, ui |
| 2.11 | Password policy | M | 1 | 0 | infra |
| 2.12 | Authorization matrix test | M | 3 | 1 | svc |
| 2.14 | Identity layer interfaces | M | 3 | 1 | svc |
| 2.15 | User identity table | M | 2 | 1 | svc |
| 2.16 | Keycloak in the local stack and CI | M | 5 | 0 | infra, svc |
| 2.17 | Keycloak login theme | M | 8 | 1–2 | ui |
| 2.18 | Just-in-time provisioning | M | 3 | 1 | svc |
| 2.19 | User lifecycle sync and reconciliation | M | 5 | 3 | svc |
| 2.20 | Logout | M | 2 | 2 | svc |
| 2.21 | Hardened staff authentication flow | S | 3 | 10 | infra |
| 2.22 | Keycloak in AWS | M | 5 | 0 | infra |

#### 2.1 Account registration through Keycloak
As a **visitor**, I want to create an account so that I can join BlackPages as a shopper or business.

**Acceptance criteria**
- "Sign up" goes to `/api/auth/register`, which opens Keycloak's registration page (`prompt=create`).
- The visitor registers with an email address and a password that meets the realm's policy.
- Keycloak sends a verification email, and the account can't complete onboarding until the email is verified.

*Priority:* M · *Points:* 3 · *Sprint:* 1 · *Team:* svc, ui · *Depends on:* 0.6, 2.16

#### 2.2 Onboarding for shoppers and businesses
As a **new user**, I want to set up my shopper or business profile after registering so that I can start using BlackPages.

**Acceptance criteria**
- After first login, a user with `onboarding_status = PENDING` is sent to `/onboarding`.
- The user chooses shopper or business, a home location, and a plan.
- Businesses enter account details, and an OWNER membership is created.
- Completing onboarding grants the SHOPPER or BUSINESS role and hands off to billing (7.3).

*Priority:* M · *Points:* 5 · *Sprint:* 2 · *Team:* svc, ui

#### 2.3 Login through the backend (OIDC)
As a **registered user**, I want to log in securely so that I can access my account.

**Acceptance criteria**
- Login uses the authorization code flow with PKCE through `blackpages-bff`. No tokens reach the browser.
- The session cookie is `__Host-bp_session` (HttpOnly, Secure, SameSite=Lax).
- `returnTo` accepts only relative paths.
- Users who aren't ACTIVE can't log in.
- A new session ID is issued at login, and session lifetime is set by role (ADR-0006).

*Priority:* M · *Points:* 5 · *Sprint:* 1 · *Team:* svc · *Depends on:* 2.16

#### 2.4 Role-based access control
As the **platform**, I want roles and permissions enforced so that each user can do only what their role allows.

**Acceptance criteria**
- Roles are SHOPPER, BUSINESS, SITE_OPERATOR, and ADMIN, stored in the application database.
- Named permissions are enforced by the API with `@PreAuthorize`, not only hidden in the UI.
- Resources outside a user's scope return 404 (ADR-0007).

*Priority:* M · *Points:* 8 · *Sprint:* 1 · *Team:* svc

#### 2.5 Profile updates and account deletion
As a **user**, I want to update my profile or delete my account so that I control my data.

**Acceptance criteria**
- Profile fields managed by the application can be edited. Email and password link to Keycloak's account console.
- Deletion requires re-authentication within the last 5 minutes.
- Deletion cancels subscriptions, anonymizes reviews, deletes the Keycloak user, and ends all sessions.

*Priority:* S · *Points:* 3 · *Sprint:* 9 · *Team:* svc, ui

#### 2.6 Member dashboard home
As a **member**, I want a dashboard home so that I can manage everything in one place.

**Acceptance criteria**
- Widgets show listings and their status, the plan and any active discount, billing, unread messages, recent reviews, and an analytics summary.

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* ui, svc

#### 2.7 Business team invites
As a **business owner**, I want to invite staff with roles so that others can help manage my listing.

**Acceptance criteria**
- Roles are Owner (full access, including billing) and Editor (listings and messages only).
- Invites are sent by email with a single-use link and handled by the application (identity design, section 5.6).

*Priority:* S · *Points:* 5 · *Sprint:* 10 · *Team:* svc, ui · *Depends on:* Q7

#### 2.8 MFA required for staff
As the **platform**, I want staff to use MFA so that admin access is protected.

**Acceptance criteria**
- Granting ADMIN or SITE_OPERATOR adds the `staff` realm role and the `CONFIGURE_TOTP` required action.
- At each staff login, the backend confirms an OTP credential exists, and without one the session gets no staff permissions.
- Admins can reset another staff member's OTP from the admin UI.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* svc

#### 2.9 Staff invites
As an **admin**, I want to invite staff so that only people I approve get staff access.

**Acceptance criteria**
- The invite specifies email, role, and locations for operators.
- The user is created through the Keycloak Admin API with `VERIFY_EMAIL`, `UPDATE_PASSWORD`, and `CONFIGURE_TOTP`, and the invite link expires after 72 hours.
- Staff can't self-register.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* svc, ui

#### 2.11 Password policy
As the **platform**, I want a strong password policy so that accounts are hard to compromise.

**Acceptance criteria**
- The realm policy is `length(12) and maxLength(128) and notEmail and notUsername and passwordHistory(3)`.
- Brute-force protection is on, with a temporary lockout of up to 15 minutes.

*Priority:* M · *Points:* 1 · *Sprint:* 0 · *Team:* infra

#### 2.12 Authorization matrix test
As the **delivery team**, I want every endpoint tested for every role so that no endpoint ships with undefined permissions.

**Acceptance criteria**
- A parameterized test runs every OpenAPI operation as each persona and compares the result with `authz-matrix.yaml`.
- An operation missing from the matrix fails the build.

*Priority:* M · *Points:* 3 · *Sprint:* 1 · *Team:* svc

#### 2.14 Identity layer interfaces
As a **developer**, I want identity accessed through our own interfaces so that modules never depend on Spring Security or Keycloak types.

**Acceptance criteria**
- `CurrentUser`, `CurrentUserProvider`, and `UserProvisioningPort` exist in `identity.api`.
- An ArchUnit rule blocks other modules from importing OAuth2 or Keycloak classes.

*Priority:* M · *Points:* 3 · *Sprint:* 1 · *Team:* svc

#### 2.15 User identity table
As a **developer**, I want a separate table linking users to Keycloak so that emails are never used as keys.

**Acceptance criteria**
- `user_identity` stores user_id, provider, and subject, with provider and subject unique together.
- Every reference to a user uses `app_user.id`.

*Priority:* M · *Points:* 2 · *Sprint:* 1 · *Team:* svc

#### 2.16 Keycloak in the local stack and CI
As a **developer**, I want Keycloak running locally and in CI so that identity features can be built and tested.

**Acceptance criteria**
- `docker compose up` starts Postgres with PostGIS, Keycloak, Mailpit, and stripe-mock.
- `blackpages-realm.json` is imported at startup.
- A CI smoke test checks discovery, both clients, and the password and OTP policies.

*Priority:* M · *Points:* 5 · *Sprint:* 0 · *Team:* infra, svc

#### 2.17 Keycloak login theme
As a **user**, I want the login and registration pages to look like BlackPages so that the experience feels seamless.

**Acceptance criteria**
- A Keycloakify theme covers login, registration, OTP setup and entry, password reset, required actions, and email templates.
- It uses the BlackPages design system and meets WCAG 2.1 AA.
- CI publishes a versioned JAR, which the infra repo pins.

*Priority:* M · *Points:* 8 · *Sprint:* 1–2 · *Team:* ui

#### 2.18 Just-in-time provisioning
As the **platform**, I want an application user created at first login so that Keycloak accounts and application data stay linked.

**Acceptance criteria**
- The first login creates `app_user` (onboarding PENDING) and `user_identity`, and publishes `UserRegistered`.
- Email and email-verified status are copied from Keycloak claims at every login.

*Priority:* M · *Points:* 3 · *Sprint:* 1 · *Team:* svc

#### 2.19 User lifecycle sync and reconciliation
As an **admin**, I want suspensions and deletions applied in both the application and Keycloak so that access is removed everywhere.

**Acceptance criteria**
- Suspend, reinstate, delete, and MFA reset are pushed to Keycloak through the outbox.
- A nightly reconciliation job fixes drift, including staff without OTP and mismatched `staff` roles, and raises alerts.

*Priority:* M · *Points:* 5 · *Sprint:* 3 · *Team:* svc

#### 2.20 Logout
As a **user**, I want logging out to end my session everywhere so that my account is secure on shared devices.

**Acceptance criteria**
- `POST /api/auth/logout` ends the application session and the Keycloak session (RP-initiated logout).
- Back-channel logout from Keycloak ends the matching application sessions.

*Priority:* M · *Points:* 2 · *Sprint:* 2 · *Team:* svc

#### 2.21 Hardened staff authentication flow
As the **platform**, I want OTP required for staff by role so that staff can't remove their second factor.

**Acceptance criteria**
- A custom browser flow in `keycloak-config-cli` requires OTP for users with the `staff` role.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* infra · *Depends on:* Q14

#### 2.22 Keycloak in AWS
As the **delivery team**, I want Keycloak deployed in staging and production so that authentication works in every environment.

**Acceptance criteria**
- Keycloak runs on ECS at `auth.blackpages.io` through the shared ALB.
- `/admin/*` is restricted to allowed IP ranges.
- `keycloak-config-cli` applies the realm configuration in the deploy pipeline.

*Priority:* M · *Points:* 5 · *Sprint:* 0 · *Team:* infra

---

<a id="e3"></a>

### E3: Listing Management and Rich Profiles

**Goal:** Let businesses create, maintain, and showcase listings, with fields that depend on their plan.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 3.1 | Create a listing | M | 5 | 2 | svc, ui |
| 3.2 | Website and social links for Platinum | M | 3 | 6 | svc, ui |
| 3.3 | Branch locations | M | 5 | 6 | svc, ui |
| 3.4 | Address entry and geocoding | M | 3 | 2 | svc, ui |
| 3.5 | Edit, pause, and reactivate a listing | M | 3 | 2 | svc, ui |
| 3.6 | Listing approval workflow | M | 3 | 3 | svc, ui |
| 3.7 | Logo and cover image | M | 3 | 3 | svc, ui |
| 3.8 | Description, hours, and details | M | 3 | 3 | svc, ui |
| 3.9 | Photo gallery | M | 5 | 7 | svc, ui |
| 3.10 | Rich profile page | M | 5 | 3 | ui, svc |

#### 3.1 Create a listing
As a **business**, I want to create a listing with my name, phone, category, and subcategory so that customers can find me.

**Acceptance criteria**
- Required fields are validated, and the address is optional.
- The listing is created in the chosen location and city.
- A unique slug is generated (6.1).

*Priority:* M · *Points:* 5 · *Sprint:* 2 · *Team:* svc, ui

#### 3.2 Website and social links for Platinum
As a **Platinum business**, I want to show my website and social links so that customers can reach me online.

**Acceptance criteria**
- The fields can be edited only on Platinum, and URLs are validated.
- Links are hidden if the business moves to a lower plan.

*Priority:* M · *Points:* 3 · *Sprint:* 6 · *Team:* svc, ui

#### 3.3 Branch locations
As a **business**, I want to add branch locations under one account so that all my locations are listed.

**Acceptance criteria**
- Each branch is its own listing with its own slug.
- Each branch adds an add-on charge to the consolidated invoice (7.5).

*Priority:* M · *Points:* 5 · *Sprint:* 6 · *Team:* svc, ui

#### 3.4 Address entry and geocoding
As a **business**, I want my address validated and placed on the map so that customers can find me.

**Acceptance criteria**
- Address entry uses Google Places Autocomplete.
- Latitude, longitude, and place ID are stored.
- Listings without an address are left off the map but still appear in the directory.

*Priority:* M · *Points:* 3 · *Sprint:* 2 · *Team:* svc, ui

#### 3.5 Edit, pause, and reactivate a listing
As a **business**, I want to keep my listing up to date so that it stays accurate.

**Acceptance criteria**
- Paused listings are hidden from the public.
- Fields the plan doesn't allow are locked in the form.

*Priority:* M · *Points:* 3 · *Sprint:* 2 · *Team:* svc, ui

#### 3.6 Listing approval workflow
As a **site operator**, I want new and edited listings approved before they publish so that the directory stays free of spam.

**Acceptance criteria**
- The status flow is Draft, Pending, then Published or Rejected.
- The business is notified by email, with a reason if rejected.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* svc, ui

#### 3.7 Logo and cover image
As a **business**, I want to upload a logo and cover image so that my profile looks professional.

**Acceptance criteria**
- JPG, PNG, and WebP up to 5 MB are accepted.
- Images are cropped and resized automatically and served from the CDN.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* svc, ui

#### 3.8 Description, hours, and details
As a **business**, I want to add a description, hours, year established, and payment methods so that customers know what to expect.

**Acceptance criteria**
- Hours support several ranges per day and holiday closures.
- Hours are interpreted in the listing's city time zone.
- The description length limit is set by the plan.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* svc, ui

#### 3.9 Photo gallery
As a **business**, I want a photo gallery so that I can show my work.

**Acceptance criteria**
- The limit is set by the plan (indicative: Silver 3, Gold 10, Platinum 25).
- Photos can be reordered, and each has alt text.

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* svc, ui · *Depends on:* Q6

#### 3.10 Rich profile page
As a **visitor**, I want a complete profile page so that I can decide whether to contact a business.

**Acceptance criteria**
- Sections: header (logo, cover, tier badge, rating), about, specialties, hours with an open or closed status, gallery, service area map, reviews (if unlocked), and a Contact button.
- Replaces the scope of the original 5.4.

*Priority:* M · *Points:* 5 · *Sprint:* 3 · *Team:* ui, svc

---

<a id="e4"></a>

### E4: Categories and Browsing

**Goal:** A three-level taxonomy, alphabetical listings, and ordering by tier.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 4.1 | Category taxonomy | M | 5 | 2 | svc, ui |
| 4.2 | Category page ordering | M | 5 | 3 | svc, ui |
| 4.3 | Filter by city and subcategory | M | 3 | 3 | ui, svc |
| 4.4 | Directory index | M | 3 | 3 | ui, svc |
| 4.5 | Pagination | M | 2 | 3 | ui, svc |
| 4.6 | Specialties | M | 3 | 2 | svc, ui |
| 4.7 | Tag a listing with specialties | M | 2 | 2 | svc, ui |

#### 4.1 Category taxonomy
As an **admin**, I want to manage categories and subcategories so that listings are organized consistently.

**Acceptance criteria**
- Categories and subcategories can be created, edited, merged, and deactivated.
- The taxonomy is shared by all locations.

*Priority:* M · *Points:* 5 · *Sprint:* 2 · *Team:* svc, ui

#### 4.2 Category page ordering
As a **visitor**, I want listings ordered by tier and then alphabetically so that the page is easy to scan.

**Acceptance criteria**
- The order is **Platinum (A–Z), then Gold (A–Z), then Silver (A–Z)**.
- Tiers are marked visually.

*Priority:* M · *Points:* 5 · *Sprint:* 3 · *Team:* svc, ui

#### 4.3 Filter by city and subcategory
As a **visitor**, I want to filter a category by city and subcategory so that I can narrow the results.

**Acceptance criteria**
- Filters update the URL, and a city filter leads to the static URL from 6.2.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* ui, svc

#### 4.4 Directory index
As a **visitor**, I want an index of all categories so that I can browse.

**Acceptance criteria**
- Categories are listed alphabetically with a count of active listings.
- Empty categories are hidden.

*Priority:* M · *Points:* 3 · *Sprint:* 3 · *Team:* ui, svc

#### 4.5 Pagination
As a **visitor**, I want results split into pages so that pages load quickly.

**Acceptance criteria**
- Each page shows 25 results, with crawlable page links.

*Priority:* M · *Points:* 2 · *Sprint:* 3 · *Team:* ui, svc

#### 4.6 Specialties
As an **admin**, I want specialties under each subcategory so that the taxonomy has three levels.

**Acceptance criteria**
- Specialties can be created, edited, merged, and deactivated.
- Specialties have synonyms for search.

*Priority:* M · *Points:* 3 · *Sprint:* 2 · *Team:* svc, ui

#### 4.7 Tag a listing with specialties
As a **business**, I want to tag my listing with specialties so that I appear in more specific searches.

**Acceptance criteria**
- The number allowed is set by the plan (to be confirmed: Silver 3, Gold 5, Platinum 10).
- Specialties appear on the profile and can be filtered on.

*Priority:* M · *Points:* 2 · *Sprint:* 2 · *Team:* svc, ui · *Depends on:* Q6

---

<a id="e5"></a>

### E5: Search and Maps

**Goal:** Keyword, category, and location search with filters, Google Maps, and service areas.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 5.1 | Search | M | 8 | 4 | svc, ui |
| 5.2 | Search autocomplete | S | 3 | 11 | ui, svc |
| 5.3 | Map view | M | 5 | 6 | ui, svc |
| 5.5 | Search filters | M | 8 | 4 | svc, ui |
| 5.7 | Service area | M | 5 | 6 | svc, ui |
| 5.8 | Search by service area | M | 5 | 7 | svc, ui |
| 5.9 | Google Maps cost controls | M | 2 | 7 | ui, infra |

#### 5.1 Search
As a **visitor**, I want to search by keyword, category, and location so that I find the right business.

**Acceptance criteria**
- A query such as "tankless plumber Phoenix" is parsed into a keyword, a category or specialty, and a city.
- Search tolerates typos and is scoped to the current location.
- Results keep the tier ordering.
- An empty search shows suggestions.

*Priority:* M · *Points:* 8 · *Sprint:* 4 · *Team:* svc, ui

#### 5.2 Search autocomplete
As a **visitor**, I want suggestions as I type so that I can search faster.

**Acceptance criteria**
- Suggestions appear after 2 characters and respond in under 300 ms.

*Priority:* S · *Points:* 3 · *Sprint:* 11 · *Team:* ui, svc

#### 5.3 Map view
As a **visitor**, I want to see listings on a map so that I can find businesses near me.

**Acceptance criteria**
- Users can switch between the list and a Google Maps view.
- Pins are clustered and styled by tier, with an info window for each.
- A "search this area" button re-queries when the map moves.

*Priority:* M · *Points:* 5 · *Sprint:* 6 · *Team:* ui, svc

#### 5.5 Search filters
As a **visitor**, I want filters so that I can narrow results.

**Acceptance criteria**
- Filters: subcategory, specialty, city, radius, minimum rating (only listings with unlocked reviews), open now (in the listing's time zone), and serves my area.
- Filters appear in the URL, and tier ordering still applies.

*Priority:* M · *Points:* 8 · *Sprint:* 4 · *Team:* svc, ui

#### 5.7 Service area
As a **business**, I want to define where I work so that customers know whether I serve them.

**Acceptance criteria**
- The service area is a list of cities or a radius around the base address.
- It's drawn on the profile map.
- The street address can be hidden.

*Priority:* M · *Points:* 5 · *Sprint:* 6 · *Team:* svc, ui · *Depends on:* Q5

#### 5.8 Search by service area
As a **visitor**, I want to find businesses that serve my city even if they're based elsewhere.

**Acceptance criteria**
- Search matches on service areas as well as addresses.
- Matching results are labeled, for example "Serves Phoenix".

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* svc, ui

#### 5.9 Google Maps cost controls
As the **platform**, I want Maps costs controlled so that the bill stays predictable.

**Acceptance criteria**
- API keys are restricted, and maps load only when needed.
- List pages use static map images.
- Usage alerts are configured.

*Priority:* M · *Points:* 2 · *Sprint:* 7 · *Team:* ui, infra

---

<a id="e6"></a>

### E6: SEO Tools (Basic MVP)

**Goal:** Crawlable static and dynamic pages, metadata, schema, and sitemaps.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 6.1 | Listing URLs | M | 3 | 4 | svc, ui |
| 6.2 | Server-rendered category and city pages | M | 3 | 4 | ui |
| 6.3 | Metadata templates | M | 5 | 4 | svc, ui |
| 6.4 | Sitemaps and robots.txt | M | 3 | 4 | svc |
| 6.5 | Redirects when slugs change | M | 2 | 4 | svc |
| 6.6 | Dynamic specialty pages | M | 5 | 4 | ui, svc |
| 6.7 | Keep thin pages out of the index | M | 3 | 4 | svc, ui |
| 6.8a | Core schema markup | M | 3 | 4 | ui |
| 6.8b | Schema for reviews, service area, and plan | M | 2 | 8 | ui |
| 6.9 | Metadata overrides | S | 3 | 10 | svc, ui |
| 6.12 | Search Console setup | M | 1 | 11 | infra |

#### 6.1 Listing URLs
As a **business**, I want a permanent URL like `/member/acme-plumbing` so that my page can rank in search engines.

**Acceptance criteria**
- Slugs are generated automatically.
- Collisions get a city suffix, for example `acme-plumbing-phoenix`.

*Priority:* M · *Points:* 3 · *Sprint:* 4 · *Team:* svc, ui

#### 6.2 Server-rendered category and city pages
As the **marketing team**, I want category and city pages rendered on the server so that crawlers can index them.

**Acceptance criteria**
- `/directory/{category}` and `/directory/{category}/{city}` are rendered on the server and regenerated when listings change.
- Invalid combinations return 404.
- LCP under 2.5 s and CLS under 0.1.

*Priority:* M · *Points:* 3 · *Sprint:* 4 · *Team:* ui

#### 6.3 Metadata templates
As an **admin**, I want metadata templates for each page type so that every page has unique metadata.

**Acceptance criteria**
- Templates exist for home, category, category and city, specialty and city, and profile pages, using variables such as `{category}`, `{city}`, and `{count}`.
- Every page has a canonical tag and Open Graph and Twitter tags.

*Priority:* M · *Points:* 5 · *Sprint:* 4 · *Team:* svc, ui

#### 6.4 Sitemaps and robots.txt
As the **marketing team**, I want sitemaps generated automatically so that search engines find every page.

**Acceptance criteria**
- There's an XML sitemap for each location, regenerated when listings or categories change.
- robots.txt is served.

*Priority:* M · *Points:* 3 · *Sprint:* 4 · *Team:* svc

#### 6.5 Redirects when slugs change
As a **business**, I want old URLs to redirect when my name changes so that I keep my search ranking.

**Acceptance criteria**
- The old slug returns a 301 redirect to the new one, and redirect history is stored.

*Priority:* M · *Points:* 2 · *Sprint:* 4 · *Team:* svc

#### 6.6 Dynamic specialty pages
As the **marketing team**, I want pages for each specialty in each city so that we rank for specific searches.

**Acceptance criteria**
- Pages are generated from the taxonomy and active cities.
- Each shows a heading, the listing count, related specialties, and listings in tier order.

*Priority:* M · *Points:* 5 · *Sprint:* 4 · *Team:* ui, svc · *Depends on:* Q8

#### 6.7 Keep thin pages out of the index
As the **platform**, I want pages with very few listings kept out of search indexes so that the site isn't penalized.

**Acceptance criteria**
- Pages with fewer than 3 listings are marked `noindex` and left out of the sitemap.
- The status updates automatically as listings change.

*Priority:* M · *Points:* 3 · *Sprint:* 4 · *Team:* svc, ui · *Depends on:* Q9

#### 6.8a Core schema markup
As the **marketing team**, I want structured data on our pages so that they're eligible for rich results.

**Acceptance criteria**
- LocalBusiness on profiles, BreadcrumbList on directory pages, ItemList on category pages, and WebSite with a search action on the home page.
- Output passes Google's Rich Results Test.

*Priority:* M · *Points:* 3 · *Sprint:* 4 · *Team:* ui

#### 6.8b Schema for reviews, service area, and plan
As the **marketing team**, I want the structured data to reflect each listing's details so that it stays accurate.

**Acceptance criteria**
- AggregateRating appears only once reviews are unlocked, and `areaServed` comes from the service area.
- `sameAs` links appear only for Platinum, and the address is omitted when the business hides it.

*Priority:* M · *Points:* 2 · *Sprint:* 8 · *Team:* ui

#### 6.9 Metadata overrides
As an **admin**, I want to override metadata on specific pages so that I can optimize important pages.

**Acceptance criteria**
- Title, description, and index setting can be overridden for any page, and changes are audited.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc, ui

#### 6.12 Search Console setup
As the **marketing team**, I want Search Console set up so that we can monitor indexing.

**Acceptance criteria**
- The domain is verified, and sitemaps are submitted for each location.

*Priority:* M · *Points:* 1 · *Sprint:* 11 · *Team:* infra

---

<a id="e7"></a>

### E7: Subscriptions and Pricing

**Goal:** Silver, Gold, and Platinum plans, discounts up to 100% on plan prices, the $1 service fee, and upgrades.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 7.1 | Configure plans | M | 5 | 5 | svc, ui |
| 7.2 | Discount engine | M | 5 | 6 | svc, ui |
| 7.3 | Choose a plan and pay at signup | M | 5 | 5 | svc, ui |
| 7.4 | Upgrade and downgrade | M | 5 | 6 | svc, ui |
| 7.5 | Consolidated billing for branches | M | 5 | 6 | svc |
| 7.6 | $1 monthly service fee | M | 3 | 5 | svc |
| 7.7 | Lapsed subscriptions | M | 3 | 6 | svc |
| 7.8 | Billing history and invoices | S | 3 | 10 | ui, svc |
| 7.10 | Entitlement engine | M | 5 | 2 | svc |
| 7.11 | Plans discounted to $0 | M | 3 | 6 | svc |
| 7.12 | Promotions at checkout and on the pricing page | M | 2 | 6 | ui |
| 7.13 | Sales tax on subscriptions | TBD | 5 | TBD | svc |

#### 7.1 Configure plans
As an **admin**, I want to configure plans so that pricing can change without code changes.

**Acceptance criteria**
- Plans are **Silver, Gold, Platinum**, and the shopper plan. There's no free plan.
- Each plan has a price, billing interval, entitlements, and status.

*Priority:* M · *Points:* 5 · *Sprint:* 5 · *Team:* svc, ui

#### 7.2 Discount engine
As an **admin**, I want to create discounts so that I can run promotions such as an Arizona launch offer.

**Acceptance criteria**
- A discount is a percentage **up to 100%** or a fixed amount that never reduces a charge below $0.
- Duration is once, a set number of months, or forever, with an optional expiry date for redemption.
- A discount covers the plan price and optionally add-on locations. **It never applies to the $1 service fee.**
- Discounts can be codes or automatic campaigns, limited by date window, location, plan, number of redemptions, and new customers only.
- Only one discount applies per subscription.

*Priority:* M · *Points:* 5 · *Sprint:* 6 · *Team:* svc, ui

#### 7.3 Choose a plan and pay at signup
As a **business**, I want to choose a plan and pay when I sign up so that my listing can go live.

**Acceptance criteria**
- Plan selection leads to payment (8.1), then listing activation.
- The total shown includes the $1 service fee and any discount.
- **A card is always required**, because the service fee is always charged.

*Priority:* M · *Points:* 5 · *Sprint:* 5 · *Team:* svc, ui

#### 7.4 Upgrade and downgrade
As a **business**, I want to change my plan so that I get the visibility I want.

**Acceptance criteria**
- Price differences are prorated.
- Upgrades apply immediately, and downgrades at the end of the billing period.
- A discount carries over only if it covers the new plan.

*Priority:* M · *Points:* 5 · *Sprint:* 6 · *Team:* svc, ui

#### 7.5 Consolidated billing for branches
As a **business**, I want charges for all my branches on one account so that billing is simple.

**Acceptance criteria**
- There's one Stripe customer and one invoice, with a line item per listing and one for the service fee.

*Priority:* M · *Points:* 5 · *Sprint:* 6 · *Team:* svc

#### 7.6 $1 monthly service fee
As the **platform**, I want the $1 monthly service fee charged to every business and shopper so that it's collected consistently.

**Acceptance criteria**
- The fee is a recurring item on every invoice.
- **Discounts can never apply to it**, so every member pays at least $1 a month.

*Priority:* M · *Points:* 3 · *Sprint:* 5 · *Team:* svc · *Depends on:* Q1

#### 7.7 Lapsed subscriptions
As the **platform**, I want unpaid subscriptions handled automatically so that unpaid listings don't stay live.

**Acceptance criteria**
- There's a 7-day grace period, after which the listing is hidden and the member is emailed.

*Priority:* M · *Points:* 3 · *Sprint:* 6 · *Team:* svc

#### 7.8 Billing history and invoices
As a **member**, I want to see my billing history so that I can track my costs.

**Acceptance criteria**
- Invoices are listed and can be downloaded as PDFs.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* ui, svc

#### 7.10 Entitlement engine
As the **platform**, I want one engine for plan features and limits so that every feature follows the plan configuration.

**Acceptance criteria**
- The API enforces gallery size, specialty count, placement, links, messaging, analytics level, and branch count.
- Downgrades apply at the end of the billing period.

*Priority:* M · *Points:* 5 · *Sprint:* 2 · *Team:* svc

#### 7.11 Plans discounted to $0
As a **member on a discounted plan**, I want to know what I'll pay and when so that there are no surprises.

**Acceptance criteria**
- A subscription whose plan is discounted to $0 is an ordinary active subscription with all the plan's entitlements, and its invoice is $1 for the service fee.
- It counts as active for reviews and secret shopper eligibility.
- Members are emailed 7 days before the full plan price is first charged, showing the new total.

*Priority:* M · *Points:* 3 · *Sprint:* 6 · *Team:* svc

#### 7.12 Promotions at checkout and on the pricing page
As a **visitor**, I want to see promotions clearly so that I understand what I'll pay.

**Acceptance criteria**
- A plan discounted to $0 shows as "Free" with the service fee and later price, for example "Silver free for 3 months: you pay only the $1/month service fee, then $X/month".

*Priority:* M · *Points:* 2 · *Sprint:* 6 · *Team:* ui

#### 7.13 Sales tax on subscriptions
As the **platform**, I want tax applied where required so that we comply with state and city tax rules.

**Acceptance criteria**
- Pending a tax adviser's review of Arizona's transaction privilege tax (TPT).
- If tax applies, it's calculated at checkout (for example with Stripe Tax) and shown on invoices.

*Priority:* TBD · *Points:* 5 · *Sprint:* TBD · *Team:* svc · *Depends on:* Q12

---

<a id="e8"></a>

### E8: Payment Processing

**Goal:** Stripe integration and the payment lifecycle.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 8.1 | Card payments | M | 8 | 5 | svc, ui |
| 8.2 | Payment webhooks | M | 5 | 5 | svc |
| 8.3 | Dunning | S | 3 | 10 | svc |
| 8.4 | Refunds | S | 3 | 10 | svc, ui |

#### 8.1 Card payments
As a **member**, I want to pay securely by card so that my card details are protected.

**Acceptance criteria**
- Stripe Checkout or Elements is used, and no card data touches our systems (PCI SAQ-A).
- Members can update their card themselves.

*Priority:* M · *Points:* 8 · *Sprint:* 5 · *Team:* svc, ui

#### 8.2 Payment webhooks
As the **platform**, I want payment events processed reliably so that subscription status is always accurate.

**Acceptance criteria**
- Success, failure, and cancellation are handled.
- Signatures are verified, and each event is processed only once.

*Priority:* M · *Points:* 5 · *Sprint:* 5 · *Team:* svc

#### 8.3 Dunning
As the **platform**, I want failed payments retried with reminders so that fewer members are lost.

**Acceptance criteria**
- Retries follow a schedule, and reminder emails are sent.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc

#### 8.4 Refunds
As an **admin**, I want to issue refunds so that I can resolve billing disputes.

**Acceptance criteria**
- Full and partial refunds are supported and logged in the audit trail.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc, ui

---

<a id="e9"></a>

### E9: Reviews

**Goal:** Reviews with a secret-shopper visibility gate and moderation.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 9.1 | Write a review | M | 5 | 8 | svc, ui |
| 9.2 | Hide reviews until a secret shopper has reviewed | M | 3 | 8 | svc, ui |
| 9.3 | Average rating | M | 2 | 8 | ui, svc |
| 9.4 | Flag and moderate reviews | M | 5 | 8 | svc, ui |
| 9.5 | Business replies | S | 3 | 10 | svc, ui |

#### 9.1 Write a review
As a **shopper or business**, I want to review a business so that I can share my experience.

**Acceptance criteria**
- Reviews have a 1–5 rating and text.
- Only users with an active subscription can review, including subscriptions discounted to $0.
- One review per business per reviewer, and it can be edited.
- A business can't review itself.

*Priority:* M · *Points:* 5 · *Sprint:* 8 · *Team:* svc, ui

#### 9.2 Hide reviews until a secret shopper has reviewed
As the **platform**, I want reviews hidden until a secret shopper has reviewed the business so that reviews are credible.

**Acceptance criteria**
- Authors see their hidden reviews marked "pending".
- The first secret shopper review sets `reviews_unlocked_at`, which makes all approved reviews visible.

*Priority:* M · *Points:* 3 · *Sprint:* 8 · *Team:* svc, ui

#### 9.3 Average rating
As a **visitor**, I want to see an average rating so that I can judge quality quickly.

**Acceptance criteria**
- The average and count appear on listing cards and profiles once reviews are unlocked.

*Priority:* M · *Points:* 2 · *Sprint:* 8 · *Team:* ui, svc

#### 9.4 Flag and moderate reviews
As a **user**, I want to flag abusive reviews, and as an **operator**, I want to moderate them, so that content stays clean.

**Acceptance criteria**
- There's a moderation queue with approve, hide, and remove actions.
- The author is notified of the outcome.

*Priority:* M · *Points:* 5 · *Sprint:* 8 · *Team:* svc, ui

#### 9.5 Business replies
As a **business**, I want to reply publicly to reviews so that I can address feedback.

**Acceptance criteria**
- One reply per review, and it can be edited.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc, ui

---

<a id="e10"></a>

### E10: Secret Shopper Program

**Goal:** Random monthly selection, confidential assignments, and evaluations.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 10.1 | Monthly random selection | M | 8 | 8 | svc |
| 10.2 | Eligibility rules | S | 3 | 10 | svc |
| 10.3 | Assign businesses to secret shoppers | M | 5 | 8 | svc |
| 10.4 | Confidential notifications | M | 3 | 8 | svc, ui |
| 10.5 | Submit an evaluation | M | 5 | 8 | svc, ui |
| 10.6 | Survey configuration | S | 5 | 10 | svc, ui |
| 10.7 | Program dashboard | S | 5 | 10 | ui, svc |

#### 10.1 Monthly random selection
As the **platform**, I want 1 in 100 active businesses and shoppers selected each month in each location so that the program is fair.

**Acceptance criteria**
- The job runs at the start of the 1st of the month **in the location's time zone** (`America/Phoenix` for Arizona).
- At least one of each is selected when the pool isn't empty.
- Only active subscriptions are eligible, including those discounted to $0.
- The random seed and selections are logged, and a location can't be selected twice in a month.

*Priority:* M · *Points:* 8 · *Sprint:* 8 · *Team:* svc

#### 10.2 Eligibility rules
As the **platform**, I want eligibility rules applied so that selection isn't biased.

**Acceptance criteria**
- Anyone selected last month is excluded, as are suspended accounts.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc

#### 10.3 Assign businesses to secret shoppers
As the **platform**, I want each secret shopper assigned businesses to evaluate so that coverage is spread out.

**Acceptance criteria**
- A secret shopper is never assigned their own business or a direct competitor in the same category.
- Businesses without a secret shopper review yet are prioritized.

*Priority:* M · *Points:* 5 · *Sprint:* 8 · *Team:* svc · *Depends on:* Q10, Q11

#### 10.4 Confidential notifications
As a **selected secret shopper**, I want to be told about my assignment privately so that I know what to do.

**Acceptance criteria**
- The notification arrives by email and in the app, with a deadline (for example, 30 days).
- The business never sees who evaluated it.

*Priority:* M · *Points:* 3 · *Sprint:* 8 · *Team:* svc, ui

#### 10.5 Submit an evaluation
As a **secret shopper**, I want to submit my review and survey so that my evaluation is complete.

**Acceptance criteria**
- The survey is required. The MVP uses a default question set seeded by migration.
- Submitting unlocks reviews for the business (9.2).

*Priority:* M · *Points:* 5 · *Sprint:* 8 · *Team:* svc, ui

#### 10.6 Survey configuration
As an **admin**, I want to edit the survey questions so that evaluations stay relevant.

**Acceptance criteria**
- Question types are rating, yes/no, and free text, and surveys are versioned.

*Priority:* S · *Points:* 5 · *Sprint:* 10 · *Team:* svc, ui

#### 10.7 Program dashboard
As an **admin**, I want to monitor the program and reselect shoppers so that assignments get done.

**Acceptance criteria**
- The dashboard shows selections, completion rate, and overdue assignments, with manual reselection.

*Priority:* S · *Points:* 5 · *Sprint:* 10 · *Team:* ui, svc

---

<a id="e11"></a>

### E11: Activity Tracking

**Goal:** Record all user and public activity for analytics, with consent.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 11.1 | Track user activity | M | 8 | 5 | svc, ui |
| 11.2 | Event storage and aggregates | M | 5 | 7 | svc |
| 11.3 | Cookie consent | M | 3 | 6 | ui |
| 11.4 | Bot filtering | S | 2 | 11 | svc |

#### 11.1 Track user activity
As the **business team**, I want every search, view, and click recorded so that we understand behavior.

**Acceptance criteria**
- Events follow the taxonomy from 0.5 and include the location.
- Anonymous and logged-in sessions are both tracked.
- Events are written asynchronously so page loads aren't slowed.

*Priority:* M · *Points:* 8 · *Sprint:* 5 · *Team:* svc, ui

#### 11.2 Event storage and aggregates
As the **data team**, I want events stored efficiently so that dashboards are fast.

**Acceptance criteria**
- `activity_event` is partitioned by month, with a retention policy.
- Materialized aggregates support the dashboards in E12.

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* svc

#### 11.3 Cookie consent
As a **visitor**, I want to control tracking cookies so that my privacy is respected.

**Acceptance criteria**
- A consent banner blocks non-essential tracking until the visitor opts in.
- It's live before the paid beta (R2).

*Priority:* M · *Points:* 3 · *Sprint:* 6 · *Team:* ui

#### 11.4 Bot filtering
As the **data team**, I want bot traffic excluded so that metrics are accurate.

**Acceptance criteria**
- Known bots are excluded from dashboards.

*Priority:* S · *Points:* 2 · *Sprint:* 11 · *Team:* svc

---

<a id="e12"></a>

### E12: Data Visualizations

**Goal:** Dashboards for subscribers by plan, for admins, and for the public.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 12.1 | Business dashboards by plan | M | 8 | 9 | ui, svc |
| 12.2 | Admin analytics dashboard | M | 5 | 9 | ui, svc |
| 12.3 | Public charts | S | 5 | 10 | ui, svc |
| 12.4 | Shopper dashboard | S | 3 | 10 | ui |

#### 12.1 Business dashboards by plan
As a **business**, I want analytics that match my plan so that I can see how my listing performs.

**Acceptance criteria**
- Silver: views and clicks.
- Gold adds trends and the search terms that lead to the listing.
- Platinum adds category benchmarks and review and survey insights.
- Message leads are included (16.8).

*Priority:* M · *Points:* 8 · *Sprint:* 9 · *Team:* ui, svc

#### 12.2 Admin analytics dashboard
As an **admin**, I want platform-wide analytics so that I can monitor the business.

**Acceptance criteria**
- It shows searches, listings, revenue (including discounted and full-price members), and reviews, filterable by location.

*Priority:* M · *Points:* 5 · *Sprint:* 9 · *Team:* ui, svc

#### 12.3 Public charts
As a **visitor**, I want to see what's popular so that I can discover businesses.

**Acceptance criteria**
- Charts such as top categories and trending searches use aggregated data only, with no personal information.

*Priority:* S · *Points:* 5 · *Sprint:* 10 · *Team:* ui, svc

#### 12.4 Shopper dashboard
As a **shopper**, I want to see my reviews and their status.

**Acceptance criteria**
- The dashboard shows the shopper's reviews and whether each is pending or visible.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* ui

---

<a id="e13"></a>

### E13: Home Page and Public UX

**Goal:** A minimal home page, responsive design, and public pages.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 13.1 | Home page | M | 3 | 5 | ui |
| 13.2 | Responsive and accessible design | M | 3 | 2 | ui |
| 13.3 | Pricing page | M | 2 | 5 | ui |
| 13.4 | Static pages | M | 2 | 9 | ui, svc |

#### 13.1 Home page
As a **visitor**, I want a simple home page so that I can start searching straight away.

**Acceptance criteria**
- The page has a search box, location selector, and links to the directory, pricing, sign-up, and login.
- LCP is under 2.5 s.

*Priority:* M · *Points:* 3 · *Sprint:* 5 · *Team:* ui

#### 13.2 Responsive and accessible design
As a **mobile user**, I want the site to work on my phone so that I can use it anywhere.

**Acceptance criteria**
- Layouts work at all breakpoints, and the site meets WCAG 2.1 AA.

*Priority:* M · *Points:* 3 · *Sprint:* 2 · *Team:* ui

#### 13.3 Pricing page
As a **visitor**, I want to compare plans so that I can choose one.

**Acceptance criteria**
- Plan data is read from the configuration in 7.1.
- Active promotions are shown per 7.12.

*Priority:* M · *Points:* 2 · *Sprint:* 5 · *Team:* ui

#### 13.4 Static pages
As a **visitor**, I want About, Terms, Privacy, and Contact pages so that I can learn about BlackPages.

**Acceptance criteria**
- The content can be edited by admins.

*Priority:* M · *Points:* 2 · *Sprint:* 9 · *Team:* ui, svc

---

<a id="e14"></a>

### E14: Administration and Site Operations

**Goal:** Tools for admins and site operators, within their access scope.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 14.1 | Manage operator assignments | M | 3 | 9 | svc, ui |
| 14.2 | Admin console access rules | M | 5 | 9 | svc, ui |
| 14.3 | Manage members | M | 5 | 9 | svc, ui |
| 14.4 | Audit log | S | 3 | 10 | svc, ui |
| 14.5 | Email templates | M | 3 | 9 | svc |
| 14.6 | Bulk moderation | S | 3 | 10 | svc, ui |

#### 14.1 Manage operator assignments
As an **admin**, I want to change which locations an operator manages so that responsibilities can shift.

**Acceptance criteria**
- Operators can be assigned to or removed from locations after they're invited (2.9).
- Changes take effect on the next request.

*Priority:* M · *Points:* 3 · *Sprint:* 9 · *Team:* svc, ui

#### 14.2 Admin console access rules
As the **platform**, I want every admin screen to respect role and location scope so that staff can't exceed their access.

**Acceptance criteria**
- Admins can write to all locations, and operators only to assigned ones. Both can read all.
- The authorization matrix covers every admin endpoint.

*Priority:* M · *Points:* 5 · *Sprint:* 9 · *Team:* svc, ui

#### 14.3 Manage members
As an **admin or operator**, I want to search, filter, edit, and approve members so that I can resolve issues.

**Acceptance criteria**
- Filters include plan, discount, status, location, category, signup date, and payment status.
- The list can be exported to CSV.
- Access is limited to each user's scope.

*Priority:* M · *Points:* 5 · *Sprint:* 9 · *Team:* svc, ui

#### 14.4 Audit log
As an **admin**, I want a record of admin actions so that there's accountability.

**Acceptance criteria**
- The log records who did what and when, and to which record.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc, ui

#### 14.5 Email templates
As the **platform**, I want consistent, branded emails so that members trust our messages.

**Acceptance criteria**
- Templates cover receipts, failed payments, discount-ending notices, secret shopper selection, review status, and listing approval.
- Authentication emails are in the Keycloak theme (2.17).

*Priority:* M · *Points:* 3 · *Sprint:* 9 · *Team:* svc

#### 14.6 Bulk moderation
As an **admin**, I want bulk actions so that moderation is efficient.

**Acceptance criteria**
- Bulk approve, reject, and suspend, with confirmation and an audit entry.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc, ui

---

<a id="e15"></a>

### E15: Non-Functional Requirements

**Goal:** Performance, accessibility, security, observability, and privacy.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 15.1 | Performance budgets | M | 3 | 11 | All |
| 15.2 | Accessibility audit | M | 3 | 11 | ui |
| 15.3 | Security testing | M | 5 | 11 | All |
| 15.4 | Observability | M | 3 | 4 | infra, svc |
| 15.5 | Privacy compliance | M | 3 | 9 | All |

#### 15.1 Performance budgets
As the **platform**, I want performance checked continuously so that the site stays fast.

**Acceptance criteria**
- API p95 under 500 ms and search p95 under 300 ms under load tests.
- Public pages meet LCP under 2.5 s and CLS under 0.1.

*Priority:* M · *Points:* 3 · *Sprint:* 11 · *Team:* All

#### 15.2 Accessibility audit
As a **user with a disability**, I want the site to be accessible so that I can use it fully.

**Acceptance criteria**
- Automated axe checks run in CI, and a manual WCAG 2.1 AA audit is done before launch.

*Priority:* M · *Points:* 3 · *Sprint:* 11 · *Team:* ui

#### 15.3 Security testing
As the **platform**, I want security tested before launch so that members' data is protected.

**Acceptance criteria**
- An OWASP Top 10 review and a penetration test of authentication, payments, and admin are completed, and findings are fixed.

*Priority:* M · *Points:* 5 · *Sprint:* 11 · *Team:* All

#### 15.4 Observability
As the **operations team**, I want logs, metrics, and alerts so that problems are found quickly.

**Acceptance criteria**
- Centralized logs with retention limits, health checks, dashboards, and alerts for errors, latency, and failed payments.

*Priority:* M · *Points:* 3 · *Sprint:* 4 · *Team:* infra, svc

#### 15.5 Privacy compliance
As a **member**, I want my personal data handled lawfully so that I can trust BlackPages.

**Acceptance criteria**
- The privacy policy, data retention rules, and data export and deletion requests are in place.

*Priority:* M · *Points:* 3 · *Sprint:* 9 · *Team:* All

---

<a id="e16"></a>

### E16: Messaging

**Goal:** Visitor-to-member communication through an email relay.

| ID | Story | Pri | Pts | Sprint | Team |
|---|---|---|---|---|---|
| 16.1 | Contact form | M | 5 | 7 | ui, svc |
| 16.2 | Spam protection | M | 3 | 7 | svc, ui |
| 16.3 | Member inbox | M | 5 | 7 | ui, svc |
| 16.4 | Replies through an email relay | M | 5 | 7 | svc |
| 16.5 | Shopper message history | S | 3 | 10 | ui, svc |
| 16.6 | Messaging by plan | M | 2 | 7 | svc |
| 16.7 | Report and block senders | S | 3 | 10 | svc, ui |
| 16.8 | Message leads in analytics | M | 2 | 9 | svc |

#### 16.1 Contact form
As a **visitor**, I want to message a business from its profile without an account so that I can ask a question.

**Acceptance criteria**
- The form asks for name, email, an optional phone number, and a message.
- The visitor sees a confirmation and gets a copy by email.

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* ui, svc

#### 16.2 Spam protection
As the **platform**, I want spam blocked so that members' inboxes stay clean.

**Acceptance criteria**
- CAPTCHA, rate limits by IP and email, link and keyword filtering, and a blocklist.

*Priority:* M · *Points:* 3 · *Sprint:* 7 · *Team:* svc, ui

#### 16.3 Member inbox
As a **business**, I want an inbox in my dashboard so that I can manage enquiries.

**Acceptance criteria**
- Messages can be marked read or unread and archived.
- New messages trigger an email and show an unread badge.

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* ui, svc

#### 16.4 Replies through an email relay
As a **business**, I want to reply to visitors so that we can continue the conversation.

**Acceptance criteria**
- Replies go through a relay so neither party's real email address is exposed.
- The full thread is stored.

*Priority:* M · *Points:* 5 · *Sprint:* 7 · *Team:* svc

#### 16.5 Shopper message history
As a **logged-in shopper**, I want to see my past messages.

**Acceptance criteria**
- Threads appear in the shopper's dashboard.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* ui, svc

#### 16.6 Messaging by plan
As the **platform**, I want messaging controlled by the entitlement engine so that it can be adjusted per plan.

**Acceptance criteria**
- Messaging is enabled for Silver, Gold, and Platinum by default through the entitlement engine (7.10).

*Priority:* M · *Points:* 2 · *Sprint:* 7 · *Team:* svc

#### 16.7 Report and block senders
As a **business or admin**, I want to report and block abusive senders.

**Acceptance criteria**
- Reported messages go to the moderation queue.

*Priority:* S · *Points:* 3 · *Sprint:* 10 · *Team:* svc, ui

#### 16.8 Message leads in analytics
As a **business**, I want messages counted as leads so that I can see the value of my listing.

**Acceptance criteria**
- "Message sent" is tracked and shown on the business dashboard (12.1).

*Priority:* M · *Points:* 2 · *Sprint:* 9 · *Team:* svc

---

## 5. Post-MVP backlog

| ID | Item | Notes |
|---|---|---|
| 2.13 | Admins viewing the site as a member (impersonation) | Read-only, time-limited, audited, with a visible banner. Could, 5 pts. |
| 12.5 | Configurable visualizations for each tier | An entitlement matrix in the admin UI. Could, 3 pts. |
| P.1 | Social login (Google, Apple) | Keycloak identity brokering. Configuration only, with no application changes. |
| P.2 | Passkeys (WebAuthn) | Keycloak passwordless support. |
| P.3 | Live chat | An alternative to the email relay (Q4). About 1–2 sprints. |
| P.4 | Advanced SEO tools | Content editor, Search Console dashboard, SEO audits, FAQ schema, and "Best X in Y" pages. |
| P.5 | Metadata that members can edit | Possibly limited to Platinum. |
| P.6 | Custom service-area polygons | About 8 pts (Q5). |
| P.7 | Mobile apps | Would use a bearer-token security chain (ADR-0006). |
| P.8 | Data warehouse export | For advanced analytics (ADR-0011). |
| P.9 | Redis/Valkey caching | When a second backend task is added (ADR-0010). |
| P.10 | Expansion to new locations | Each new state is configuration plus data seeding, following the pattern of story 1.5. |

---

## 6. Change log: removed and merged stories

| ID | Former story | Outcome | Reason |
|---|---|---|---|
| 5.4 | Listing detail page | Merged into 3.10 | Replaced by the rich profile page |
| 7.9 | Free tier | Removed | There is no free plan. Discounts (7.2, 7.11, 7.12) replace it. |
| 2.10 | Session management page | Removed | Keycloak's account console provides it |
| 2.13 | Impersonation | Moved to post-MVP | Could-have |
| E17 | Keycloak migration epic (about 30–40 pts) | Cancelled | Keycloak is used from day one (ADR-0005) |
| — | Local authentication (credentials, TOTP, reset tokens) | Removed | Handled by Keycloak |
| — | Local social login | Moved to post-MVP | Keycloak identity brokering (P.1) |
| 7.2 | Discounts | Changed from Should to **Must**, moved from Sprint 10 to Sprint 6 | Discounts are the main acquisition lever now that there's no free plan |
| 3.6 | Listing approval | Changed from Should to **Must** | Member approval is a Must-have |

---

## 7. Open questions that affect stories

| Question | Summary | Stories affected | Needed by |
|---|---|---|---|
| Q1 | Card fees on $1 invoices when a plan is discounted to $0: accept the cost, or bill the fee annually ($12) during discounted periods? | 7.6 | Before Sprint 5 |
| Q5 | Are a list of cities or a radius enough for service areas? | 5.7 | Before Sprint 6 |
| Q6 | How many specialties and gallery photos should each plan allow? | 3.9, 4.7 | Before Sprint 2 |
| Q7 | Is business team access needed at launch? | 2.7 | Before Sprint 10 |
| Q8 | URL pattern for specialty pages, and whether the state appears in URLs. | 6.6 | Before Sprint 4 |
| Q9 | Is 3 listings the right threshold for indexing a dynamic page? | 6.7 | Before Sprint 4 |
| Q10 | Secret shopper incentives, and how many businesses each one evaluates. | 10.3 | Before Sprint 8 |
| Q11 | Can a secret shopper who is a business review a competitor in the same category? (Assumed: no.) | 10.3 | Before Sprint 8 |
| Q12 | Does Arizona's transaction privilege tax (TPT) apply to subscriptions? | 7.13 | Before billing goes live |
| Q14 | Staff MFA: default conditional OTP with reconciliation, or a custom flow keyed on the staff role? | 2.21 | Before Sprint 10 |
| Q15 | Final list of Arizona launch cities. | 1.5 | Before Sprint 2 |
