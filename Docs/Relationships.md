# RELATIONSHIPS

This document describes how entities interact within the Money Manager domain model.

Relationships describe domain behavior and ownership, not database implementation details.

---

# Event ↔ Asset

Events may create, modify, convert/transfer, appreciate, depreciate, or remove value from assets.

Examples:

Income

```text
Outside World
↓
Account
```

Expense

```text
Account
↓
Outside World
```

Transfer (Neutral Conversion)

```text
Account
↓
Account
```

Investment Purchase (Neutral Conversion)

```text
Account
↓
Investment Position
```

Investment Sale (Neutral Conversion)

```text
Investment Position
↓
Account
```

Asset Appreciation

```text
Investment Position
↑
Market Value Increase (Net Worth ↑, Income Unchanged)
```

Asset Depreciation

```text
Investment Position
↓
Market Value Decrease (Net Worth ↓, Spending Unchanged)
```

Assets represent the current financial state while events represent the actions that caused that state.

---

# Event ↔ Obligation

Events may create, modify, reduce, settle, or write off obligations.

Examples:

Debt Creation

```text
Obligation (Owed By Me)
↑
Amount Owed (Projected Net Worth ↓, Current Net Worth & Spending Unchanged)
```

Interest

```text
Obligation (Owed By Me)
↑
Accrued Amount Owed (Projected Net Worth ↓, Current Net Worth & Spending Unchanged)
```

Debt Payment

```text
Account → Outside World (Expense)
Obligation (Owed By Me) ↓ Amount Paid
(Current Net Worth ↓, Spending ↑, Projected Net Worth Unchanged)
```

Temporary Expense

```text
Account → Outside World
Creates / Increases Obligation (Direction: Owed To Me)
(Current Net Worth & Spending Unchanged)
```

Reimbursement

```text
Outside World → Account
Reduces Obligation (Direction: Owed To Me)
(Current Net Worth, Income & Spending Unchanged)
```

Bad Debt

```text
Closes / Reduces Obligation (Direction: Owed To Me)
Converts Written-Off Amount Into Expense
(Current Net Worth ↓, Spending ↑)
```

Obligations represent ongoing financial relationships while events represent changes to those relationships.

---

# Event ↔ Event (Causal Links Only)

Events are strictly atomic and are **not** bundled into compound multi-leg transactions—simultaneous actions (such as a transfer and its fee) exist as separate standalone events.

However, a later event may reference an earlier event when reversing its financial meaning:

Refund

```text
Refund Event
↓ (related_event_id)
Original Expense Event
(Offsets net spending in the original Expense's period while keeping both events in history)
```

---

# Event ↔ Category

Categorizable events (such as `Expense` and `Income`) must be assigned **strictly one category**.

Assigning a single category guarantees that category rollups and pie charts always total 100% without double-counting. Broad events that don't fit a specific category can be assigned to a user-created `"Other"` category.

Categories are used exclusively for organization and reporting.

Examples:

```text
Expense
Category: Food → Coffee

Income
Category: Salary
```

Categories do not affect financial behavior.

---

# Asset ↔ Category

Assets may be assigned **at most one category** (which may sit inside a subcategory hierarchy such as `Investments → IHSG → Banking`).

Categories provide organizational structure and reporting views.

Examples:

```text
BBCA
Category: IHSG → Banking

Nvidia
Category: US → Technology
```

Categories do not affect asset behavior or valuation.

---

# Obligation ↔ Category

Obligations may be assigned **at most one category** when useful for organization and reporting.

Examples:

```text
Friend Loan
Category: Personal

Credit Card Debt
Category: Consumer Debt
```

Categories do not affect obligation behavior.

---

# Journal Entry ↔ Event

Journal entries may be attached to events.

Examples:

* Explanation of an unusual purchase
* Non-cash context (loyalty coins redeemed, device trade-in credit applied)
* Context behind an investment decision or a bad-debt write-off

Journal entries provide human context for historical events.

---

# Journal Entry ↔ Asset

Journal entries may be attached to assets.

Examples:

* Investment thesis
* Long-term financial goals
* Asset-specific notes

---

# Journal Entry ↔ Obligation

Journal entries may be attached to obligations.

Examples:

* Details about a personal loan
* Notes regarding repayment schedules or expectations
* Context behind a temporary expense or in-kind settlement

---

# Reports

Reports are generated views of the domain model.

Reports are not entities and do not own data.

Reports are derived from:

* Events
* Assets
* Obligations
* Categories

Examples:

* Income Reports
* Spending & Monthly Discipline Reports (with optional toggles for gross pre-refund spending and temporary expenses)
* Investment Performance Reports (realized vs. unrealized appreciation/depreciation, net of fees)
* Debt & Installment Reports
* Net Worth Reports (Current Net Worth vs. Projected Net Worth factoring in remaining `Owed By Me` obligations)
* Reimbursement Reports

Reports should always reflect the underlying domain model and should never become the source of truth.
