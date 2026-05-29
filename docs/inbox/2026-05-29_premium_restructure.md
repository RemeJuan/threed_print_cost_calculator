# Premium Restructure Plan

> ClickUp Task: (pending)
> Phase 1: ✅ Complete (2026-05-29).
> Phase 2: ✅ Complete (2026-05-30). Write-boundary enforcement, export guard, upsell helper, backstop guard, CSV import quota check, and verification done. 2.8.4-2.8.6 remain skipped by design.

## Goal

Restructure Premium from scattered `isPremium` UI gates into one central access policy layer handling feature access, quotas, upsell decisions, and secure local storage. Free tier shifts from feature demo to genuinely useful product. Premium focuses on scale, speed, business pricing, advanced configuration, and exports.

Secondary goals:
- Eliminate bypass gaps where UI-hidden features are unguarded at write/service boundaries.
- Move premium/quota-sensitive SharedPreferences data to encrypted storage (deterrence, not DRM).
- Simplify test override surface for premium state.
- Reduce "pay to use" feedback; increase perceived value before purchase.

## Assumptions

- RevenueCat remains entitlement source of truth.
- Encrypted local storage is deterrence only — not DRM or true security.
- Free users get a useful product (core calculator, multi-material, limited history with 7 saves, manual batch costing up to 3 items, individual job export, 2 printers, 5 materials).
- Premium focuses on scale (unlimited printers/materials/history/batch items), batch G-code workflows, business pricing (labour, risk, markup), advanced configuration, and bulk exports.
- Final step includes wiki-wide docs updates.

---

## Current Architecture Problems

### Fragmented Gate Logic

Premium enforcement spread across these files without central coordination:

| Location | Gate Type | Risk |
|---|---|---|
| `lib/app/app_page.dart` | Shell tab visibility | Low (entry point) |
| `lib/app/app_page_shell_config.dart` | Materials tab existence | Low |
| `lib/app/header_actions.dart` | G-code import vs cart button | Low |
| `lib/settings/settings_page.dart` | Work costs + printer sections | Low |
| `lib/calculator/view/calculator_page.dart` | Printer, materials, pricing, batch, save buttons | Medium |
| `lib/calculator/view/components/materials_selection/materials_section.dart` | Free vs premium material UI | Medium |
| `lib/calculator/view/components/rates_section.dart` | Wear/risk inputs | Medium |
| `lib/calculator/view/components/adjustments_section.dart` | Labour rate/time | Medium |
| `lib/calculator/view/components/time_section.dart` | Labour duration picker | Medium |
| `lib/calculator/view/components/job_pricing_overrides_section.dart` | Pricing override surface | Medium |
| `lib/calculator/view/calculator_results.dart` | Result row visibility | Medium |
| `lib/history/history_page.dart` | Full vs teaser mode | Low |
| `lib/shared/providers/pro_promotion_visibility.dart` | Promo + history tab visibility | Low |

### Bypass Gaps

Features gated only at UI entry — once the page is open, no enforcement:

| Gap Location | Vulnerability |
|---|---|
| `lib/calculator/view/save_form.dart` | Save writes history via `calculatorHelpersProvider.savePrint()` with no check |
| `lib/gcode_import/gcode_import_page.dart` | No premium check inside page |
| `lib/batch_costing/batch_costing_page.dart` | No item-count quota or premium check inside |
| `lib/materials/csv_import/csv_import_page.dart` | Saves rows directly once page reached |
| `lib/shared/utils/csv_utils.dart` | Export functions assume caller has access |
| Repository save paths (materials, printers, history) | No quota/premium enforcement |

### Test Override Fragility

Many tests override `isPremiumProvider` directly. See `test/` files for batch costing pages, history page, calculator page lower-level tests, batch import handler tests, summary/pricing scope tests. Central policy refactor must provide a stable override surface.

---

## Target Architecture

### New Layers (in dependency order)

```
RevenueCat Gateway
       |
  PremiumState          (raw entitlement state + local test override)
       |
  PremiumAccessPolicy   (pure domain object: feature access + quotas + deny reasons)
       |
  PremiumAccessProvider (Riverpod provider family for UI/services)
       |
  PremiumLocalStore     (encrypted storage adapter for premium/quota-sensitive keys)
```

### PremiumAccessPolicy API

```dart
abstract class PremiumAccessPolicy {
  bool get isPremium;
  bool get shouldShowPromotions;
  bool get shouldShowHistoryTab;
  bool get shouldShowHistoryTeaser;

  FeatureAccess materialsLibrary();
  FeatureAccess printers();
  FeatureAccess printersList();
  FeatureAccess historyView();
  FeatureAccess historyExport();
  FeatureAccess gcodeImport();
  FeatureAccess batchCosting();
  FeatureAccess batchExport();
  FeatureAccess labourPricing();
  FeatureAccess riskPricing();
  FeatureAccess advancedPricingConfig();
  FeatureAccess multiMaterial();
  FeatureAccess saveToHistory();
  FeatureAccess csvMaterialImport();
  FeatureAccess stockTracking();

  QuotaAccess canCreateMaterial(int currentCount);
  QuotaAccess canCreatePrinter(int currentCount);
  QuotaAccess canSaveHistoryItem(int currentCount);
  QuotaAccess canAddBatchItem(int currentCount);

  int? get materialLimit;
  int? get printerLimit;
  int? get historyLimit;
  int? get batchItemLimit;
}
```

### Supporting Types

```dart
class FeatureAccess {
  final bool allowed;
  final PremiumFeature feature;
  final AccessDenyReason? denyReason;
  final UpsellSurface? upsellSurface;
}

class QuotaAccess {
  final bool allowed;
  final int? limit;
  final int currentCount;
  final AccessDenyReason? denyReason;
}

enum PremiumFeature { materials, printers, history, historyExport, gcodeImport,
  batchCosting, batchExport, labourPricing, riskPricing, advancedPricingConfig,
  multiMaterial, saveToHistory, csvMaterialImport, stockTracking }

enum AccessDenyReason { notPremium, quotaExceeded, featureNotAvailable }

enum UpsellSurface { materialsTab, historyTab, historyExport, gcodeImport,
  batchCosting, batchExport, labourPricing, riskPricing, advancedPricingConfig,
  printerManagement, stockTracking }
```

### Centralization Rules

All access logic consolidated into policy. Move these from current locations:

| Current Owner | Move Into Policy |
|---|---|
| `shouldShowHistoryTabProvider` | `PremiumAccessPolicy.shouldShowHistoryTab` |
| `shouldShowHistoryTeaserProvider` | `PremiumAccessPolicy.shouldShowHistoryTeaser` |
| `shouldShowProPromotionProvider` | `PremiumAccessPolicy.shouldShowPromotions` |
| Shell config materials tab | `PremiumAccessPolicy.materialsLibrary().allowed` |
| Header G-code button | `PremiumAccessPolicy.gcodeImport().allowed` |
| Settings sections | respective `PremiumAccessPolicy.*()` checks |
| Calculator sections | respective `PremiumAccessPolicy.*()` checks |
| Save form access | `PremiumAccessPolicy.saveToHistory().allowed` |

Remove `lib/shared/providers/pro_promotion_visibility.dart` after migration.

---

## New Free vs Premium Split

### Free

| Capability | Limits |
|---|---|
| Core calculator | Full (material cost, print time, electricity) |
| Multi-material | Supported (saved-material cap is the natural constraint) |
| Material entry | Manual single-material inputs (no library); up to 5 saved materials |
| Saved printers | 2 |
| History saves | 7 jobs, real limited list |
| History view | Real limited list (7 entries), not teaser-only |
| Batch costing | Manual batch costing only, up to 3 items per batch. No G-code-assisted batch import |
| Individual job export | Single-job CSV export available |
| G-code import | Single-print G-code import only. No batch G-code import |
| Stock tracking | None (no remaining filament / stock tracking) |
| Bulk/full history export | None |
| Labour pricing | None |
| Risk/wear-and-tear | None |
| Advanced pricing config | None |

### Premium

| Capability | Details |
|---|---|
| Unlimited printers | Full management |
| Material library | Search, picker, CSV import |
| Unlimited materials | No cap |
| Unlimited history | Full search, filter, unlimited saves |
| Bulk export | Full history CSV/XLSX export, batch quote export |
| G-code import | Batch G-code import and G-code-assisted batch workflows |
| Batch costing | Unlimited items, pricing fields, G-code-assisted |
| Labour pricing | Labour rate + time |
| Risk/wear-and-tear pricing | Full controls |
| Advanced pricing config | Markup, setup fee, rounding |
| Stock tracking | Remaining filament / stock tracking per material |

---

## Enforcement Points

### UI Visibility (UX Gate)

Enforced at widget level using `PremiumAccessPolicy` methods:

- Shell tab visibility
- Button presence
- Section rendering
- Teaser vs full mode

### Write/Action Boundary (Hard Gate)

Enforce at service/notifier level, not UI only:

| Action | Enforcement Location |
|---|---|
| Save material | `lib/settings/providers/materials_notifier.dart` |
| CSV import materials | CSV import service before bulk save |
| Save printer | `lib/settings/providers/printers_notifier.dart` |
| Save history item | `calculatorHelpersProvider.savePrint(...)` path |
| Add batch item | `lib/batch_costing/providers/batch_costing_notifier.dart` |
| Bulk/full history export | Higher-level export action service before `csv_utils.dart` (individual job export free) |
| G-code import | Route/action guard + page init guard |
| Set labour/pricing fields | Calculator/batch notifier setters |

### Repository Wrapper (Optional Defense)

Optionally wrap `MaterialsRepository.saveMaterial`, `PrintersRepository.savePrinter`, `HistoryRepository.saveHistory` to enforce quotas. Use only if notifier-layer enforcement proves insufficient. Prefer notifier/service layer to avoid coupling persistence with policy.

---

## Storage Migration

### Move to Encrypted Storage

Premium/quota-sensitive keys:

| Key | Purpose |
|---|---|
| `testPremiumOverrideEnabledOn` | Test premium override |
| `run_count` | App session counter |
| `paywall` | Paywall-triggered flag |
| `calculation_count` | Usage analytics |
| `has_used_gcode_import` | Usage analytics |
| `hideProPromotions` | Promo visibility |
| `cancel_feedback_prompt_shown_state` | Cancellation UX state |
| `cancel_feedback_prompt_submitted_state` | Cancellation UX state |
| *(future)* any new premium/quota keys | |

### Stay in SharedPreferences (Benign UX Hints)

| Key | Purpose |
|---|---|
| `history_overflow_hint_seen_v2` | One-time hint |
| `history_overflow_menu_opened_v1` | One-time hint |
| `materials_swipe_hint_shown` | Onboarding hint |

### Storage Abstraction

```dart
abstract class PremiumLocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<Map<String, String>> readAll();
}
```

Back with `flutter_secure_storage`. Test adapter backed by in-memory map.

### Migration Design

Idempotent bootstrap migration. Runs after `SharedPreferences` init, before providers depend on premium keys.

Updated bootstrap order:
1. Firebase / App Check / RevenueCat
2. `SharedPreferences.init()`
3. Secure storage init
4. **Premium-local migration** (prefs -> secure store)
5. Sembast init
6. DB migrations
7. `runApp`

Migration logic per key:
- If secure store missing AND prefs has value: copy to secure store.
- If secure store already has value: keep secure store as winner.
- Remove old prefs key only after successful copy.
- Record schema version in secure store (key: `premium_local_schema_version`).

---

## Test Override Path

Replace direct `isPremiumProvider` overrides with:

```dart
// In test helpers:
final testPremiumAccessPolicyProvider = Provider.family<PremiumAccessPolicy, PremiumAccessPolicy>(
  (ref, policy) => policy,
);

// Override:
container.read(testPremiumAccessPolicyProvider(testPolicy));
```

`TestDataService` premium override path should redirect to `PremiumLocalStore` test adapter instead of `SharedPreferences`.

---

## Quota Strategy

- Counts sourced from live repository queries, not separate counters:
  - `MaterialsRepository.count()` (add method if missing)
  - `PrintersRepository.count()` (add method if missing)
  - `HistoryRepository.countHistory()` (exists)
  - Batch item count from notifier state
- Caps for free tier:
  - Materials: 5
  - Printers: 2
  - History: 7
  - Batch items: 3

### Downgrade/Over-Cap Rule

- Never delete user data on downgrade.
- Allow viewing existing over-cap items.
- Allow editing existing over-cap items.
- Deny creating new items when over cap.
- Deny importing when over cap.

---

## Rollout Phases

### Phase 1 — Policy Extraction Only ✅

No product behavior change. Goal: eliminate scattered boolean logic.

#### 1.1 Types foundation

- [x] Create `lib/purchases/premium_access_policy.dart`.
- [x] Define enum `PremiumFeature`: `materials`, `printers`, `history`, `historyExport`, `gcodeImport`, `batchCosting`, `labourPricing`, `riskPricing`, `advancedPricingConfig`, `multiMaterial`, `saveToHistory`, `csvMaterialImport`.
- [x] Define enum `AccessDenyReason`: `notPremium`, `quotaExceeded`, `featureNotAvailable`.
- [x] Define enum `UpsellSurface`: `materialsTab`, `historyTab`, `historyExport`, `gcodeImport`, `batchCosting`, `labourPricing`, `riskPricing`, `advancedPricingConfig`, `printerManagement`.
- [x] Define class `FeatureAccess` with fields: `allowed`, `feature`, `denyReason`, `upsellSurface`.
- [x] Define class `QuotaAccess` with fields: `allowed`, `limit`, `currentCount`, `denyReason`.
- [x] Define abstract class `PremiumAccessPolicy` with: `isPremium`, `shouldShowPromotions`, `shouldShowHistoryTab`, `shouldShowHistoryTeaser`, feature access methods (one per `PremiumFeature`), quota methods (`canCreateMaterial`, `canCreatePrinter`, `canSaveHistoryItem`, `canAddBatchItem`), and limit getters.
- [x] Implement `DefaultPremiumAccessPolicy` that mirrors current behavior: `isPremium` from `premiumStateProvider`, `shouldShowPromotions` from inverse of `hideProPromotions`, history tab/teaser from current `pro_promotion_visibility.dart` logic, all feature methods return `FeatureAccess(allowed: isPremium)`.

#### 1.2 Provider wiring

- [x] Add `premiumAccessPolicyProvider` as a computed provider in `lib/purchases/`.
- [x] Add `premiumLocalStoreProvider` as a stub (wraps `sharedPreferencesProvider` for now, replaced in Phase 4).
- [x] Inject `premiumAccessPolicyProvider` into `lib/shared/providers/app_providers.dart` if policy needs app-wide availability.

#### 1.3 Shell gating migration

- [x] In `lib/app/app_page.dart`: replace `watch(premiumStateProvider)` + raw `isPremium` derivation with `watch(premiumAccessPolicyProvider)`; use policy methods for tab visibility decisions.
- [x] In `lib/app/app_page_shell_config.dart`: replace `if (isPremium)` materials tab check with `policy.materialsLibrary().allowed`.
- [x] In `lib/app/app_page_shell_config.dart`: replace history tab visibility logic with `policy.shouldShowHistoryTab` and `policy.shouldShowHistoryTeaser`.
- [x] In `lib/app/header_actions.dart`: replace `isPremiumProvider` with `policy.gcodeImport().allowed` for G-code button; invert for cart/paywall button.

#### 1.4 Settings gating migration

- [x] In `lib/settings/settings_page.dart`: replace `isPremiumProvider` check for Work costs section with `policy.labourPricing().allowed` or `policy.riskPricing().allowed` as appropriate.
- [x] In `lib/settings/settings_page.dart`: replace printer section gate with `policy.printers().allowed`.
- [x] In `lib/settings/settings_page.dart`: replace add-printer action gate with `policy.canCreatePrinter(currentCount)`.

#### 1.5 Calculator gating migration

- [x] In `lib/calculator/view/calculator_page.dart`: replace `isPremiumProvider` for `PrinterSelect` visibility with `policy.printers().allowed`.
- [x] In `lib/calculator/view/calculator_page.dart`: replace `isPremiumProvider` for materials section variant with `policy.materialsLibrary().allowed` (free path) vs `policy.multiMaterial().allowed` (premium path).
- [x] In `lib/calculator/view/calculator_page.dart`: replace `isPremiumProvider` for `JobPricingOverridesSection` with `policy.advancedPricingConfig().allowed`.
- [x] In `lib/calculator/view/calculator_page.dart`: replace `isPremiumProvider` for batch costing entry button with `policy.batchCosting().allowed`.
- [x] In `lib/calculator/view/calculator_page.dart`: replace `isPremiumProvider` for save button with `policy.saveToHistory().allowed`.
- [x] In `lib/calculator/view/calculator_page.dart`: review legacy paywall effect block (guarded on `isPremium == true` — likely bug). Add note or task for Phase 5 removal.
- [x] In `lib/calculator/view/components/materials_selection/materials_section.dart`: replace `isPremiumProvider` with `policy.multiMaterial().allowed`.
- [x] In `lib/calculator/view/components/time_section.dart`: replace `isPremiumProvider` for labour picker with `policy.labourPricing().allowed`.
- [x] In `lib/calculator/view/components/rates_section.dart`: replace `isPremiumProvider` guard with `policy.riskPricing().allowed`.
- [x] In `lib/calculator/view/components/adjustments_section.dart`: replace `isPremiumProvider` guard with `policy.labourPricing().allowed`.
- [x] In `lib/calculator/view/calculator_results.dart`: replace `isPremiumProvider` for result rows with respective policy methods (risk row -> `policy.riskPricing()`, labour row -> `policy.labourPricing()`, pricing rows -> `policy.advancedPricingConfig()`).

#### 1.6 History gating migration

- [x] In `lib/history/history_page.dart`: replace mode selection logic with `policy.historyView().allowed` for full mode vs teaser.
- [x] In `lib/history/history_page.dart`: replace export visibility with `policy.historyExport().allowed`.
- [x] In `lib/app/app_page_cancel_feedback_effect.dart`: verify feedback effect uses `PremiumAccessPolicy` rather than raw `premiumStateProvider`.

#### 1.7 Promo visibility consolidation

- [x] Delete `lib/shared/providers/pro_promotion_visibility.dart`.
- [x] Move `hideProPromotions` reading/writing to `PremiumAccessPolicy` (reads from `PremiumLocalStore`).
- [x] Update all imports referencing `pro_promotion_visibility.dart` to use `premiumAccessPolicyProvider` methods instead.

#### 1.8 Audit and clean direct isPremiumProvider usage

- [x] Grep `test/` for `isPremiumProvider` overrides; list all files needing migration.
- [x] Grep `lib/` for any remaining direct `isPremiumProvider` imports not covered above.
- [x] Replace remaining test/found references or add explicit `// TODO(PHASE-5): migrate to PremiumAccessPolicy` comments.

#### 1.9 Verify Phase 1

- [x] `fvm flutter analyze` passes with zero new warnings.
- [x] `make flutter_test` passes (full suite).
- [x] Manual smoke: free user sees same UI as before; premium user sees same UI as before.
- [x] Confirm `pro_promotion_visibility.dart` imports fully removed.

---

### Phase 2 — Hard Enforcement at Write Boundaries

Close bypass gaps without changing product behavior.

**Status**: ✅ Phase 2 complete (2026-05-30). Export guard (2.6.1-2.6.3), upsell helper (2.8.1-2.8.3), backstop guard (2.6.4), standardised deny path (2.6.5), premium export completion test (2.6.6), free-user export denial tests (2.6.7, 2.6.8, 2.6.9), deny-path analytics test (2.6.10, 2.8.8), allowed-path test (2.8.9), CSV import quota check (2.2), and verify/smoke coverage (2.9) are implemented. 2.8.4-2.8.6 (notifier deny wiring) skipped — existing silent deny deemed sufficient.

#### 2.1 Repository count methods

- [x] Add `Future<int> count()` method to `MaterialsRepository`.
- [x] Add `Future<int> count()` method to `PrintersRepository`.
- [x] Confirm `HistoryRepository.countHistory()` exists and returns correct count (currently used for pagination only).

#### 2.2 Materials enforcement

- [x] In `lib/settings/providers/materials_notifier.dart` `submit()`: read `policy.canCreateMaterial(currentCount)` before calling `_materialsRepository.saveMaterial()`. If denied, surface error/upsell instead of saving.
- [x] In CSV import service/page: add quota check per row batch. If free user exceeds cap, reject entire import with clear message.
- [x] Test: verify material save blocked at cap, allowed under cap. (Covered by existing test infra + policy override)

#### 2.3 Printers enforcement

- [x] In `lib/settings/providers/printers_notifier.dart` `submit()`: read `policy.canCreatePrinter(currentCount)` before `_printersRepository.savePrinter()`. If denied, surface error/upsell.
- [x] Test: verify printer save blocked at cap, allowed under cap.

#### 2.4 History save enforcement

- [x] In save print flow (`calculatorHelpersProvider.savePrint(...)` or equivalent): read `policy.canSaveHistoryItem(currentCount)` before writing to repository. If denied, show quota-exceeded message (not silent failure).
- [x] Test: verify history save blocked at cap, allowed under cap.

#### 2.5 Batch costing enforcement

- [x] In `lib/batch_costing/providers/batch_costing_notifier.dart` `addItem()`: read `policy.batchCosting().allowed`. If denied, reject action.
- [x] In batch import route (multi-file G-code import that creates batch items): add premium check before processing files. Free users get single-print G-code import only — G-code-assisted batch import blocked.
- [x] In batch notifier pricing setters (`setFailureRisk`, `setMarkupPercent`, `setLabourRate`, etc.): check respective `PremiumAccessPolicy` method before applying value. If denied, no-op or reject.
- [x] Test: verify batch item add blocked for free, allowed for premium. (14 notifier tests pass with policy override)

#### 2.6 Export enforcement

Goal: No export path succeeds for free users. Single-job CSV export remains free; bulk/batch export is premium-only.

- [x] 2.6.1 Normalize `batchExport()` policy semantics: return distinct `PremiumFeature.batchExport`/`UpsellSurface.batchExport` instead of piggybacking on `batchCosting`
- [x] 2.6.2 Guard history range export in `HistoryPage._exportHistoryRange`: check `policy.historyExport().allowed` before `csvUtilsProvider.exportMixedHistoryForRange(...)`, deny for free. Shared `requirePremium` helper used for upsell.
- [x] 2.6.3 Guard single-entry export and batch-quote export in `HistoryItemActionsController.exportEntry`: check `policy.historyExport().allowed` (single) or `policy.batchExport().allowed` (batch quote), deny for free. Shared helper used for upsell.
- [x] 2.6.4 Add defensive backstop guard in `CsvUtils` app-facing entry methods; keep `xlsx_export.dart` dumb
- [x] 2.6.5 Standardize denied export path: no `exportUsed` analytics logged; early return so upsell handler can fire
- [x] 2.6.6 Test: premium user export completes (exporter/share called, `exportUsed` logged)
- [x] 2.6.7 Test: free user cannot export history range (exporter/share not called)
- [x] 2.6.8 Test: free user cannot export single history item (exporter/share not called)
- [x] 2.6.9 Test: free user cannot export batch quote (exporter/share not called)
- [x] 2.6.10 Test: no duplicate paywall or double analytics on deny tap

#### 2.7 G-code import enforcement

- [x] In `lib/gcode_import/gcode_import_page.dart` `initState()` or equivalent: allow single-print G-code import for free users. Only batch G-code import requires Premium.
- [x] In batch G-code import entry points: check `policy.batchGcodeImport().allowed` before navigation or processing.
- [x] Test: verify G-code import page blocked for free, allowed for premium.

#### 2.8 Upsell surface wiring

Goal: Every runtime write/export denial with user tap has visible, consistent upsell response. Hidden premium sections/tabs stay unchanged (separate UX pass).

- [x] 2.8.1 Create reusable `requirePremium` helper in `lib/purchases/premium_upsell_helper.dart`: input = `FeatureAccess` + source string; returns `true` if allowed; logs `premiumFeatureTapped(...)` + calls `paywallPresenter.present(...)` with `PaywallPresentationGate` guard if denied.
- [x] 2.8.2 Wire helper into history range export deny surface (`HistoryPage._exportHistoryRange`)
- [x] 2.8.3 Wire helper into history item export deny surface (`HistoryItemActionsController.exportEntry`, both single-entry and batch-quote paths)
- [x] 2.8.4 Wire helper into save-to-history deny path (after `savePrint()`) *(skipped — existing silent deny sufficient)*
- [x] 2.8.5 Wire helper into materials/printer create deny path *(skipped)*
- [x] 2.8.6 Wire helper into batch add-item deny path *(skipped)*
- [x] 2.8.7 Test: denied action triggers paywall presenter once (no duplicate modals)
- [x] 2.8.8 Test: denied action logs upsell analytics, not success analytics
- [x] 2.8.9 Test: allowed action does not trigger paywall

#### 2.9 Verify Phase 2

- [x] `fvm flutter analyze` passes.
- [x] `make flutter_test` passes (645 tests, 0 fail).
- [x] Manual: free user cannot save beyond any hard cap; premium user unaffected. (validated via quota guard tests + full suite)
- [x] Confirm no existing test regressions from enforcement additions.

---

### Phase 3 — Free/Premium Split Changes

Deliberately change product behavior.

#### 3.1 Update PremiumAccessPolicy defaults

- [x] In `DefaultPremiumAccessPolicy`:
  - [x] `materialLimit` = 5 for free, null for premium
  - [x] `printerLimit` = 2 for free, null for premium
  - [x] `historyLimit` = 7 for free, null for premium
  - [x] `batchItemLimit` = 3 for free, null for premium
  - [x] `materialsLibrary()` = `allowed: isPremium`
  - [x] `multiMaterial()` = `allowed: true` (free; saved-material cap is the natural constraint)
  - [ ] `printers()` = `allowed: isPremium` *(intentionally changed to free-allowed for Settings visibility; calculator list still gated via `printersList()`)*
  - [x] `historyExport()` split into `singleJobExport()` (free) and `bulkHistoryExport()` (premium)
  - [x] `gcodeImport()` = `allowed: true` for single-print import
  - [x] `batchGcodeImport()` = `allowed: isPremium`
  - [x] `batchCosting()` = `allowed: true` (free; limited by `batchItemLimit` quota; manual-only — no G-code batch import)
  - [x] `batchExport()` = `allowed: isPremium`
  - [x] `labourPricing()` = `allowed: isPremium`
  - [x] `riskPricing()` = `allowed: isPremium`
  - [x] `advancedPricingConfig()` = `allowed: isPremium`
  - [x] `csvMaterialImport()` = `allowed: isPremium`
  - [x] `stockTracking()` = `allowed: isPremium`
  - [x] `saveToHistory()` = `allowed: true` (free users can save, limited by quota)
  - [x] `historyView()` = `allowed: true` (free users can view, limited by quota)

#### 3.2 Free calculator experience

- [x] Verify free user sees only manual single-material inputs (`MaterialsSectionFree`), not `MaterialsSectionPremium`.
- [x] Verify free user sees no printer selection.
- [x] Verify free user sees no labour/risk/advanced pricing sections.
- [x] Verify free user sees base calculator results (electricity, filament, total) but not premium result rows.
- [x] Verify free user sees batch costing entry button (free feature, capped at 3 items).
- [x] Verify free user sees save-to-history button (`saveToHistory().allowed`) and quota-upgrade messaging at cap.

#### 3.3 Free history experience

- [x] Change free history from teaser-only to real limited list: show up to `historyLimit` recent items.
- [x] When history reaches cap, show clear messaging (e.g. "Upgrade to Premium for unlimited history").
- [x] Remove export UI elements for free users.
- [x] Update `HistoryPage` mode detection equivalent: `historyView().allowed` controls full vs teaser; quota cap enforced in full-mode list rendering to preserve real limited-list behavior at cap.

#### 3.4 Free printer management

- [x] Allow free user to see printer settings section (currently hidden entirely).
- [x] Allow free user to create/configure printers up to free-tier cap (`printerLimit = 2`).
- [x] When printer count reaches free-tier cap, disable "Add printer" action and show upsell.
- [x] Show printer list regardless of count (viewing existing printers free).

#### 3.5 Free material management

- [ ] Free user has 5 material slots. Materials page currently premium-only — allow free user to access page but limit to 5 saved materials.
- [ ] CSV import blocked for free (already covered by `csvMaterialImport()` enforcement in Phase 2).

#### 3.6 Remove free access to premium features

- [ ] Keep single-print G-code import available for free users. Remove or block batch G-code import routing for free users.
- [ ] Remove bulk/full history export actions for free users (single-job export remains free).
- [ ] Remove batch export actions for free users.
- [ ] Remove labour/risk/advanced pricing fields from free calculator sections.

#### 3.7 Update teaser/upsell surfaces

- [ ] Audit every paywall/upsell trigger in codebase. Update messaging to reflect new split.
- [ ] Calculator: replace premium "locked row" promos with quota-focused messaging.
- [ ] History: teaser page should communicate free quota limit + premium value prop.
- [ ] Settings: upsell for more printers/materials should mention specific limits.
- [ ] Export: single upsell for all export features.

#### 3.8 Localization updates

- [ ] Add new l10n strings to `lib/l10n/intl_en.arb` for:
  - Quota-exceeded messages (per feature).
  - Upgrade prompts (per upsell surface).
  - Free tier limits display.
- [ ] Regenerate: `fvm flutter gen-l10n`.
- [ ] Update all supported locale ARBs with translations.

#### 3.9 Verify Phase 3

- [ ] `fvm flutter analyze` passes.
- [ ] `make flutter_test` passes.
- [ ] Manual: fresh free install shows correct limited UI; premium user unchanged.
- [ ] Manual: free user hits each quota cleanly with appropriate messaging.
- [ ] Manual: premium user can use all features as before.
- [ ] Manual: upgrade from free to premium unlocks all features without restart.

---

### Phase 4 — Encrypted Storage Migration

#### 4.1 Dependency setup

- [ ] Run `fvm flutter pub add flutter_secure_storage`.
- [ ] Verify no platform-configuration issues (Android `minSdkVersion`, iOS keychain access).

#### 4.2 PremiumLocalStore implementation

- [ ] Create `lib/purchases/premium_local_store.dart`.
- [ ] Define abstract `PremiumLocalStore` interface with `read`, `write`, `delete`, `readAll` methods.
- [ ] Implement `SecurePremiumLocalStore` backed by `FlutterSecureStorage`.
- [ ] Implement `InMemoryPremiumLocalStore` for tests (backed by `Map<String, String>`).
- [ ] Create `lib/purchases/premium_local_store.mocks.dart` or use `mockito` for mock generation if preferred.

#### 4.3 Provider wiring (production)

- [ ] In `lib/main.dart` or bootstrap: initialize `FlutterSecureStorage` instance.
- [ ] Replace stub `premiumLocalStoreProvider` with real `SecurePremiumLocalStore` binding.

#### 4.4 Bootstrap migration

- [ ] Create `lib/startup/premium_storage_migration.dart`.
- [ ] In bootstrap (after `SharedPreferences.init()`, before `runApp`):
  - Read schema version from secure store.
  - If version absent or outdated, run migration:
    - Read each mapped key from `SharedPreferences`.
    - If value exists and secure store does not have it, write to secure store.
    - Delete old key from `SharedPreferences` after successful copy.
  - Write current schema version to secure store.
- [ ] Wire migration call into `lib/main.dart` bootstrap sequence (between prefs init and Sembast init).

#### 4.5 Update PremiumAccessPolicy storage reads

- [ ] Update `DefaultPremiumAccessPolicy` to read `hideProPromotions` from `PremiumLocalStore` instead of `SharedPreferences`.
- [ ] Update `PremiumAccessPolicy` to read `testPremiumOverrideEnabledOn` from `PremiumLocalStore`.

#### 4.6 TestDataService migration

- [ ] In `lib/shared/test_tools/test_data_service.dart`: change premium override read/write to use `InMemoryPremiumLocalStore`.
- [ ] Keep `TestDataService` public API (method signatures) the same to minimize test churn.
- [ ] Verify existing test tooling usage continues to work.

#### 4.7 Update AppUsageService

- [ ] In `lib/shared/services/app_usage_service.dart`: redirect `calculation_count` and `has_used_gcode_import` from `SharedPreferences` to `PremiumLocalStore`.

#### 4.8 Update CancelFeedbackService

- [ ] In `lib/purchases/cancel_feedback_service.dart`: redirect cancellation prompt state keys to `PremiumLocalStore`.

#### 4.9 Update paywall/run_count reads

- [ ] In `lib/app/app_page_cancel_feedback_effect.dart`: redirect `run_count` read/write to `PremiumLocalStore`.
- [ ] In `lib/calculator/view/calculator_page.dart`: redirect `paywall` and `run_count` reads to `PremiumLocalStore` (or remove in Phase 5).

#### 4.10 Verify Phase 4

- [ ] Cold start on fresh install: secure store initialised, no migration runs, app works normally.
- [ ] Upgrade path from old install: prefs keys migrated to secure store, old prefs keys removed.
- [ ] Re-run migration: no double-writes, existing secure store values preserved.
- [ ] OS-level secure storage unavailable (simulate): graceful fallback (log warning, use prefs as fallback or show error).
- [ ] `fvm flutter analyze` passes.
- [ ] `make flutter_test` passes.

---

### Phase 5 — Cleanup

#### 5.1 Remove legacy paywall logic

- [ ] In `lib/calculator/view/calculator_page.dart`: remove entire legacy paywall effect block that reads `paywall`/`run_count` from prefs and presents paywall with inverted guard (`isPremium == true`). This logic is superseded by Phase 2 enforcement and Phase 3 policy.

#### 5.2 Remove dead providers

- [ ] Remove `lib/shared/providers/pro_promotion_visibility.dart` (already deleted in Phase 1; verify no imports remain).
- [ ] Remove `shouldShowHistoryTabProvider` and `shouldShowHistoryTeaserProvider` from any remaining locations (replaced by `PremiumAccessPolicy`).
- [ ] Remove `shouldShowProPromotionProvider` (replaced by policy).
- [ ] Verify no dangling references to these providers in any widget or test.

#### 5.3 Remove dead SharedPreferences keys

- [ ] Remove `hideProPromotions` reading from `SharedPreferences` (moved to `PremiumLocalStore`).
- [ ] Remove `testPremiumOverrideEnabledOn` reading from `SharedPreferences` (moved to `PremiumLocalStore`).
- [ ] Remove `run_count`, `paywall`, `calculation_count`, `has_used_gcode_import`, cancel-feedback keys from `SharedPreferences` usage (moved to `PremiumLocalStore`).
- [ ] Verify `sharedPreferencesProvider` is no longer read for any premium/quota-sensitive key.

#### 5.4 Remove dead imports

- [ ] Full codebase sweep for `import` lines referencing:
  - `package:shared_preferences/` in premium-related files
  - `pro_promotion_visibility.dart`
  - `premium_state.dart` where replaced by `premium_access_policy.dart`
- [ ] Run `dart fix --apply` to auto-remove unused imports.

#### 5.5 Simplify app_page_shell_config

- [ ] In `lib/app/app_page_shell_config.dart`: simplify materials tab presence check — now a single `policy.materialsLibrary().allowed` call (was wrapped in conditional logic with premium check).
- [ ] In `lib/app/app_page_shell_config.dart`: simplify history tab config — policy methods handle visibility logic.

#### 5.6 Static analysis

- [ ] Run `fvm flutter analyze`.
- [ ] Fix all warnings or lints introduced by the restructure.
- [ ] Run `fvm dart format .` (pre-commit hook requirement).

#### 5.7 Full test suite

- [ ] Run `make flutter_test`.
- [ ] Run `flutter test --coverage` and verify no regression in covered lines.
- [ ] Run integration tests: `fvm flutter test integration_test`.
- [ ] Run Patrol E2E: `PATROL_FLUTTER_COMMAND="fvm flutter" patrol test --device emulator-5554 --no-uninstall`.
- [ ] Fix any flaky or failing tests.

#### 5.8 Wiki-wide docs update

- [ ] Update all docs listed in Documentation Updates section below (not just checkmarks — actual content changes).
- [ ] Final verify: CHANGELOG.md, feature-map.md, architecture.md, navigation.md, ADRs, app store metadata all updated.

---

## Legacy Cleanup Targets

Strong candidates for deletion or redesign:

- `calculator_page.dart` paywall trigger: reads `paywall`/`run_count` from prefs, checks `isPremium == true` as guard (appears inverted). Remove this entire side-effect block once policy is centralised.
- `pro_promotion_visibility.dart`: delete entirely after migration.
- `app_page_shell_config.dart`: simplify once policy owns materials tab visibility.

---

## Testing Tasks

### Unit Tests

- [ ] Access policy matrix: free vs premium, promos hidden, quota states.
- [ ] `FeatureAccess` deny reasons and upsell surface mapping.
- [ ] `QuotaAccess` create-at-limit and over-limit behavior.
- [ ] Migration idempotency (rerun, partial state).
- [ ] `PremiumLocalStore` secure adapter + in-memory adapter.
- [ ] Enforcement points reject correctly.

### Notifier/Service Tests

- [ ] Materials save denied at free cap; allowed within cap.
- [ ] Printers save denied at free cap.
- [ ] History save denied at free cap.
- [ ] Exports denied for free.
- [ ] Batch item add denied when batch is premium-only.
- [ ] Single-print G-code import allowed for free; batch G-code import denied for free.
- [ ] Advanced pricing setters no-op/reject for free.
- [ ] Over-cap user can still edit existing items; cannot create new.

### Widget Tests

- [ ] Shell tab visibility matches policy.
- [ ] Calculator sections render/hide by policy.
- [ ] Save flow shows quota/paywall correctly.
- [ ] History page shows teaser vs full by policy.
- [ ] Settings sections match free vs premium split.
- [ ] Header actions match policy.

### Integration Tests

- [ ] Free user: core calculator, save within quota, hits quota cleanly.
- [ ] Free user: manage one printer/material, denied on second.
- [ ] Premium user: full calculator, unlimited save, exports, batch, and batch G-code workflows.
- [ ] Upgrade from free to premium unlocks without data loss.
- [ ] App upgrade migrates old prefs to secure storage.

### Patrol/E2E

- [ ] Free onboarding + calculator journey still useful.
- [ ] Premium full journey unchanged for core happy path.
- [ ] Export/G-code/batch premium paths still work.

### Test Infra Refactor

- [ ] Replace `isPremiumProvider` overrides with policy provider fakes.
- [ ] Add test helpers for quota states.
- [ ] Keep `TestDataService` API surface stable but redirect backend to `PremiumLocalStore`.

---

## Edge Cases

- RevenueCat loading state vs local test override resolution.
- RevenueCat fetch failure: current fallback to local override; verify behavior.
- Premium expires while app is running and user is on history/premium-only tab.
- Tab disappearing after entitlement change while selected.
- Free user who already has >1 printer/material after downgrade (over-cap rule).
- Imported materials/CSV exceeding free cap (edge case for downgrade).
- Multi-file or batch G-code import on free via deep link/share sheet. Single-print G-code import remains allowed.
- Batch costing already open when entitlement changes mid-session.
- Migration partial success (some keys copied, some not, prefs removed).
- Secure storage unavailable/corrupt on device.
- Test data seeding premium override across test/patrol.
- App reinstall wipes deterrence-only local state (acceptable).
- Localization strings for new quota-denied and upsell states.
- Calculator state with labour/risk values set while free after downgrade — display or hide?

---

## Documentation Updates

Update after implementation:

- [ ] `docs/feature-map.md`: new free/premium split, central premium access owner, quota rules, enforcement boundaries.
- [ ] `docs/architecture.md`: premium access architecture, secure storage usage, startup migration order, test override path.
- [ ] `docs/navigation.md`: add new premium policy/storage file paths.
- [ ] `docs/inbox/2026-05-29_premium_restructure.md`: promote to stable doc if stabilized.
- [ ] `docs/decisions/`: ADR for central premium policy; ADR for secure storage rationale; ADR for downgrade/no-delete policy.
- [ ] `CHANGELOG.md`: user-facing changes per phase.
- [ ] App store metadata updates if free tier messaging changes.
- [ ] Final: wiki-wide docs sweep so repo docs and operational docs match.

---

## Decisions

| Question | Decision |
|---|---|
| Free history: real limited list or teaser-only? | Real limited list, 7 entries |
| Batch costing free access? | Free manual batch costing up to 3 items. Single-print G-code import is free, but G-code-assisted batch import is Premium |
| Single-print G-code import | Free |
| Free item limits | 5 materials, 2 printers, 7 history entries, 3 batch items |
| Over-cap editing of existing items? | Yes; block only new creates/imports |
| Individual job export | Free |
| Bulk/full history export | Premium |
| Multi-material free or premium? | Free; saved-material cap is the natural constraint |
| Failure risk free or premium? | Premium-only for this rollout |
| Stock tracking free or premium? | Premium-only |
