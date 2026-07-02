# Play Integrity Rollout Plan

> ClickUp Task: TBD
> Status: Draft
> Scope: Planning only. No implementation yet.
> Related: `docs/architecture.md`

## Summary

This document captures the planned expansion of Play Integrity handling for Android.

Current app posture already uses Play licence, app integrity, and virtual integrity in some form. Remaining verdicts should be enabled and handled conservatively:

- Device integrity
- Recent device activity
- Play Protect status
- App access risk

Core rule:

- Never block the basic calculator because of risky, missing, or unknown device-side integrity signals.
- Only hard-block clear app tampering or unlicensed purchase-sensitive flows.
- Start with telemetry-first handling for new verdicts.

## Goals

- Keep existing licence and app-integrity protections intact.
- Enable remaining Play Integrity verdicts in Play Console.
- Decode full verdict payload safely on backend.
- Apply conservative decisions in app:
  - calculator/free flows continue working
  - purchase/restore flows may soft-gate on risky device integrity
- Log all integrity context to Sentry using stable structured tags.
- Keep UI quiet unless user action cannot continue.

## Non-goals

- No hard lockout of the free calculator on risky device verdicts.
- No aggressive blocking based on recent device activity, Play Protect, or app access risk in first rollout.
- No local-only decode path in Flutter; detailed verdict decode requires backend.
- No production implementation in this document.

## Locked Product Decisions

### Hard blocks

- `block_tampered`
  - clear app integrity failure
  - example: app verdict clearly not `PLAY_RECOGNIZED` and not `UNEVALUATED`
- `block_unlicensed`
  - licence verdict `UNLICENSED` during purchase/restore-sensitive flows

### Soft gate

- `soft_gate_premium`
  - device integrity missing/failing during purchase/restore-sensitive flows
  - intended to protect premium purchase/restore paths only

### Log only

- `allow_logged_risk`
  - recent device activity elevated
  - Play Protect risky or unavailable
  - app access risk labels present
  - non-blocking device integrity concerns outside premium-sensitive flow

### Normal allow

- `allow`
  - verdicts normal, absent-but-safe, or backend unavailable

### Failure mode

- If backend decode fails, network fails, or Play Integrity token request fails:
  - allow app usage
  - log issue to Sentry
  - do not break calculator flow

## Required Sentry Shape

Set tags:

- `play_integrity.license`
- `play_integrity.app_integrity`
- `play_integrity.device_integrity`
- `play_integrity.virtual_integrity`
- `play_integrity.recent_device_activity`
- `play_integrity.play_protect`
- `play_integrity.app_access_risk`
- `play_integrity.decision`

Add structured context object:

- `play_integrity`

Decision values must stay limited to:

- `allow`
- `allow_logged_risk`
- `soft_gate_premium`
- `block_tampered`
- `block_unlicensed`

## External Constraints And Findings

### Why backend decode is required

Full Play Integrity verdict decoding must happen server-side. Flutter/Android client can request integrity token, but detailed verdict data should be decoded on trusted backend only.

### Preferred backend

Firebase Cloud Functions chosen over Supabase Edge Functions because project already uses Firebase and App Check.

### Region

- Preferred initial region: `europe-west1`
- User approved EU region

### Play Integrity fields to normalize

- `accountDetails.appLicensingVerdict`
  - `LICENSED`
  - `UNLICENSED`
  - `UNEVALUATED`
- `appIntegrity.appRecognitionVerdict`
  - `PLAY_RECOGNIZED`
  - `UNRECOGNIZED_VERSION`
  - `UNEVALUATED`
- `deviceIntegrity.deviceRecognitionVerdict`
  - labels may include `MEETS_DEVICE_INTEGRITY`
  - labels may include `MEETS_VIRTUAL_INTEGRITY`
  - labels may include `MEETS_BASIC_INTEGRITY`
  - labels may include `MEETS_STRONG_INTEGRITY`
  - field may be omitted when nothing qualifies
- `deviceIntegrity.recentDeviceActivity.deviceActivityLevel`
  - `LEVEL_1`
  - `LEVEL_2`
  - `LEVEL_3`
  - `LEVEL_4`
  - `UNEVALUATED`
- `environmentDetails.playProtectVerdict`
  - `NO_ISSUES`
  - `NO_DATA`
  - `POSSIBLE_RISK`
  - `MEDIUM_RISK`
  - `HIGH_RISK`
  - `UNEVALUATED`
- `environmentDetails.appAccessRiskVerdict.appsDetected`
  - may include installed/capturing/controlling/overlay labels
  - may be empty when unevaluated

Missing or unknown fields must never crash parsing or trigger aggressive fallback decisions.

## Proposed Technical Design

### 1. Play Console setup

Enable remaining verdicts:

- Device integrity
- Recent device activity
- Play Protect status
- App access risk

Keep existing licence/app/virtual integrity settings enabled.

### 2. Firebase callable function

Create callable function:

- name: `decodePlayIntegrity`
- platform: Firebase Functions v2
- region: `europe-west1`
- App Check: `enforceAppCheck: true`
- App Check replay protection: `consumeAppCheckToken: true`

Request shape:

```json
{
  "integrityToken": "...",
  "flow": "startup" | "purchase" | "restore" | "calculator"
}
```

Response shape:

```json
{
  "license": "...",
  "appIntegrity": "...",
  "deviceIntegrity": "...",
  "virtualIntegrity": "...",
  "recentDeviceActivity": "...",
  "playProtect": "...",
  "appAccessRisk": ["..."],
  "decision": "allow" | "allow_logged_risk" | "soft_gate_premium" | "block_tampered" | "block_unlicensed"
}
```

Function responsibilities:

- validate callable input
- call Play Integrity decode API for package `com.threed_print_calculator`
- normalize known, missing, and unknown values
- compute decision server-side
- never return raw token, raw Google credentials, or unnecessary payload details

### 3. Android token request

Add native Play Integrity token request path in `MainActivity.kt`.

Expected work:

- keep existing gcode picker MethodChannel intact
- add separate MethodChannel for Play Integrity token request
- add Play Integrity Android dependency in Gradle
- use current library version supporting app access risk

### 4. Flutter integrity layer

Expected new files under `lib/core/integrity/`:

- `play_integrity_models.dart`
- `play_integrity_service.dart`
- `play_integrity_decision.dart`
- `play_integrity_sentry.dart`

Expected responsibilities:

- request native token
- call Firebase function
- parse normalized response
- apply decision locally to purchase/restore flow
- emit Sentry tags/context
- fall back to allow+log on infrastructure failure

### 5. App bootstrap change

In `lib/main.dart`:

- keep Apple App Attest
- explicitly set Android App Check provider to Play Integrity

### 6. Purchase/restore integration

Primary integration point:

- `lib/purchases/paywall_screen_actions.dart`

Behavior:

- run integrity check before premium purchase
- run integrity check before restore
- quiet path on `allow`
- quiet path with logging on `allow_logged_risk`
- show neutral blocking/warning copy only when action cannot continue

Free calculator flow must remain untouched.

## Decision Matrix

| Condition | Flow | Decision | Notes |
| --- | --- | --- | --- |
| App integrity clearly bad | Any | `block_tampered` | Hard block |
| Licence unlicensed | Purchase / Restore | `block_unlicensed` | Hard block |
| Device integrity fails or absent | Purchase / Restore | `soft_gate_premium` | Calculator still allowed |
| Recent activity elevated | Any | `allow_logged_risk` | Log only |
| Play Protect risky / no data / unknown | Any | `allow_logged_risk` | Log only initially |
| App access risk labels present | Any | `allow_logged_risk` | Log only initially |
| Backend or network failure | Any | `allow` | Log infrastructure issue |
| Safe / unevaluated conservative case | Any | `allow` | No user disruption |

## UX And Copy Guidance

- UI stays silent unless purchase/restore action cannot continue.
- Block/soft-gate copy must be neutral, not accusatory.
- Avoid promising permanent denial when signal may be transient.
- Keep app currency-agnostic.
- Any user-facing copy must go through existing l10n system.

Suggested tone:

- "This action can't continue on this device right now."
- "Try again later or use a different device."

Avoid:

- fraud accusations
- malware accusations
- technical jargon about verdict classes

## Testing Plan

### Unit tests

- verdict parsing for all known values
- missing-field parsing
- unknown-value parsing
- decision mapping for each decision label

### Purchase flow tests

- purchase proceeds on `allow`
- restore proceeds on `allow`
- premium flow blocks on `soft_gate_premium`
- tampered flow blocks on `block_tampered`
- unlicensed flow blocks on `block_unlicensed`
- backend failure falls back to allow+log

### Regression checks

- existing licence/app integrity handling still works
- calculator remains usable under risky/unknown device verdicts
- Sentry receives expected tags/context

## Open Questions

- Whether startup flow should call integrity immediately in first rollout, or only purchase/restore-sensitive flows.
- Exact threshold mapping for recent device activity levels beyond initial log-only rollout.
- Whether future versions should escalate app access risk overlays/capture signals from log-only to premium soft-gate.

## Task List

### Planning

- [ ] Confirm Play Console verdict toggles enabled in production project
- [ ] Confirm Firebase Functions project setup path for this repo
- [ ] Confirm service account/scopes needed for Play Integrity decode API

### Backend

- [ ] Add `functions/` Firebase Functions v2 scaffold
- [ ] Add callable `decodePlayIntegrity` in `europe-west1`
- [ ] Add Play Integrity decode client using Google-authenticated access token
- [ ] Normalize decode payload into app-safe response model
- [ ] Implement server-side decision mapper
- [ ] Add backend tests for verdict normalization and decision outputs

### Android

- [ ] Add Play Integrity Android dependency in `android/app/build.gradle`
- [ ] Add new MethodChannel token request path in `MainActivity.kt`
- [ ] Preserve existing gcode picker channel behavior

### Flutter

- [ ] Add `cloud_functions` dependency
- [ ] Add `lib/core/integrity/` model/service/decision/Sentry files
- [ ] Wire explicit Android App Check Play Integrity provider in `lib/main.dart`
- [ ] Integrate integrity check before purchase flow
- [ ] Integrate integrity check before restore flow
- [ ] Keep calculator/free flows unchanged

### UX / Localization

- [ ] Add neutral localized strings for soft-gate and block cases
- [ ] Update all supported locale ARBs
- [ ] Regenerate localization files

### Verification

- [ ] Add/extend unit tests for integrity parsing and decisions
- [ ] Add/extend purchase action tests
- [ ] Run codegen if localization/generated files change
- [ ] Run analyze
- [ ] Run test suite relevant to touched areas

### Documentation

- [ ] Promote stable parts of this plan into `docs/architecture.md` once implementation lands
- [ ] Link final implementation PR/task back to this inbox doc
