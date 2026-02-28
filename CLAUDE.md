# CLAUDE.md — 3D Print Cost Calculator

This file provides guidance for AI assistants working on this codebase.

## Project Overview

A Flutter mobile/desktop/web application that calculates the cost of 3D printing projects. It factors in:
- **Filament cost** (item weight vs. spool weight and price)
- **Electricity cost** (printer wattage × print duration × kWh rate)
- **Wear & tear** (fixed amount per print)
- **Failure risk** (percentage of total cost as a buffer)
- **Labour cost** (hourly rate × hours spent)

The app supports iOS, Android, macOS, Windows, and Web. Data is stored locally using Sembast (NoSQL embedded database). Firebase provides Analytics, Crashlytics, and App Check. RevenueCat handles in-app purchases for premium features.

**Current version:** 2.4.0
**Flutter SDK:** 3.38.3 (managed via FVM)
**Dart SDK:** >=3.10.0 <4.0.0

---

## Development Environment

### Flutter Version Management (FVM)

This project uses [FVM](https://fvm.app/) to pin the Flutter SDK version. Always prefix Flutter commands with `fvm`:

```bash
fvm flutter run
fvm flutter test
fvm flutter analyze
fvm flutter pub get
```

The pinned version is in `.fvm/fvm_config.json` and `.fvmrc`.

### Pre-push Hook

[Lefthook](https://github.com/evilmartians/lefthook) runs `fvm flutter analyze lib test` before every `git push`. Fix all analysis errors before pushing — there is no way to bypass this hook.

---

## Common Commands

All frequently-used workflows are in the `Makefile`:

| Command | Description |
|---|---|
| `make flutter_test` | Run all tests with random ordering |
| `make flutter_generate` | Run `build_runner` for code generation |
| `make bump_fix` | Bump patch version (bug fix release) |
| `make bump_feat` | Bump minor version (new feature release) |
| `make bump_build` | Bump build number only |
| `make fix_ios` | Re-install iOS Pods after Flutter cache update |

### Running Tests Directly

```bash
# All tests, randomised order
fvm flutter test test --no-pub --test-randomize-ordering-seed random

# Single file
fvm flutter test test/calculator/helpers/calculator_helpers_test.dart
```

### Static Analysis

```bash
fvm flutter analyze lib test
```

---

## Repository Structure

```
threed_print_cost_calculator/
├── lib/
│   ├── main.dart                    # Entry point: Firebase, RevenueCat, DB init
│   ├── bootstrap.dart               # App bootstrap wrapper
│   ├── firebase_options.dart        # Generated Firebase config
│   ├── app/                         # App shell, theme, routing, shared dialogs
│   │   ├── app.dart                 # Root MaterialApp widget
│   │   ├── app_page.dart            # Main scaffold with bottom navigation
│   │   ├── header_actions.dart      # AppBar action buttons
│   │   ├── support_dialog.dart      # In-app support dialog
│   │   └── components/
│   │       └── focus_safe_text_field.dart
│   ├── calculator/                  # Core calculation feature
│   │   ├── calculator.dart          # Feature barrel export
│   │   ├── helpers/
│   │   │   └── calculator_helpers.dart   # Electricity, filament, labour formulas
│   │   ├── provider/
│   │   │   └── calculator_notifier.dart  # CalculatorProvider (NotifierProvider)
│   │   ├── state/
│   │   │   ├── calculator_state.dart     # Form state (FormzMixin)
│   │   │   └── calculation_results_state.dart  # Result value object
│   │   └── view/                    # UI widgets for the calculator screen
│   ├── database/                    # Sembast database layer
│   │   ├── database.dart            # Platform-aware factory
│   │   ├── database_contract.dart   # Abstract interface
│   │   ├── database_helpers.dart    # DataBaseHelpers class + DBName enum
│   │   ├── database_main.dart       # Web implementation
│   │   └── database_mobile.dart     # Mobile/desktop implementation
│   ├── history/                     # Saved print history feature
│   │   ├── history_page.dart
│   │   ├── components/              # HistoryItem, HistoryToolbar widgets
│   │   ├── index/
│   │   │   └── printer_index.dart   # PrinterIndexHelpers (printer → record-key index)
│   │   ├── model/
│   │   │   └── history_model.dart
│   │   └── provider/
│   │       ├── history_providers.dart       # historyRecordsProvider, historyQueryProvider
│   │       └── history_paged_notifier.dart  # Paged loading notifier
│   ├── settings/                    # User settings feature
│   │   ├── settings_page.dart
│   │   ├── general_settings_form.dart
│   │   ├── work_costs_form.dart
│   │   ├── helpers/
│   │   │   └── settings_helpers.dart
│   │   ├── materials/               # Material management UI
│   │   ├── printers/                # Printer management UI
│   │   ├── model/                   # GeneralSettingsModel, MaterialModel, PrinterModel
│   │   ├── state/                   # MaterialState, PrinterState
│   │   └── providers/               # MaterialsNotifier, PrintersNotifier
│   ├── shared/                      # Cross-feature utilities
│   │   ├── components/
│   │   │   ├── num_input.dart       # NumberInput (FormzInput)
│   │   │   ├── string_input.dart    # StringInput (FormzInput)
│   │   │   └── accordion_menu/      # Collapsible menu component
│   │   ├── providers/
│   │   │   └── app_providers.dart   # databaseProvider, sharedPreferencesProvider
│   │   ├── theme.dart               # App ThemeData (dark blue palette)
│   │   └── utils/
│   │       └── csv_utils.dart       # CSV export logic + CsvUtils provider
│   ├── generated/                   # Auto-generated i18n files (do not edit manually)
│   └── l10n/                        # Localisation ARB source files
├── test/                            # Mirrors lib/ structure
│   ├── helpers/
│   │   ├── helpers.dart             # pumpApp() test extension
│   │   └── mocks.dart               # MockCalculatorNotifier, MockSharedPreferences
│   ├── app/
│   ├── calculator/
│   ├── history/
│   └── shared/
├── assets/fonts/                    # Montserrat font family
├── android/ ios/ macos/ windows/ web/  # Platform-specific projects
├── Makefile                         # Developer shortcuts
├── lefthook.yml                     # Git hooks (pre-push lint)
├── analysis_options.yaml            # Lint config
├── pubspec.yaml                     # Dependencies + version
└── l10n.yaml                        # Flutter i18n config
```

---

## State Management

The project uses **Riverpod 3.x** throughout. Do not use `Provider` (the package), BLoC, or `setState` for feature state.

### Provider Types in Use

| Pattern | When to use |
|---|---|
| `NotifierProvider` | Mutable state with methods (e.g., `CalculatorProvider`) |
| `StateNotifierProvider` | Legacy pattern; prefer `NotifierProvider` for new code |
| `Provider` | Immutable/computed values or service objects |
| `Provider.family` | Parameterised services (e.g., `dbHelpersProvider(DBName.history)`) |
| `FutureProvider` | Async data loading (e.g., `historyRecordsProvider`) |

### Key Root Providers

Defined in `lib/shared/providers/app_providers.dart`:

```dart
// Both are overridden in main() via ProviderScope; they throw if accessed without override
final sharedPreferencesProvider = Provider<SharedPreferences>(...);
final databaseProvider = Provider<Database>(...);
```

### Notifier Conventions

- `build()` returns the initial state synchronously. Use `ref.onDispose()` inside `build()` for cleanup.
- Read DB/services via on-demand getters (`Database get _db => ref.read(databaseProvider)`) rather than storing them as fields — this keeps tests simple.
- Persist to DB **before** updating local state; only update state after a successful write.
- Use `submitDebounced()` to avoid running expensive calculations on every keystroke.

---

## Database Layer (Sembast)

Sembast is a NoSQL embedded database. All access goes through `DataBaseHelpers`.

### Store Names (`DBName` enum)

| Enum | Store | Purpose |
|---|---|---|
| `DBName.settings` | `settings` | General user preferences |
| `DBName.printers` | `printers` | Saved printer configurations |
| `DBName.history` | `history` | Past calculation records |
| `DBName.materials` | `materials` | Saved filament materials |
| _(internal)_ | `printer_index` | Printer → history record key index |

### Getting a Helper

```dart
final dbHelpers = ref.read(dbHelpersProvider(DBName.history));
```

### Common Operations

```dart
// Insert a new record (auto-key)
await dbHelpers.insertRecord(data);

// Update an existing record by key
await dbHelpers.updateRecord(key, data);

// Delete a record by key
await dbHelpers.deleteRecord(key);

// Read settings (handles activePrinter validation automatically)
final settings = await dbHelpers.getSettings();

// Put a single top-level document (e.g., settings blob)
await dbHelpers.putRecord(settingsMap);
```

### Printer Index

`PrinterIndexHelpers` (`lib/history/index/printer_index.dart`) maintains a secondary index mapping normalised printer names to history record keys. It is updated automatically by `DataBaseHelpers` on insert/update/delete. On app startup, `main.dart` rebuilds the index if it is empty.

```dart
// Access from a Riverpod Ref
final helpers = PrinterIndexHelpers.fromRef(ref);

// Access from a ProviderContainer (e.g., in startup code)
final helpers = PrinterIndexHelpers.fromContainer(container);
```

---

## Form Validation

Use `NumberInput` (Formz) for all numeric form fields.

```dart
// In state class
final NumberInput watt;

// In notifier — parse strings defensively (handle comma decimals)
void updateWatt(String value) {
  state = state.copyWith(
    watt: NumberInput.dirty(
      value: num.tryParse(value.replaceAll(',', '.')) ?? 0,
    ),
  );
}
```

`NumberInput` considers a value valid when it is non-null and `> -1`. The `CalculatorState` implements `FormzMixin` and exposes an `inputs` list covering all form fields.

---

## Testing

### Structure

- Mirror `lib/` in `test/` (e.g., `test/calculator/helpers/` matches `lib/calculator/helpers/`).
- Shared utilities live in `test/helpers/`.

### Widget Tests

Use `pumpApp()` from `test/helpers/helpers.dart`:

```dart
await tester.pumpApp(MyWidget(), overrides: [
  myProvider.overrideWith(...),
]);
```

`pumpApp()` automatically provides an in-memory Sembast database, `ProviderScope`, and localization delegates.

### Mocks

Use `mocktail`. Pre-built mocks are in `test/helpers/mocks.dart`:

```dart
class MockCalculatorNotifier extends CalculatorProvider with Mock { ... }
class MockSharedPreferences extends Mock implements SharedPreferences { ... }
```

### Test Conventions

```dart
void main() {
  group('FeatureName', () {
    setUp(() { /* arrange */ });

    test('should do X when Y', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

---

## Code Style

Governed by `analysis_options.yaml` (extends `package:flutter_lints/flutter.yaml`).

### Disabled Lint Rules

- `public_member_api_docs` — documentation comments are optional
- `constant_identifier_names` — allows `SCREAMING_SNAKE_CASE` for color constants

### Conventions

- Prefer `final` over `var` for values that do not change.
- Use trailing commas on multi-line argument lists.
- Avoid unnecessary null checks — use Dart null safety properly.
- Use `late` only when truly necessary.
- No Hungarian notation.
- Replace comma decimal separators before parsing: `value.replaceAll(',', '.')`.
- Use `const` constructors wherever possible.

---

## Internationalisation

Localization uses Flutter's `intl` package with Localizely for OTA updates.

- Source ARB files: `lib/l10n/arb/`
- Generated code: `lib/generated/l10n.dart` and `lib/generated/intl/`
- Supported locales: `en`, `de`, `es`, `fr`, `id`, `it`, `ja`, `nl`, `pt`, `th`
- Config: `l10n.yaml`

All user-facing strings must be wrapped with localisation:

```dart
S.of(context).someKey
// or
S.current.someKey  // outside a BuildContext
```

---

## Theme

Defined in `lib/shared/theme.dart`. The app uses a **dark blue** palette:

| Token | Color |
|---|---|
| `DARK_BLUE` | `#1A1C2B` — scaffold background |
| `DEEP_BLUE` | `#0D0D17` — AppBar / BottomNavBar / dialogs |
| `LIGHT_BLUE` | `#5499FE` — primary accent |

---

## Firebase Integration

Initialised in `main()` before the widget tree is mounted:

1. `Firebase.initializeApp()` with `DefaultFirebaseOptions.currentPlatform`
2. `FirebaseAppCheck.instance.activate()` (Apple App Attest on iOS/macOS)
3. `FirebaseCrashlytics` is wired to `FlutterError.onError` and `PlatformDispatcher.instance.onError`

Config files per platform:
- Android: `android/app/google-services.json`
- iOS/macOS: `*/Runner/GoogleService-Info.plist`

---

## In-App Purchases (RevenueCat)

Configured in `main()` via `revenueCat()`. Platform-specific API keys:

- Android: `goog_JuJbmwmKhkyRSsswDqoVyMDlGdM`
- iOS/macOS: `appl_pKHoxoNodCJqGiKMyPkOzCNtcyF`

Premium features must check subscription status and degrade gracefully when not subscribed. The subscription paywall UI is in `lib/calculator/view/subscriptions.dart`.

---

## Version Management

Versions follow [Semantic Versioning](https://semver.org/). Use the Makefile targets which internally call `version-bump.sh` and `cider`:

```bash
make bump_fix    # 2.4.0 → 2.4.1  (bug fix)
make bump_feat   # 2.4.0 → 2.5.0  (new feature)
make bump_build  # increments build number only
```

---

## CI / CD

### `main.yaml` (manually triggered)
Builds the web app and deploys to GitHub Pages (`gh-pages` branch).

### `maintenance.yaml` (bi-weekly scheduled)
Creates a GitHub Issue assigned to `copilot-swe-agent` with a dependency-upgrade runbook. It runs on a `*/14 * *` cron and requires a `COPILOT_AGENT_PAT` secret.

---

## Commit Messages

All commits **must** follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

feat(calculator): add debounced submit to reduce recalculations
fix(history): prevent crash when printer field is empty
chore: upgrade flutter_riverpod to 3.2.1
docs: update CLAUDE.md with database layer details
```

Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`.

---

## Key Invariants for AI Assistants

1. **Always use `fvm flutter …`** — never bare `flutter`.
2. **Do not bypass lefthook** — fix analysis errors before pushing.
3. **Riverpod only** — no BLoC, ChangeNotifier, or setState for feature state.
4. **Write-then-update** — persist to DB before mutating provider state; rethrow on failure.
5. **Printer index is maintained automatically** — do not manually write to `printer_index`; always go through `DataBaseHelpers` or `PrinterIndexHelpers`.
6. **Test everything in `test/`** — mirror the `lib/` path; use `pumpApp()` for widget tests.
7. **Use conventional commits** — the maintenance runbook and changelog tooling (`cider`) depend on this.
8. **Localise all user-facing strings** — never hardcode display text.
9. **No public API docs required** — the `public_member_api_docs` lint rule is disabled.
10. **Keep widgets small** — extract sub-widgets rather than building large `build()` methods.
