# ADR-0002: The frontend is one Next.js (React) application with route groups

- **Status:** Accepted
- **Date:** 2026-09-27

## Context
Public directory pages must be crawlable (Epic 6). A single-page React app that renders only in the browser does not reliably produce indexable HTML.

## Decision
- One Next.js application has three route groups:
  - `(public)`: rendered on the server or statically, and regenerated when content changes.
  - `(member)/app`: the member dashboard, rendered mostly in the browser.
  - `(admin)/admin`: the admin console, rendered mostly in the browser.
- All calls to the backend go through the typed client generated from the published OpenAPI contract (ADR-0012).
- Authentication redirects to `/api/auth/login` and `/api/auth/register`. The frontend never handles OAuth tokens (ADR-0006).
- **Keycloak login, registration, and email pages are a Keycloakify theme** owned by the web team and built as a JAR for the Keycloak image (ADR-0005, ADR-0016).

## Consequences
- There is one design system and one deployment for all web pages. SEO requirements are met.
- The team has to handle both server and client component patterns.
