# BlackPages.io: Architecture Pack (Revision 2026-09-27)

This revision adopts **Keycloak from day one** and cancels the planned migration away from local authentication.

**Start with [`HANDOFF.md`](HANDOFF.md)**, which has the context, decisions, open questions, and next steps.

## Contents

| Path | What it is | Target repository |
|---|---|---|
| `docs/product/mvp.md` | MVP definition | `directory-app-infra/docs/product/` |
| `docs/product/answers-log.md` | Answers to Q1–Q15 from the product owner, how each was applied, and follow-up questions | `directory-app-infra/docs/product/` |
| `docs/product/todo.md` | To-do list: privacy, terms, profile switching, billing intervals, annual discounts, update limits, addresses, taxes per location, cross-state listings, demand tracking by state | `directory-app-infra/docs/product/` |
| `docs/product/backlog.md` | Product backlog: epics, user stories, acceptance criteria, sprint plan | `directory-app-infra/docs/product/` |
| `docs/product/specs/SPEC-BILL-01-listing-tiers-and-entitlements.md` | Feature spec: account types, listing tiers, and entitlements (billing, part 1) | `directory-app-infra/docs/product/specs/` |
| `docs/reviews/ui-screen-stories-review.md` | Review of the web team's UI Screen Stories v1.1: 11 missing screens, 5 conflicts, 9 new-scope items, timing risks | `directory-app-ui/docs/product/` |
| `docs/product/specs/SPEC-SRV-01-survey-integration-and-insights.md` | Feature spec: survey app integration (sites are locations) and survey insights | `directory-app-infra/docs/product/specs/` |
| `docs/adr/` | ADR-0001 to ADR-0022, with an index and status list | `directory-app-infra/docs/adr/` |
| `docs/architecture/system-overview.md` | **System architecture overview**: context, containers, 15 modules, data model, runtime flows, deployment, cross-cutting concepts, quality targets | `directory-app-infra/docs/architecture/` |
| `docs/architecture/frontend.md` | **Frontend architecture**: rendering, data access, authentication in the UI, errors, SEO, styling, the Keycloak theme, testing, deployment | `directory-app-infra/docs/architecture/` |
| `docs/architecture/api-guidelines.md` | **API style guide**: URLs, methods, bodies, pagination, errors, concurrency, idempotency, security, versioning, OpenAPI rules, review checklist | `directory-app-infra/docs/architecture/` |
| `docs/architecture/identity-and-access.md` | Full identity and access design: realm, flows, backend, frontend, testing, backlog impact | `directory-app-infra/docs/architecture/` |
| `infra/local/docker-compose.yml` | Local stack: Postgres with PostGIS (databases for the app and Keycloak), Keycloak, Mailpit, stripe-mock | `directory-app-infra/local/` |
| `infra/local/.env.example` | Local-only settings | `directory-app-infra/local/` |
| `infra/local/postgres/init/20-create-databases.sh` | Creates the `blackpages` and `keycloak` databases and roles, and the PostGIS extensions | `directory-app-infra/local/postgres/init/` |
| `infra/keycloak/realm/blackpages-realm.json` | Realm imported for local development and CI | `directory-app-infra/keycloak/realm/` |
| `infra/keycloak/Dockerfile` | Optimized production Keycloak image with the theme | `directory-app-infra/keycloak/` |

## Quick start (local)

```bash
cd infra/local
cp .env.example .env
docker compose up -d
# Keycloak admin console: http://localhost:8081/admin   (admin / admin)
# Mailpit:                 http://localhost:8025
# OIDC discovery:          http://localhost:8081/realms/blackpages/.well-known/openid-configuration
```

## Repositories

| Repository | Contents |
|---|---|
| `directory-app-svc` | Spring Boot backend and the OpenAPI contract |
| `directory-app-ui` | Next.js frontend and the Keycloakify theme |
| `directory-app-infra` | Terraform, the Keycloak image and realm configuration, the local stack, and shared ADRs |

## What changed from the previous design

- **Authentication:** Keycloak replaces local authentication with Spring Security (ADR-0005).
- **Sessions:** the backend is the OIDC client and keeps sessions in Spring Session JDBC. Keycloak tokens never reach the browser (ADR-0006).
- **Authorization:** unchanged in substance. Split into its own decision, ADR-0007.
- **Registration:** now Keycloak account creation followed by onboarding in the application.
- **Removed local tables:** `local_credential`, `local_mfa_totp`, `mfa_recovery_code`, `auth_token`, `login_event`.
- **Backlog:** epic E17 (Keycloak migration, about 30–40 points) is cancelled, and story 2.10 is dropped. New stories 2.16–2.22 are added.
- **Cost:** about $29 a month more for the Keycloak task (ADR-0014).
