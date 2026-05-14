# Update Checker

## Purpose

The update checker exists to improve release adoption and reduce long-tail version fragmentation across the app install base.

Historically, users update slowly and multiple app generations remain active simultaneously for extended periods. This creates several operational issues:

- bug fixes propagate slowly
- analytics instrumentation changes take weeks to stabilise
- crash fixes remain active in older cohorts longer than expected
- rollout analysis becomes noisy due to mixed-version traffic
- product conclusions become difficult when multiple analytics schemas coexist

The goal of this feature is not to aggressively push updates.

The goal is to gently improve rollout convergence while maintaining the app’s lightweight, local-first, non-intrusive UX philosophy.

## UX Philosophy

The update checker should remain lightweight and respectful.

The app is:

- a utility application
- offline/local-first
- non-social
- non-security critical
- often used during active workflows or print preparation

Because of this:

- updates should never block app usage
- updates should never interrupt calculator workflows
- updates should never become modal spam
- forced updates are intentionally avoided

The feature should behave as a subtle nudge rather than a growth-style retention mechanism.

## Package Choice

The implementation uses:

- `update_available`

Reasons:

- supports both Android and iOS
- lightweight and simple
- allows app-owned UI
- avoids tightly coupling UX to store-specific update flows
- keeps behavior consistent across platforms

Alternatives intentionally avoided for this implementation:

### `in_app_update`

Not used as the primary solution because:

- Android only
- more intrusive
- designed around Play Store in-app update flows
- introduces stronger update pressure than desired

### `app_version_update`

Not used because:

- more UI-opinionated than required
- this project prefers app-owned UX and presentation

## Expected Behaviour

The update check should:

- run after startup
- not block first render
- cache results for the current session
- display only when a newer store version exists
- support dismissal
- respect cooldown periods after dismissal
- deep link users to the correct store page

The prompt should preferably be:

- a banner
- a card
- or another lightweight inline component

The update checker should not:

- force updates
- block app access
- require authentication
- require remote config
- interrupt active calculator usage

## Cooldown Behaviour

Dismissals should be persisted locally.

Suggested behavior:

- once dismissed, suppress prompts for approximately 7 days
- avoid repeatedly showing prompts within the same session
- allow future releases to re-trigger visibility naturally

## Analytics

The feature adds lightweight analytics instrumentation.

Events:

- `update_prompt_shown`
- `update_prompt_tapped`
- `update_prompt_dismissed`

Suggested params:

- `current_version`
- `store_version`
- `platform`
- `source`

Suggested source values:

- `startup_banner`
- `help_support`

Analytics should remain:

- low-cardinality
- privacy-safe
- implementation-focused

No user identifiers, free-text fields, or device identifiers should be included.

## Operational Motivation

This feature primarily exists to improve:

- rollout convergence
- analytics trustworthiness
- crash-fix propagation
- instrumentation stability

This is especially important because analytics instrumentation evolves regularly and mobile update adoption is significantly slower than engineering iteration speed.

The update checker is therefore considered part of the app’s operational observability strategy, not only a UX enhancement.

## Manual Testing Flow

The implementation should include a clear manual testing strategy.

Suggested testing approaches:

- temporarily override the detected store version
- inject mocked update responses in debug builds/tests
- simulate newer versions locally
- validate cooldown persistence after dismiss
- validate analytics events fire correctly
- validate deep links open the correct store
- validate prompts do not appear repeatedly within the cooldown window

The implementation should avoid relying exclusively on live store version changes for testing.

## Agent Notes

Agents should primarily document:

- implementation details
- architecture
- integration points
- analytics schemas
- testing behavior

Strategic or operational reasoning in this document should generally be preserved unless explicitly updated by a human.