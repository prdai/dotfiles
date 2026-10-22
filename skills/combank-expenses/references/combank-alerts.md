# ComBank alert interpretation

These are synthetic examples of observed alert families. Inspect current messages for format changes. Amounts and merchants below are fixtures, not user data.

| Alert family | Example | Treatment |
| --- | --- | --- |
| Purchase | `Dear Cardholder, Purchase at SAMPLE CAFE COLOMBO LK for LKR 1,250.00 on 01/10/26 09:46 AM has been authorised on your debit card ending #0000.` | Purchase authorization: LKR 1,250.00. Not proof of final settlement. |
| Decline | `Your card was declined due to insufficient funds. The attempted transaction amount was USD 10.00 at SAMPLE SERVICE US on 03/10/26 08:32 PM.` | Failed attempt; exclude from spending. |
| Authentication | `Your OTP at Merchant 'SAMPLE' for LKR 1,250.00 is [REDACTED]` | Exclude before export or logging, even though it contains an amount and merchant. |
| Approval request | `ComBank Digital-Transfer to Other Banks LKR 333.00 attempted. Please use code [REDACTED] to approve.` | Authentication request; not a completed transfer. |
| ATM | `Withdrawal at SAMPLE ATM COLOMBO LK for LKR 5,000.00 on 01/10/26 05:24 PM from card ending #0000.` | Cash withdrawal, separate from purchases. Omit appended receipt links. |
| Transfer acknowledgement | `Transfer within ComBank in the amount of LKR 1,500.00 was received on 01/10/2026 from the ComBank Digital.` | Transfer request acknowledgement; direction and settlement unverified. “Received” does not establish income. |
| Other-bank transfer | `Transfer to Other Banks in the amount of LKR 200.00 was received on 01/10/2026 from the ComBank Digital.` | Same ambiguity; preserve as a separate movement type. |
| Cancellation | `YOUR TRANSACTION AT SAMPLE ON YOUR CARD ENDING WITH 0000 HAS BEEN CANCELLED.` | Review item. No automatic subtraction without an amount and matching authorization. |
| Coverage notice | `SMS Alert Facility on your Account No. [REDACTED] was discontinued on 2026-01-01 due to insufficient funds ...` | Coverage gap. Card alerts can continue while account alerts are absent. |
| Promotion | `Get 10% cashback up to Rs.1,500 when you complete 5 bill payments ...` | Advertising; neither spending nor a received refund. |

## Merchant cues

Classify by descriptor, preserving uncertainty and retaining the original merchant field.

- `UBER EATS` → food delivery; other `UBER` ride descriptors → transport. Match delivery before the broader brand.
- `BARISTA`, `PIZZA HUT`, `COCOS`, `THE FAB`, `BREADTALK`, café/restaurant descriptors → dining and coffee.
- `KEELLS`, `CARGILLS`, `SPAR EXPRESS`, `LAUGFS SUPER MARKET` → groceries.
- `OPENAI`, `OPENCODE`, `CLOUDFLARE`, `GOOGLE*CLOUD` → AI/developer services. Do not silently map an unfamiliar company name to one of these services.
- `APPLE.COM/BILL` → Apple services; the descriptor alone does not identify the subscription or app.
- `GOOGLE*WORKSPACE`, `SPACESHIP.COM` → workspace/domains; `SPOTIFY`, `PATREON` → memberships/entertainment.
- `DIALOG AXIATA` → telecom; `UCSC` → education. Other names require evidence or remain unclassified.

## Extraction pitfalls

- Handles can end in `\r`; normalize them before filtering. Messages may mix title case and uppercase sender names.
- A search against `message.text` alone can miss messages stored only in `attributedBody`. Binary substring search is not a substitute for validated decoding and can have different case behavior.
- Join tables may produce duplicate rows. Count unique source messages before aggregation; do not deduplicate separate messages by merchant/amount alone.
- Purchase dates commonly use `dd/mm/yy` and 12-hour times; transfer acknowledgements may use `dd/mm/yyyy` without a time. Do not invent a transaction time for date-only messages.
- Current-day and first/last-month totals can be incomplete. Message retention and disabled alerts can cause additional gaps.
- Distinguish exported purchases from all bank activity. No-alert fees, unsynced messages, cash purchases and actual foreign-currency conversion charges require statement reconciliation.
