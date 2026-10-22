# Bank alert interpretation

Use these synthetic examples to distinguish transaction states, not as universal parsing templates. Bank wording, sender names, currencies and date formats vary. Inspect representative alerts before building a parser.

| Alert family | Synthetic example | Treatment |
| --- | --- | --- |
| Purchase | `Purchase at SAMPLE CAFE for USD 12.50 on 2026-01-02 has been authorized.` | Purchase authorization; not proof of final settlement. |
| Decline | `Payment of EUR 10.00 at SAMPLE SERVICE was declined.` | Failed attempt; exclude from spending. |
| Authentication | `Your OTP for payment of USD 12.50 is [REDACTED].` | Exclude before export or logging, even though it contains an amount. |
| Approval request | `Transfer of GBP 30.00 requested. Use code [REDACTED] to approve.` | Authentication request; not a completed transfer. |
| ATM | `Cash withdrawal of EUR 50.00 at SAMPLE ATM.` | Cash withdrawal, separate from purchases. Omit receipt links. |
| Transfer acknowledgement | `Your transfer request for USD 20.00 was received.` | Request acknowledgement; direction and settlement may be unverified. “Received” does not establish income. |
| Completed transfer | `Transfer of USD 20.00 to beneficiary completed.` | Outgoing transfer when wording establishes direction and completion; do not count as a merchant purchase or assume its purpose. |
| Cancellation | `Your transaction at SAMPLE has been cancelled.` | Review item. No automatic subtraction without an amount and matching authorization. |
| Coverage notice | `Account SMS alerts have been discontinued.` | Coverage gap. Card alerts may continue independently. |
| Promotion | `Spend USD 100 to earn cashback up to USD 10.` | Advertising; neither spending nor a received refund. |

## Classification

- Classify merchant descriptors by their meaning: groceries, dining, food delivery, transport, utilities, health, education, shopping and digital services are useful starting categories. Adapt to observed transactions.
- Match specific services before broader brands, such as food delivery before ride-hailing. A payment processor name alone may not identify the underlying merchant or category.
- Group clear spelling/location variants for brand subtotals while keeping original descriptors. Leave uncertain merchants unclassified rather than inferring from personal preferences.
- Distinguish recurring-charge candidates from confirmed subscriptions. Repeated retries, top-ups and usage-based services can resemble subscriptions.

## Extraction pitfalls

- Sender identifiers can contain carriage returns, mixed case or whitespace. Confirm additional identifiers belong to the requested bank before including them.
- In macOS Messages, searching `message.text` alone can miss messages stored only in `attributedBody`. Binary substring search does not replace validated decoding and may differ in case handling.
- Join tables and overlapping exports can duplicate source records. Count unique source messages before aggregation. Distinct alerts can refer to the same economic event, such as authorization and settlement: link them where evidence permits and avoid counting both as separate purchases.
- Dates such as `01/02/26` are ambiguous without a locale. Do not assume date order or invent a time for date-only alerts. Use transaction dates for expense buckets and retain receipt timestamps separately when available.
- Currency symbols can be ambiguous. Determine the currency from explicit codes or reliable account context before aggregation; flag unresolved amounts instead of combining them.
- First/last months and the current day can be incomplete. Retention, synchronization and disabled alerts can create additional gaps.
- No-alert fees, cash purchases, missing refunds and settled foreign-exchange charges require statement reconciliation. Alert totals alone do not establish complete cash flow.
