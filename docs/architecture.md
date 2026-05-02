# Architecture

## Current state management pattern

- Primary state management: Riverpod 3 (`riverpod`, `flutter_riverpod`, `hooks_riverpod` in `pubspec.yaml`).
- App root creates a `ProviderScope` in `lib/main.dart` and overrides infrastructure providers for `SharedPreferences` and `Database`.
- Feature state mostly uses `NotifierProvider` + `Notifier`, for example:
  - `lib/calculator/provider/calculator_notifier.dart`
  - `lib/history/provider/history_paged_notifier.dart`
  - `lib/purchases/premium_state_notifier.dart`
  - `lib/settings/providers/printers_notifier.dart`
  - `lib/settings/providers/materials_notifier.dart`
- Simple UI filters use lightweight providers such as `StateProvider` in `lib/materials/providers/materials_providers.dart`.
- Stream-backed persistence readers are exposed through `StreamProvider`, for example `materialsStreamProvider` and `settingsStreamProvider`.
- UI shell uses hooks-based widgets (`HookConsumerWidget` in `lib/app/app_page.dart`) for page controller and effect wiring.
- `bloc` remains in repo for bootstrap logging (`lib/bootstrap.dart`), but feature state flow is Riverpod-led rather than Bloc/Cubit-led.

## Bootstrap sequence

- `lib/main.dart` initializes app services in a fixed order: Firebase, App Check, Crashlytics, RevenueCat (`Purchases.configure(...)`), Localizely, `SharedPreferences`, and Sembast DB.
- Startup migrations from `lib/startup.dart` run after those services are ready and before the root Riverpod `ProviderScope` is applied.
- That order matters for downstream code: SharedPreferences-backed test overrides, Sembast migrations, premium gating in `lib/app/app_page.dart`, `PremiumStateNotifier` / `premiumStateProvider`, `RevenueCatPurchasesGateway.watchPremiumState()` / `fetchPremiumState()`, and `paywall_presenter` all assume those dependencies exist first.

## Data persistence approach

- Local persistence uses Sembast (`pubspec.yaml`, `lib/database/`).
- `lib/database/database.dart` conditionally exports platform-specific storage implementations.
- Core app dependencies injected through providers in `lib/shared/providers/app_providers.dart`:
  - `sharedPreferencesProvider`
  - `databaseProvider`
  - `appRefreshProvider`
- Repositories under `lib/database/repositories/` own record read/write and mapping:
  - `history_repository.dart`
  - `materials_repository.dart`
  - `settings_repository.dart`
  - `printers_repository.dart`
  - `calculator_preferences_repository.dart`
- Settings persist in the Sembast main store via `lib/database/repositories/settings_repository.dart`.
- Materials, printers, and history use named stores keyed by `DBName` enums/helpers in `lib/database/`.
- Startup migrations run in `lib/startup.dart` before `runApp`; current startup work rebuilds printer/history indexes and migrates legacy history material data.
- `SharedPreferences` stores lighter app flags and counters such as premium overrides and run counts.

## Premium gating approach

- RevenueCat configured in `lib/main.dart` through `Purchases.configure(...)` before app bootstrap.
- Premium state source of truth lives in `lib/purchases/premium_state_notifier.dart`.
- `premiumStateProvider` subscribes to `RevenueCatPurchasesGateway.watchPremiumState()` and fetches initial state through `fetchPremiumState()`.
- Local test override path exists in `PremiumStateNotifier` using `SharedPreferences` and `lib/shared/test_tools/test_data_service.dart`.
- App shell gating happens in `lib/app/app_page.dart`:
  - Materials tab only renders when `isPremium`.
  - History tab visibility depends on premium-related promotion providers in `lib/shared/providers/pro_promotion_visibility.dart`.
- Paywall entry points are centralized in `lib/purchases/paywall_presenter.dart`, with feature-specific triggers in calculator/history/header/settings flows.

## Localization rules

- ARB source of truth: `lib/l10n/intl_*.arb`.
- Generated API: `lib/l10n/app_localizations.dart` and `lib/l10n/app_localizations_*.dart`.
- Config: `l10n.yaml` points `arb-dir` to `lib/l10n`, template file to `intl_en.arb`, and output class to `AppLocalizations`.
- `MaterialApp` wires localization through `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales` in `lib/app/app.dart`.
- Do not edit generated localization files directly.
- After ARB changes, run `fvm flutter gen-l10n` or project codegen workflow.
- App is currency-agnostic: no currency symbols in user-facing output.

## Testing conventions

- Main lower-level test roots: `test/`, `integration_test/`, `patrol_test/`.
- Widget tests should use `test/helpers/helpers.dart`.
- Integration tests should use `integration_test/helpers/integration_test_harness.dart`.
- Patrol helpers live under `patrol_test/helpers/`.
- Migration coverage anchor: `test/main_migration_test.dart`.
- Current local verify order from `AGENTS.md`:
  1. `fvm flutter analyze`
  2. `make flutter_test`
- If generated code or localization sources changed, run `make flutter_generate` before analyze/tests.
- `TESTING.md` keeps current test pyramid: unit + widget heavy, two Patrol release-gate journeys, optional legacy `integration_test` sweep.

## CI and release notes

- GitHub Actions:
  - `.github/workflows/main.yaml`: checkout, `flutter pub get`, `flutter build web`, deploy `build/web` to `gh-pages`.
  - `.github/workflows/maintenance.yaml`: biweekly maintenance issue assigned to Copilot agent; runbook includes analyze, tests, upgrade, and patch version bump.
- Codemagic release/publish pipeline lives in `codemagic.yaml`:
  - `android_release`, `ios_release`
  - `android_patch`, `ios_patch`
  - `patrol` Firebase Test Lab workflow
- Releases use FVM-managed Flutter plus Shorebird for releases/patches.
- `shorebird.yaml` stores Shorebird app configuration.
- Current version source: `pubspec.yaml`.
- Version bump helpers referenced in repo docs: `make bump_fix`, `make bump_feat`, `make bump_build`.
