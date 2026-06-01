# Free Temporary Material Flow

> ClickUp Task: <task_id>
> Related: `docs/inbox/2026-05-29_premium_restructure.md`
> Status: Draft
> Scope: Planning only. No implementation.

## Summary

This document refines the Premium restructure plan to ensure free-tier material limits apply to saved materials only, never to calculator usability.

Free users may save up to 5 materials, but must still be able to cost prints with a new filament even after reaching that saved-material cap. To support this, free users may use up to 1 temporary material per calculation. Temporary materials are calculator-local, never persisted, and do not count toward saved-material quotas.

## Problem

The current Premium restructure plan caps free users at 5 saved materials. However, the calculator currently supports ad-hoc material creation during costing flows. Without a separate temporary-material path, a free user who already has 5 saved materials could be blocked from costing a print with a new filament.

This is not acceptable.

Guiding principle:

- Material limits apply to persistence and library management.
- Material limits must not block costing calculations.
- Calculator flows must remain usable even when saved-material quota is exhausted.

## Approved Product Rules

### Free users

- Up to 5 saved materials.
- Up to 1 temporary unsaved material per calculation.
- Temporary materials are calculator-only and are never persisted.
- If no saved materials exist, the calculator must allow immediate temporary material entry.
- If saved materials exist, the material picker must offer an `Unsaved Material` option as a selectable fake material.
- Only one unsaved material may be selected within a calculation. Once selected, it disappears from the picker like any other already-selected material.
- Free users may combine saved materials and one temporary material in multi-material calculations.
- A free user may therefore use up to 5 saved materials plus 1 temporary material in a single calculation.

### Premium users

- Unlimited saved materials.
- Material import.
- Remaining filament / stock tracking.
- Unlimited material management.
- Temporary material support may remain available if it simplifies implementation.

## Non-goals

- No change to saved-material repository schema unless implementation later requires it.
- No temporary material persistence in the materials library.
- No stock tracking for temporary materials.
- No import flow for temporary materials.
- No cross-session restoration of temporary materials outside normal calculator state/history behavior.

## Definitions

### Saved material

A repository-backed material that:
- appears in the materials library
- can be edited/deleted/duplicated/imported
- counts toward saved-material quota
- may participate in stock tracking for Premium

### Unsaved temporary material

A calculator-local material that:
- exists only inside the active calculation flow
- never appears in the materials library
- never writes to the materials repository
- does not use the saved-material create flow
- does not count toward saved-material quota
- does not support stock tracking
- may be used in single-material or multi-material calculations

## Current Behavior And Planning Conflict

Current code/path assumptions create a mismatch with the Premium restructure plan:

- free users can access the materials page
- free users are planned to have 5 saved materials
- calculator picker currently supports add/create behavior inside costing flow
- saved-material creation is quota-guarded at persistence boundary

Conflict:

- once saved-material cap is reached, a repository-backed create path may deny the user from using a new filament during costing
- this would make quota rules block calculator capability, which violates product intent

This document resolves that conflict by separating:
- saved-material persistence
- temporary calculator-only material entry

## Desired User Experience

### Flow A: no saved materials exist

- User opens calculator material selection.
- User is not forced to visit materials library first.
- Calculator immediately allows temporary material entry.
- User can complete costing with that temporary material.

### Flow B: saved materials exist and user wants one of them

- User opens material picker.
- Picker shows saved materials.
- User selects a saved material.
- Calculation updates as normal.

### Flow C: saved materials exist and user wants a new filament not in library

- User opens material picker.
- Picker shows saved materials plus `Unsaved Material`.
- User chooses `Unsaved Material`.
- User enters unsaved material data required for costing.
- Unsaved material becomes part of the active calculation only.

### Flow D: free user already has one temporary material in the calculation

- User cannot add a second unsaved material.
- Picker hides `Unsaved Material`, matching the existing rule that a material can only be selected once per calculation.
- Existing unsaved material remains editable/removable within the calculation.

### Flow E: multi-material free flow

- User may combine:
  - saved + saved
  - saved + one temporary
- User may not combine:
  - temporary + temporary

## Quota Rules

### Saved-material quota

- Free: maximum 5 saved materials.
- Premium: unlimited saved materials.

### Temporary-material quota

- Free: maximum 1 temporary material per calculation.
- Premium: unlimited or unchanged temporary-material behavior, if keeping same path reduces branching.

### Enforcement boundary

Saved-material quota applies to:
- create
- duplicate
- import
- any action that persists a new library material

Saved-material quota does not apply to:
- selecting existing saved materials in calculator
- using existing saved materials after downgrade
- creating one unsaved material inside the calculator
- recalculating with an unsaved material already in the active calculation

Saved-material creation and unsaved-material selection are separate flows. A free user may still create a saved material from the picker if they are below the 5-material cap. Choosing `Unsaved Material` is not a create action, does not call the material form submit path, and must never persist anything to the materials repository.

## PremiumAccessPolicy Implications

The Premium restructure should separate material-library access from calculator-temporary access.

Recommended policy shape:

- `savedMaterialsLibrary()`
- `unsavedMaterialInCalculator()` (removed — all users always get unsaved option via `onUnsavedSelected`)
- `multiMaterial()`
- `csvMaterialImport()`
- `stockTracking()`
- `canCreateSavedMaterial(int currentCount)`

Recommended free defaults:

- saved materials library: allowed
- unsaved material in calculator: allowed
- multi-material: allowed
- CSV import: denied
- stock tracking: denied
- create saved material: allowed only under cap

Important distinction:

- policy for browsing/using saved materials in calculator should not imply permission to persist another saved material
- unsaved material selection must remain available even when `canCreateSavedMaterial(...)` denies persistence

## Material-Management Flows

### Materials page

Free users:
- may view existing saved materials
- may edit existing saved materials
- may delete existing saved materials
- may create saved materials until cap
- may not import materials
- may not create a 6th saved material

At cap:
- add action disabled or upsell-gated
- duplicate action denied
- import denied
- existing saved materials remain usable and editable

### Material form

Saved-material form remains a persistence flow.

Unsaved material selection must not depend on normal saved-material submit semantics. It is a calculator selection path only, not a create flow and not a draft material form that later submits to the repository.

## Calculator Flows

### Picker behavior

If saved materials exist:
- show saved materials
- show `Unsaved Material` option as a fake selectable material

If no saved materials exist:
- show unsaved-material entry immediately or as the primary picker action

If an unsaved material already exists in the calculation:
- hide the `Unsaved Material` option, because the existing selection rules already prevent selecting the same material twice

### Temporary material lifecycle

Temporary material may:
- be selected from the picker as a fake material option
- be created inside calculator flow
- be edited inside calculator flow
- be removed from calculator flow
- participate in recalculation
- participate in multi-material flow

Temporary material may not:
- be saved to the materials library automatically
- go through the saved-material create flow
- be imported
- be used for stock deduction/tracking
- count toward saved-material cap

## History / Save Behavior

If a calculation using a temporary material is saved to history:

- history should preserve the calculation snapshot needed for accurate review/reload
- this must not create a new saved material in the materials repository
- temporary-material data should remain part of the saved calculation snapshot only, not library state
- reloading history may recreate the unsaved material inside the calculator as calculation-local state, but must not create a saved material

This preserves costing continuity without converting a temporary material into a persistent one.

## Downgrade Behavior

### Downgraded user over saved-material cap

If a Premium user downgrades while having more than 5 saved materials:

- existing saved materials remain intact
- existing saved materials remain selectable in calculator
- existing saved materials remain editable/deletable
- user cannot create/import/duplicate new saved materials while over cap
- user may still use 1 temporary material in a calculation

### Downgrade during active calculation

If downgrade happens while a calculation already contains a temporary material:

- active calculation remains usable
- existing temporary material may remain in that calculation
- second temporary material remains disallowed under free rules

## Edge Cases

- Free user at 5 saved materials starts a new print with a new filament.
- Free user has zero saved materials and starts from calculator first.
- Free user removes a temporary material, then adds another in the same calculation.
- Free user tries to add two temporary materials in one multi-material calculation.
- Free user combines 5 saved materials plus 1 temporary material across a single calculation.
- Temporary material exists when loading/modifying imported G-code values.
- Calculation containing temporary material is saved to history.
- History reload restores temporary-material-derived costing without creating a saved material.
- Downgraded user remains over saved-material cap.
- Premium-only stock tracking fields exist on saved materials after downgrade.
- Localization and upsell messaging distinguish saved-material cap from calculator-temporary availability.

## Test Plan

### Unit tests

- policy matrix: saved-material library vs temporary-material calculator access
- saved-material create quota under/at/over cap
- temporary-material limit of one per calculation
- downgrade over-cap behavior does not block calculator usage

### Notifier/service tests

- saved-material create denied at cap
- saved-material duplicate denied at cap
- import denied for free
- temporary material creation does not call materials repository save path
- temporary material remains usable when saved-material cap reached

### Widget tests

- picker shows `Unsaved Material` for free users
- picker still offers temporary path when saved-material cap reached
- picker allows immediate temporary flow when no saved materials exist
- picker hides/disables second temporary-material path after one exists
- materials page blocks sixth saved material but keeps existing materials accessible

### Integration/E2E tests

- free user with zero saved materials can cost using temporary material
- free user with 5 saved materials can still cost using temporary material
- free user can mix saved materials and one temporary material
- free user cannot persist a 6th saved material
- downgraded premium user over cap can still cost with existing saved materials and one temporary material

## Recommended Representation

Recommended approach: calculator-local fake material selection.

Reasoning:

- best matches product rule that unsaved materials are selected for calculation only and are not persisted
- avoids coupling temporary calculator flows to repository-backed material management
- minimizes quota bugs
- simplifies downgrade semantics
- keeps material-limit enforcement focused on persistence boundaries

Not recommended:

- dedicated persisted temporary material entity
- reuse of normal saved-material create flow for unsaved material selection

Implementation bias:

- represent unsaved material as calculator-local state behind a fake picker option
- store only fields needed for costing and display: local temp id, name, cost-per-kg or source cost/weight inputs, optional color/type for UX parity
- never expose through `materialsStreamProvider`
- never send through `MaterialsRepository`
- serialize only into calculator/history snapshot if needed, not into materials library

## Impact On Premium Restructure Document

The following sections in `docs/inbox/2026-05-29_premium_restructure.md` should be updated to reference this document:

- Assumptions
- PremiumAccessPolicy API
- Centralization Rules
- New Free vs Premium Split
- Enforcement Points
- Phase 2.2 Materials enforcement
- Phase 3.1 Update PremiumAccessPolicy defaults
- Phase 3.2 Free calculator experience
- Phase 3.5 Free material management
- Testing Tasks
- Edge Cases
- Decisions

Suggested reference line:

`Temporary unsaved material support for free-tier calculator flows is specified in docs/inbox/2026-06-01_free-material-temporary-flow.md.`

## Decisions Proposed Here

| Question | Decision |
|---|---|
| Saved-material quota scope | Persistence and library management only, never calculator capability |
| Free temporary material per calculation | 1 |
| Unsaved material persistence | Never persisted to materials library and never routed through saved-material create flow |
| Saved material creation from picker | Separate flow allowed only while under saved-material cap |
| Free multi-material with temporary | Allowed, 1 temporary max per calculation |
| Over-cap downgrade and calculator | Existing saved materials remain usable; new persistence blocked; 1 temporary allowed |
