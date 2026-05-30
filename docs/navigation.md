# Navigation

## High-level repo map

- `lib/`: Flutter app code.
- `test/`: unit and widget tests.
- `integration_test/`: Flutter integration journeys and harness.
- `patrol_test/`: Patrol release-gate E2E journeys.
- `test_support/`: shared test doubles used outside `test/`.
- `docs/`: product, architecture, developer, and feature docs.
- `assets/test_data/`: deterministic seed data for in-app test tools (`SeedLoader`). JSON files: `settings.json`, `printers.json`, `materials.json`, `history.json`. Loaded via `lib/shared/test_tools/seed_loader.dart` and `test_data_service.dart`. History items may include `batchQuote`, `batchQuoteItems`, and `batchQuoteSummary` for batch costing. Settings supports `pricingMarkupPercent`, `pricingSetupFee`, `pricingRoundingMode` (`"none"`, `".00"`, `".99"`), `currencySymbol`, `currencyPosition`, `currencySpacing`.
- `android/`, `ios/`, `web/`: platform shells.
- `.github/workflows/`: GitHub Actions workflows.
- `codemagic.yaml`: Codemagic + Shorebird release and patch workflows.
- `scripts/`: local and CI helper scripts.

## Primary app entry points

- `lib/main.dart`: real app entry. Initializes Firebase, App Check, Crashlytics, RevenueCat, SharedPreferences, Sembast DB, then runs startup migrations before `ProviderScope`.
- `lib/startup.dart`: startup migrations for history/printer indexes and legacy history records.
- `lib/bootstrap.dart`: installs Bloc observer/logging and calls `runApp`.
- `lib/app/app.dart`: root `MaterialApp`, theme, localization delegates, BotToast, RateMyApp.
- `lib/app/app_page.dart`: main shell. Bottom-nav tabs and top-level page wiring.
- `lib/app/header_actions.dart`: shared app-bar actions used outside Materials tab.

## Feature directories

- `lib/calculator/`: calculator form, results, history load, imported value application.
- `lib/materials/`: materials browser (free with quota limits), filters, CSV import UI, stock tracking.
- `lib/history/`: history list (free with 7-save limit), search, export UI.
- `lib/purchases/`: RevenueCat gateway, custom paywall screen, premium gateway, paywall presenter, premium policy/state.
- `lib/gcode_import/`: file picking, parsing, import flow, feedback reporting.
- `lib/settings/`: general settings, work costs, printer forms, material forms.
- `lib/database/`: Sembast storage abstraction, repositories, record mapping.
- `lib/core/analytics/`: analytics facade and Firebase bridge.
- `lib/shared/`: cross-feature components, providers, theme, utilities, test tools.
- `lib/l10n/`: ARB source files and generated localization API.

## Test directories

- `test/helpers/helpers.dart`: default widget-test harness.
- `test/helpers/mocks.dart`: shared mocks.
- `test/main_migration_test.dart`: startup and migration coverage.
- `test/calculator/`, `test/materials/`, `test/history/`, `test/purchases/`, `test/settings/`, `test/gcode_import/`, `test/core/`, `test/database/`, `test/shared/`: feature/unit/widget coverage.
- `integration_test/helpers/integration_test_harness.dart`: integration harness with in-memory DB/prefs and fake purchases.
- `integration_test/helpers/integration_test_ui.dart`: integration UI helpers.
- `patrol_test/helpers/patrol_test_bootstrap.dart`: Patrol app bootstrap.
- `patrol_test/helpers/patrol_test_ui.dart`: Patrol selectors/helpers.
- `test_support/fake_purchases_gateway.dart`: reusable premium fake.

## Generated and localization files

- Source localization files: `lib/l10n/intl_*.arb`.
- Generated localization API: `lib/l10n/app_localizations.dart` and `lib/l10n/app_localizations_*.dart`.
- Localization config: `l10n.yaml`.
- Generated Firebase config: `lib/firebase_options.dart`.
- Generated model/state files: `lib/**/*.freezed.dart`.
- Build outputs: `build/`, `.dart_tool/`, `coverage/`.

## Files agents should not edit directly

- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_*.dart`
- `lib/firebase_options.dart`
- `lib/**/*.freezed.dart`
- `build/**`
- `.dart_tool/**`
- `coverage/**`

Edit source instead:

- Localization text: `lib/l10n/intl_*.arb`, then regenerate.
- Model/state definitions: source `.dart` file beside generated `.freezed.dart`, then regenerate.

## Fast repo entry paths

- App shell: `lib/app/app_page.dart`
- Calculator screen: `lib/calculator/view/calculator_page.dart`
- Materials screen: `lib/materials/widgets/materials_page.dart`
- History screen: `lib/history/history_page.dart`
- Settings screen: `lib/settings/settings_page.dart`
- Premium state: `lib/purchases/premium_state_notifier.dart`
- Premium policy: `lib/purchases/premium_access_policy.dart`
- Premium local store: `lib/purchases/premium_local_store.dart`
- G-code import flow: `lib/gcode_import/gcode_import_page.dart`
- Paywall screen: `lib/purchases/paywall_screen.dart`
- Premium purchase gateway: `lib/purchases/premium_purchase_gateway.dart`
- Paywall comparison table: `lib/purchases/paywall_comparison_table.dart`
- Paywall plan selector: `lib/purchases/paywall_plan_selector.dart`
- App navigator key: `lib/shared/providers/app_providers.dart` (`appNavigatorKey`)
- Analytics facade: `lib/core/analytics/app_analytics.dart`
- Shared providers: `lib/shared/providers/app_providers.dart`
