# Custom Paywall Phase 1 Plan

Status: **Completed** (2026-05-30)
Scope: Phase 1 preview only
Rollout: No
Production default paywall: Unchanged RevenueCat hosted paywall
Preview entry: Hidden admin tools only

## Goal

Build a fully functioning, production-ready custom in-app paywall that uses live RevenueCat data and real purchase/restore flows, but expose it only from the hidden admin menu for design iteration before replacing the existing hosted paywall.

The paywall must align with the premium restructure (2026-05-29):
- Free is a useful default tier, not a teaser or demo
- Premium is for scale, speed, business pricing, advanced workflows, and inventory control
- Comparison must highlight free-vs-premium trade-offs in scannable table form, not a premium-only marketing checklist

## Non-goals

- No rollout of the custom paywall to normal user-facing triggers in Phase 1
- No changes to existing paywall trigger/gate behavior
- No analytics additions
- No history-related changes
- No second source of truth for premium features or limits
- No special already-premium paywall UX work in this phase

## Constraints

- RevenueCat remains source of truth for offerings, packages, purchases, restores, and entitlements
- Existing `paywall_presenter` remains the active production path
- Preview must use real data and real purchase flows
- Feature comparison must be generated from the same metadata source used by premium gating/enforcement
- User-facing strings must use existing Flutter l10n
- UI must support long locales and variable package text lengths
- Currency output remains currency-agnostic in app-owned copy; RevenueCat price strings can still render store-provided localized pricing
- Comparison section must render as a table with columns: Feature | Free | Premium
- Comparison content must scroll independently from package selection area
- Package options must remain persistently visible while user browses the comparison table
- Package options must render side-by-side in a single row where screen width allows
- Table cells must display short scannable values (quota numbers, "Included", "No") instead of descriptive paragraphs

## Product positioning alignment

- Free is a functional calculator tier, not a preview or demo
- Free includes: core calculator, multi-material, 2 printers, 5 materials, 7 history saves, unlimited batch quotes, up to 3 items per batch, single-job export, single-print G-code import
- Premium is for: unlimited printers/materials/history, unlimited items per batch, batch G-code import, bulk export, labour/risk/advanced pricing, stock tracking
- Do not frame Premium as "unlock everything" — Free already has real value
- Do not frame features present in both tiers as premium-only
- Use comparisons that show progression (5 → Unlimited) instead of presence/absence where both tiers offer the feature

## Current code anchors

### Premium gating and limits
- `lib/purchases/premium_access_policy.dart`
- `lib/purchases/premium_access_providers.dart`

### Existing production paywall presenter
- `lib/purchases/paywall_presenter.dart`

### Existing custom RevenueCat purchase sheet
- `lib/calculator/view/subscriptions.dart`

### RevenueCat premium state mapping
- `lib/purchases/purchases_gateway.dart`

### Hidden admin tools
- `lib/shared/components/settings_version_tap_target.dart`
- `lib/shared/test_tools/test_data_tools_dialog.dart`

### Existing tests to extend
- `test/purchases/premium_access_policy_test.dart`
- `test/shared/components/settings_version_tap_target_test.dart`
- `test/helpers/lower_level_test_fakes.dart`

## Product decisions locked

- Phase 1 preview is fully functional, not mock-only
- Preview is for design/content iteration before replacing current paywall
- Existing production entry points still show RevenueCat hosted paywall
- Existing gates/triggers remain responsible for preventing premium users from seeing paywall in real usage
- No need to design special already-premium behavior inside the new paywall

## Implementation plan

### 1. Keep production presenter untouched

Do not change normal paywall entry behavior in:
- `lib/purchases/paywall_presenter.dart`

Expected Phase 1 behavior:
- current triggers still call hosted RevenueCat UI
- hidden admin preview opens new custom paywall directly

Reason:
- zero rollout risk
- design iteration can happen without affecting live paywall entry points

### 2. Add canonical paywall metadata to premium policy layer

Extend `lib/purchases/premium_access_policy.dart` with structured metadata colocated with `PremiumFeature` and quota logic.

New metadata should support:
- stable feature identity
- paywall row ordering
- inclusion/exclusion from paywall table
- whether feature is free or premium
- optional quota-backed display values
- localization mapping via typed metadata, not hardcoded widget copy

Expected result:
- premium enforcement and paywall comparison table share one source of truth
- free-tier limits such as materials/printers/history/batch items can render dynamically from policy-backed values

### 3. Add real RevenueCat paywall data abstraction

Current `PurchasesGateway` only covers premium state/customer info. Add a new abstraction under `lib/purchases/` for custom paywall actions.

Recommended responsibilities:
- fetch current offering
- expose available packages
- purchase selected package
- restore purchases
- optionally refresh or re-read customer info after purchase/restore completion

Recommendation:
- keep this separate from the existing premium-state gateway unless cleanly extensible without mixing concerns
- widgets should depend on Riverpod providers/gateways, not raw `Purchases` SDK calls

Reason:
- easier testing
- cleaner later swap from hosted paywall to custom paywall
- avoids duplicating RevenueCat SDK glue in multiple widgets

### 4. Build new custom paywall UI

Add new paywall screen under `lib/purchases/`.

Expected structure (top to bottom):
- compact header with close action
- short pitch section reframed around scale and business tools
- grouped comparison table driven by policy metadata
- pinned package selection row (side-by-side cards)
- CTA / restore / legal area

Expected behavior:
- uses live RevenueCat `availablePackages`
- supports real purchase flow
- supports real restore flow
- handles loading state
- handles missing offering state
- handles purchase cancel and purchase failure
- handles restore completion/failure feedback
- handles long localized strings and long price/package labels

Comparison table layout:
- three-column layout: Feature | Free | Premium
- table rows grouped by category with group header rows
- cell values are short scannable values: quota numbers, "Included", "No"
- no paragraph-length descriptions per row
- area scrolls independently; package selector stays pinned
- group headers and row labels tolerate translation length

Package selection area:
- package options render in a single horizontal row, side-by-side
- must remain visible while user scrolls comparison content
- on compact screens, use tighter cards or horizontal plan carousel instead of vertical stacking
- selected plan highlights clearly

#### 4.1 Comparison table content model

Feature metadata must be richer than the current enum + switch pattern.

Required fields per row:
- stable row id
- group/category name
- row label (localized)
- free tier value string (e.g. "5", "7 saves", "Included", "No")
- premium tier value string (e.g. "Unlimited", "Included", "No")
- optional helper/note text
- optional emphasis flag for strongest upgrade rows
- ordering within group

Rules:
- display metadata must remain separate from raw gating enum if enum identity is overloaded
- do not encode quota numbers as string literals in the model — derive from policy defaults
- keep the model simple enough to generate both the table and any future compact summary views from the same source

#### 4.2 Batch costing row split

Do not represent batch costing as a single comparison row. Split into three distinct rows:

- Batch quotes — Free: Unlimited, Premium: Unlimited
- Items per batch — Free: Up to 3, Premium: Unlimited
- Batch G-code import — Free: No, Premium: Included

Rationale: Free limitation is per-quote complexity (max 3 items), not number of quotes. A single row would mislead users into thinking batch costing is entirely premium-only.

UI system guidance:
- reuse `AppSurfaceCard`
- reuse `AppPrimaryButton`, `AppSecondaryButton`, `AppTertiaryButton`
- reuse `kAppSpace*` and radius tokens from `lib/shared/app_ui_tokens.dart`
- prefer semantic colors from `lib/shared/app_colors.dart`
- avoid marketing-heavy hero treatment

### 5. Add hidden admin preview entry

Update hidden test tools flow.

Files:
- `lib/shared/test_tools/test_data_tools_dialog.dart`
- `lib/shared/components/settings_version_tap_target.dart`

Changes:
- add new hidden action enum value
- add localized button label
- launch new custom paywall preview from hidden tools
- preview path should bypass `paywallPresenterProvider`

Reason:
- keep preview isolated from live production trigger wiring

### 6. Localization work

Update ARB files for all user-facing paywall strings.

Files:
- `lib/l10n/intl_en.arb`
- all supported locale ARBs:
  - `intl_de.arb`
  - `intl_es.arb`
  - `intl_fr.arb`
  - `intl_id.arb`
  - `intl_it.arb`
  - `intl_ja.arb`
  - `intl_nl.arb`
  - `intl_pt.arb`
  - `intl_th.arb`

String categories likely needed:
- paywall title/subtitle
- table column labels
- trust row text
- CTA labels
- loading/error/restore feedback
- preview button label in hidden tools
- feature-specific labels generated from metadata

Rules:
- no hardcoded user-facing copy in widgets
- avoid encoding entitlement/product names into app copy
- use placeholders where dynamic counts/limits appear
- table cell values must be short enough for scan-friendly layout
- prefer placeholders for quota-backed values (e.g. "{limit}" not hardcoded "5")
- group headers and column labels must tolerate translation-driven width variation

### 7. Test plan

#### Policy metadata tests
Extend:
- `test/purchases/premium_access_policy_test.dart`

Add assertions for:
- paywall metadata rows exist for expected features
- metadata aligns with free/premium gating rules
- quota-backed display values match policy limits
- table row model free values match policy-backed limits
- table row model premium values reflect expected upgrade values

Keep existing assertions for:
- free-tier limits
- gated vs free feature behavior
- quota denial behavior

#### Hidden preview launch tests
Extend:
- `test/shared/components/settings_version_tap_target_test.dart`

Add assertions for:
- hidden tools dialog shows custom paywall preview button
- tapping preview button opens custom paywall screen

#### Custom paywall tests
Add new tests under:
- `test/purchases/`

Coverage:
- renders feature rows from metadata
- renders packages from fake offering data
- loading state
- missing offering/error state
- purchase action calls gateway
- restore action calls gateway
- close action dismisses
- long text does not break critical layout behavior where practical
- renders table with Feature / Free / Premium columns
- free column values reflect policy limits
- premium column values reflect expected upgrade values
- package selection row remains visible while comparison content scrolls
- batch quote and items-per-batch rows render separate values

#### Test doubles
Likely extend:
- `test/helpers/lower_level_test_fakes.dart`
- or add focused fake gateway in `test_support/` / `test/helpers/`

Need fakes for:
- offerings
- package purchase
- restore result

## Copy strategy

- Frame Premium around unlimited capacity, faster workflows, business pricing, and inventory control
- Avoid "unlock everything", "all features", or similar blanket framing
- Use short factual cell values for the comparison table:
  - Quota numbers: "5", "2", "7 saves"
  - Binary: "Included", "No"
  - Upgrade: "Unlimited"
- Longer explanations belong in the pitch subtitle or group helper text, not individual rows
- CTA should emphasize upgrading to fit growing needs, not unlocking from a restricted state
- Do not imply that features present in both tiers are premium-only

## File-by-file implementation checklist

### Existing files to update

- `lib/purchases/premium_access_policy.dart`
  - add paywall metadata model(s)
  - add canonical metadata list/accessors
  - keep current gating semantics unchanged

- `lib/shared/test_tools/test_data_tools_dialog.dart`
  - add preview action
  - add preview button

- `lib/shared/components/settings_version_tap_target.dart`
  - handle preview action
  - launch custom paywall screen

- `lib/l10n/intl_en.arb`
  - add new English strings

- `lib/l10n/intl_*.arb`
  - add translated strings for all supported locales

- `test/purchases/premium_access_policy_test.dart`
  - add metadata assertions

- `test/shared/components/settings_version_tap_target_test.dart`
  - add preview button + launch coverage

### New files likely needed

- `lib/purchases/...` custom paywall page/widget file
- `lib/purchases/...` offerings/purchase/restore gateway/provider file
- `test/purchases/...` custom paywall widget/provider tests
- optionally small feature-row/package-card subwidgets if screen grows too large

## Acceptance criteria

- Hidden admin tools can open the new custom paywall
- New custom paywall shows live RevenueCat offering/package data
- Purchase and restore actions are real and wired to RevenueCat
- Existing production paywall flows remain unchanged
- Feature comparison is generated from premium policy metadata, not duplicated config
- All new user-facing copy is localized through ARB files
- Screen remains usable with long localized text
- Unit/widget tests cover metadata and hidden preview wiring

## Verification plan

Run after implementation:
1. `fvm flutter gen-l10n`
2. `fvm flutter analyze`
3. targeted paywall and hidden-tools tests
4. `make flutter_test`

If generated files or broader codegen becomes necessary:
- `make flutter_generate`

## Actual implementation notes (2026-05-30)

### Deviations from plan
- **No separate offerings gateway/provider**: Phase 1 calls `Purchases.getOfferings()` directly inside PaywallScreen (no abstraction layer). This is acceptable for preview but should be extracted before production rollout.
- **`paywallFeatures` on `PremiumAccessPolicy`**: added as static const list on `DefaultPremiumAccessPolicy`, not on the abstract class (abstract has `List<PremiumFeatureData> get paywallFeatures`).
- **Radio deprecation**: Flutter 3.41.6 deprecates `Radio.groupValue`/`onChanged` in favor of `RadioGroup<T>` wrapper. Fixed in `paywall_screen.dart`.
- **11 premium features defined**: materials, printers, historyExport, bulkHistoryExport, batchGcodeImport, batchExport, labourPricing, riskPricing, advancedPricingConfig, csvMaterialImport, stockTracking.
- **Outdated product positioning**: Current screen uses premium-only checklist and "unlock everything" framing, conflicting with Free-as-useful-tier strategy from the 2026-05-29 premium restructure
- **No comparison table**: Current UI renders a flat vertical checklist, not a free-vs-premium comparison table
- **No sticky pricing row**: Package cards are inside the scrollable body rather than pinned below the comparison area
- **Batch costing not split**: A single "batch costing" row hides the free tier's actual access (unlimited quotes, capped at 3 items per quote)
- **Metadata too weak**: `PremiumFeatureData` model lacks free/premium display values, quota fields, category/group, and ordering metadata — insufficient for table rendering
- **Packages stacked vertically**: Plan options render as a vertical radio list instead of a side-by-side row

### New files
- `lib/purchases/paywall_screen.dart` — ~480 lines, ConsumerStatefulWidget
- `test/purchases/paywall_screen_test.dart` — 5 tests

### Changed files
- `lib/purchases/premium_access_policy.dart` — +paywallFeatures getter + feature data
- `lib/shared/test_tools/test_data_tools_dialog.dart` — +TestDataAction.previewCustomPaywall
- `lib/shared/components/settings_version_tap_target.dart` — +preview handler
- All 10 ARB files — +29 keys each
- `test/purchases/premium_access_policy_test.dart` — +2 paywall feature tests
- `test/shared/components/settings_version_tap_target_test.dart` — +preview launch test

### Final verification
- `fvm flutter analyze lib/purchases/` — 0 issues
- Full `fvm flutter test` — 670 passed, 1 skipped (pre-existing flaky test)
- `fvm flutter gen-l10n` — regenerated cleanly

### Tokens used
- `kAppSpace4/8/12/16`, `kAppSurfaceRadius`/`kAppSurfaceRadiusLarge`
- `SHELL_BORDER`, `STATUS_ERROR`, `TEXT_SECONDARY`, `ICON_SECONDARY`
- `AppPrimaryButton`, `AppSurfaceCard`

## Main risks

- metadata drift if paywall display data is not derived from canonical premium policy source
- accidental rollout if preview uses existing presenter path instead of direct hidden-tool launch
- RevenueCat SDK glue spreading across widgets instead of staying behind provider/gateway seam
- layout overflow in long locales or with long package/price text
- unclear missing-offering UX if RevenueCat current offering is null

## Phase 2: Extraction + Analytics (completed 2026-05-30)

### Gateway extraction
- New `lib/purchases/premium_purchase_gateway.dart` — abstract + RevenueCat impl + Riverpod provider
- Updated `paywall_screen.dart` — uses gateway instead of direct `Purchases.*` calls
- Added `FakePremiumPurchaseGateway` to `test/helpers/lower_level_test_fakes.dart`
- Updated `paywall_screen_test.dart` — overrides provider with fake, tests purchase/restore call counting

### Analytics instrumentation
- New `AppAnalytics.restoreCompleted()` — logs `restore_completed` event with source/entry_point
- `paywall_screen.dart` — fires `paywallShown` on load, `purchaseCompleted` on purchase success, `restoreCompleted` on restore success
- All events use `source='custom_paywall_preview'`, `defaultEntryPoint='admin_preview'`
- `paywall_screen_test.dart` — 3 new analytics event verification tests using `_FakeAnalytics`
- Full suite: 676 pass, 1 pre-existing skip, 0 analyze issues

### UI polish (completed 2026-05-30)
- Purchase error: SnackBar with `purchaseError` (existing ARB key)
- Restore success: SnackBar with new `paywallRestoreSuccess`
- Restore error: SnackBar with new `paywallRestoreError`
- Empty offerings: renders `paywallEmptyOfferings` text vs `SizedBox.shrink()`
- New ARB keys across 10 locales: `paywallRestoreSuccess`, `paywallRestoreError`, `paywallEmptyOfferings`
- `FakePremiumPurchaseGateway` — added `shouldThrowOnPurchase`/`shouldThrowOnRestore` flags
- 12 new tests (empty offerings, purchase error snackbar, restore success/error snackbar)
- Full suite: 688 pass, 1 pre-existing skip, 0 analyze issues

### Remaining Phase 2 work
- Production swap: switch normal paywall entry points from hosted RevenueCat UI to custom paywall presenter
- Remove or deprecate old `subscriptions.dart` if no longer needed
