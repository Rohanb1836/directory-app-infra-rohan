# ADR-0016: Keycloak deployment, database, and configuration as code

- **Status:** Accepted
- **Date:** 2026-09-27
- **Related:** ADR-0003, ADR-0005, ADR-0013, ADR-0014

## Context

Keycloak runs from day one (ADR-0005). We need a repeatable setup across local development, CI, staging, and production that keeps cost low for the MVP and doesn't rely on manual changes in the admin console.

## Decision

### Image
- The base image is `quay.io/keycloak/keycloak`, **pinned to a patch version** (26.7.4 at the time of writing) through `KEYCLOAK_VERSION`.
- Production uses a custom image built in `directory-app-infra/keycloak/`. The build stage runs `kc.sh build` with `KC_DB=postgres`, enables health and metrics, and adds the Keycloakify theme JAR from the web team. The runtime stage uses `start --optimized`.
- Local development uses the stock image with `start-dev --import-realm`.

### Database
- **Local:** one PostGIS container holds two databases, `blackpages` and `keycloak`, each with its own owner role.
- **Staging and production (MVP):** one RDS instance holds two logical databases, `blackpages` and `keycloak`, with **separate credentials** stored in Secrets Manager. The Keycloak role can't access the application database, and the application role can't access Keycloak's.
- **Later:** move Keycloak to its own RDS instance if it needs different sizing or maintenance windows, or for compliance.
- Keycloak manages its own schema. Flyway never touches the `keycloak` database.

### Network and hostnames
- Keycloak is served at `https://auth.blackpages.io` through a host-based rule on the **existing ALB**. TLS ends at the ALB. Keycloak runs with `KC_HTTP_ENABLED=true`, `KC_PROXY_HEADERS=xforwarded`, and `KC_HOSTNAME=https://auth.blackpages.io`.
- **Paths under `/admin/` on the public hostname are restricted** by an ALB rule that allows only the office and VPN IP ranges and returns 403 to everyone else. The management port (9000) for health and metrics is reachable only inside the VPC.
- The back-channel logout URL uses the backend's internal service address, not the public URL.

### Configuration as code
- **Local and CI:** `infra/keycloak/realm/blackpages-realm.json` is imported at startup. Secrets and URLs are filled from environment variables.
- **Staging and production:** `keycloak-config-cli` applies the realm configuration from `directory-app-infra/keycloak/config/`, for each environment, in the deploy pipeline. Changes made by hand in the admin console are treated as drift and overwritten on the next deploy.
- Client secrets live in Secrets Manager and are passed to both Keycloak's configuration and the backend.

### Operations
- **MVP:** one Keycloak task (1 vCPU and 2 GB on ARM). **For high availability:** two tasks, using Keycloak's clustered cache with discovery over the database (the default in the 26 line; confirm for the pinned version).
- **Health checks:** `/health/ready` on the management port.
- **Upgrades:** apply each patch release on the pinned minor version promptly, and review the minor version quarterly. Always upgrade staging first and run the login end-to-end suite before production.
- **Backups:** the `keycloak` database is covered by the RDS automated backups.
- **Events:** login events are kept for 90 days. Admin events are enabled for auditing.

## Consequences

- There's one repeatable realm definition, and drift is caught automatically.
- The MVP cost increase is small: one task, and no extra database instance.
- Sharing an RDS instance couples maintenance windows and noisy-neighbor risk. That's acceptable at MVP scale, and the design allows splitting them later.
