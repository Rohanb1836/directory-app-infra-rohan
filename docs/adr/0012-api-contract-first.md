# ADR-0012: The API is designed contract-first, and the typed client is published

- **Status:** Accepted
- **Supersedes:** The code-first approach with springdoc in the Sprint 0 draft
- **Date:** 2026-09-27

## Decision
- `openapi.yaml` in `directory-app-svc/contract/` is written **before** the code is implemented. Both teams approve each change to the spec.
- The backend generates Spring interfaces from the spec with `openapi-generator` (`interfaceOnly=true`), and controllers implement them. Generated code is excluded from coverage.
- On every merge to `main`, backend CI:
  - checks for breaking changes with openapi-diff;
  - publishes `@blackpages/api-client` to GitHub Packages with semantic versioning;
  - pushes the backend Docker image to GHCR with the same version.
- The frontend pins the client version and develops against MSW mocks generated from the spec.
- **Auth endpoints in the contract:**
  - `/api/auth/login`, `/api/auth/register`, and `/api/auth/logout` are redirects handled by the browser.
  - `/api/auth/me` and the `/api/onboarding/*` endpoints are ordinary JSON operations.
  - The OAuth callback endpoints aren't part of the contract.

## Consequences
- The teams can work in parallel, and breaking changes are caught automatically.
