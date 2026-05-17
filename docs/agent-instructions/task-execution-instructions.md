## Purpose

This is the required execution contract for every batch costing implementation agent.

Before starting any batch costing implementation subtask, read this ticket and follow the rules here.

## Required Subtask Sequence

Work through the batch costing subtasks in this order:

1. `86c9u8c6z` Feature gate and hidden entry
2. `86c9u8da6` Batch item domain model and state
3. `86c9u8e0k` Batch review screen
4. `86c9u8cz0` Manual batch setup screen
5. `86c9u8cmw` G-code quantity enhancement
6. `86c9u8dqt` Add, edit, and remove manual batch items from review
7. `86c9u8dww` Multi-file G-code import
8. `86c9u8e64` Printer assignment step
9. `86c9u8ec7` Material assignment step
10. `86c9u8f06` Pricing scope step
11. `86c9u8fbq` Batch calculation and summary
12. `86c9u8fkb` Persistence/history deferral guardrail
13. `86c9u8fvv` Docs and validation checklist
14. Final integration and QA pass

Each task must leave real working state, UI, routes, or logic that the next task can build on. If the required previous task output is missing, stop and report the blocker.

## Required Execution Order

Follow this sequence for every assigned batch costing implementation task:

1. Read the assigned ClickUp task and this execution contract.
2. Checkout main.
3. Pull latest changes.
4. Create a new branch from main.
5. Move the assigned ClickUp task to **in progress**.
6. Implement only the assigned task.
7. Run required verification.
8. Apply valid fixes and rerun verification as needed.
9. Commit the changes.
10. Push the branch.
11. Open the PR against main.
12. Move the assigned ClickUp task to **in review**.
13. Report back with the PR link and outcome.

If a ClickUp status update fails, continue the implementation when safe and report the ClickUp status update failure in the final response and PR body.

Do not move this contract task unless you were explicitly assigned to update the contract itself.

## Branching

- Create a new branch from latest main.
- Use one branch and one PR per implementation subtask.
- Do not stack branches unless explicitly instructed.
- Keep changes scoped to the assigned subtask.
- Do not include unrelated refactors, formatting churn, or opportunistic cleanup.

## Scope Rules

- Implement only the assigned ClickUp subtask.
- Do not combine multiple batch costing subtasks into one PR.
- Do not introduce new packages.
- Do not perform broad architecture rewrites.
- Prefer small, reviewable diffs.
- If the task grows beyond the ClickUp description, stop and report back instead of expanding scope.

## Feature Gate

Batch costing must remain hidden unless the developer/debug flag is enabled.

- Default state is **disabled**.
- No incomplete UI may be visible to normal users.
- Existing calculator and G-code import flows must continue to work when the flag is disabled.
- `batchCostingEnabled` must hard-gate every visible batch-costing UI surface.
- With the flag off, normal calculator and G-code flows show zero batch-related UI.
- Do not rely on route gating alone or a hidden button alone.
- Batch-costing docs must carry the active ClickUp task ID at top; use cleanup task `86c9uq5xr` for this contract/update work.

## Behaviour Preservation Rules

Batch costing tasks must not change existing behaviour unless the assigned ClickUp task explicitly requires it.

**Do not change:**

- existing single-print calculator results
- RevenueCat or premium gating behaviour
- stored data formats
- migrations
- existing G-code parsing semantics outside the assigned batch flow
- export formats
- existing navigation behaviour outside the assigned batch flow
- existing localization keys unless intentionally updating related copy

## Architecture

- Reuse existing app architecture patterns.
- Use existing Riverpod/provider/notifier patterns where state is needed.
- Use existing route, validation, localization, and UI conventions.
- Keep batch-specific state separate from the current single-print calculator state unless values are intentionally seeded from it.
- Do not duplicate calculator cost logic. Reuse or safely extend the deterministic cost engine.

## Localization

All new user-facing strings must be localized.

**Rules:**

- Do not hardcode user-facing strings directly in widgets, dialogs, buttons, validation messages, snackbars, empty states, or error states.
- Add new strings to the ARB localization files: `lib/l10n/intl_*.arb`.
- Update **every** supported locale, not only English.
- Regenerate localization output with `fvm flutter gen-l10n` when required.
- Generated localization output lives in `lib/generated/l10n.dart`.
- Use the existing `S.of(context)` / generated localization patterns used in the app.
- Tests must use the existing localization setup, such as `S.delegate`, where widget tests render localized strings.
- Developer-only labels inside hidden debug/admin flows may stay hardcoded only if that matches the existing debug convention, but anything reachable in the batch user journey must be localized.

PR body must explicitly state whether localization was updated or why no new localized strings were required.

## Expected V1 Flow

### Manual path

1. Manual batch setup creates the first manual item.
2. Batch review shows real batch item state.
3. Add/edit/remove manual items from review.
4. Printer assignment.
5. Material assignment.
6. Pricing scope.
7. Summary / quote.

### G-code path

1. Existing G-code review supports quantity.
2. **Quantity 1** keeps existing calculator flow.
3. **Quantity greater than 1** creates a batch item and enters batch review.
4. Multi-file G-code import creates one batch item per successful file and enters batch review.

## Pricing Scope Rules

Values keep their normal units. Scope changes where the value applies.

**Default scopes:**

| Scope | Applies to |
|---|---|
| Additional cost | batch |
| Labour/processing | item |
| Risk | item |
| Markup | item |

## Required Validation

For every implementation task, run at minimum:

- `fvm flutter analyze`
- relevant unit/widget tests
- existing calculator tests where calculation logic is touched
- existing G-code import tests where import logic is touched

Run `make flutter_test` when shared app behaviour is touched.

For tasks that add or change user-facing strings, verify localization files are updated and generated localization output is refreshed using `fvm flutter gen-l10n`.

## Pull Request Requirements

Open a PR against main.

**PR title format:**

```
[<clickup-task-id>] <ClickUp task title>
```

**PR body must include:**

- ClickUp task link
- summary of changes
- tests run
- risks
- follow-up tasks, if any
- final verification result
- localization updates made, or why none were needed
- wiki updates made, or why none were needed
- ClickUp status update failures, if any

## Stop Conditions

Stop and report back when:

- required behaviour is unclear
- a required previous task output is missing
- existing tests fail for unrelated reasons
- the implementation requires changing existing public behaviour
- the task requires broad architectural changes
- the implementation would introduce a new package
- the task appears stale or already completed
- the work cannot remain hidden behind the batch costing feature flag

## Final Gate

Before the final response, verify:

- Required verification has been rerun after fixes.
- Existing calculator and G-code flows were checked when touched.
- New user-facing strings are localized, or no new user-facing strings were added.
- PR title matches the required format.
- Assigned ClickUp task was moved to **in review** only after the PR was created, unless ClickUp status update failed and was reported.

## Out of Scope for V1 Unless Explicitly Assigned

- Saving batch quotes to history
- Exporting batch quotes
- Shareable quote images/PDFs
- Multi-currency changes
- Tax settings
- Separate line items for shipping/admin/packaging
- Cloud/account/sync work
