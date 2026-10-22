# ComBank alert interpretation

These synthetic fixtures preserve ComBank alert wording while using fictional merchants, amounts, dates and masked identifiers. They describe format families, not a particular customer's history. Verify current formats before parsing.

| Alert family | Synthetic example | Treatment |
| --- | --- | --- |
| Purchase | `Dear Cardholder, Purchase at SAMPLE CAFE COLOMBO LK for LKR 1,234.00 on 02/01/26 09:30 AM has been authorised on your debit card ending #0000.` | Purchase authorization; not proof of final settlement. |
| Decline | `Dear Cardholder, your card was declined due to insufficient funds. The attempted transaction amount was USD 12.00 at SAMPLE SERVICE US on 03/01/26 08:30 PM.` | Failed attempt; exclude from spending. |
| Authentication | `Your OTP at Merchant 'SAMPLE' for LKR 1,234.00 is [REDACTED]` | Exclude before export or logging, even though it contains an amount. |
| Approval request | `ComBank Digital-Transfer to Other Banks LKR 250.00 attempted. Please use code [REDACTED] to approve.` | Authentication request; not a completed transfer. |
| ATM | `Withdrawal at SAMPLE ATM COLOMBO LK for LKR 4,000.00 on 04/01/26 05:30 PM from card ending #0000.` | Cash withdrawal, separate from purchases. Omit appended receipt links. |
| Transfer acknowledgement | `Transfer within ComBank in the amount of LKR 1,200.00 was received on 05/01/2026 from the ComBank Digital.` | Request acknowledgement; direction and settlement unverified. “Received” does not establish income. |
| Other-bank transfer | `Transfer to Other Banks in the amount of LKR 250.00 was received on 06/01/2026 from the ComBank Digital.` | Same ambiguity; keep separate from purchases. |
| Cancellation | `YOUR TRANSACTION AT SAMPLE ON YOUR CARD ENDING WITH 0000 HAS BEEN CANCELLED.` | Review item. No automatic subtraction without an amount and matching authorization. |
| Coverage notice | `SMS Alert Facility on your Account No. [REDACTED] was discontinued on 2026-01-07 due to insufficient funds ...` | Coverage gap. Card alerts may continue independently. |
| Promotion | `Get 10% cashback up to Rs.900 when you complete 3 bill payments ...` | Advertising; neither spending nor a received refund. |

## Classification

- Classify merchant descriptors by their meaning: groceries, dining, food delivery, transport, utilities, health, education, shopping and digital services are useful starting categories. Adapt to observed transactions.
- Match specific services before broader brands, such as food delivery before ride-hailing. A payment processor name alone may not identify the underlying merchant or category.
- Group clear spelling/location variants for brand subtotals while keeping original descriptors. Leave uncertain merchants unclassified rather than inferring from personal preferences.
- Distinguish recurring-charge candidates from confirmed subscriptions. Repeated retries, top-ups and usage-based services can resemble subscriptions.

## Extraction pitfalls

- Sender identifiers can contain carriage returns, mixed case or whitespace. Confirm additional identifiers belong to the ComBank before including them.
- In macOS Messages, searching `message.text` alone can miss messages stored only in `attributedBody`. Binary substring search does not replace validated decoding and may differ in case handling.
- Join tables and overlapping exports can duplicate source records. Count unique source messages before aggregation. Distinct alerts can refer to the same economic event, such as authorization and settlement: link them where evidence permits and avoid counting both as separate purchases.
- ComBank purchase alerts commonly use `dd/mm/yy` with 12-hour times; transfer acknowledgements may use `dd/mm/yyyy` without a time. Verify the observed format and do not invent a time for date-only alerts. Use transaction dates for expense buckets and retain receipt timestamps separately when available.
- Currency symbols can be ambiguous. Determine the currency from explicit codes or reliable account context before aggregation; flag unresolved amounts instead of combining them.
- First/last months and the current day can be incomplete. Retention, synchronization and disabled alerts can create additional gaps.
- No-alert fees, cash purchases, missing refunds and settled foreign-exchange charges require statement reconciliation. Alert totals alone do not establish complete cash flow.
