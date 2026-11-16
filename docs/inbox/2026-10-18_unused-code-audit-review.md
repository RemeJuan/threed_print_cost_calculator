# Unused-Code Audit Review

Date: 2026-10-18

## Goal

Review audit candidates one at a time. Remove only candidates whose references and impact have been checked, then record focused verification. Audit findings are advisory and may include static-analysis false positives.

## Ordered candidate review

`removed; verified` means references and impact checked, removal completed, and post-removal checks passed.

### Dead classes and widgets

- [x] `removed; verified` — `SettingsHelpers` — removed `lib/settings/helpers/settings_helpers.dart`. Pre-removal reference search found no imports, construction, or method calls outside definition; current settings save path calls `_materialsRepository.saveMaterial` (`lib/settings/providers/materials_notifier.dart:211`); no registration/reflection hooks found. Baseline and post-removal checks passed: `fvm flutter test test/settings/providers/materials_notifier_test.dart` (exit 0, 7 tests); `fvm flutter analyze` (exit 0, no issues). Post-removal targeted reference search found no remaining `SettingsHelpers`/`settings_helpers` references. `git diff --check` passed; `git diff --no-index --check /dev/null docs/inbox/2026-10-18_unused-code-audit-review.md` passed (exit 1 only because files differ). No other candidate changed.
- [x] `removed; verified` — `SecurePremiumLocalStore` — deleted `lib/purchases/premium_local_store_secure.dart` and removed its export from `lib/purchases/premium_local_store.dart`. Before removal, search showed no construction/import outside definition; production uses `SharedPrefsPremiumLocalStore` (`lib/main.dart:60,63-68`), provider default uses in-memory store, and migration/cached fallback files remain untouched. Baseline passed: `fvm flutter test test/purchases/premium_local_store_test.dart` (exit 0, 7 tests), `fvm flutter test test/purchases/premium_local_store_migration_test.dart` (exit 0, 3 tests). After removal both same commands passed (exit 0, 7 and 3 tests); `fvm flutter analyze` passed (exit 0, no issues). Targeted search found no code references; historical notes retain name only. `git diff --check` passed. One parallel migration-test attempt hit transient macOS native-asset signing error; rerun serially passed. No other candidate changed.
- [x] `removed; verified` — `GCodeImportButton` — deleted `lib/gcode_import/gcode_import_button.dart`. Pre-removal reference search found no code references (only feature-map inventory and this review row); live HeaderActions routes directly to `GCodeImportPage`, preserved. Baseline: `fvm flutter test test/app/view/header_actions_test.dart` (exit 0, 2 tests); `fvm flutter test test/gcode_import/gcode_import_page_actions_test.dart test/gcode_import/gcode_import_page_rendering_test.dart` (exit 0, 9 tests). After removal, same commands passed (exit 0, 2 and 9 tests); `fvm flutter analyze` passed (exit 0, no issues). No other candidate changed.
- [x] `removed; verified` — `AdjustmentsSection` — deleted `lib/calculator/view/components/adjustments_section.dart`. Pre-removal reference search found no code references; live `JobPricingOverridesSection` remains mounted in calculator. Baseline `fvm flutter test test/calculator/provider/pricing_settings_sync_test.dart test/calculator/view/calculator_page_test.dart` passed (exit 0, 8 tests). After removal, `fvm flutter analyze` passed (exit 0, no issues) and same focused tests passed (exit 0, 8 tests). No other candidate changed.
- [x] `removed; verified` — `RatesSection` — deleted `lib/calculator/view/components/rates_section.dart`. Pre-removal reference search found no code references; live `JobPricingOverridesSection` remains mounted and contains wear/risk inputs. Baseline `fvm flutter test test/calculator/provider/pricing_settings_sync_test.dart test/calculator/view/calculator_page_test.dart` passed (exit 0, 8 tests). After removal, `fvm flutter analyze` passed (exit 0, no issues) and same focused tests passed (exit 0, 8 tests). No other candidate changed.
- [x] `removed; verified` — `PromoHistoryTabIcon` — deleted `lib/app/promo_history_tab_icon.dart`. Pre-removal search found no code references; shell builds history icon directly. Baseline `fvm flutter test test/app/view/premium_gating_test.dart test/app/view/app_page_selection_test.dart` passed (exit 0, 8 tests). After removal, `fvm flutter analyze` passed (exit 0, no issues), and same tests passed (exit 0, 8 tests). No other candidate changed.
- [x] `removed; verified` — `AccordionMenu` — removed orphan subtree `lib/shared/components/accordion_menu/` (widget, model, notifier). Pre-removal search found no references outside subtree; internal item/notifier references were exclusive to widget. Baseline `fvm flutter test test/settings/` passed (exit 0, 94 tests); `fvm flutter analyze` passed (exit 0, no issues). After removal same test and analyze commands passed (exit 0, 94 tests; no issues). No other candidate changed.
- [x] `removed; verified` — `BatchAnchorSelector` widget — removed widget implementation from `lib/batch_costing/widgets/batch_anchor_selector.dart`; preserved `BatchAnchorSelectorEntry` and its file/import path. Pre-removal constructor search found no widget callsites; material/printer pages use `BatchSearchableSelector` and the entry model. Baseline and post-removal `fvm flutter test test/batch_costing/batch_material_assignment_page_test.dart test/batch_costing/batch_printer_assignment_page_test.dart` passed (exit 0, 10 tests); post-removal `fvm flutter analyze` passed (exit 0, no issues). No other candidate changed.

### Dependency candidates

- [x] `removed; verified` — `equatable` — removed direct declaration from `pubspec.yaml`. Search found no Dart/test/config references. Baseline and post-removal `fvm flutter test test/calculator/helpers/pricing_calculator_test.dart` passed (exit 0, 9 tests); `fvm flutter analyze` passed before and after (exit 0, no issues). `fvm flutter pub get` passed; `equatable` remains in lockfile as transitive dependency. No other dependency changed.
- [x] `removed; verified` — `platform_info` — removed direct declaration from `pubspec.yaml`. Search found no Dart/test/platform/build/config references. Baseline and post-removal `fvm flutter test test/settings/providers/printers_notifier_test.dart` passed (exit 0, 3 tests); `fvm flutter analyze` passed before and after (exit 0, no issues). `fvm flutter pub get` passed. No other dependency changed.
- [x] `removed; verified` — `bloc_test` — removed dev dependency from `pubspec.yaml`; updated exactly two stale mentions in `.github/copilot-instructions.md`. Search found no test imports/API use, generator, or CI use. Baseline and post-removal `fvm flutter test test/settings/providers/materials_notifier_test.dart` passed (exit 0, 7 tests); `fvm flutter analyze` passed before and after (exit 0, no issues). `fvm flutter pub get` passed. No other package or guidance changed.
- [x] `removed; verified` — `shorebird_code_push` — removed app dependency from `pubspec.yaml`. Search found no Dart imports or manual updater API calls (`ShorebirdUpdater`, `checkForUpdate`, `update`, `readCurrentPatch`); only `shorebird.yaml` explanatory comment and package declaration were found. Baseline and post-removal `fvm flutter test test/main_migration_test.dart` passed (exit 0, 10 tests); `fvm flutter analyze` passed before and after (exit 0, no issues); `fvm flutter pub get` passed. Shorebird CLI configuration, `shorebird.yaml`, and CI workflows remain unchanged. Package is optional Dart API; automatic OTA updates are engine-driven.

### Font candidates

- [x] `removed; verified` — removed exact 18 files matching `assets/fonts/Montserrat-*.ttf`: `Montserrat-Black.ttf`, `Montserrat-BlackItalic.ttf`, `Montserrat-Bold.ttf`, `Montserrat-BoldItalic.ttf`, `Montserrat-ExtraBold.ttf`, `Montserrat-ExtraBoldItalic.ttf`, `Montserrat-ExtraLight.ttf`, `Montserrat-ExtraLightItalic.ttf`, `Montserrat-Italic.ttf`, `Montserrat-Light.ttf`, `Montserrat-LightItalic.ttf`, `Montserrat-Medium.ttf`, `Montserrat-MediumItalic.ttf`, `Montserrat-Regular.ttf`, `Montserrat-SemiBold.ttf`, `Montserrat-SemiBoldItalic.ttf`, `Montserrat-Thin.ttf`, `Montserrat-ThinItalic.ttf`. No pubspec font/assets declaration or Dart/config/native/build reference found. Baseline `fvm flutter build bundle` passed; pre-removal `AssetManifest.bin`/`FontManifest.json` contained four Inter font files and no Montserrat. After removal `fvm flutter build bundle`, `fvm flutter analyze`, and `fvm flutter test test/app/view/app_test.dart` passed (exit 0; 5 tests); manifests still list four Inter faces and no Montserrat. Confirmed `assets/icons/app_icon.png`, `assets/icons/app_icon_monochrome.png`, and `shorebird.yaml` remain present/configured. No dependency changes.

## Review outcome

All 13 candidate entries removed and verified separately: eight class/widget candidates, four direct dependencies, and one group of 18 Montserrat files. Final `make flutter_test` passed (945 tests); `fvm flutter analyze`, `fvm flutter build bundle`, and `git diff --check` passed. Post-cleanup audit reports 0 dead classes, 3 tooling-only packages, and 7 configuration/build assets; preserve those false positives. Tests and bundle validation do not replace signed release/OTA checks in CI.

## Keep / likely false-positive list

Keep these; audit result does not justify removal:

- `cider` — referenced by `scripts/version-bump.sh`.
- `husky` — used for Git hooks.
- `flutter_launcher_icons` — used by launcher-icon generator configuration.
- Four Inter font files — declared in the theme/pubspec asset configuration.
- `assets/icons/app_icon.png` and `assets/icons/app_icon_monochrome.png` — configured launcher icons.
- `shorebird.yaml` — Shorebird configuration, also declared as a pubspec asset; static asset scan misclassifies it.

## Safe verification protocol

Review one checkbox at a time. For each candidate:

1. Record its exact references: source/import/export search, pubspec/configuration, platform and build scripts, indirect registration/reflection, and tests. A zero-use static result alone is insufficient.
2. Record behavior and release impact, including premium/persistence, navigation, platform-specific, CI, generator, and store/release paths where applicable.
3. Before removal, identify focused tests or checks covering affected behavior. After any removal, run them, plus analyzer/build or release configuration validation when relevant. Record exact commands and outcomes; reference review alone does not establish post-removal success.
4. Remove one verified candidate at a time and review its diff before proceeding to the next.
5. Never use automatic cleanup; retain configuration/tooling assets and dependencies despite static false positives.
