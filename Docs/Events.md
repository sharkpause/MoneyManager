# Event Types

Every event in Money Manager is **strictly atomic** (one row = one financial action) and denominated in **whole Indonesian Rupiah (`Rp` integers)**. There are no compound events—if one real-world occurrence involves a transfer plus a fee, a split bill, or a stock valuation update plus a sale and fee, each part is logged as its own standalone event.

---

## Income

Real money enters my financial ecosystem from outside the tracked asset boundary.

Examples:

* Salary
* Gift
* Dividend
* Selling a previously expensed item (e.g., an old phone) for cash

Does **not** include transfers, investment sales, refunds, or reimbursements.

---

## Expense

Behavioral cash outflow or permanent reduction of wealth for needs, wants, fees, taxes, debt installments, or unrecovered receivables.

Spending reports are derived from expenses to evaluate monthly discipline.

Examples:

* Food
* Subscriptions
* Broker / Transfer Fees
* Taxes
* Debt Payments (installment & credit card repayments)

Does **not** include investment market losses (`Asset Depreciation`) or asset purchases (`Investment Purchase`).

---

## Transfer

Neutral movement of value between owned accounts.

Examples:

* BCA → Jago
* Cash → DANA

Any transfer admin fee is recorded separately as an `Expense`.

---

## Investment Purchase

Neutral conversion of cash from an `Account` into an `Investment Position`.

Examples:

* Stock Purchase
* Mutual Fund Purchase
* Cryptocurrency Purchase

Presented as a neutral conversion rather than `-Cash` spending and `+Asset` income. Any broker fee or tax is recorded as an `Expense`.

---

## Investment Sale

Neutral conversion of value from an `Investment Position` back into an `Account`.

Examples:

* Stock Sale
* Mutual Fund Sale
* Cryptocurrency Sale

If the sale price differs from the value currently recorded on the `Investment Position`, the price change is first reconciled via `Asset Appreciation` or `Asset Depreciation`, followed by the neutral `Investment Sale` conversion and any fee/tax `Expense`.

---

## Temporary Expense

Cash paid out that is expected to be recovered in cash later (creates or increases an `Owed To Me` obligation).

Examples:

* Paying for a friend's share of a meal
* Lending money
* Reimbursable business expenses

---

## Reimbursement

Cash recovery of a previous `Temporary Expense` (reduces an `Owed To Me` obligation).

Examples:

* Friend pays back debt in cash/transfer
* Business reimbursement deposited to bank

Never treated as `Income`.

---

## Bad Debt

Write-off of an `Owed To Me` obligation when cash recovery is no longer expected—whether because the debtor defaulted, the remainder was forgiven, or it was settled informally in-kind without real cash returning.

Converts the written-off obligation amount into an `Expense` (reducing net worth and increasing spending reports) while preserving historical context and still allowing future reimbursement just in case.

Examples:

* Unrecoverable loan to a friend
* Debt settled in-kind ("buy my lunch and we're even") or forgiven

---

## Debt Creation

Creation or increase of an `Owed By Me` financial obligation.

Examples:

* Credit card purchase
* Installment purchase
* Interest accrual on an unpaid debt

Increases the tracked obligation (and reduces **Projected Net Worth** in projection views), without immediately reducing current net worth or increasing spending reports.

---

## Debt Payment

Cash payment toward an existing `Owed By Me` obligation.

Examples:

* Paying a monthly installment
* Credit card repayment
* Paying down a personal loan

Reduces cash, reduces the remaining `Owed By Me` obligation, counts as an `Expense` in spending reports (linked back to the original debt item), and reduces current net worth by the installment amount paid.

---

## Refund

Cash reversal of a previous `Expense`.

Examples:

* Product return
* Service cancellation refund

Offsets the net impact of the original expense in spending reports without counting as `Income` or erasing the original purchase event.

---

## Asset Appreciation

Increase in an `Investment Position`'s market value without converting to cash (logged periodically as unrealized gain, or reconciled at the time of sale).

Examples:

* Stock appreciation
* Gold / cryptocurrency price rise
* Currency appreciation on an investment asset

Increases investment value and net worth; leaves `Income` and `Spending` reports unchanged.

---

## Asset Depreciation

Decrease in an `Investment Position`'s market value without converting to cash (logged periodically as unrealized loss, or reconciled at the time of sale).

Examples:

* Stock price drop
* Gold / cryptocurrency loss
* Currency depreciation on an investment asset

Decreases investment value and net worth; leaves `Spending` and `Income` reports unchanged so market drops never distort behavioral spending discipline.

---

## Adjustment

Uncategorized `+` or `-` balance correction for an unexpected discrepancy in cash or assets due to human tracking mistakes or forgotten entries.

Adjusts the target asset balance and net worth directly **without** requiring a category and **without** affecting `Income` or `Spending` reports.

Examples:

* Finding extra cash in wallet (`+`)
* Discovering missing cash or reconciling a miscalculated bank balance (`-`)
