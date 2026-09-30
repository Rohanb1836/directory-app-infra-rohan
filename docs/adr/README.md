# Architecture Decision Records

ADRs use a lightweight version of the Nygard format: Status, Context, Decision, Consequences. To change a decision, write a new ADR that supersedes the old one, and don't edit accepted ADRs other than to update their status.

**Where ADRs live:** decisions that affect more than one team are kept in `directory-app-infra/docs/adr/` (see ADR-0013).

| ADR | Title | Status | Changed in this revision |
|---|---|---|---|
| [0001](0001-backend-modular-monolith.md) | Backend is a Spring Boot modular monolith | Accepted (amended) | `entitlement` module added (15 modules). Platform versions superseded by ADR-0018. |
| [0002](0002-frontend-nextjs.md) | Frontend is one Next.js app with route groups | Accepted | Added Keycloakify theme ownership |
| [0003](0003-database-postgresql-postgis.md) | PostgreSQL 16 with PostGIS, using Flyway | Accepted (amended) | Added a separate `keycloak` database |
| [0004](0004-search-postgres.md) | Search uses Postgres full-text search behind a SearchPort | Accepted | — |
| [0005](0005-identity-provider-keycloak.md) | **Keycloak is the identity provider from day one** | Accepted (wording amended) | **New.** Supersedes the draft for local authentication |
| [0006](0006-session-management-bff.md) | **Backend is the OIDC client, with server-side sessions** | Accepted | **New.** Supersedes the draft for JWT in cookies |
| [0007](0007-authorization-model.md) | **Authorization in four layers, enforced by the application** | Accepted (wording amended) | **New.** Split out of the identity decision |
| [0008](0008-location-scoping.md) | Location scoping | Accepted | — |
| [0009](0009-payments-stripe.md) | Payments use Stripe Billing | Proposed | Billing items follow ADR-0017 |
| [0010](0010-async-processing-and-scheduling.md) | Outbox, ShedLock on Postgres, no Redis in the MVP | Accepted | Redis removed; reconciliation job added |
| [0011](0011-analytics-events.md) | Analytics events in a partitioned table | Accepted | Clarified that Keycloak events stay in Keycloak |
| [0012](0012-api-contract-first.md) | API designed contract-first, with a published client | Accepted | Supersedes the code-first approach |
| [0013](0013-repository-structure.md) | Separate repositories: `directory-app-svc`, `directory-app-ui`, `directory-app-infra` | Accepted | **New**; repositories renamed |
| [0014](0014-hosting-aws.md) | Hosting on AWS with ECS Fargate | Proposed | Keycloak service and updated costs |
| [0015](0015-email-provider.md) | Postmark for application email, Keycloak SMTP, and the reply relay | Proposed | Keycloak email stream added |
| [0016](0016-keycloak-deployment-and-configuration.md) | **Keycloak deployment and configuration as code** | Accepted | **New** |
| [0017](0017-account-types-and-listing-tiers.md) | **Two account types, with tiers on each listing** | Accepted | **New (2026-09-30).** Supersedes the account-plan model. Clarified the same day: the default Silver listing is charged like any other |
| [0018](0018-backend-platform-spring-boot-4-java-25.md) | **Backend platform: Spring Boot 4.1 on Java 25** | Accepted | **New (2026-09-30).** Supersedes the platform versions in ADR-0001 |

## Wording amendments

ADR-0005, ADR-0007, and ADR-0009 had their wording updated on 2026-09-30 to use account types and listing tiers. Their decisions are unchanged. The pricing-model change itself is recorded in ADR-0017.

## Superseded drafts

The early decisions listed in the Sprint 0 proposal were drafts, never formal ADRs. These parts of them are superseded:

- **The draft of ADR-05** (Spring Security local authentication with JWT cookies, and later server-side sessions with a planned migration to Keycloak) is replaced by ADR-0005, ADR-0006, and ADR-0007.
- **The draft of ADR-10** (code-first OpenAPI) is replaced by ADR-0012.

## Open decisions

| Topic | ADR | Owner |
|---|---|---|
| Confirm AWS as the cloud provider | 0014 | Product owner and tech lead |
| Confirm Stripe and who owns the account | 0009 | Product owner |
| Confirm Postmark or SendGrid | 0015 | Tech lead |
| Staff MFA: default conditional OTP with reconciliation, or a custom flow keyed on the staff role | 0005 | Tech lead (by Sprint 2) |
