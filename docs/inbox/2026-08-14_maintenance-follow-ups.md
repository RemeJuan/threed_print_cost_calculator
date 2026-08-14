# Maintenance Follow-ups

Date: 2026-08-14

## Goal

Reduce maintenance cost without changing product behavior. Preserve deterministic domain logic, offline-first storage, Riverpod boundaries, and RevenueCat premium gating.

Earlier maintenance work is tracked in `2026-07-14_project-maintenance-execution-plan.md`. This list covers remaining findings from the latest review.

## Todo

### Safe quick wins

- [x] Replace hardcoded history teaser preview rows in `lib/history/hooks/history_page_actions.dart` with a neutral/generated sample path. Keep user-facing strings localized.
- [x] Consolidate CSV quoting and spreadsheet-formula sanitizing from `lib/shared/utils/csv_generation.dart` and `lib/materials/csv_import/materials_csv_export_service.dart` into one shared helper. Add formula-prefix regression tests.
- [x] Add focused tests for `batch_flow_reset.dart`, `batch_pricing_formatter.dart`, and `batch_costing_page_state_sync.dart` under `test/batch_costing/helpers/`.
- [x] Split `test/helpers/lower_level_test_fakes.dart` into feature-scoped fake files. Preserve imports and test behavior.

### Characterize before refactor

- [x] Add or confirm regression coverage for `HistoryPagedNotifier`: query reset, paging, stale-generation suppression, error state, and refresh behavior.
- [x] Add or confirm regression coverage for premium local storage: cache behavior, secure-storage fallback, and local override expiry cleanup.
- [x] Add or confirm regression coverage for batch quote save: history persistence, usage tracking, analytics, error handling, and navigation outcomes.

### Product instrumentation follow-up

- [x] Add review-prompt analytics for existing `RateMyApp` flow in `lib/app/app.dart` and `lib/core/analytics/app_analytics.dart`. Preserve native review support; do not rewrite dialog UX.
- [x] Track coarse native-capable funnel: eligibility check reached, prompt request attempted, custom dialog shown when fallback path used, custom dialog action (`rate|later|no`), and dismiss without action.
- [x] Document limits in `docs/analytics.md`: native review outcome and submitted store rating cannot be observed reliably.
- [x] Add regression tests for analytics wrappers and `RateMyApp` wiring in `test/core/analytics/app_analytics_test.dart` and `test/app/view/app_test.dart` or focused review-prompt tests.

### Careful refactors

- [x] Split `lib/batch_costing/helpers/batch_quote_save_service.dart`: persistence mapping/service, analytics, quote-name dialog, and success-dialog/navigation actions. Keep UI out of save core.
- [x] Split `lib/history/provider/history_paged_notifier.dart`: state model, repository paging/fetch logic, and thin notifier. Preserve stale-generation guard exactly.
- [ ] Split `lib/purchases/premium_local_store.dart` by interface and implementation: shared preferences, secure storage, cached wrapper, in-memory store. Preserve iOS keychain workaround behavior.
- [ ] Decouple `lib/purchases/paywall_screen_controller.dart` from `paywall_plan_selector.dart`; move package-selection logic below widget layer. Consider separate controller state/outcome model files.
- [ ] Split `lib/batch_costing/widgets/batch_allocation_picker_dialog.dart` into dialog composition, entry model/state, search, and validation pieces without changing allocation semantics.

### Later cleanup candidates

- [ ] Extract swipe-hint preference access from `lib/materials/widgets/materials_page.dart` into an injected notifier/service.
- [ ] Extract reset dialog, save section, and batch-entry area from `lib/calculator/view/calculator_page.dart`; preserve init/submit timing.
- [ ] Split oversized test files by behavioral domain: batch G-code import, G-code controller, materials page, and Play Integrity service.

## Delivery rules

- One behavior-preserving concern per PR.
- Add characterization tests before premium, persistence, paging, or save-flow structural edits.
- Do not change premium policy, local-first persistence semantics, or navigation behavior during file splits.
- Validate with focused tests and `fvm flutter analyze`; run `make flutter_test` before merging grouped maintenance work.
