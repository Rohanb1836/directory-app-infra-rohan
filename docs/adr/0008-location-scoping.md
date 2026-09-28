# ADR-0008: Location scoping

- **Status:** Accepted
- **Date:** 2026-09-27

## Decision
- Each request resolves a `LocationContext` from the URL, the user's selection, or the resource being accessed.
- Entities scoped to a location use a Hibernate filter keyed on `location_id`. An ArchUnit rule fails the build if a repository for one of these entities can be called without a `LocationContext`.
- Write access for site operators is checked by `LocationPolicy` (ADR-0007) against `operator_location`. The check reads the database on every request, with a short cache, so reassigning an operator takes effect immediately.
- A trigger or service rule enforces the limit of 50 active locations.

## Consequences
- Scoping rules live in one place, and tests prove that data doesn't leak between locations.
