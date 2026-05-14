# Maintenance Review: 3D Print Cost Calculator

## Summary

Repo shape solid. Biggest maintenance drag: large files mixing UI, persistence, analytics, and domain orchestration in same place. No obvious TODO/deprecated-code pile. Better investment: split responsibilities at existing seams, add tests around untested UI-state persistence, avoid behavior rewrites.

## Findings

| File | Issue | Risk | Suggested cleanup | Effort |
|---|---:|---:|---:|---:|
| `lib/calculator/provider/calculator_notifier.dart` | One notifier owns hydration, selection, persistence, analytics, G-code apply flow, history load, submit orchestration | High | Keep notifier as facade. Extract collaborators for persistence/hydration, imported-value application, submit orchestration | L |
| `lib/history/history_page.dart` | Page owns hint prefs, analytics, debounce/listener lifecycle, export flow, teaser/paywall flow | High | Extract overflow-hint prefs helper, export sheet/widget, teaser/paywall action handlers | M |
| `lib/gcode_import/gcode_import_page.dart` | Page mixes analytics session logic, preview rendering, apply-to-calculator action, dialogs, navigation | High | Split summary/preview widgets. Move apply-flow + analytics payload shaping into helper/controller layer | M |
| `lib/settings/work_costs_form.dart` | Large form with repeated debounce timers and repeated `settingsService.update(...)` wrappers | Medium | Add shared debounced persistence helper. Split field groups into separate widgets/files | M |
| `lib/gcode_import/gcode_import_controller.dart` | Controller file also contains file-sniffing heuristics and state model/enums | Medium | Move validation/sniff helpers to dedicated helper. Move state/enums to separate state file | S |
| `lib/shared/components/settings_version_tap_target.dart` | Hidden test-tools widget also acts as admin action runner and cross-feature refresh orchestrator | Medium | Extract hidden-tools action service/controller. Keep widget focused on gesture gate + dialog launch | M |
| `lib/materials/widgets/materials_page.dart` | Page directly mutates repo, calculator cleanup, swipe-hint prefs, duplicate/delete flows | Medium | Move delete/duplicate/swipe-hint logic behind notifier/service callbacks | S-M |
| `lib/core/analytics/app_analytics.dart` | 710-line analytics sink accumulating feature-specific behavior | Medium | Split by feature behind stable facade. Keep event names unchanged | M |
| `lib/settings/materials/material_form.dart` | Large dialog with repeated field/validation plumbing and post-submit repository fetch | Medium | Split form sections. Isolate save/return-material flow helper | S-M |
| `lib/gcode_import/feedback/gcode_import_feedback_models.dart` | One-line re-export shim with mixed import styles in consumers | Low | Standardize one public import path, then decide if shim can die | S |

## Safe Quick Wins

- Add test coverage for history overflow hint persistence/analytics. Search found no test references for `history_overflow_hint` or `history_overflow_opened`.
- Add test coverage for materials swipe-hint persistence. Search found no tests for `materials_swipe_hint_shown`.
- Extract G-code sniff/validation helpers from `gcode_import_controller.dart`. Small, low-behavior-risk.
- Standardize feedback model imports to one path in `gcode_import/feedback/`.
- Introduce one internal helper for debounced settings persistence in `work_costs_form.dart` before any bigger split.

## Needs Careful Refactor

- `calculator_notifier.dart`. Core business flow. High blast radius across calculator, history, materials, G-code import.
- `history_page.dart`. Many hooks, timers, post-frame refresh, premium gating, export behavior.
- `gcode_import_page.dart`. Analytics flow and calculator apply path tightly coupled to UI.
- `app_analytics.dart`. Easy to churn event behavior if split carelessly.
- Currency-setting surfaces versus repo note saying currency-agnostic. This looks like doc/product mismatch, not safe blind removal. Clarify product intent first.

## Suggested ClickUp Tasks

### TECH: Extract history overflow hint + export actions from HistoryPage

Scope:
- `lib/history/history_page.dart`

Move prefs keys, hint tracking, export bottom-sheet plumbing into dedicated helpers/widgets. Add widget tests for hint persistence and open-event behavior.

Verification:
- `fvm flutter analyze` passes
- relevant focused tests pass

### TECH: Split G-code import controller helpers from state/orchestration

Scope:
- `lib/gcode_import/gcode_import_controller.dart`
- new helper/state files

Move file validation/sniff functions and state types into dedicated files. Backfill focused tests for unsupported/too-large/text-sniff cases.

Verification:
- `fvm flutter analyze` passes
- all `test/gcode_import/` tests pass

### TECH: Introduce debounced settings persistence helper for WorkCostsForm

Scope:
- `lib/settings/work_costs_form.dart`

Replace repeated timer/update/error-handling blocks with one reusable internal helper. Then split form into smaller field-group widgets.

Verification:
- `fvm flutter analyze` passes
- `test/settings/work_costs_form_test.dart` passes

### TECH: Move material duplicate/delete flows out of MaterialsPage

Scope:
- `lib/materials/widgets/materials_page.dart`
- `lib/materials/provider/`

Centralize repo mutation, calculator cleanup, and swipe-hint persistence behind notifier/service callbacks. Add tests for swipe-hint persistence.

Verification:
- `fvm flutter analyze` passes
- material tests pass

### TECH: Extract hidden tools action runner from SettingsVersionTapTarget

Scope:
- `lib/shared/components/settings_version_tap_target.dart`
- new service file

Keep gesture gate in widget; move tool actions, provider invalidation, and refresh orchestration to service/controller.

Verification:
- `fvm flutter analyze` passes
- settings tests pass

### TECH: Slice AppAnalytics by feature behind stable facade

Scope:
- `lib/core/analytics/app_analytics.dart`

Keep public event API stable. Internally separate calculator, premium, and G-code import analytics modules.

Verification:
- `fvm flutter analyze` passes
- `test/core/analytics/app_analytics_test.dart` passes

### TECH: Break CalculatorNotifier into orchestration + collaborators

Scope:
- `lib/calculator/provider/calculator_notifier.dart`
- new collaborator files

First extract persistence/hydration collaborator, then imported-values collaborator. Preserve notifier API and deterministic calculation behavior.

Verification:
- `fvm flutter analyze` passes
- calculator tests pass

### TECH: Standardize G-code feedback model import path

Scope:
- `lib/gcode_import/feedback/`

Pick one public import path, update consumers, remove shim only if no external need remains.

Verification:
- `fvm flutter analyze` passes

## Recommended First PR

`TECH: Split G-code import controller helpers from state/orchestration`

Why first:
- Smallest safe boundary cleanup.
- Existing test surface already strong in `test/gcode_import/*`.
- Low product risk.
- Creates pattern for later page/controller extraction work.

Files touched:
- `lib/gcode_import/gcode_import_controller.dart` — remove sniff helpers and state types
- New: `lib/gcode_import/gcode_import_validator.dart` — moved sniff/validation helpers
- New: `lib/gcode_import/gcode_import_state.dart` — moved enums and state class
- `test/gcode_import/gcode_import_controller_test.dart` — update imports
- New/adjusted tests for unsupported type, unsupported file, too-large, read-failure paths

Verification:
- `fvm flutter analyze` passes
- `fvm flutter test test/gcode_import/` passes
