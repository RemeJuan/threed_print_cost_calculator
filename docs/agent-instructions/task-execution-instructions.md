Purpose

This is the required execution contract for every batch costing implementation agent.

Before starting any batch costing implementation subtask, read this ticket and follow the rules here.

Required Subtask Sequence

Work through the batch costing subtasks in this order:

86c9u8c6z Feature gate and hidden entry
86c9u8da6 Batch item domain model and state
86c9u8e0k Batch review screen
86c9u8cz0 Manual batch setup screen
86c9u8cmw G-code quantity enhancement
86c9u8dqt Add, edit, and remove manual batch items from review
86c9u8dww Multi-file G-code import
86c9u8e64 Printer assignment step
86c9u8ec7 Material assignment step
86c9u8f06 Pricing scope step
86c9u8fbq Batch calculation and summary
86c9u8fkb Persistence/history deferral guardrail
86c9u8fvv Docs and validation checklist
Final integration and QA pass

Each task must leave real working state, UI, routes, or logic that the next task can build on. If the required previous task output is missing, stop and report the blocker.

Required Execution Order

Follow this sequence for every assigned batch costing implementation task:

Read the assigned ClickUp task and this execution contract.
Checkout main.
Pull latest changes.
Create a new branch from main.
Move the assigned ClickUp task to in progress.
Implement only the assigned task.
Run required verification.
Run CodeRabbit on the uncommitted diff.
Apply valid fixes and rerun verification as needed.
Commit the changes.
Push the branch.
Open the PR against main.
Move the assigned ClickUp task to in review.
Report back with the PR link and outcome.

If a ClickUp status update fails, continue the implementation when safe and report the ClickUp status update failure in the final response and PR body.

Do not move this contract task unless you were explicitly assigned to update the contract itself.

Branching

Create a new branch from latest main.
Use one branch and one PR per implementation subtask.
Do not stack branches unless explicitly instructed.
Keep changes scoped to the assigned subtask.
Do not include unrelated refactors, formatting churn, or opportunistic cleanup.

Scope Rules

Implement only the assigned ClickUp subtask.
Do not combine multiple batch costing subtasks into one PR.
Do not introduce new packages.
Do not perform broad architecture rewrites.
Prefer small, reviewable diffs.
If the task grows beyond the ClickUp description, stop and report back instead of expanding scope.

Feature Gate

Batch costing must remain hidden unless the developer/debug flag is enabled.
Default state is disabled.
No incomplete UI may be visible to normal users.
Existing calculator and G-code import flows must continue to work when the flag is disabled.

Behaviour Preservation Rules

Batch costing tasks must not change existing behaviour unless the assigned ClickUp task explicitly requires it.

Do not change:

existing single-print calculator results
RevenueCat or premium gating behaviour
stored data formats
migrations
existing G-code parsing semantics outside the assigned batch flow
export formats
existing navigation behaviour outside the assigned batch flow
existing localization keys unless intentionally updating related copy

Architecture

Reuse existing app architecture patterns.
Use existing Riverpod/provider/notifier patterns where state is needed.
Use existing route, validation, localization, and UI conventions.
Keep batch-specific state separate from the current single-print calculator state unless values are intentionally seeded from it.
Do not duplicate calculator cost logic. Reuse or safely extend the deterministic cost engine.

Localization

All new user-facing strings must be localized.

Rules:

Do not hardcode user-facing strings directly in widgets, dialogs, buttons, validation messages, snackbars, empty states, or error states.
Add new strings to the ARB localization files: lib/l10n/intl_*.arb.
Update every supported locale, not only English.
Regenerate localization output with fvm flutter gen-l10n when required.
Generated localization output lives in lib/generated/l10n.dart.
Use the existing S.of(context) / generated localization patterns used in the app.
Tests must use the existing localization setup, such as S.delegate, where widget tests render localized strings.
Developer-only labels inside hidden debug/admin flows may stay hardcoded only if that matches the existing debug convention, but anything reachable in the batch user journey must be localized.

PR body must explicitly state whether localization was updated or why no new localized strings were required.

Expected V1 Flow

Manual path:

Manual batch setup creates the first manual item.
Batch review shows real batch item state.
Add/edit/remove manual items from review.
Printer assignment.
Material assignment.
Pricing scope.
Summary / quote.

G-code path:

Existing G-code review supports quantity.
Quantity 1 keeps existing calculator flow.
Quantity greater than 1 creates a batch item and enters batch review.
Multi-file G-code import creates one batch item per successful file and enters batch review.

Pricing Scope Rules

Values keep their normal units.
Scope changes where the value applies.

Default scopes:

Additional cost = batch
Labour/processing = item
Risk = item
Markup = item

Required Validation

For every implementation task, run at minimum:

fvm flutter analyze
relevant unit/widget tests
existing calculator tests where calculation logic is touched
existing G-code import tests where import logic is touched

Run make flutter_test when shared app behaviour is touched.

For tasks that add or change user-facing strings, verify localization files are updated and generated localization output is refreshed using fvm flutter gen-l10n.

Pull Request Requirements

Open a PR against main.

PR title format must be:

[<clickup-task-id>] <ClickUp task title>

PR body must include:

ClickUp task link
summary of changes
tests run
risks
follow-up tasks, if any
final verification result
localization updates made, or why none were needed
wiki updates made, or why none were needed
ClickUp status update failures, if any

Stop Conditions

Stop and report back when:

required behaviour is unclear
a required previous task output is missing
existing tests fail for unrelated reasons
the implementation requires changing existing public behaviour
the task requires broad architectural changes
the implementation would introduce a new package
the task appears stale or already completed
the work cannot remain hidden behind the batch costing feature flag

CodeRabbit Pre-Review

After code changes and verification are complete, but before git commit and before pushing the branch, run:

cr --prompt-only --type uncommitted

Do not commit until the review is complete and any valid fixes are applied.

Final Gate

Before the final response, verify:

CodeRabbit was run on the final uncommitted diff.
Required verification has been rerun after fixes.
Existing calculator and G-code flows were checked when touched.
New user-facing strings are localized, or no new user-facing strings were added.
PR title matches the required format.
Assigned ClickUp task was moved to in review only after the PR was created, unless ClickUp status update failed and was reported.

Out of Scope for V1 Unless Explicitly Assigned

Saving batch quotes to history
Exporting batch quotes
Shareable quote images/PDFs
Multi-currency changes
Tax settings
Separate line items for shipping/admin/packaging
Cloud/account/sync work
