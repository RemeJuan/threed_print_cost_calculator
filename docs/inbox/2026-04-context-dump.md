# Release backfill (v2.5.1 → v2.7.0)

Backfill-only context. This file appends recovered rationale and issue notes; it does not replace changelog entries.

## v2.5.1
- Multi-material v1 introduced with weight-based split and shared duration model.
  - Why: unblock multi-material costing demand without refactoring the entire calculator engine.
  - Known issues at the time: normalization emitted multiple states; potential UI performance impact.
- Calculator accuracy fix applied for zero-cost material switching.
  - Why: stale totals were being shown after material changes.
  - Known issues at the time: more frequent recalculation/state updates.

## v2.5.2
- Form validation tightened for required fields.
  - Why: invalid form data was entering persistence and calculations.
  - Known issues at the time: duplicate numeric parsing logic remained.
- Material stock tracking added with deduction on save.
  - Why: users needed basic inventory awareness in normal calculator/history flow.
  - Known issues at the time: no undo path; no sync.

## v2.6.0
- History v2 groundwork expanded with search and index-assisted lookup paths; pagination identified as planned follow-up.
  - Why: history became hard to use at 500+ entries.
  - Known issues at the time: N+1 reads, full-scan fallback, search input focus loss on refresh.
- Free vs Pro gating restructured with history teaser, lock indicators, and optional upsell hiding.
  - Why: previous boundaries were unclear and conversion/trust balance was weak.
  - Known issues at the time: messaging consistency and paywall UX still needed improvement.
- Admin tools expanded for internal testing (version tap unlock, seeding, purge, premium toggle).
  - Why: speed up QA and premium-path testing without external tooling.
  - Known issues at the time: restart required after seeding.

## v2.7.0
- G-code import effort revived as phased implementation; upload + preview targeted first.
  - Why: deliver incremental value sooner while avoiding full parser upfront risk.
  - Known issues at the time: incomplete feature surface, limited support.
- Android backup gap tracked as parity issue.
  - Why: iOS backup behavior was considered available while Android remained uncertain/incomplete.
  - Known issues at the time: restore behavior not fully verified.
- Localization shift tracked toward AppLocalization migration.
  - Why: reduce workflow friction and improve localization automation consistency.
  - Known issues at the time: hardcoded strings still present in some flows.

## Global recovered priorities from this window
- Fix history search performance and focus retention.
- Implement pagination.
- Optimize multi-material state updates.
- Add Android backup and verify restore.
- Complete G-code feature.
- Centralize numeric parsing.
- Improve paywall UX.
- Fix seed refresh behavior.
- Add performance test coverage.

## Notes on confidence
- Version mapping above is inferred from backfill context where explicit tags were not provided.
- TODO: verify in code and release tags for exact first-appearance version of each item.
