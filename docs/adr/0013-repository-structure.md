# ADR-0013: Frontend, backend, and infrastructure each have their own repository

- **Status:** Accepted
- **Date:** 2026-09-27 (repositories renamed on the same date)

## Decision

| Repository | Owner | Contents |
|---|---|---|
| `directory-app-svc` | Backend team | Spring Boot application, `contract/openapi.yaml`, Flyway migrations, and backend CI |
| `directory-app-ui` | Web team | Next.js application, the Keycloakify theme (`keycloak-theme/`, built as a JAR artifact), Playwright tests, and frontend CI |
| `directory-app-infra` | DevOps (or the backend team until DevOps exists) | Terraform, the Keycloak image build, `keycloak-config-cli` realm configuration for each environment, the local docker-compose stack, and ADRs that affect more than one team |

- ADRs that affect both teams live in `directory-app-infra/docs/adr/`. ADRs specific to one team live in that team's repository.
- The local development stack (Postgres with PostGIS, Keycloak, Mailpit, stripe-mock) is defined in `directory-app-infra/local/`.

## Naming
- Repositories follow the pattern `directory-app-<role>`: `svc` for the backend service, `ui` for the web frontend, and `infra` for infrastructure.
- Artifacts published from each repository:

| Artifact | Built in | Name |
|---|---|---|
| Backend container image | `directory-app-svc` | `ghcr.io/<org>/directory-app-svc:<semver>` |
| Generated TypeScript API client | `directory-app-svc` | `@blackpages/api-client` on GitHub Packages |
| Keycloakify theme JAR | `directory-app-ui` | `blackpages-keycloak-theme-<version>.jar` (CI artifact) |
| Web container image | `directory-app-ui` | `ghcr.io/<org>/directory-app-ui:<semver>` |
| Keycloak container image | `directory-app-infra` | `ghcr.io/<org>/directory-app-keycloak:<keycloak-version>-<build>` |

- Keycloak realm and client IDs (`blackpages`, `blackpages-bff`, `blackpages-admin-api`) and Java packages (`io.blackpages.*`) keep the product name. They identify the product, not a repository.

## Consequences
- Each team is independent, with a simpler pipeline. Changes across repositories are coordinated through the contract (ADR-0012) and versioned artifacts: the client package, the backend image, and the theme JAR.
