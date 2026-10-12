# ADR-0021: Our own pipeline for product analytics; PostHog is optional, for internal use only

- **Status:** Accepted
- **Date:** 2026-10-06
- **Related:** ADR-0010 (async processing), ADR-0011 (analytics events table), ADR-0020 (backend events and the UI), System Overview section 8.14, API Style Guide section 12.2, backlog stories 11.1, 11.2, 11.5, and 12.x

## Context

BlackPages records website activity (views, searches, clicks, contact reveals, map use) for two purposes:

1. **Customer-facing analytics.** Each listing's dashboard is scoped by its tier (SPEC-BILL-01, section 4.4), the admin dashboard tracks revenue and activity, and public charts show what's popular. These are **features businesses pay for**, with BlackPages-specific rules: per-listing metrics, analytics depth and history by tier, and a minimum of 5 listings before showing comparisons.
2. **Internal product analytics.** The team needs to see where users drop out of onboarding and checkout, find usability problems, and test pricing wording.

We considered a hosted tool, **PostHog**, for both purposes. PostHog bundles product analytics, session replay, feature flags, A/B tests, and surveys, with a free monthly tier.

## Decision

1. **Customer-facing analytics use our own pipeline:** `POST /api/public/events`, the `activity_event` table, and summary tables in the `blackpages` database (System Overview section 8.14; API Style Guide section 12.2). The data, its definitions, retention, and deletion are fully under our control.
2. **PostHog is optional, and for internal use only** (backlog story 11.5, a Could, **unscheduled**). If adopted:
   - **PostHog Cloud**, not self-hosted;
   - loaded **only after cookie consent**;
   - **no emails or names** sent;
   - **session replay with text and form fields masked**;
   - automatic event capture tuned down to control volume;
   - events sent **once** from the frontend's analytics code, using the same event names (story 0.5);
   - added to the privacy policy as a data processor (T1).
3. **No customer-facing number ever depends on PostHog.**

## Consequences

**Positive**
- Paid features run on our own tested data, with no vendor dependency, rate limits, or per-event costs.
- Deleting and anonymizing data (story 2.5) is simple.
- The team can still get funnels, replay, and A/B tests cheaply later, without changing the product pipeline.

**Negative**
- We build and run the ingestion, summary tables, and dashboards ourselves (stories 11.1, 11.2, and 12.x).
- If PostHog is adopted, there are two analytics stores. Their numbers will differ slightly (consent, bot filtering, sampling), and **ours is the source of truth** for anything shown to customers.

## Alternatives considered

| Option | Reason rejected |
|---|---|
| PostHog for everything, including customer dashboards | Paid features would depend on a vendor's query API, limits, and pricing, and the per-listing, per-tier rules would be harder to implement |
| Self-hosted PostHog | A much heavier analytics stack than our small AWS setup can justify at this stage |
| No internal analytics tool | Possible for the MVP. Story 11.5 keeps the option open without committing to it. |
