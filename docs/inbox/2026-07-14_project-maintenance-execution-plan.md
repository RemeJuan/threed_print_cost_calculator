# Project Maintenance Execution Plan

Date: 2026-07-14

## Goal

Reduce maintenance cost without changing behavior. Preserve deterministic domain logic, local-first Sembast storage, Riverpod UI/domain separation, and RevenueCat premium gating.

## Ordered task list

- [x] Add calculator notifier state-transition tests before refactor.
- [x] Split calculator notifier orchestration from collaborators in small sequential PRs.
- [x] Extract paywall offering/purchase/restore controller from `PaywallScreen`.
- [x] Decompose help and support page side effects and FAQ construction.
- [x] Split app shell navigation/effects from `AppPage` layout.
- [x] Split history screen modes, pagination wiring, and UI composition.
- [x] Extract settings premium card/page actions.
- [x] Split batch costing page composition widgets.
- [x] Extract startup migration registry and legacy history transformer.
- [x] Split material form into logical field sections.
- [x] Add G-code import end-to-end coverage.
- [x] Add settings material/printer CRUD persistence journeys.
- [x] Add history save/export/share journey coverage.
- [x] Add app-wide free/premium gating journeys.
- [x] Remove or justify stale history paging debug fields after usage confirmation.

## Sequencing

1. Tests establish characterization coverage for calculator transitions. Scope only missing public-transition contracts: reset transient cleanup, history-load atomicity/warning/import state, import edge cases, settings override behavior, and pending completed-costing cancellation.
2. Calculator refactor proceeds only after baseline passes; split collaborators one at a time.
3. Commerce and persistence refactors require focused behavioral tests before structural changes.
4. Screen composition extractions remain behavior-preserving and independently reviewable.
5. End-to-end coverage tasks follow stable UI keys and existing test harness conventions.

## Validation per task

- run `make flutter_generate` before analyze when ARB/localization or other generated-code inputs change
- `fvm flutter analyze`
- focused tests for changed behavior
- full `make flutter_test` before grouped milestone or merge

## Findings source

- `lib/calculator/provider/calculator_notifier.dart`: 776 LOC orchestration hotspot.
- `lib/purchases/paywall_screen.dart`, `lib/app/help_support/help_support_page.dart`: UI side-effect boundaries.
- `lib/app/app_page.dart`, `lib/history/history_page.dart`, `lib/settings/settings_page.dart`, `lib/batch_costing/batch_costing_page.dart`: screen composition hotspots.
- `lib/history/provider/history_paged_notifier.dart`: `debugQueryCount` and `debugUsedFallbackScan` appear write-only; confirm before removal.
- Missing focused journeys: G-code import, settings CRUD persistence, history save/export/share, app-wide premium gating.

## Phase 1 test scope

- `test/calculator/provider/calculator_init_persistence_test.dart`: reset from dirty/imported/history-warning state; latest settings/preferences reload; reset does not seed initial material usage.
- `test/calculator/provider/load_from_history_test.dart`: settings-persistence failure atomicity, imported-G-code restoration, warning dismissal, unsaved material rows.
- `test/calculator/provider/calculator_import_values_test.dart`: null argument preservation, negative weight clamp, imported flag, recalculation, usage recording.
- `test/calculator/provider/pricing_settings_sync_test.dart`: pre-hydration event ignore plus baseline/override behavior. Current coupling between markup override and setup/rounding baseline refresh requires explicit legacy characterization or a separate bug task.
- `test/calculator/provider/calculator_completed_costing_test.dart`: reset/history-load cancels pending completed-costing tracking.
