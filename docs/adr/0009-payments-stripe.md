# ADR-0009: Payments use Stripe Billing

- **Status:** Accepted (2026-10-06: the product owner owns the Stripe account, per the answer to Q13. Whether to also offer PayPal is an open question.)
- **Date:** 2026-09-27 (amended 2026-09-30: billing items follow ADR-0017, with account types and a tier per listing; discounts never apply to the service fee)

## Decision
- Card details are entered through Stripe Checkout or Elements, so no card data touches our systems and we stay within the PCI SAQ-A scope.
- There is one Stripe customer and **one subscription for each business or shopper account**, which produces one consolidated invoice (story 7.5). The subscription has one item for the $1 service fee, one item per listing at its tier's price (including the default Silver listing), and for shoppers one shopper-account item. See ADR-0017.
- Discounts use Stripe coupons (percentage up to 100% or a fixed amount; once, repeating, or forever). They're attached to individual subscription items and restricted to **listing tier and shopper-account products only**. **Coupons never apply to the service-fee price.** Promotion codes cover discounts entered by the customer. Automatic campaigns apply the coupon on the server. Each listing item, and each shopper-account item, can carry one discount.
- Because the $1 service fee is always charged, **every account has a charge of at least $1**, so Checkout always collects a card.
- Seven days before a discount ends, a scheduled job emails the member with the new monthly total.
- Listing tier upgrades, and listings added mid-period, are prorated by Stripe. Tier downgrades are scheduled for the end of the billing period and can be canceled until then.
- Webhooks are verified by their signature and processed **idempotently**, using a unique `payment_event.stripe_event_id`.
- Failed payments are retried by Stripe (dunning), and our webhook handlers update the subscription status in our database.

## Consequences
- Stripe provides proration, dunning, invoices, and coupons, so we don't build them.
- Per-transaction card fees make a $1 charge on its own uneconomical. That happens when all of an account's listings are discounted to $0, or when a shopper's account price is discounted to $0, so MVP question Q1 (annual billing of the fee) needs a decision.
