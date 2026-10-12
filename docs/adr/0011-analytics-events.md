# ADR-0011: Analytics events are stored in an append-only, partitioned table

- **Status:** Accepted (2026-10-06: the detailed design is in System Overview section 8.14 and API Style Guide section 12.2. Tooling is decided in ADR-0021.)
- **Date:** 2026-09-27

## Decision
- The `activity_event` table is partitioned by month on `occurred_at`. Events are ingested asynchronously (ADR-0010).
- The event taxonomy (names and properties) is versioned in `docs/architecture/event-taxonomy.md`.
- **Keycloak login events are not copied into analytics.** Keycloak keeps them for 90 days for security auditing.

## Consequences
- This is simple for the MVP. Data can be exported to a warehouse later, and dashboards read from materialized aggregates.
