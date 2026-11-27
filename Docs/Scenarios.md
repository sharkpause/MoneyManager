# SCENARIOS

## Salary

### Situation

I receive a monthly salary of Rp 5,000,000.

### Expected Meaning

Income.

### Expected Outcome

* Cash increases by Rp 5,000,000.
* Income reports increase by Rp 5,000,000.
* Spending reports remain unchanged.
* Net worth increases by Rp 5,000,000.

---

## Food Purchase

### Situation

I buy lunch for Rp 50,000.

### Expected Meaning

Expense.

### Expected Outcome

* Cash decreases by Rp 50,000.
* Spending reports increase by Rp 50,000.
* Income reports remain unchanged.
* Net worth decreases by Rp 50,000.

---

## Bank Transfer

### Situation

I transfer Rp 1,000,000 from BCA to Jago.

### Expected Meaning

Transfer.

### Expected Outcome

* BCA balance decreases by Rp 1,000,000.
* Jago balance increases by Rp 1,000,000.
* Spending reports remain unchanged.
* Income reports remain unchanged.
* Net worth remains unchanged.

---

## Investment Purchase

### Situation

I have Rp 1,000,000 in Cash and buy Rp 1,000,000 worth of BBCA stock.

### Expected Meaning

Investment Purchase (neutral conversion).

### Expected Outcome

* Cash decreases by Rp 1,000,000.
* BBCA investment position increases by Rp 1,000,000.
* Spending reports remain unchanged (unless there was a purchase fee, which is logged as an `Expense`).
* Income reports remain unchanged.
* Net worth remains unchanged.

### Notes

This is not treated as an expense because wealth has simply converted into another liquid asset, and in reports it is presented as a neutral conversion rather than `-Cash` / `+BBCA`.

---

## Investment Sale (At Recorded Value)

### Situation

I sell Rp 500,000 worth of stocks whose recorded asset value already reflects that price.

### Expected Meaning

Investment Sale (neutral conversion).

### Expected Outcome

* Investment position decreases by Rp 500,000.
* Cash increases by Rp 500,000.
* Spending reports remain unchanged (aside from any broker fee/tax `Expense`).
* Income reports remain unchanged.
* Net worth remains unchanged.

### Notes

This is not treated as income because wealth has only changed form. The only expense involved is any broker fee or tax that reduces the final cash received.

---

## Selling an Appreciated Stock with Fees (Without Prior Price Updates)

### Situation

I bought BBCA for Rp 1,000,000 and never logged intermediate unrealized gains. Later I sell the entire position for Rp 1,250,000 gross; after Rp 3,000 in broker fees and tax, Rp 1,247,000 lands in my cash/RDN account.

### Expected Meaning

* Asset Appreciation: Rp 250,000
* Investment Sale: Rp 1,250,000
* Expense (Fee/Tax): Rp 3,000

### Expected Outcome

* BBCA appreciates from Rp 1,000,000 to Rp 1,250,000, then converts to Rp 0 upon sale.
* Cash increases by Rp 1,247,000 net.
* Net worth increases by Rp 247,000 (`+Rp 250,000` appreciation `- Rp 3,000` fee).
* Income reports remain unchanged.
* Spending reports increase only by Rp 3,000 (the fee).
* Investment reports show the Rp 250,000 gain and Rp 3,000 fee.

### Notes

Because events are strictly atomic (no compound events), these are logged as three separate events (`Asset Appreciation`, `Investment Sale`, and `Expense` categorized under `Fees`). Logging the missing price change on BBCA before executing the neutral transfer guarantees the exact same outcome whether unrealized gains were updated weekly or only at the time of sale.

---

## Selling a Stock at a Loss

### Situation

BBCA is recorded at Rp 1,000,000, and I sell the entire position for Rp 800,000.

### Expected Meaning

* Asset Depreciation: Rp 200,000
* Investment Sale: Rp 800,000

### Expected Outcome

* BBCA depreciates from Rp 1,000,000 to Rp 800,000, then converts to Rp 0 upon sale.
* Cash increases by Rp 800,000.
* Net worth decreases by Rp 200,000.
* Spending reports remain unchanged (aside from any broker fee/tax).
* Income reports remain unchanged.

### Notes

Investment losses never count as spending. Spending measures behavioral cash outflows (buying needs or wants) to evaluate monthly discipline—market drops belong in Investment and Net Worth reports, not lifestyle spending.

---

## Temporary Expense

### Situation

I pay Rp 200,000 for a group meal.

My share is Rp 120,000.

A friend owes me Rp 80,000.

### Expected Meaning

* Expense: Rp 120,000
* Temporary Expense: Rp 80,000

### Expected Outcome

* Cash decreases by Rp 200,000.
* Spending reports increase by Rp 120,000.
* Outstanding reimbursement (`Owed To Me`) increases by Rp 80,000.
* Net worth decreases by Rp 120,000.

### Notes

Logged as two separate atomic events (`Expense` for my Rp 120,000 share and `Temporary Expense` for the friend's Rp 80,000 share).  
The reimbursable amount must not distort spending reports.  
Temporary expenses are excluded from spending totals by default (with an optional toggle to include them), appearing by default as a small contextual note near expense statistics.

---

## Reimbursement Received

### Situation

A friend repays Rp 80,000 from a previous temporary expense.

### Expected Meaning

Reimbursement.

### Expected Outcome

* Cash increases by Rp 80,000.
* Outstanding reimbursement decreases by Rp 80,000.
* Income reports remain unchanged.
* Spending reports remain unchanged.
* Net worth remains unchanged.

### Notes

Reimbursements must never be treated as income.

---

## Partial Reimbursement

### Situation

A friend owes me Rp 100,000 from a previous temporary expense and repays Rp 40,000.

### Expected Meaning

Partial Reimbursement.

### Expected Outcome

* Cash increases by Rp 40,000.
* Outstanding reimbursement decreases by Rp 40,000.
* Remaining reimbursement balance is Rp 60,000.
* Income reports remain unchanged.

### Notes

Reimbursements should not be treated as income.

---

## Bad Debt

### Situation

A reimbursement of Rp 80,000 is considered unrecoverable.

### Expected Meaning

Bad Debt.

### Expected Outcome

* Outstanding reimbursement decreases by Rp 80,000.
* Spending reports increase by Rp 80,000.
* Net worth decreases by Rp 80,000.

### Notes

The loss becomes a real expense while preserving historical context.  
The temporary expense can still be reimbursed later in the future, just in case.

---

## In-Kind Debt Settlement ("Buy My Lunch and We're Even")

### Situation

A friend owes me Rp 150,000 from last week. Today they pay Rp 110,000 directly to the cashier for my meal, and I forgive the remaining Rp 40,000 so we call it even. Zero cash touches my accounts.

### Expected Meaning

Bad Debt: Rp 150,000 (with context recorded in a Journal Entry).

### Expected Outcome

* Cash remains unchanged.
* Outstanding reimbursement (`Owed To Me`) decreases by Rp 150,000 (closed).
* Spending reports increase by Rp 150,000.
* Net worth decreases by Rp 150,000.

### Notes

Because no real cash ever returned across the asset boundary, all expectation of cash recovery is gone and the Rp 150,000 receivable is written off as `Bad Debt`, with the meal/forgiveness details noted in the Journal Entry.

---

## Refunds

### Situation

I buy headphones for Rp 500,000.

A week later I return them and receive a full refund.

### Expected Meaning

* Expense: Rp 500,000
* Refund: Rp 500,000

### Expected Outcome

* Original expense remains in history.
* Cash decreases by Rp 500,000 when purchased.
* Cash increases by Rp 500,000 when refunded.
* Net spending impact becomes Rp 0.
* Income reports remain unchanged.

### Notes

The purchase and refund both remain visible in history.  
A refund is not income—it reverses a previous expense.  
Reports reflect the net financial impact by default while preserving a small label/toggle to view gross expenses prior to refunds.

---

## Cashback Coins / Loyalty Points

### Situation

Day 1: I pay Rp 200,000 via GoPay for dinner and earn Rp 25,000 in GoPay Coins.  
Day 2: I buy a Rp 50,000 coffee by redeeming those Rp 25,000 GoPay Coins plus Rp 25,000 from my GoPay balance.

### Expected Meaning

* Day 1 Expense: Rp 200,000
* Day 2 Expense: Rp 25,000 (optional Journal Entry noting Rp 25,000 coins used)

### Expected Outcome

* GoPay balance decreases by Rp 200,000 on Day 1 and Rp 25,000 on Day 2.
* Spending reports increase by Rp 225,000 total.
* Net worth decreases by Rp 225,000 total.

### Notes

In-app coins, reward points, and membership credits are not tracked as Assets. Only actual GoPay balance deductions are logged; promotional details go in the free-text Journal Entry if worth remembering.

---

## Device Trade-In on a Previously Expensed Item

### Situation

Two years ago I bought a phone for Rp 8,000,000 (logged then as an `Expense`, so it has no tracked Asset value). Today I buy a new Rp 10,000,000 phone by trading in the old phone for Rp 2,500,000 store credit and paying Rp 7,500,000 from BCA.

### Expected Meaning

Expense: Rp 7,500,000 (with trade-in details in a Journal Entry).

### Expected Outcome

* BCA decreases by Rp 7,500,000.
* Spending reports increase by Rp 7,500,000.
* Net worth decreases by Rp 7,500,000.
* The Rp 2,500,000 trade-in credit is not logged as a financial event, only explained in the Journal Entry.

---

## Selling a Previously Expensed Item for Cash

### Situation

I sell my old previously expensed phone to a buyer for Rp 2,500,000 real cash into BCA.

### Expected Meaning

Income: Rp 2,500,000.

### Expected Outcome

* BCA increases by Rp 2,500,000.
* Income reports increase by Rp 2,500,000.
* Net worth increases by Rp 2,500,000.

### Notes

Because the old phone was already outside the tracked asset boundary (valued at Rp 0), real cash entering BCA from selling it crosses into the financial ecosystem as `Income`.

---

## Credit Card / Installment Purchase

### Situation

I purchase a phone for Rp 3,000,000 using a credit card or installment plan.

### Expected Meaning

Debt Creation: Rp 3,000,000.

### Expected Outcome

* Outstanding debt (`Owed By Me`) increases by Rp 3,000,000.
* Cash remains unchanged.
* Spending reports remain unchanged.
* Current net worth remains unchanged.
* **Projected Net Worth** (in the report projection view) decreases by Rp 3,000,000.

### Notes

Debt creation does not immediately reduce current net worth by the full calculated total; current net worth and spending move together as individual installments are paid, while the projection view shows the full committed liability.

---

## Credit Card / Installment Repayment

### Situation

I pay a Rp 1,000,000 installment toward the existing Rp 3,000,000 phone debt.

### Expected Meaning

Debt Payment: Rp 1,000,000.

### Expected Outcome

* Cash decreases by Rp 1,000,000.
* Outstanding debt decreases by Rp 1,000,000 (Rp 2,000,000 remaining).
* Spending reports increase by Rp 1,000,000.
* Current net worth decreases by Rp 1,000,000.
* **Projected Net Worth** remains unchanged (Rp 1,000,000 less cash is offset by Rp 1,000,000 less remaining debt).

### Notes

Debt payments are recorded as expenses while remaining linked to the original debt obligation. This lets monthly spending reports and current net worth reflect actual installment cash outflows while debt reports and projected net worth track the remaining total commitment.

---

## Interest

### Situation

Interest accrues on the financed phone purchase by Rp 50,000.

### Expected Meaning

Debt Creation (Interest accrual): Rp 50,000.

### Expected Outcome

* Outstanding debt (`Owed By Me`) increases by Rp 50,000.
* **Projected Net Worth** decreases by Rp 50,000.
* Current net worth and spending reports remain unchanged until paid via `Debt Payment`.

---

## Dividend Received

### Situation

I receive Rp 100,000 in stock dividends.

### Expected Meaning

Income.

### Expected Outcome

* Cash increases by Rp 100,000.
* Income reports increase by Rp 100,000.
* Net worth increases by Rp 100,000.

### Notes

Dividends are real cash income generated by an investment asset.

---

## Stock Appreciation

### Situation

An investment position increases in value from Rp 1,000,000 to Rp 1,300,000.

### Expected Meaning

Asset Appreciation.

### Expected Outcome

* Investment value increases by Rp 300,000.
* Net worth increases by Rp 300,000.
* Income reports remain unchanged.
* Spending reports remain unchanged.

### Notes

Unrealized gains remain distinguishable from realized sales in investment reports and never inflate income.

---

## Subscription Renewal

### Situation

A monthly music subscription renews for Rp 55,000.

### Expected Meaning

Expense.

### Expected Outcome

* Cash decreases by Rp 55,000.
* Spending reports increase by Rp 55,000.
* Net worth decreases by Rp 55,000.

### Notes

Recurring expenses remain individual historical events while optionally being grouped for analysis.

---

## Receiving a Gift

### Situation

I receive Rp 250,000 as a birthday gift.

### Expected Meaning

Income.

### Expected Outcome

* Cash increases by Rp 250,000.
* Income reports increase by Rp 250,000.
* Net worth increases by Rp 250,000.

### Notes

Gifts can be categorized separately from salary or dividend income.

---

## Cash Adjustment

### Situation

My wallet contains Rp 50,000 more than recorded.

### Expected Meaning

Adjustment (`+`).

### Expected Outcome

* Cash increases by Rp 50,000.
* Net worth increases by Rp 50,000.
* Income reports remain unchanged.
* Spending reports remain unchanged.

---

## Cash Loss

### Situation

I discover Rp 50,000 is missing from my wallet.

### Expected Meaning

Adjustment (`-`).

### Expected Outcome

* Cash decreases by Rp 50,000.
* Net worth decreases by Rp 50,000.
* Income reports remain unchanged.
* Spending reports remain unchanged.
