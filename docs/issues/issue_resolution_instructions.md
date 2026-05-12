# Crashlytics Issue Resolution Instructions

## Scope & Ownership Boundary
- This document is handed to the resolving agent (for example OpenCode).
- It covers resolver-side work only: investigate, reproduce, implement, validate, update the issue doc, and record handoff facts.
- It does **not** control Hermes-side actions such as Kanban state changes, release promotion, or upstream Crashlytics closure.
- Hermes reads the issue doc produced by this workflow, then performs its own follow-up, board reconciliation, PR/merge checks, and release closure using Hermes-side Crashlytics workflow skills.

## Inputs
- Crashlytics Issue ID
- Path: `docs/issues/<issue-id>.md`

## Objective
Investigate, fix, and validate a Crashlytics issue using the documented context.  
Do not assume context outside the issue doc.

## Steps

### 0. Validate Issue Status

- Open the issue doc and check current Status.
- If Status is:
  - `released`:
    - Stop. Do not proceed unless explicitly re-opened.
  - `fixed` or `not-fixable`:
    - Stop unless explicitly re-opened or the handoff requests follow-up before Hermes release closure.
  - `ignored`:
    - Stop unless priority has been reclassified.
- Check if a fix branch already exists:
  - If yes, review existing work before continuing.
  - Avoid creating duplicate branches or fixes.
- Check for duplicate or related issues:
  - Look for similar stack traces or symptoms in other issue docs.
  - If duplicate:
    - Link issues together in the doc.
    - Prefer updating the existing canonical issue.
- Update Status → `investigating` when actively working the issue.
- Add a short “Investigation started” note with timestamp if not present.

### 1. Load Context
- Open the issue doc.
- Extract:
  - stack trace
  - affected versions
  - affected users
  - suspected cause (if present)
  - Firebase console link (if present)

### 2. Enrich (Required via MCP or Firebase Console)
- Hermes may provide only a stub issue doc. Do not assume completeness.
- Before calling `crashlytics_get_report`, read `firebase://guides/crashlytics/reports` via `firebase_read_resources` when native Firebase MCP tools are available.
- Use Crashlytics MCP or the Firebase Console link to fetch:
  - full stack trace (including all frames)
  - frequency / trend
  - device + OS distribution
  - recent occurrences
  - ANR vs crash classification
- Update the issue doc with enriched data before attempting reproduction.

### 2.1 Severity & Priority Classification
- Classify issue before proceeding:
  - Type: crash | ANR | non-fatal
  - Impact: affected users + trend
  - Surface: critical flow (import, save, calculator) vs edge
- Priority guidance:
  - Crash or ANR on core flow → high priority
  - Increasing trend → high priority
  - Low volume + edge case → medium/low
- Update issue doc with priority decision.

### 3. Reproduce
- Attempt local reproduction using:
  - described flow
  - similar file/input (e.g. G-code)
- If not reproducible:
  - document assumptions
  - proceed with defensive fix
- Prefer reproducing on device/OS from Crashlytics data when possible.

### 4. Implement Fix
- Create branch/worktree:
  - Ensure local `main` is checked out and up to date first (`git checkout main` then `git pull`).
  - Always create the branch from the latest `main` branch (pull/rebase before branching).
  - `fix/crashlytics-<issue-id>-<short-name>`
- Link branch name back into the issue doc immediately.
- Apply minimal, targeted fix.
- Avoid unrelated refactors.

### 5. Add Safeguards
- Add or update tests where feasible.
- If not possible:
  - document why in issue doc.

### 6. Validate
- Run:
  - analyzer
  - full test suite
- Manually validate affected flow.
- Confirm no new regressions in related flows.
- Before handoff, verify repo persistence state too: local-only working tree changes do **not** count as complete.

### 7. Update Issue Doc
- Root cause
- Status → `fixed` or `not-fixable`
- Fix summary
- Branch name
- Validation notes
- Risk assessment (what could break)
- Any follow-up work
- Resolver must **not** set status to `released`; Hermes owns release closure after merge-state verification.

### 8. Handoff
- Record exact completion state in the issue doc before handing back.
- Check whether an existing branch already contains the work.
- If only files inside `docs/issues/` changed:
  - Commit and merge directly back to `main`.
  - No PR required.
- If any file outside `docs/issues/` changed:
  - Create a PR before marking work complete.
  - If you cannot create the PR in the current run, add an explicit follow-up note: `PR required before Hermes release closure`.
- Do **not** report the issue complete if changes exist only in the local working tree.
- Before handoff, check `git status` and make sure the required persistence step happened:
  - docs-only path => committed and pushed on `main`
  - code-change path => committed and pushed to branch, with PR created if required
- If the required commit/push/PR step did not happen, leave an explicit follow-up note describing exactly what is still local and what action remains.
- Include:
  - issue ID
  - root cause
  - fix summary
  - validation steps
  - final status (`fixed` or `not-fixable`)
  - branch name
  - PR link if one exists
  - notes on whether follow-up monitoring is required
  - notes on whether Hermes must perform PR/merge check-in before release closure
  - clear evidence Hermes can use later (for example: branch exists, PR missing, PR open, merged to `main`, docs-only merge path used, or local changes still not committed/pushed)

## Constraints
- No auto-merge.
- No changes outside scoped issue.
- Local `main` must be checked out and pulled before creating a fix branch/worktree.
- Branches must always be created from the latest `main` to avoid drift or invalid fixes.
- Prefer stability over optimization unless clearly related.
- Must enrich issue before coding; do not fix based on partial data.
- Do not optimize unless directly related to the root cause.
- Any code change outside `docs/issues/` requires a PR before Hermes can promote the issue to `released`.
- Local-only file edits are not a completed handoff state.

## Status Definitions
- `new`: created by Hermes
- `investigating`: agent in progress
- `fixed`: implementation complete, awaiting Hermes merge/release closure
- `not-fixable`: terminal outcome, no additional implementation planned, awaiting Hermes release closure
- `released`: merged into `main` and ready for Hermes to close upstream in Crashlytics

## Notes
- Hermes is a monitoring and triage agent only.
- Resolving agents (e.g. OpenCode) are responsible for enrichment, diagnosis, and fixes.
- Issue doc is the single source of truth and must be kept up to date throughout the lifecycle.
- Hermes must later verify branch/PR/main state before promoting `fixed` or `not-fixable` to `released`.
- Known app IDs for this project:
  - Android: `1:476308766683:android:7fc07cf44f4526bc0c31fe`
  - iOS: `1:476308766683:ios:df64edd07e4671b80c31fe`
- If app context looks wrong, verify with `firebase_get_environment`, then confirm app mappings with `firebase_list_apps` when native MCP tools are available.
