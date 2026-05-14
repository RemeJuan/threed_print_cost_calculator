# Technical Investment Execution Instructions
ClickUp Task: 86c9qf1m4

Technical-investment work is maintenance, refactoring, test hardening, structure cleanup, and architecture hygiene. Improve maintainability without changing user-facing behaviour unless the ClickUp task explicitly says otherwise.

Before making changes:
- Read the delegated ClickUp task in full.
- Move the ClickUp task to `in progress` when work starts.
- Work only on that task.
- Do not bundle multiple investment tasks into one PR.
- Preserve existing behaviour.
- Report blockers clearly in the task outcome.
- Do not pause after intake when the task is clear; continue to the next concrete step.
- If blocked, name the blocker and the exact next action or question.

## Before Starting

- Checkout `main`.
- Pull latest changes.
- Create a new branch from `main`.
- Use branch name format: `investment/<clickup-task-id>_<short-task-slug>`.
- Work only on the linked ClickUp task.
- Do not combine this task with any other investment task.

## Required Execution Order

Follow this sequence for every technical-investment task:

1. Read the ClickUp task and these instructions.
2. Checkout `main`.
3. Pull latest changes.
4. Create the branch from `main`.
5. Move the ClickUp task to `in progress`.
6. Implement the task.
7. Run required verification.
8. Run CodeRabbit on the uncommitted diff.
9. Apply valid fixes and rerun verification as needed.
10. Commit the changes.
11. Push the branch.
12. Open the PR against `main`.
13. Move the ClickUp task to `in review`.
14. Report back with the PR link and outcome.

Never stop after step 1 unless a blocker prevents step 2.

Do not skip ahead in the sequence. If a later step is blocked, stop and report the blocker instead of performing steps out of order.

## Scope Rules

- Preserve existing behaviour.
- Do not introduce new packages.
- Do not perform broad architecture rewrites.
- Do not rename unrelated files.
- Do not clean up unrelated code opportunistically.
- Prefer small, reviewable diffs.
- If the task grows beyond the ClickUp description, stop and report back instead of expanding scope.

## Behaviour Preservation Rules

Technical-investment tasks must not change:
- calculation results
- RevenueCat or premium gating behaviour
- stored data formats
- migrations
- G-code parsing semantics
- export formats
- user-facing copy
- localization keys
- navigation behaviour

Any intentional behaviour change requires explicit approval from Reme before implementation.

## Required Verification

Always run:
- `fvm flutter analyze`

Run focused tests relevant to the touched area.

Run `make flutter_test` when the change touches any of these areas:
- calculator logic
- providers or notifiers
- persistence
- settings
- history
- export
- premium gating
- G-code import
- app startup or navigation


If verification cannot be run locally, document why in the PR and report it back in the task outcome.

## Wiki Documentation

Update the wiki only when the task:
- changes architecture, ownership, or module boundaries
- creates a new shared helper/service pattern
- changes testing strategy or expected coverage
- introduces a convention future agents should follow
- reveals a useful maintenance finding worth preserving

Do not update the wiki for simple file splits, widget extraction, import cleanup, or mechanical duplication removal unless it creates a new convention.

When wiki updates are needed, include them in the same PR and mention them in the PR body.

## Pull Request Requirements

Open a PR against `main`.

PR title must match the ClickUp task title and include the task ID.

PR title format must be:

`[<clickup-task-id>:] <ClickUp task title>`

Example:

`[86c9qf1ga] Centralize formatWeight and debounce constants`

The ClickUp task ID must be included because webhook automation parses PR titles.

Do not reuse the git commit subject as the PR title unless it already matches this exact format. Commit messages and PR titles may differ.

Before creating the PR, explicitly verify:
- the title starts with `[<clickup-task-id>]`
- the rest of the title exactly matches the ClickUp task title

PR body must include:
- ClickUp task link
- summary of changes
- tests run
- risks
- follow-up tasks, if any
- final verification result
- wiki updates made, or why none were needed

Move the ClickUp task to `in review` once the PR is created.

Do not move the ClickUp task to `in review` before the PR exists.

PRs must stay focused. If a second investment opportunity is discovered, recommend a separate task instead of including it.

## Stop Conditions

Stop and report back when:
- required behaviour is unclear
- existing tests fail for unrelated reasons
- the refactor requires changing public behaviour
- circular imports appear
- the task requires broad architectural changes
- more than one feature area needs major changes
- the implementation would introduce a new package
- the task appears stale or already completed
- the ClickUp task lacks enough detail to execute safely

## Suggested PR Size

Preferred PR size:
- 1 logical task
- fewer than 10 files touched when practical
- focused tests included
- no unrelated cleanup

If a task naturally exceeds this size, stop and recommend smaller follow-up ClickUp tasks.

## Review Expectations

A technical-investment PR should be easy to review.

Reviewers should be able to answer:
- What maintenance problem was solved?
- Why is the behaviour safe?
- What tests prove it?
- What was intentionally left out?

If the PR cannot answer those questions clearly, it is too broad.

## CodeRabbit Pre-Review

After code changes and verification are complete, but before `git commit` and before pushing the branch, run the custom CodeRabbit command:
- `cr --prompt-only --type uncommitted`

This command expects the relevant changes to still be uncommitted. Do not commit until the review is complete and any valid fixes are applied.

This is a long-running process. Do not assume the default 2 minute timeout is sufficient. Wait for the command to complete before continuing.

After it completes:
- Read the full review output carefully.
- Identify only actionable, relevant feedback.
- Apply fixes for valid issues.
- Ignore low-signal or incorrect suggestions.
- Summarize issues fixed, suggestions ignored, and any follow-up still needed.

If the branch was already committed by mistake, either rerun CodeRabbit with a mode that supports committed diffs or return the branch to an uncommitted state before using `--type uncommitted`.

Do not apply CodeRabbit suggestions that:
- change user-facing behaviour
- broaden the task scope
- introduce new packages
- conflict with the ClickUp task
- require architectural decisions outside this task

If CodeRabbit raises useful but out-of-scope feedback, mention it as a follow-up in the PR body instead of implementing it.

## Final Pre-Commit / Pre-PR Gate

Before the final response, explicitly verify all of the following:

- ClickUp task is still `in progress` until after PR creation.
- CodeRabbit was run on the final uncommitted diff.
- Any valid CodeRabbit fixes were applied.
- Required verification has been rerun after those fixes.
- No commit was created before CodeRabbit completed.
- PR title starts with `[<clickup-task-id>]` and exactly matches the ClickUp task title.
- ClickUp task was moved to `in review` only after the PR was created.

If any item above is false, do not report the task as finished.
