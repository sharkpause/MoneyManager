# DATABASE SCHEMA

This document defines the concrete SQLite (`Drift`) schema for Money Manager.

The schema is designed around four core invariants:

1. **Rupiah Integers Only**: Every monetary column (`*_rp`) is a 64-bit integer (`INTEGER`) representing whole Indonesian Rupiah (`Rp`). Zero floats, zero decimals.
2. **Strictly Positive Event Amounts**: `events.amount_rp` is always `> 0`. Direction is determined unambiguously by `from_asset_id`, `to_asset_id`, and `type`—never by guessing whether a number should be negative.
3. **Events as Source of Truth**: Current balances, open obligation amounts, net worth, and reports are derived from `initial_*_rp` + the `events` table, never stored as mutable cached columns.
4. **Sync-Safe Rows**: Every domain table uses client-generated UUID primary keys (`TEXT`), `created_at`, `updated_at`, and soft-delete `deleted_at` (Unix epoch milliseconds UTC) so Mobile and Desktop databases can smart-merge deterministically via Google Drive or `.db` file import without ID collisions or lost deletions.

---

# Tables

## 1. `categories`

Stores the user-defined organizational hierarchy. Contains zero financial behavior.

| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | UUID |
| `name` | `TEXT` | `NOT NULL` | Display name (e.g., `Food`, `Coffee`, `IHSG`, `Other`) |
| `parent_id` | `TEXT` | `NULL` | FK → `categories.id` (`NULL` = top-level root category) |
| `icon` | `TEXT` | `NULL` | Optional icon identifier for UI |
| `color` | `INTEGER` | `NULL` | Optional ARGB integer color for charts/badges |
| `sort_order` | `INTEGER` | `NOT NULL` | Default `0`; controls ordering in pickers |
| `is_archived` | `INTEGER` | `NOT NULL` | `0` or `1`; hides retired categories from entry pickers without affecting historical reports |
| `created_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `updated_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `deleted_at` | `INTEGER` | `NULL` | Epoch ms UTC (`NULL` = active) |

---

## 2. `assets`

Stores both liquid cash `Accounts` and market-valued `Investment Positions`.

| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | UUID |
| `name` | `TEXT` | `NOT NULL` | e.g., `Cash`, `BCA`, `Jago`, `GoPay`, `BBCA`, `Nvidia` |
| `type` | `TEXT` | `NOT NULL` | `'account'` \| `'investment'` |
| `category_id` | `TEXT` | `NULL` | FK → `categories.id` (at most one category) |
| `initial_balance_rp` | `INTEGER` | `NOT NULL` | Default `0`; starting balance when onboarding so existing wealth doesn't fake Day-1 `Income` |
| `sort_order` | `INTEGER` | `NOT NULL` | Default `0` |
| `is_archived` | `INTEGER` | `NOT NULL` | `0` or `1`; hides closed accounts or exited positions |
| `created_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `updated_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `deleted_at` | `INTEGER` | `NULL` | Epoch ms UTC (`NULL` = active) |

---

## 3. `obligations`

Stores ongoing financial relationships (`Owed By Me` debts/installments and `Owed To Me` reimbursements/loans).

| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | UUID |
| `name` | `TEXT` | `NOT NULL` | e.g., `Phone Installment`, `Friend Dinner Split`, `BCA Credit Card` |
| `direction` | `TEXT` | `NOT NULL` | `'owed_by_me'` \| `'owed_to_me'` |
| `counterparty` | `TEXT` | `NULL` | Optional person/institution name (e.g., `Budi`, `BCA`) |
| `category_id` | `TEXT` | `NULL` | FK → `categories.id` (at most one category) |
| `initial_amount_rp` | `INTEGER` | `NOT NULL` | Default `0`; optional pre-existing unpaid balance at onboarding |
| `is_closed` | `INTEGER` | `NOT NULL` | `0` or `1`; marks settled/archived obligations |
| `created_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `updated_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `deleted_at` | `INTEGER` | `NULL` | Epoch ms UTC (`NULL` = active) |

---

## 4. `events`

The single atomic ledger of all historical financial actions.

| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | UUID |
| `type` | `TEXT` | `NOT NULL` | One of the 14 canonical event types (see matrix below) |
| `amount_rp` | `INTEGER` | `NOT NULL` | Always strictly positive (`amount_rp > 0`) in whole Rupiah |
| `occurred_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC when the financial event actually happened |
| `title` | `TEXT` | `NULL` | Optional short label (e.g., `Warteg Lunch`, `Installment 2/6`) |
| `from_asset_id` | `TEXT` | `NULL` | FK → `assets.id` whose balance **decreases** by `amount_rp` |
| `to_asset_id` | `TEXT` | `NULL` | FK → `assets.id` whose balance **increases** by `amount_rp` |
| `obligation_id` | `TEXT` | `NULL` | FK → `obligations.id` affected by this event |
| `category_id` | `TEXT` | `NULL` | FK → `categories.id` (strictly one; required on `income`, `expense`, `bad_debt`, `debt_payment`) |
| `related_event_id` | `TEXT` | `NULL` | FK → `events.id` for causal reversals (`refund` → original `expense` or `bad_debt`) |
| `created_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `updated_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `deleted_at` | `INTEGER` | `NULL` | Epoch ms UTC (`NULL` = active) |

> **Future-Proof Note on Grouping**: Events are strictly atomic. If convenience multi-insert UI forms or visual grouping are ever wanted later, an optional `group_id TEXT NULL` column can be added via `ALTER TABLE` without modifying existing rows or any report calculation.

---

### Event Type Column Matrix

Every one of the 14 event types maps cleanly onto the `events` columns above:

| `type` | `from_asset_id` (`-`) | `to_asset_id` (`+`) | `obligation_id` | `category_id` | `related_event_id` |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `income` | `NULL` | `Account` | `NULL` | **Required** | `NULL` |
| `expense` | `Account` | `NULL` | `NULL` | **Required** | `NULL` |
| `transfer` | Source `Account` | Dest `Account` | `NULL` | Optional | `NULL` |
| `investment_purchase` | Source `Account` | `Investment` | `NULL` | Optional | `NULL` |
| `investment_sale` | `Investment` | Dest `Account` | `NULL` | Optional | `NULL` |
| `temporary_expense` | `Account` | `NULL` | `Owed To Me` (`+`) | Optional | `NULL` |
| `reimbursement` | `NULL` | `Account` | `Owed To Me` (`-`) | Optional | `NULL` |
| `bad_debt` | `NULL` | `NULL` | `Owed To Me` (`-`) | **Required** | `NULL` |
| `debt_creation` | `NULL` | `NULL` | `Owed By Me` (`+`) | Optional | `NULL` |
| `debt_payment` | `Account` | `NULL` | `Owed By Me` (`-`) | **Required** | `NULL` |
| `refund` | `NULL` | `Account` | `NULL` | Inherited / Optional | **Required** (`→ expense` / `bad_debt`) |
| `asset_appreciation` | `NULL` | `Investment` | `NULL` | Optional | `NULL` |
| `asset_depreciation` | `Investment` | `NULL` | `NULL` | Optional | `NULL` |
| `adjustment` *(gain)* | `NULL` | `Asset` | `NULL` | Optional | `NULL` |
| `adjustment` *(loss)* | `Asset` | `NULL` | `NULL` | Optional | `NULL` |

*(Note: If a written-off `Bad Debt` is unexpectedly repaid in cash later, logging a `refund` pointing via `related_event_id` to that `bad_debt` event cleanly restores cash, reverses the bad-debt expense, and restores net worth without reopening negative obligation math.)*

---

## 5. `journal_entries`

Stores free-text notes attached to an event, asset, or obligation (or standalone general reflections if all three foreign keys are `NULL`).

| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `id` | `TEXT` | PK | UUID |
| `content` | `TEXT` | `NOT NULL` | Free-text / Markdown note |
| `occurred_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC timestamp of the note |
| `event_id` | `TEXT` | `NULL` | FK → `events.id` |
| `asset_id` | `TEXT` | `NULL` | FK → `assets.id` (supports chronological thesis timeline on an asset) |
| `obligation_id` | `TEXT` | `NULL` | FK → `obligations.id` |
| `created_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `updated_at` | `INTEGER` | `NOT NULL` | Epoch ms UTC |
| `deleted_at` | `INTEGER` | `NULL` | Epoch ms UTC (`NULL` = active) |

---

## 6. `local_sync_meta` *(Device-Local Only — Excluded From Merge)*

A tiny key-value table used strictly by the local device to remember local settings and sync state (e.g., `last_drive_sync_at`, `drive_file_id`, `device_id`).

| Column | Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `key` | `TEXT` | PK | Setting / metadata key |
| `value` | `TEXT` | `NOT NULL` | String / JSON value |

---

# Universal Derived State Formulas

Because `from_asset_id` always means `-amount_rp` and `to_asset_id` always means `+amount_rp` (across active rows where `deleted_at IS NULL` and `occurred_at <= t`):

* **Balance of any Asset $A$ at time $t$**:
  $$\text{Balance}(A, t) = A.\text{initial\_balance\_rp} + \sum_{\text{to\_asset\_id} = A} \text{amount\_rp} - \sum_{\text{from\_asset\_id} = A} \text{amount\_rp}$$

* **Remaining Balance of any Obligation $O$ at time $t$**:
  * For `owed_by_me`: `initial_amount_rp + sum(debt_creation) - sum(debt_payment)`
  * For `owed_to_me`: `initial_amount_rp + sum(temporary_expense) - sum(reimbursement) - sum(bad_debt)`

* **Current Net Worth at time $t$**:
  $$\text{Current Net Worth}(t) = \sum_{A \in \text{Assets}} \text{Balance}(A, t) + \sum_{O \in \text{OwedToMe}} \text{Balance}(O, t)$$

* **Projected Net Worth at time $t$**:
  $$\text{Projected Net Worth}(t) = \text{Current Net Worth}(t) - \sum_{O \in \text{OwedByMe}} \text{Balance}(O, t)$$

---

# Indexes

* `events(occurred_at)` — date-window slicing and multi-month bucketing
* `events(type)` — report lens filtering
* `events(category_id)` — hierarchical category rollups
* `events(from_asset_id)` & `events(to_asset_id)` — fast point-in-time asset balance reconstruction
* `events(obligation_id)` — obligation balance and payment history lookup
* `events(related_event_id)` — cross-period `refund` attribution lookup
* `categories(parent_id)` — category tree traversal
* `journal_entries(event_id)`, `journal_entries(asset_id)`, `journal_entries(obligation_id)` — attached notes lookup
