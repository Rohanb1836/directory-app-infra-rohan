# Feature Spec: Survey App Integration and Survey Insights

| | |
|---|---|
| **Spec ID** | SPEC-SRV-01 |
| **Version** | 0.1 (draft) |
| **Date** | 2026-10-06 |
| **Status** | Draft for review by the product owner, the BlackPages tech leads, and the survey app team |
| **Owner** | Product owner |
| **Decisions** | ADR-0022 (integration), ADR-0021 (analytics), ADR-0008 (location scoping) |
| **Backlog** | Epic E18, stories 18.1–18.18 |
| **Related** | Survey app technical specification (`survey-app-svc`), SPEC-BILL-01 (entitlements), System Overview, API Style Guide |

---

## 1. Problem and goals

The survey app sends scheduled surveys to members and collects their answers. Today the answers go to Brilliant Directories through MariaDB, which is being switched off. BlackPages needs to:

1. **Become the survey app's source of locations and recipients**, replacing MariaDB.
2. **Receive survey responses** reliably, without coupling the two databases.
3. **Show survey results** to businesses, shoppers, the public, and admins, with detail by tier and audience, and **without exposing any respondent**.

**Out of scope:**
- secret shopper evaluation surveys, which stay in BlackPages and are covered in SPEC-REV-01 (open question OQ-S3);
- surveys that businesses create themselves (screen S43, not approved);
- changes to how surveys are created and scheduled in the survey app.

---

## 2. Definitions

| Term | Meaning |
|---|---|
| **Survey app** | The separate `survey-app-svc` application and its PostgreSQL database `survey_app_db` |
| **Site** | A survey app site. **Equivalent to a BlackPages location (a US state)**, one to one. |
| **Recipient** | A BlackPages business or shopper account eligible to receive surveys for a site |
| **Survey log** | One sending of a survey (`Survey_Log`). Its **question snapshot** (`Survey_Log_Questions`) records the exact questions sent. |
| **Response** | One answer to one question (`Survey_Response`), within a **submission** (one person's reply to one survey log) |
| **Survey insights** | Charts of survey results in BlackPages |
| **Minimum group size (k)** | The smallest number of distinct respondents a chart group may show. **k = 5.** |

---

## 3. How the data maps

| Survey app | BlackPages | Rule |
|---|---|---|
| `Site` | `location` | One to one. The survey app stores **`location_id` (UUID, unique)**. BlackPages is the source of the name, slug, status, and time zone. |
| `Site.active` | `location.status` | `active = true` only while the location is ACTIVE |
| `Site.live` | (survey app setting) | Can be `true` only while the location is ACTIVE. While `false`, surveys go only to admins (test mode). |
| `Site.database_url` | — | **Removed.** The BlackPages API address is a single application setting. |
| `Site.time_zone` *(new)* | `location.time_zone` | Copied from BlackPages. **Used when working out survey dates.** |
| `Users.directory_user_id` | The business account ID or shopper account ID | **Changes from a number to a UUID** (stored as `uuid` or `varchar(36)`) |
| `Users.type` (`company` / `individual`) | Account type `BUSINESS` / `SHOPPER` | `company` = BUSINESS, `individual` = SHOPPER |
| `Users.site_id` | The account's **home location** | Each recipient has one site (BR-SI-03) |
| `Users.active` (0 / 2 / 5) | Account status, plus survey consent | `2` (active) = account in good standing **and** survey consent given. `0` = not eligible (lapsed, suspended, or no consent). `5` = deleted (anonymized). |
| `Users.email`, `phone_number` | Account email. **Phone isn't shared.** | The survey app only needs an email address to send surveys |

---

## 4. Business rules

| ID | Rule |
|---|---|
| **BR-SI-01** | The survey app is the **owner** of surveys, questions, and responses. BlackPages never changes them. |
| **BR-SI-02** | BlackPages is the **owner** of locations and recipients. The survey app never creates its own sites or users for BlackPages members. |
| **BR-SI-03** | A recipient belongs to **one** site: their **home location**. A business with listings in other states (to-do T9) is surveyed only in its home location in the MVP. |
| **BR-SI-04** | **Only accounts that have given survey consent** are recipients. Consent is captured at onboarding and can be withdrawn in account settings (open question OQ-S4). Withdrawing stops future surveys, but doesn't delete past answers. |
| **BR-SI-05** | If a recipient changes their home location, they move to the new site. **Past answers stay with the site and location where they were given.** |
| **BR-SI-06** | Survey dates are worked out in the **site's time zone** (Arizona: `America/Phoenix`) |
| **BR-SI-07** | **Minimum group size:** no chart, table, or export outside the admin console shows a value based on **fewer than 5 distinct respondents**. Such groups are shown as "Not enough responses yet". |
| **BR-SI-08** | **Free-text answers are never public.** Whether businesses see them, and only after admin approval, is open question **OQ-S2**. Until it's decided, businesses don't see free text. |
| **BR-SI-09** | **Respondents are never identified** to anyone except BlackPages staff, and staff only see account IDs in the admin console |
| **BR-SI-10** | Results always use the **question wording that was actually sent** (the survey log's question snapshot), even after a question has a new version |
| **BR-SI-11** | When an account is **deleted** (story 2.5), BlackPages removes its pseudonymous responses from its copy, and tells the survey app to **anonymize** them. Results already summarized are kept, because they're anonymous. |
| **BR-SI-12** | Survey insights are **scoped by location** (ADR-0008). Site operators see admin results only for their assigned locations. |
| **BR-SI-13** | The level of survey insights a business sees comes from its **highest active listing tier** (open question OQ-S1 confirms this) |

---

## 5. What each audience sees

New entitlement keys are added to SPEC-BILL-01, sections 4.1–4.3:

| Key | Source | Values |
|---|---|---|
| `listing.survey_insights.level` | Listing tier | Silver **BASIC**, Gold **STANDARD**, Platinum **ADVANCED**. The account uses its highest active listing (BR-SI-13). |
| `account.survey_insights.shopper` | Account type | Shopper: **Yes** |

| Audience | Level | What they see |
|---|---|---|
| **Public** | — | **A few charts for each location:** headline results for selected questions, chosen by admins (`is_public` flag, set in BlackPages), shown for the location and, where there are enough respondents, by city. Totals only. No free text. |
| **Shopper** | — | **Results of surveys they took part in:** the overall result for each question, and how their own answer compares with the community (shown only to them). No breakdown by business or category. |
| **Business** | BASIC (Silver) | Overall results for each survey sent to businesses in their location, as the latest result per question |
| | STANDARD (Gold) | BASIC, plus breakdowns by **city** and **respondent type** (businesses and shoppers), plus results for **shopper surveys** in their location |
| | ADVANCED (Platinum) | STANDARD, plus **trends over time** (same question across survey logs), breakdown by **category** (their own categories compared with the location), and export of the summarized results as CSV |
| **Admin and site operator** | — | Everything, within their location scope: response rates by survey log, all breakdowns, small groups (marked as small), free text (with moderation if OQ-S2 allows it), and comparison with the MariaDB copy during the parallel run (section 10) |

**How each question type is charted**

| Question type | Chart |
|---|---|
| **Scale** (`min_scale` to `max_scale`, with `scale_unit`) | A distribution bar chart, the median and average (with the unit, for example "days"), and a trend line at ADVANCED |
| **Multiple choice** | Horizontal bars showing the share for each answer, ordered as in the answer key |
| **Boolean** | A share bar for Yes and No |
| **Text** | Admin console only (BR-SI-08), or approved excerpts if OQ-S2 allows them |

---

## 6. APIs

All integration endpoints are under **`/api/integration/v1`** in both apps, are **read-only** (except the anonymize request), use **cursor pagination**, and accept **only Keycloak client-credentials bearer tokens** carrying the permission shown (API Style Guide, section 3.1). Permissions are **Keycloak client roles**: `survey.*` on the `survey-app-svc` client, and `directory.*` on the `blackpages-integration-api` client. They're granted to the service accounts `blackpages-survey-reader` and `survey-app-svc` (realm file `blackpages-realm.json`).

### 6.1 Provided by BlackPages (`directory-app-svc`), called by the survey app

| Endpoint | Scope | Returns |
|---|---|---|
| `GET /api/integration/v1/locations?updatedSince=…` | `directory.locations.read` | `{ items: [{ locationId, slug, name, stateCode, status, timeZone, updatedAt }], nextCursor }` |
| `GET /api/integration/v1/survey-recipients?locationId=…&updatedSince=…&cursor=…` | `directory.recipients.read` | `{ items: [{ recipientId, accountType: BUSINESS \| SHOPPER, email, status: ACTIVE \| NOT_ELIGIBLE \| DELETED, surveyConsent, homeLocationId, updatedAt }], nextCursor }`. **Deleted accounts appear as `DELETED` with no email**, so the survey app can anonymize them. |

### 6.2 Provided by the survey app (`survey-app-svc`), called by BlackPages

| Endpoint | Scope | Returns |
|---|---|---|
| `GET /api/integration/v1/surveys?updatedSince=…` | `survey.read` | Surveys: `surveyId`, `siteId`, `locationId`, `title`, `type` (company or individual), `status`, `isIntake` |
| `GET /api/integration/v1/survey-logs?updatedSince=…&cursor=…` | `survey.read` | Survey logs: `surveyLogId`, `surveyId`, `locationId`, `status`, `distributedAt`, `recipientCount`, and the **question snapshot**: questions with `questionId`, text, type, scale settings and unit, period label, display order, and answer keys |
| `GET /api/integration/v1/responses?cursor=…&limit=500` | `survey.read` | `{ items: [{ changeSeq, op: UPSERT \| DELETE, submissionId, surveyLogId, locationId, recipientId, submittedAt, answers: [{ questionId, answerId?, value? , text? }] }], nextCursor }`. Ordered by a **change sequence**, so nothing is missed or repeated. Anonymized submissions arrive as `DELETE` with no `recipientId`. |
| `POST /api/integration/v1/respondents/{recipientId}/anonymize` | `survey.respondents.anonymize` | 202. Removes the link between the recipient and their submissions, and their email, and keeps the anonymous answers (BR-SI-11). Safe to repeat. |

**Shared rules**
- Errors use Problem Details (RFC 9457, which is compatible with the RFC 7807 the survey app uses today).
- IDs are UUIDs for BlackPages objects and numbers for survey app objects. Both are strings in JSON.
- Timestamps are ISO 8601 in UTC.
- Cursors are opaque.
- Rate limit: 60 requests a minute for each client.

---

## 7. Synchronization jobs

| Job | Runs in | Schedule | What it does |
|---|---|---|---|
| **Location sync** | Survey app | Daily, plus on demand | Pulls `/locations`, creates or updates `Site` rows (name, `location_id`, `time_zone`, `active`). **A new site starts with `live = false`.** |
| **Recipient sync** | Survey app | Each site's `user_sync_frequency_minutes` | Pulls `/survey-recipients` for the site, then adds, updates, deactivates, or **anonymizes** `Users` rows |
| **Survey and log sync** | BlackPages (`survey-insights`) | Hourly | Pulls `/surveys` and `/survey-logs` into `survey_def`, `survey_log_ref`, and `survey_question_snapshot` |
| **Response sync** | BlackPages (`survey-insights`) | Hourly | Pulls `/responses` from the stored cursor into `survey_response_copy`, applies deletions, then rebuilds the summaries for the survey logs affected |
| **Anonymize request** | BlackPages (outbox handler for `UserDeleted`) | On event | Calls `POST /respondents/{recipientId}/anonymize`, retrying with backoff |

All jobs use ShedLock, record their cursor and status, and raise an alert after 3 failed runs in a row.

---

## 8. BlackPages data (`survey-insights` module)

| Table | Contents | Retention |
|---|---|---|
| `survey_def` | survey ID, location ID, title, type, status | While the survey exists |
| `survey_log_ref` | survey log ID, survey ID, location ID, distributed time, recipient count | 25 months |
| `survey_question_snapshot` | survey log ID, question ID, text, type, scale settings, unit, display order, answer keys (JSON), `is_public` (set by BlackPages admins) | 25 months |
| `survey_response_copy` | submission ID, survey log ID, location ID, **recipient ID (pseudonymous)**, account type, city ID and category IDs **at the time of the response**, submitted time, answers (JSON) | **13 months**, matching raw activity events (System Overview 8.14.5). Also removed on account deletion (BR-SI-11). |
| `survey_result_summary` | survey log ID × question ID × slice (overall, city, respondent type, category) × answer or bucket: respondent count, share, median, average | 25 months |
| `survey_sync_state` | Each job's cursor, last run, status, and error | — |

- **Small groups:** groups below k = 5 are **stored**, so admins can see them, but **marked**. Only admin endpoints return them (BR-SI-07).
- **City and category are copied at the time of the response**, so results don't change when a business later moves or recategorizes.

### BlackPages API for the UI (session-based, as in the API Style Guide)

| Endpoint | Access |
|---|---|
| `GET /api/public/locations/{locationSlug}/survey-highlights` | Public (BR-SI-07, BR-SI-08) |
| `GET /api/survey-insights/surveys?locationId=…` | Business or shopper, filtered by their entitlements |
| `GET /api/survey-insights/survey-logs/{surveyLogId}/results?slice=CITY\|RESPONDENT_TYPE\|CATEGORY` | Business (slices allowed by level) or shopper (overall only) |
| `GET /api/survey-insights/questions/{questionId}/trend` | Business at ADVANCED |
| `GET /api/survey-insights/survey-logs/{surveyLogId}/export.csv` | Business at ADVANCED (summaries only) |
| `GET /api/admin/survey-insights/…` and `PUT /api/admin/survey-insights/questions/{questionId}/public` | Admin and site operator (BR-SI-12) |

---

## 9. Screens (`directory-app-ui`)

| Screen | Who | Content |
|---|---|---|
| **S50 Survey insights (business)** | Business owner | A list of surveys. Each one's results as charts by question type (section 5), with breakdown tabs, a trend view, and CSV export depending on level. Locked tabs show the tier that includes them. |
| **S51 Survey insights (shopper)** | Shopper | The surveys they answered: overall results, and "your answer compared with the community" |
| **S52 Public survey highlights** | Public | Location-level charts for questions marked public, shown on each state's directory pages and a dedicated `/insights/{locationSlug}` page |
| **S53 Survey analytics (admin)** | Admin, site operator | Response rates, all slices including small ones (marked), free text (if allowed), choosing which questions are public, and sync health and parallel-run comparison |

Every screen needs a **"Not enough responses yet"** state, a **no-surveys** state, and **error** and **locked** states.

---

## 10. Retiring the MariaDB sync (rollout)

| Phase | Survey app | BlackPages |
|---|---|---|
| **1. Build** | Integration API (18.6); sites from locations (18.4); recipients from BlackPages (18.5); Keycloak client (18.3); email limit fixed (18.15) | Integration API for locations and recipients (18.1, 18.2); `survey-insights` module (18.7–18.9); screens (18.10–18.13) |
| **2. Run in parallel** | **MariaDB sync stays on.** Both destinations receive responses. | A daily comparison of counts by survey log (admin screen S53). Any difference raises an alert. |
| **3. Switch off** (when Brilliant Directories closes) | `Site.active_sync = false`. MariaDB jobs disabled (18.16). | — |
| **4. Clean up** | The Synchronization context's MariaDB code, the `Response_Sync_Log` direction, and the `database_url` column removed (18.16) | — |

---

## 11. Changes to the survey app (summary)

| Area | Change | Story |
|---|---|---|
| `Site` | Add `location_id` (unique) and `time_zone`. Remove `database_url`. Survey dates use the site's time zone. | 18.4 |
| `Users` | `directory_user_id` becomes a UUID. The source becomes the BlackPages recipients API. Consent is honored. Deleted accounts are anonymized. | 18.5 |
| Integration API | New `/api/integration/v1` endpoints (section 6.2), with a `change_seq` column on submissions and responses, and records of deletions | 18.6 |
| Security | Keycloak resource server for `/api/integration/**`, and a client to call BlackPages | 18.3 |
| Email | Raise the daily limit: a paid Mailgun plan, or Postmark (ADR-0015) | 18.15 |
| Platform and links | Spring Boot 4.1 and the Boot 4 starter names (ADR-0018). Survey link tokens stored **hashed**, with an **expiry**, and kept out of logs. | 18.18 |
| Admin login | Move to Keycloak (staff roles, MFA). Retire its own JWT stored in `localStorage`. | 18.17 (Should) |
| MariaDB | Run in parallel, then retire | 18.16 |

---

## 12. Acceptance scenarios

| # | Given | When | Then |
|---|---|---|---|
| AS-1 | Arizona is ACTIVE in BlackPages | The location sync runs | The survey app has a site for Arizona with its `location_id` and `America/Phoenix`, and `live = false` |
| AS-2 | A shopper in Phoenix has given survey consent | The recipient sync runs | The survey app has an `individual` user for that site, with status `2` |
| AS-3 | That shopper withdraws consent | The next recipient sync runs | The user becomes `0`, and receives no further surveys |
| AS-4 | A survey log was answered by 12 Phoenix businesses and 3 Tucson businesses | A Gold business in Phoenix views it by city | Phoenix is shown. **Tucson shows "Not enough responses yet"** (3 is fewer than 5). |
| AS-5 | The same survey log | A Silver business views it | Only overall results. The city and respondent-type tabs are locked, showing "Available for Gold". |
| AS-6 | A question gets a new version after a survey was sent | Results for the earlier log are viewed | The **wording that was sent** is shown (BR-SI-10) |
| AS-7 | An account is deleted in BlackPages | The outbox handler runs | BlackPages removes the copied responses, the survey app anonymizes them, and the summaries still show the anonymous counts |
| AS-8 | The survey app is down | A business opens survey insights | Results load from BlackPages' summaries. Sync health shows the failed pull in the admin console. |
| AS-9 | A response sync stops halfway | It runs again | It carries on from the stored cursor, with no gaps or duplicates |
| AS-10 | A free-text question | Results are viewed by the public, a business, or an admin | Public: never shown. Business: hidden (until OQ-S2 is decided). Admin: shown. |
| AS-11 | The parallel run | The daily comparison finds different submission counts | An alert is raised, and S53 shows the survey log with the difference |
| AS-12 | A request to `/api/integration/v1/responses` without a valid Keycloak token, or without the `survey.read` scope | — | 401 or 403 |

---

## 13. Open questions

| ID | Question | Proposed answer | Needed by |
|---|---|---|---|
| OQ-S1 | How detailed a business's view is when it has listings on several tiers | Its **highest** active tier (BR-SI-13) | Before story 18.9 |
| OQ-S2 | Do businesses ever see free-text answers? | No for the MVP. Possibly approved excerpts later. | Before story 18.10 |
| OQ-S3 | Should secret shopper evaluation surveys move to the survey app? | **No.** They stay in BlackPages, tied to the listing and the review unlock rule. Only the question format is reused. | Before SPEC-REV-01 |
| OQ-S4 | Survey consent: requested at onboarding, can be opted out of, and covered in the privacy policy and terms (T1, T2)? | Yes | Before Sprint 8 |
| OQ-S5 | Which team owns the survey app changes, its repository name, and whether it joins the GitHub project | — | Now |
| OQ-S6 | Survey insights per location only, or also comparisons across states once more states are live? | Per location in the MVP | Later |
| OQ-S7 | Should businesses with cross-state listings (T9) be surveyed in every state where they have listings? | No. Home location only (BR-SI-03). | With T9 |
