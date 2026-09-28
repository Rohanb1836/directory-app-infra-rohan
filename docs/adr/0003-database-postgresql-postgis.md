# ADR-0003: PostgreSQL 16 with PostGIS, using Flyway for migrations

- **Status:** Accepted (amended 2026-09-27 to add the Keycloak database)
- **Date:** 2026-09-27

## Decision
- The application database is `blackpages` on PostgreSQL 16 with the `postgis`, `pg_trgm`, and `unaccent` extensions. Flyway manages its schema, including the Spring Session tables.
- **Keycloak has its own database, `keycloak`**, owned by a separate role. On the MVP it sits on the same server or RDS instance, and Keycloak manages its schema itself (ADR-0016).
- Every table scoped to a location has `location_id NOT NULL` (ADR-0008).

## Consequences
- PostGIS handles map and service-area queries, and full-text search needs no separate engine (ADR-0004).
- The database roles are isolated, so neither the application nor Keycloak can read the other's data.
