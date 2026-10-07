# ADR-0019: Frontend platform is Next.js 16.3, React 19, and Node.js 24 LTS

- **Status:** Accepted
- **Date:** 2026-09-30
- **Related:** ADR-0002 (Next.js), ADR-0012 (contract-first API), ADR-0014 (hosting), ADR-0018 (backend platform), Frontend Architecture v1.0

## Context

ADR-0002 chose Next.js but didn't pin versions. Next.js 16 has been stable since October 2025. Its current minor release, **16.3**, shipped in June 2026, and security patches are being released for the 16.3 line. Next.js 16 changes several things the frontend design depends on: Turbopack is the default bundler, the old `middleware` file is now the request **proxy** (`proxy.ts`), and the caching model has been reworked.

## Decision

1. **Next.js 16.3.x** (App Router), pinned to the latest patch release, with **React 19.x** at the version Next.js supports.
2. **Node.js 24 LTS** for builds and runtime, in ARM64 container images (ADR-0014).
3. **TypeScript** in strict mode.
4. Supporting libraries, as described in the Frontend Architecture:
   - Tailwind CSS and Radix UI for styling and accessible components;
   - TanStack Query for server data in the browser;
   - React Hook Form and Zod for forms;
   - `openapi-typescript` and `openapi-fetch` for `@blackpages/api-client`;
   - `@vis.gl/react-google-maps` for maps;
   - Keycloakify for the login theme;
   - Vitest, MSW, Playwright, and axe for testing.
5. **Next.js Server Actions aren't used for business operations.** Every change goes from the browser straight to the backend API, so there's one entry point and one CSRF model (ADR-0006, ADR-0007).
6. **Upgrades:** apply Next.js security releases as soon as they're published. Move to new minor releases within a sprint of release, after the Playwright and Lighthouse checks pass. Plan major upgrades as backlog stories.

## Consequences

- The app starts on the current, supported versions, with no early migration.
- Some patterns and libraries online still target Next.js 14 and 15 (for example, `middleware.ts`). The `CLAUDE.md` for `directory-app-ui` must state the Next.js 16 conventions explicitly.
- Next.js now ships security patches frequently, so applying them quickly needs to be a routine operations task.
