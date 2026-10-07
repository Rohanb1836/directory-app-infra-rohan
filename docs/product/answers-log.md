# Answers Log

| | |
|---|---|
| **Version** | 1.0 |
| **Date** | 2026-10-06 |
| **Source** | Google Sheet "Ram questions 9-30-26" (answers to MVP questions Q1–Q15), and the linked "BPM - sales tax policy" document |
| **Purpose** | Records each answer, how it was interpreted, and where it was applied, so every document change can be traced back to the product owner's answer |

**Status key:** ✅ applied · 🟡 partly applied, follow-up needed · ❓ needs clarification · ➖ no change needed

---

## 1. Answers and how they were applied

| # | Question (short) | Answer (summary) | Interpretation | Status | Applied to |
|---|---|---|---|---|---|
| Q1 | Card fees on $1 invoices | Supports billing the fee annually, to lock in shoppers and listings. Accepts that acquiring members has a cost, which will be measured as BlackPages grows. | **While an account's listings or shopper price are discounted to $0, the $1 service fee is billed annually ($12).** Other card-fee costs are accepted as acquisition cost. | ✅ | MVP Q1 and risks; backlog 7.6; to-do T4 (◐); SPEC-BILL-02 (to write) |
| Q2 | Is Maps a Must? | Silver (L1) listings don't appear on the directory landing page, but do appear on the map for their category. Option to not show on the map, for online-only listings, set in the address options. A Drive file was attached. | **Maps are a Must.** New tier rule: `listing.landing_page` is No for Silver. Online-only listings, and owners who opt out, aren't shown on the map. | ✅ | MVP section 4.2 and Q2; SPEC-BILL-01 v0.6 (new key); backlog 4.4, 5.3, 5.7. **The attached Drive file couldn't be opened** (no access). |
| Q3 | Discounts never cover the fee | Confirmed ("X") | Already resolved | ➖ | — |
| Q4 | Email relay or live chat | No live chat envisioned. When visitors don't find what they're looking for, they type it in and are contacted when it's added. | **No live chat.** The email relay stays. New feature: category requests with "notify me when found". | ✅ | MVP Q4 and section 5.5; **new backlog story 4.8** (Should, Sprint 10); matches screen S39 and review finding R-27 |
| Q5 | Service area: cities, radius, or polygons | A list of cities is fine. A state's major metro area spans several cities. A threshold for adding a city may be discussed, based on responses from that city. | **Service area = a list of cities only.** Radius and polygons are dropped from the MVP. A city-adding threshold goes with demand tracking (T10). | ✅ | MVP Q5, A14, and out of scope; backlog 5.7 (5 → 3 points); System Overview v1.3 (data model); to-do T10 note |
| Q6 | Specialties and photos per tier | "Specialties? Do you mean categories?" Photos: L1 = 1, L2 = 3, L3 = 6. | **Photos: Silver 1, Gold 3, Platinum 6.** Specialties need a follow-up. | 🟡 | SPEC-BILL-01 v0.6 (section 4.2 and scenarios); MVP section 4.2; backlog 3.9; API Style Guide and Frontend Architecture examples |
| Q7 | Team access at launch | About the whole team attending an event in Arizona | Appears to answer a different question. **Already decided:** one user per business account (D20). | ➖ | MVP Q7 note |
| Q8 | Specialty URL pattern; state in URLs | The state in the URL isn't relevant. Didn't understand the first part. | **No state in URLs** (unchanged). The specialty URL pattern needs a follow-up. | 🟡 | MVP Q8 |
| Q9 | Threshold for indexing pages | Apply noindex tags, to keep the category structure for future growth while hiding it from search engines for now | **Confirms the noindex approach.** The threshold stays at 3 listings. | ✅ | MVP Q9; backlog question table |
| Q10 | Secret shopper incentives and number of businesses | The incentive is embedded in each listing's response, as an offer that guides any consumer. Listings that aren't being selected may need to change their message. A shopper can get a rebate from no more than 2 locations. | **The incentive is a rebate offered by each listing. A maximum of 2 listings per secret shopper.** This suggests shoppers **choose** listings based on the offers, which differs from the current design (the platform assigns listings). | 🟡 | MVP section 5.3, A7, and Q10; backlog 10.3 (rewritten); SPEC-REV-01 (to write) |
| Q11 | Can a business secret shopper review a competitor? | Agrees: no. A listed company can be a B2B secret shopper, and must buy in the company's name. | Confirmed, plus a new rule about buying in the company's name | ✅ | MVP section 5.3 and Q11; backlog 10.1, 10.3, 10.5 |
| Q12 | Sales tax | No Arizona state sales tax on advertising, but some municipalities charge city tax, **including Phoenix**. Other states have registration thresholds, some as low as 200 sales. | **Tax is needed at launch** (Phoenix city tax), and thresholds in other states must be tracked | ✅ | MVP section 1.3 and Q12; backlog **7.13 becomes a Must, 8 points, Sprint 5**; to-do T8 (◐) |
| Q13 | Accounts and owners | The product owner owns PayPal and Stripe. No other accounts. | **Stripe confirmed** (ADR-0009 accepted). **AWS and Postmark accounts don't exist yet.** PayPal: an open question. | 🟡 | ADR-0009 (Accepted), ADR-0014, ADR-0015, ADR index; MVP Q13 |
| Q14 | Staff MFA flow | Needs a discussion | Still open | ❓ | — |
| Q15 | Launch cities; Navajo Nation time zone | Tucson, Phoenix, Mesa, Glendale, Scottsdale, Tempe, Goodyear, Gilbert, Chandler, Peoria, Surprise. Tribal-land time zones aren't of consequence. | **11 launch cities.** Flagstaff is dropped, and Goodyear and Surprise are added. No time-zone override for individual cities. | ✅ | MVP section 1.3 and Q15; backlog 1.2, 1.5 |

---

## 2. Follow-up questions for the product owner

| ID | Question | Why it matters | Needed by |
|---|---|---|---|
| F-1 (Q6) | **Specialties** are a third level under a subcategory, for example *Plumbers > Residential > Tankless water heaters*. A listing can tag a few, and visitors can filter by them and land on pages such as "tankless water heaters in Phoenix". **Keep them?** If yes, how many per tier (proposed: Silver 3, Gold 5, Platinum 10)? | Affects stories 4.6, 4.7, 5.5, 6.6, screen S38, and the UI review finding R-21 | Sprint 1 refinement |
| F-2 (Q8) | For a page like "tankless water heaters in Phoenix", which address do you prefer: **A)** `/directory/plumbers/phoenix/tankless-water-heaters` (under the category) or **B)** `/directory/tankless-water-heaters/phoenix` (shorter)? | Search-engine pages and routes (6.6) | Before Sprint 4 |
| F-3 (Q10) | Do selected secret shoppers **choose** up to 2 listings from the listings' rebate offers, or does the platform **assign** them? Who pays the rebate (the business directly, or through BlackPages), and how is it confirmed? Is the limit of 2 per month? | Changes the secret shopper design (stories 10.3 and 10.5, screen S32, SPEC-REV-01) | Before SPEC-REV-01 drafting (Sprint 6) |
| F-4 (Q13) | Who will **create and own the AWS and Postmark accounts**? Should **PayPal** be offered at checkout, alongside Stripe? | AWS is needed for staging in **Sprint 0**. PayPal affects ADR-0009 and screen S11 (review finding R-23). | AWS: **now**. PayPal: before Sprint 5 |
| F-5 (Q14) | Schedule the discussion on the staff MFA flow | Story 2.21 | Before Sprint 10 |
| F-6 (Q2) | **Share the Drive file** attached to the Q2 answer, as an upload or with link access | It may contain rules for the landing page or map not yet captured | This week |
| F-7 (Q1) | Should **annual billing** be offered to everyone (to-do T4), or only for the service fee during $0 offers? | SPEC-BILL-02 | Before Sprint 3 |

---

## 3. Documents updated on 2026-10-06

| Document | New version | Changes |
|---|---|---|
| MVP Definition | 1.10 | Launch cities, tax, maps confirmed, photo limits, landing-page and map rules, service areas as a list of cities, secret shopper rebates and B2B rules, no live chat, answers to Q1–Q15 |
| Product Backlog | 1.6 | Stories 1.2, 1.5, 3.9, 4.4, 5.3, 5.7, 7.6, 7.13, 10.1, 10.3, and 10.5 updated. **New story 4.8.** Story 7.13 is now a Must in Sprint 5 (Sprint 5 goes from 39 to 47 points). |
| SPEC-BILL-01 | 0.6 | Photo limits 1/3/6, new key `listing.landing_page`, scenarios updated |
| System Overview | 1.3 | Service-area data model (cities only) |
| ADR-0009 | Accepted | Stripe confirmed. PayPal question noted. |
| ADR-0014, ADR-0015 | Proposed (note) | No AWS or Postmark account yet |
| To-Do List | 1.1 | T4 and T8 in progress, T10 note |
| API Style Guide, Frontend Architecture | — | Examples updated to the new photo limits |
| UI Screen Stories Review | 1.1 | Addendum with the answers that affect the screens |
| HANDOFF | — | Decisions D25–D29, updated open questions |

**Sprint load:** Sprint 5 is now 47 points, above the 35–45 range, because tax became a Must. Consider moving 13.1 (home page, 3 points) or 11.1 (tracking, 8 points) into Sprint 4 or 6 during refinement.
