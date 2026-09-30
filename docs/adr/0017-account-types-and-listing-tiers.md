# ADR-0017: Two account types, with tiers on each listing

- **Status:** Accepted (clarified the same day, before any implementation; see "Clarification" below)
- **Date:** 2026-09-30
- **Supersedes:** The account-plan model (Silver, Gold, and Platinum as account plans) previously described in ADR-0009, the MVP definition up to v1.4, and SPEC-BILL-01 v0.1
- **Related:** ADR-0007 (authorization), ADR-0009 (payments), SPEC-BILL-01 v0.2

## Context

Until now, Silver, Gold, and Platinum were **plans on an account**. Every listing on the account shared the plan, and extra listings were billed as add-ons. The product owner has redefined the model:

- There are **two account types: business and shopper**.
- A business account can add **any number of listings**, and **each listing is Silver, Gold, or Platinum**.
- Every business account gets **one Silver listing by default**.

This changes where entitlements come from, how billing items are structured, and how the directory's ordering data is maintained.

## Decision

1. **Account types.** `BUSINESS` and `SHOPPER` are the only account types. There are no account plans.
2. **Tiers belong to listings.** Each listing has exactly one tier. A business can mix tiers across its listings.
3. **Entitlements come from two sources** (SPEC-BILL-01, section 4):
   - **Listing entitlements** come from the listing's tier: gallery, specialties, description length, links, placement, messaging, and analytics level.
   - **Account entitlements** come from the account type: listing cap, review rights, and secret shopper eligibility.
4. **Billing stays at the account level.** Each account has one Stripe customer and **one subscription**, and therefore one invoice. The subscription has these items:
   - one `SERVICE_FEE` item ($1, never discounted);
   - one `LISTING` item per listing, priced at its tier, **including the default Silver listing**, which is charged the normal Silver price;
   - for shoppers, one `SHOPPER_ACCOUNT` item.
5. **The default Silver listing is an ordinary listing.** It's created automatically during business onboarding, billed at the Silver price, discounted the same way as any Silver listing, and can be upgraded, downgraded, or removed like any other (the account must keep at least one listing). Nothing in billing treats it specially.
6. **Discounts are applied per item.** Stripe discounts are attached to individual subscription items (the `LISTING` or `SHOPPER_ACCOUNT` items), limited to the tier or shopper-account products, and **never to the service-fee price**.
7. **Lapses apply to the whole account.** Because billing is per account, an unpaid invoice hides all of the account's listings.
8. **Ordering data is stored on each listing.** Each listing keeps its own `tier` and `tier_rank`, updated from its subscription item through `ListingEntitlementsChanged`.
9. **Tier changes are per listing, and only the owner can make them.** Each business account has exactly one user, its owner, who can upgrade any listing (immediately, prorated) or schedule a downgrade (at the end of the period, cancelable). Changing one listing's subscription item never touches the others.

## Consequences

**Positive**
- Businesses pay for visibility only where they want it, for example Platinum for the main location and Silver for the others.
- Every business gets a listing straight away, and launch discounts on Silver can lower the cost of joining.
- The entitlement engine gets simpler: one set of values per tier and one per account type.

**Negative and risks**
- An account whose listings are all discounted to $0 pays only the $1 fee, and standard card fees take about a third of it (MVP question Q1).
- Prorated upgrades, scheduled and canceled downgrades, and per-item discounts need careful testing (SPEC-BILL-01, AS-5 to AS-11a). They're covered by the PIT mutation targets in the `billing` module.
- Secret shopper selection needs a clear unit, accounts or listings (MVP question Q18).

## Alternatives considered

- **Keep account plans and add per-listing upgrades:** rejected. It creates two overlapping pricing mechanisms.
- **Make the first Silver listing free:** considered in an earlier draft of this ADR and rejected by the product owner. The default listing is charged like any other.

## Clarification (2026-09-30)

An earlier draft of this ADR, written the same day, treated the default Silver listing as free (a $0 "included" price with an allowance that moved between listings). The product owner clarified that **the default Silver listing is charged the Silver price, discounts apply to it the same way, and every listing can be upgraded or downgraded**. Decisions 4, 5, and 9 reflect that. Nothing had been implemented, so the ADR was corrected rather than superseded.
