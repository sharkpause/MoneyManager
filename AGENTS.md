# AGENTS.md — Architecture & Guardrails

## 1. Scope & Identity
**Money Manager** is a local-first personal finance app built **strictly for a single user (the creator)**.
- **Targets**: **Android** + **Native Desktop (Linux / Windows)** from one Flutter codebase with **100% feature parity**.
- **Public Repo Only**: Never add multi-user auth, cloud SaaS backends, telemetry, or multi-currency abstractions. Keep personal OAuth credentials in gitignored local config.

## 2. Source-of-Truth (`Docs/`)
Read the relevant spec before changing domain, DB, or reporting code. Never contradict `Docs/` without approval:
- `Docs/Vision.md` & `Docs/DesignPrinciples.md` — Purpose and 14 core rules.
- `Docs/Entities.md`, `Docs/Events.md`, `Docs/Relationships.md` — Entities, 14 event types, causal links.
- `Docs/Scenarios.md` — Expected numerical outcomes (use as acceptance test specs).
- `Docs/Reports.md` — Reporting rules, lens toggles, 3-layer report pipeline.
- `Docs/App.md` — Adaptive Mobile/Desktop ergonomics and sync strategy.
- `Docs/Schema.md` — SQLite (`Drift`) tables, 14-event column matrix, balance/net-worth formulas.

## 3. Tech Stack & Commands
Do **not** introduce competing state managers, ORMs, or routers:
- **UI & State**: Flutter (Dart 3, Material 3), built-in **`ChangeNotifier` + `ListenableBuilder`** (MVVM). *No Riverpod, Bloc, GetX, or MobX.*
- **Navigation & Charts**: `go_router` (`StatefulShellRoute`), `fl_chart`.
- **Database & IDs**: `drift` + `drift_flutter` + `sqlite3` (native SQLite + `VACUUM INTO`), `uuid`.
- **Sync & Files**: `googleapis` + `googleapis_auth` + `flutter_secure_storage`, `file_selector` + `desktop_drop`.
- **Testing**: `flutter_test` / `test` with in-memory `NativeDatabase.memory()`.
- **Commands**:
  - Codegen: `dart run build_runner build --delete-conflicting-outputs`
  - Analyze & Test: `flutter analyze` | `flutter test`

## 4. Structure & Layer Rules
```text
lib/
├── core/        # Constants, Rp formatters, result types, constructor DI
├── data/        # Drift DB, tables, repositories, .db export/import, UUID merge, Drive sync
├── domain/      # Pure Dart entities, event validators, 3-layer Report Engine
└── ui/
    ├── core/    # Theme, shared chart/picker widgets, adaptive shell (BottomNav vs. Rail)
    └── features/<feature>/
        ├── <feature>_view_model.dart    # Shared ChangeNotifier
        ├── <feature>_compact_view.dart  # Narrow layout (< 600px)
        └── <feature>_expanded_view.dart # Wide multi-pane layout (>= 600px)
```
- **`domain/` purity**: Pure Dart only (no `flutter` or `data/` Drift imports); all money is `int` (`*_rp`), never `double`.
- **View rules**: Zero math/DB calls in Views; share one `ViewModel` and switch layouts via `LayoutBuilder` width, never `Platform.is*`.
- **DB & Sync**: Derive balances/reports from `events` (no cached balance columns); merge `.db` transactionally in FK order (`categories → assets → obligations → events → journal_entries`) via `updated_at` + `deleted_at`, excluding `local_sync_meta`.

```