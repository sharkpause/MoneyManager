# REPORTS

Reports are procedurally generated, read-only views computed from the chain of events and current entities.

Reports never own or store mutable state—they are invoked on demand over any chosen time window (most commonly at the end of each month to review spending discipline, income, and overall financial position, or across custom multi-month ranges).

---

# Core Reporting Mechanics

## 1. Single-Category Rollups & Progressive Drill-Down

Because every categorizable record has **strictly one category** (and `Income` / `Expense` events require a category, using a user-created `"Other"` category if needed), every hierarchical breakdown always totals **100%** without double-counting or special uncategorized hacks.

* **Parent Rollup**: At high levels, any parent category (`Food`) displays the combined total of itself and all of its nested descendants (`Food → Coffee`, `Food → Groceries`, etc.).
* **Arbitrary-Depth Drill-Down**: Selecting a slice zooms one level deeper into that category's direct children, repeating through as many subcategory levels as exist, all the way down to individual events and their `Journal Entries`.
* **`Generic` Slice for Direct Parent Events**: If a parent category has both subcategories (`Food → Coffee: Rp 200,000`, `Food → Groceries: Rp 500,000`) and events logged directly on the parent itself (`Food: Rp 300,000`), drilling into `Food` displays that direct `Rp 300,000` as a **`Generic`** slice alongside `Coffee` and `Groceries` so the drilled-down view still totals `Rp 1,000,000`.

---

## 2. Cross-Period Attribution (Refunds)

Reversing events that reference an earlier event—specifically `Refund`—offset against the **original `Expense`'s period** by default in spending reports.

* Example: Headphones bought on Oct 28 (`Rp 500,000`) and refunded on Nov 3 (`Rp 500,000`) reduce October's net `Electronics` spending to `Rp 0` rather than creating a broken `-Rp 500,000` negative slice in November.
* Chronological account balances still reflect the real cash leaving in October and returning in November, and both events remain visible when drilling into history.

---

## 3. Customizable Lenses (Toggles)

Because events preserve their semantic type, reports allow dynamically adding or removing detail via toggles without mutating data:

* **Refunds**: `Net of Refunds` *(default)* vs. `Gross Spending (before refunds)`.
* **Temporary Expenses**: `Excluded` *(default—shown only as a small side note near spending stats)* vs. `Included` (shows raw cash fronted).
* **Debt Mode**:
  * `Paid Installments` *(default—includes `Debt Payment` outflows paid during the period)*
  * `Discretionary Cash Only` *(excludes `Debt Payments` from past commitments)*
  * `Committed Debt` *(includes new `Debt Creation` totals incurred during the period)*
* **Investment & Asset Activity**: `Excluded` *(default in cash-flow views)* vs. toggling on `Investment Purchases / Sales` or `Asset Appreciation / Depreciation`.
* **Adjustments**: `Excluded` *(default—human balance corrections never distort `Income` or `Spending`)* vs. optional toggle to inspect net adjustments in a period.

---

# Core Report Models

## 1. Period Cash-Flow & Category Overview (Monthly Review)

Designed for answering *"What happened with my money this period, and was I disciplined?"*

* **High-Level Summary**:
  * `Total Inflows (Income)`
  * `Total Outflows (Spending)`
  * `Net Flow (Income - Spending)`
  * **Spend-to-Income Percentage** (`Spending / Income`, e.g., `60%` of income spent—handles `>100%` cleanly if dipping into savings)
* **Separate Outflows & Inflows Pies**:
  * **Outflows Pie**: Category breakdown of spending (plus any toggled layers), supporting full hierarchical drill-down to leaf events.
  * **Inflows Pie**: Category breakdown of income sources, supporting the same drill-down.

---

## 2. Multi-Month & Custom-Period Trends

Evaluates patterns across multiple time buckets (e.g., month-by-month over 6 or 12 months, quarterly, yearly, or custom windows):

* Income vs. Spending and Spend-to-Income % trajectory over time
* Category or subcategory trend lines (e.g., tracking `Food → Coffee` across months)
* Net Worth trajectory over time

---

## 3. Net Worth & Portfolio View

Provides a snapshot of overall financial standing at a point in time (or across history):

* **Current Net Worth**: Total liquid `Accounts` + `Investment Positions` + open `Owed To Me` receivables.
* **Projected Net Worth**: `Current Net Worth` minus total remaining `Owed By Me` obligations (credit cards, unpaid installments, accrued interest).
* **Asset & Investment Breakdown**: Allocation across cash vs. investment categories, and unrealized vs. realized `Asset Appreciation` / `Asset Depreciation` (net of fees).

---

## 4. Open Obligations View

Tracks active unresolved relationships in both directions:

* **`Owed To Me`**: Outstanding reimbursements and friend loans, partial repayments received so far, and quick actions to settle or write off as `Bad Debt`.
* **`Owed By Me`**: Active installment plans and credit debts, paid vs. remaining schedule, accrued interest, and linked `Debt Payment` history.

---

# Composable Reporting Architecture

To keep the system maintainable, scalable, and easy to extend with brand-new report models in the future, reporting is structured into **three decoupled layers**:

```text
[1. Domain Source of Truth]
Events, Assets, Obligations, Categories, Journal Entries
        ↓
[2. Shared Query Primitives & Lenses]
• Period & Attribution Resolver (date windows, bucket slicing, cross-period refund linking)
• Lens / Filter Pipeline (declarative toggles for refunds, debt modes, temporary expenses, asset flows)
• Category Tree Rollup Engine (recursive descendant sum + "Generic" direct-parent bucketing)
• Point-in-Time Snapshot Projector (reconstructs balances, Current Net Worth, and Projected Net Worth at any date t)
        ↓
[3. Pluggable Report Projections]
Stateless functions: (Domain Data, Report Config) → Report View Output
(Period Pie Drill-Down, Multi-Month Trends, Net Worth, Open Obligations, + any future report model)
```

### Why This Scales Cleanly

* **Zero report logic in UI widgets**: Charts and tables only render structured report outputs; they never compute financial rules themselves.
* **Zero report caching as source of truth**: Adding a new report model later never requires database schema migrations or changing how mobile events are recorded.
* **Consistent numbers everywhere**: Because every report composes the same Layer 2 primitives (attribution, lenses, category rollup, and snapshot projection), two different reports viewing the same lens will always agree to the Rupiah.
