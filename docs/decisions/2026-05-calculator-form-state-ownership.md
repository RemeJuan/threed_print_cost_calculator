# 2026-05-calculator-form-state-ownership

## Context

Calculator form input values were resetting implicitly. Defaults/settings/hydration
re-ran on page mount, `appRefreshProvider` changes, tab switches, and accordion
collapse. Users lost in-progress values when navigating away and back, switching
tabs, or when any app-refresh event fired. Settings changes could silently mutate
an active draft calculation.

No explicit "new calculation" or "reset" action existed. The only way to return
to defaults was to kill the app and relaunch.

## Decision

Introduce a single form-state source of truth in `CalculatorState` with an
explicit hydration sentinel (`hasHydratedDefaults`). Defaults/settings hydrate
the form exactly once. After hydration, the calculator draft owns all active
values until the user taps an explicit Reset action.

Key semantics:

| Aspect | Before | After |
|--------|--------|-------|
| Default hydration | Merged on every `init()` call | One-shot; `hasHydratedDefaults` guard |
| Navigation / tab switch | Values could reload from settings | Values persist — `init()` returns early |
| Explicit 0 | Could be overwritten by settings reload | 0 survives remount / re-init |
| Empty/cleared field | Could silently reload defaults | Stays empty |
| Reset | Did not exist | Explicit button with confirmation dialog |
| Save payload | Read live settings as fallback/baseline | Reads draft-owned ids + baseline snapshots |
| Printer/material selection | Lived in settings stream / local widget state | Lives in `CalculatorState` |
| History load | Started from `currentState.copyWith(...)`, leaked old override/pricing state | Builds fresh state from history fields + draft baselines |
| Settings changes during edit | Could mutate active draft | Ignored unless Reset tapped |

### State additions

`CalculatorState` gained:

- `activePrinterId`, `selectedMaterialId` — form-owned printer/material selection
- `hasHydratedDefaults` — sentinel that blocks implicit rehydration
- Baseline snapshot fields (`baselineWearAndTear`, `baselineFailureRisk`, etc.) —
  frozen copies of settings/defaults at hydration time, used for override
  detection in save flow instead of live settings

### Provider additions

- `selectPrinter(String)` — persists selection to settings and updates draft-owned
  printer + wattage
- `resetToDefaults()` — cancels debounced submit, reloads clean defaults from
  current settings, recomputes pricing, does not seed material rows
- `setSetupFee(num)`, `setRoundingMode(PricingRoundingMode)` — local-only mutators
  for fields that previously had no calculator-level editor

### Reset UI

- OutlinedButton beside Save Print (key `calculator.reset.button`)
- Confirmation `AlertDialog` with localized title/body
- On confirm: closes save form, calls `resetToDefaults()`, material section returns empty

### History load

- No longer uses `currentState.copyWith(...)`. Builds a fresh `CalculatorState`
  from stored history pricing fields, material usages, and draft baseline
  snapshots for fields not stored in history (wear, failure, labour).
- Sets its own baseline snapshot to freeze loaded/default values.
- Carries forward `kwCost`, spool defaults, and other runner-level fields from
  the current draft.

## Alternatives considered

- **Merge-on-init (status quo ante)**: preserved some in-progress values but also
  re-applied settings defaults on every init; too unpredictable.
- **Per-widget controller as source of truth**: controllers already local;
  elevating them would scatter business logic across widgets.
- **Auto-save draft to DB**: unnecessary persistence for transient calculator
  edits; adds complexity for no user-facing benefit.

## Tradeoffs

- More fields in `CalculatorState` and `copyWith` boilerplate.
- Baseline snapshots add conceptual overhead — but eliminate settings dependency
  in save/override logic.
- Material section starts empty on first open; user must explicitly add materials.
  (Previously the default selected material auto-seeded a row.)

## Status

Implemented.

## Implementation notes

Key files:

- `lib/calculator/state/calculator_state.dart` — new fields + baseline snapshots
- `lib/calculator/provider/calculator_notifier.dart` — hydration guard, reset API, printer ownership, pricing mutators
- `lib/calculator/provider/calculator_settings_sync.dart` — one-shot load, optional material seed, baselines
- `lib/calculator/provider/calculator_history_loader.dart` — fresh state construction, baseline carry-forward
- `lib/calculator/view/calculator_page.dart` — Reset button + confirmation dialog
- `lib/calculator/view/printer_select.dart` — reads calculator state, not settings stream
- `lib/calculator/view/save_form.dart` — reads draft-owned ids, compares against draft baselines
- `lib/calculator/provider/material_selection_recalculation_test.dart` — async material selection with settings persistence
- `test/calculator/provider/calculator_init_persistence_test.dart` — regression: re-init, zero semantics, settings immunity, reset, empty materials
- `test/calculator/provider/load_from_history_test.dart` — override/pricing leakage guards
- `test/calculator/view/save_form_test.dart` — blank draft, active draft over settings
- `test/calculator/view/calculator_page_lower_level_test.dart` — reset UI confirmation
