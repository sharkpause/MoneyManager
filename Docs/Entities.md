# ENTITIES

This document defines the core entities that exist within the Money Manager domain model.

Entities represent long-lived objects that exist independently.

---

# Asset

An Asset represents anything with a **clear, liquid, checkable monetary value** that contributes positively to my financial position.

All asset, obligation, and event amounts across the entire system are denominated strictly in **whole Indonesian Rupiah (`Rp` integers)**—including foreign equities, gold, or cryptocurrency, which are tracked by their Rupiah value.

Assets may increase, decrease, appreciate, depreciate, or be converted/transferred between one another.

Examples:

* Cash
* Bank Accounts
* E-Wallets
* Stocks
* ETFs
* Mutual Funds
* Cryptocurrency
* Gold

Assets contribute positively to net worth.

Items without an objective, liquid cash balance—such as purchased consumer goods (phones, laptops, clothes), promotional store credits, or in-app loyalty coins—are **not** tracked as Assets. Once money is spent on a consumer item, its tracked asset value is zero; any non-cash credits or loyalty coins used on future purchases simply reduce the real cash spent, with context recorded in a Journal Entry.

---

## Asset Types

### Account

A liquid location where cash/money is stored.

Examples:

* Cash
* BCA
* Jago
* GoPay
* DANA
* OVO

Account values change only when financial events occur.

Examples:

* Income
* Expense
* Transfer
* Investment Purchase
* Investment Sale
* Debt Payment
* Reimbursement
* Refund
* Adjustment

---

### Investment Position

An owned investment asset with a market-quoted or checkable monetary value.

Examples:

* BBCA
* BMRI
* S&P 500 ETF
* Nvidia
* Gold
* Bitcoin

Buying (`Account → Investment Position`) and selling (`Investment Position → Account`) are neutral conversions of wealth rather than income or spending (aside from transaction fees/taxes).

Investment positions change in value through `Asset Appreciation` and `Asset Depreciation`—either logged periodically as unrealized market updates or reconciled right before/at the moment of sale.

Investment positions belong to a single category for reporting purposes.

Examples:

* IHSG
* US
* Technology
* Dividend
* Growth

---

# Obligation

An Obligation represents money that is owed between parties.

Obligations may either be owed by me or owed to me.

Examples:

* Credit Card Debt
* Installment Purchases
* Friend Reimbursements
* Personal Loans
* Business Reimbursements

---

## Obligation Directions

### Owed By Me

Examples:

* Credit Card Debt
* Installment Purchase
* Personal Loan

`Owed By Me` obligations track the full remaining commitment (principal and any accrued interest), but do **not** immediately deduct their full unpaid total from current net worth or spending upon creation:

* **Current Net Worth & Spending**: Decrease incrementally as individual installments/repayments (`Debt Payment`) are actually paid in cash.
* **Projected Net Worth**: Subtracting total remaining `Owed By Me` obligations in a dedicated report projection view shows my full committed financial position.

---

### Owed To Me

Examples:

* Temporary Expenses (split bills, fronting group costs)
* Friend Loans
* Outstanding Reimbursements

`Owed To Me` obligations preserve net worth when I pay cash on someone else's behalf (cash decreases while the receivable increases by the same amount). They are reduced in cash via `Reimbursement` or written off as `Bad Debt` (including when settled in-kind without cash returning or forgiven).

---

# Event

An Event represents a **single, strictly atomic** financial action that occurred, denominated in whole Rupiah (`Rp` integers).

There are **no compound events**. When a real-world situation involves multiple distinct financial actions—such as a bank transfer plus an admin fee, splitting a group meal into my expense and a friend's temporary expense, or updating an investment's price before selling it and paying a broker fee—each action is recorded as its own separate atomic event. Keeping events strictly atomic preserves model simplicity while remaining non-breaking if multi-insert UI shortcuts or an optional `group_id` are ever added later.

While simultaneous actions are not bundled into compound records, events do maintain **causal links** across time where financial meaning requires it:

* **`obligation_id`**: Links `Temporary Expense`, `Reimbursement`, `Bad Debt`, `Debt Creation`, and `Debt Payment` to the specific `Obligation` they affect.
* **`related_event_id`**: Links a reversing event (such as a `Refund`) back to the original `Expense` it offsets.

Events represent historical financial actions. Later events may reverse, offset, or modify the financial impact of earlier events while preserving historical context. Events are mutable and can be edited in the case of an input mistake; mutating an event updates all derived state (accounts, obligations, net worth, and reports).

Examples:

* Income
* Expense
* Transfer
* Investment Purchase
* Investment Sale
* Temporary Expense
* Reimbursement
* Bad Debt
* Debt Creation
* Debt Payment
* Refund
* Asset Appreciation
* Asset Depreciation
* Adjustment

Reports are primarily generated from events.

Assets and obligations represent the current state of finances, while events represent the historical record of how that state was reached.

---

# Category

A Category is a user-defined organizational label used for grouping and reporting.

Categories do not directly affect balances, net worth, or financial behavior. They exist solely to help organize and analyze financial data.

Categories are intentionally simple and must never contain business logic.

Examples:

* Food
* Transportation
* Entertainment
* Salary
* Investments
* IHSG
* US
* Technology
* Growth

Categories may optionally contain an arbitrary number of subcategories through a parent-child relationship.

Examples:

```text
Food
└── Coffee

Investments
└── IHSG
    └── Banking
```

Each categorizable event, asset, or obligation is assigned **strictly one category** (never multiple categories on the same record) so category breakdowns and pie charts always sum cleanly to 100% without double-counting. Categorizable events (such as `Income` and `Expense`) require a category when recorded; broad items that do not fit a specific bucket simply use a user-created category like `"Other"`.

Category structures remain fully configurable, with no hardcoded behavior attached to any specific category.

---

# Journal Entry

A free-text note written by me and attached to financial records.

Journal entries provide human context that does not belong inside structured financial numbers—especially details outside the cash-value boundary.

Examples:

* Explanation of unusual spending
* Notes on loyalty coins, promos, or device trade-in credits applied to a purchase
* Details on how an obligation was forgiven or settled in-kind
* Investment reasoning and thesis
* Personal reflections

Journal entries do not directly affect balances, reports, or net worth.
