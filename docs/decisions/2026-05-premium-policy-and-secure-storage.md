# 2026-05-premium-policy-and-secure-storage

## Context
- Premium access checks were spread across UI widgets, promotion helpers, and prefs-backed test overrides.
- Quota-sensitive flags and counters lived in `SharedPreferences`, which made test setup brittle and left an easy-to-scan local state surface.

## Decision
- Centralize premium access decisions in `PremiumAccessPolicy` and expose it through Riverpod.
- Move premium/quota-sensitive keys to `PremiumLocalStore` backed by encrypted storage.
- Keep `SharedPreferences` for non-premium app preferences only.

## Tradeoffs
- More bootstrap wiring and one extra storage abstraction.
- Better isolation for premium state, simpler tests, and less scattered gate logic.

## Status
- adopted
