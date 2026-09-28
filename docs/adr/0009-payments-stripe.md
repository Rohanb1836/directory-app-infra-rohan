# ADR-0009: Payments use Stripe Billing

- **Status:** Proposed (the product owner needs to confirm Stripe and who owns the account)
- **Date:** 2026-09-27 (amended: no free plan; discounts apply to plan prices and never to the service fee)

## Decision
- Card details are entered through Stripe Checkout or Elements, so no card data touches our systems and we stay within the PCI SAQ-A scope.
- There is one Stripe customer for each business account or shopper. Each subscription has separate **items** for the plan, each add-on location, and the $1 service fee, which produces one consolidated invoice (story 7.5).
- Discounts use Stripe coupons (percentage up to 100% or a fixed amount; once, repeating, or forever). They are restricted to **plan and add-on-location products only**. **Coupons never apply to the service-fee price.** Promotion codes cover discounts entered by the customer. Automatic campaigns apply the coupon on the server. Only one discount can apply to each subscription.
- Because the $1 service fee is always charged, **every subscription has a charge of at least $1**, so Checkout always collects a card.
- Seven days before a discount ends, a scheduled job emails the member with the new monthly total.
- Upgrades and downgrades are prorated by Stripe.
- Webhooks are verified by their signature and processed **idempotently**, using a unique `payment_event.stripe_event_id`.
- Failed payments are retried by Stripe (dunning), and our webhook handlers update the subscription status in our database.

## Consequences
- Stripe provides proration, dunning, invoices, and coupons, so we don't build them.
- Per-transaction card fees make a $1 fee charged on its own uneconomical, which is why the fee is always part of a consolidated invoice.
