# Crashlytics Issue Resolution Instructions

## Inputs
- Crashlytics Issue ID
- Path: `docs/issues/crashlytics/<issue-id>.md`

## Objective
Investigate, fix, and validate a Crashlytics issue using the documented context.  
Do not assume context outside the issue doc.

## Steps

### 0. Validate Issue Status

- Open the issue doc and check current Status.
- If Status is:
  - `fixed` or `release`:
    - Stop. Do not proceed unless explicitly re-opened.
  - `watching`:
    - Only proceed if new regression or spike is detected.
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

### 7. Update Issue Doc
- Root cause
- Status → `fixed`
- Fix summary
- Branch name
- Validation notes
- Risk assessment (what could break)
- Any follow-up work

### 8. Handoff
- Create PR or patch.
- Include:
  - issue ID
  - root cause
  - fix summary
  - validation steps
  - notes on whether follow-up monitoring is required

## Constraints
- No auto-merge.
- No changes outside scoped issue.
- Branches must always be created from the latest `main` to avoid drift or invalid fixes.
- Prefer stability over optimization unless clearly related.
- Must enrich issue before coding; do not fix based on partial data.
- Do not optimize unless directly related to the root cause.

## Status Definitions
- `new`: created by Hermes
- `investigating`: agent in progress
- `fixed`: patch ready
- `watching`: deployed, monitoring
- `ignored`: low value / not actionable
- `release`: issue has been merged into the main branch and the source issue can be closed.

## Notes
- Hermes is a monitoring and triage agent only.
- Resolving agents (e.g. OpenCode) are responsible for enrichment, diagnosis, and fixes.
- Issue doc is the single source of truth and must be kept up to date throughout the lifecycle.
