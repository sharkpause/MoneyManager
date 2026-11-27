# Platform & Architecture Philosophy

Money Manager is built strictly for my own personal use (published only as source code on GitHub, never deployed for a broader audience) from a **single Flutter codebase** targeting **iOS (via SideStore)**, **Android**, and **Native Desktop (Linux / Windows)**.

---

## Full Feature Parity, Adaptive Ergonomics

Mobile and Desktop have **100% feature parity**—neither platform is stripped down. Every event editor, category manager, lens toggle, and report drill-down exists on both.

The difference is purely **layout ergonomics**:

### Mobile Experience (Compact Layout)

Optimized for speed, thumb reach, and daily on-the-go use:

* Fast, low-friction recording of financial events
* Stacked navigation, bottom navigation bar, and bottom sheets
* Quick checks on balances, obligations, and monthly spending discipline
* Full access to reports via progressive vertical drill-down

### Desktop Experience (Expanded Layout)

Optimized for screen real estate, keyboard/mouse comfort, and seeing the bigger picture:

* Sidebar navigation and multi-pane split views (e.g., category pie chart, trend view, and underlying event list visible side-by-side)
* Comfortable long-form `Journal Entry` writing and end-of-month deep reviews
* Drag-and-drop `.db` import/merge alongside 1-tap sync

---

## Single-Codebase Layered Architecture

Following Flutter's standard **Layered MVVM + Adaptive UI** pattern, business logic and state are written once while layouts adapt cleanly by available window width:

```text
lib/
├── core/               # Constants, Rp formatters, result types, constructor DI
├── data/               # SQLite (Drift), Repositories, .db export/import, Google Drive sync
├── domain/             # Entities, Event rules, and 3-layer Composable Report Engine
└── ui/
    ├── core/           # Shared charts, theme, adaptive shell (BottomNav vs. NavigationRail)
    └── features/
        └── <feature>/
            ├── <feature>_view_model.dart    # Shared state & actions (written once)
            ├── <feature>_compact_view.dart  # Mobile / narrow-window layout (< 600px)
            └── <feature>_expanded_view.dart # Desktop / wide multi-pane layout (>= 600px)
```

* Layouts switch by **window width breakpoints** (`LayoutBuilder` / `MediaQuery.sizeOf`), not hardcoded OS checks—so resizing a desktop window narrow beside another window still behaves cleanly.
* Because both views bind to the **same ViewModel**, Mobile and Desktop never drift out of feature parity.

---

## Local-First Storage & Sync

Each device stores the complete financial history locally in **SQLite (`Drift`)**.

To move and sync data seamlessly between Mobile and Desktop without running a custom backend server:

1. **UUID Merge Foundation**: Every entity and event uses client-generated UUIDs, `updated_at` timestamps, and soft-deletes (`deleted_at`) so two database snapshots can smart-merge changes made on either device without blindly overwriting newer edits.
2. **Drag-and-Drop / File Export & Import**: One-action SQLite snapshot export (`VACUUM INTO`) and drag-and-drop import/merge on Desktop (and native file share/picker on iOS/Android) for offline transfer and manual backups.
3. **Google Drive Sync**: Direct sync against my personal Google Drive account using `googleapis` + `googleapis_auth` (with personal OAuth credentials kept local/gitignored outside the public repo), doubling as an automatic off-device backup.

---

## iOS Delivery via SideStore & GitHub Actions

To run natively on my iPhone from a Linux dev environment without paying the \$99/year Apple Developer fee:

* **Unsigned CI Builds**: GitHub Actions (`macos-latest`, free on the public repo) compiles `flutter build ios --release --no-codesign` and packages `Runner.app` into an unsigned `.ipa` artifact/release.
* **On-Device Sideloading**: Installed and refreshed every 7 days directly on the iPhone via **SideStore** (preserving the app's sandbox `Documents/` SQLite database across refreshes).
* **SideStore Signing Constraints**: Because SideStore re-signs the `.ipa` on-device with a free personal Apple ID (rewriting Team ID and appending a suffix to the Bundle ID):
  * Never depend on paid Apple entitlements (iCloud, Push Notifications, App Groups, or custom Keychain Sharing groups).
  * Avoid Bundle-ID-locked `google_sign_in`; use `googleapis_auth` and persist iOS OAuth refresh tokens inside `local_sync_meta` in the sandboxed SQLite database (avoiding iOS Keychain `-34018` entitlement errors on re-signed builds).
