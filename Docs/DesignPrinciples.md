# DESIGN PRINCIPLES

1. Meaning is sacred.

Every financial event should represent what actually happened.

2. Reality comes before reporting.

Reports must be derived from the underlying financial reality, not the other way around.

3. Events are the source of truth.

Assets, balances, net worth, and reports are derived from events.

4. Categories are organizational only.

Categories must never contain financial behavior or business logic.

5. Simplicity in UI, correctness in data.

The user interface should hide complexity without sacrificing accuracy.

6. Mobile records reality.

The mobile application is optimized for recording and reviewing financial information quickly and with minimal friction.

7. Analytics explains reality.

The analytics platform is optimized for understanding and exploring financial information.

8. Historical context should be preserved.

Refunds, reimbursements, debt repayments, bad debt write-offs, and similar actions should not erase the original event.

9. Reports are views, not data.

Reports should never become the source of truth.

10. Build selfishly for an audience of one.

I am the sole user of this application. Even though the code lives in a public GitHub repository, it will never be deployed for a general audience—features and models should solve my actual habits and problems, never hypothetical ones for other people.

11. Respect the cash-value boundary.

Only assets with a clear, liquid, checkable monetary value (cash, bank accounts, e-wallets, stocks, gold, crypto) live inside structured balances. Non-liquid items—consumer goods, loyalty coins, store trade-in credits, and in-kind favors—stay outside the ledger; log only the real money movement and put the story in a journal entry.

12. Spending measures behavioral cash outflow.

Spending exists to evaluate personal discipline—money handed out for needs, wants, fees, taxes, paid installments, or unrecovered bad debt. Investment market swings and asset conversions must never pollute spending or income reports.

13. Events are strictly atomic.

One event equals one financial action—there are no compound events. When one real-world moment involves multiple actions (a transfer plus a fee, my share of a meal plus a friend's share, or a stock price update plus a sale and fee), each action is recorded as its own standalone event. Keeping rows strictly atomic keeps the system simple today while allowing optional UI shortcuts or visual grouping later without rewriting historical data or the report engine.

14. Rupiah integers only.

Every monetary value in the system is stored and calculated strictly in whole Indonesian Rupiah (`Rp` integers)—even for foreign stocks or crypto—avoiding multi-currency complexity and floating-point rounding bugs.
