# ADR-0007: Authorization happens in four layers, all enforced by the application

- **Status:** Accepted (wording amended 2026-09-30 for account types and listing tiers, ADR-0017)
- **Date:** 2026-09-27
- **Related:** ADR-0005, ADR-0006, ADR-0008

## Context

Access rules combine four things:
- **Platform roles:** public visitor, shopper, business, site operator, and admin.
- **Location scope:** site operators can write only to the locations assigned to them.
- **Ownership:** a business account's owner can act only on their own account and its listings. In the MVP, each business account has exactly one user, its owner.
- **Entitlements:** what each listing's tier allows, and what each account type allows (ADR-0017).

Most of this changes often, such as operator reassignments, listing tier changes, and staff invites. It's also specific to BlackPages, and it needs to take effect immediately. Putting it in Keycloak tokens would mean access continues after it's been revoked, and Keycloak would need our business logic.

## Decision

1. **All authorization decisions are made in `io.blackpages.identity` by an `AuthorizationService` that checks four layers:**
   1. **Role.** Named permissions such as `LISTING_APPROVE` are mapped to the roles stored in `user_role`.
   2. **Location scope.** `LocationPolicy`: ADMIN can write to every location. SITE_OPERATOR can write only to locations in `operator_location`. Both roles can read all locations.
   3. **Ownership.** `OwnershipPolicy`: checks that the user is the account's OWNER in `business_account_member`. In the MVP each account has exactly one member, the owner, and only the owner can change listing tiers, add or remove listings, and manage billing.
   4. **Entitlement.** The entitlement engine (story 7.10), which checks the listing's tier for listing actions and the account type for account actions (SPEC-BILL-01).
2. **The application database is the source of truth for roles.** Keycloak's realm role `staff` is used only to enforce MFA and is never used for authorization (ADR-0005).
3. **Modules read the user through `CurrentUser`**, a record in our own domain. They never use Spring's `OidcUser` or any Keycloak types. An ArchUnit rule enforces this.
4. **Resources outside a user's scope return 404**, not 403, so users can't discover records belonging to others.
5. **Staff permissions require verified MFA.** When a staff user logs in, the backend checks through the Admin API that the user has an OTP credential. If not, the session gets no staff permissions and the user is sent to set up OTP.
6. **`GET /api/auth/me`** returns the user, their roles, locations, memberships, entitlements, and onboarding status. The frontend uses it only to show or hide UI, never to make security decisions.
7. **An authorization matrix test** runs every OpenAPI operation as each persona and compares the result with `authz-matrix.yaml`. An operation that isn't listed in the matrix fails the build.

## Consequences

- Revocation takes effect on the next request, and Keycloak tokens stay small.
- The same rules will apply to future bearer-token clients.
- The matrix file becomes a required artifact for every new endpoint.
