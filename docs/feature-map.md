# Feature map

## Shared UI primitives

- Main screens/widgets:
  - `lib/shared/widgets/app_surface_card.dart` — reusable grouped surface wrapper used by cards, accordions, settings sections, and support panels
  - `lib/shared/widgets/app_expansion_card.dart` — reusable compact expansion-card shell used by support FAQ rows and batch costing review/summary cards
  - `lib/shared/widgets/app_search_bar.dart` — shared search field used by history and materials
  - `lib/shared/widgets/app_buttons.dart` — shared primary/secondary/tertiary button set used across batch costing, history, settings, and dialogs
  - `lib/shared/widgets/app_filter_chip.dart` — shared filter chip used by batch costing source filters
  - `lib/shared/widgets/stock_status_badge.dart` — shared stock-state badge used for material availability/status display
- Theme/system notes:
  - shared input styling is theme-driven in `lib/shared/theme.dart`
  - active/focused input accent stays `LIGHT_BLUE`
  - cards and grouped panels use `AppSurfaceCard` instead of ad-hoc `Material` wrappers
  - shared spacing/radius constants live in `lib/shared/app_ui_tokens.dart`
  - search/header rows should prefer `kAppSearchSectionPadding` and tokenized spacing (`kAppSpace*`) over feature-local literals
  - semantic color tokens live in `lib/shared/app_colors.dart`; prefer `TEXT_*`, `ICON_*`, `STATUS_*`, `BORDER_*`, and overlay tokens over direct `Colors.*`

## Calculator

- Main screens/widgets:
  - `lib/calculator/view/calculator_page.dart`
  - `lib/calculator/view/calculator_results.dart`
  - `lib/calculator/view/save_form.dart`
  - `lib/calculator/view/printer_select.dart`
  - `lib/calculator/view/material_select.dart`
  - `lib/calculator/view/components/materials_selection/`
  - `lib/calculator/view/components/materials_selection/material_picker.dart` — shared-tokenized material picker sheet with inline add-material CTA
- Providers/state:
  - `lib/calculator/provider/calculator_notifier.dart` (`calculatorProvider`)
  - `lib/calculator/provider/calculator_history_loader.dart`
  - `lib/calculator/provider/calculator_settings_sync.dart`
  - `lib/calculator/provider/calculator_materials_service.dart`
  - `lib/calculator/state/calculator_state.dart`
  - `lib/calculator/state/calculation_results_state.dart`
- Presentation gates:
  - `lib/calculator/view/calculator_page.dart` gates printer select, advanced pricing overrides, batch costing entry, and save form by policy and interface state.
  - `lib/calculator/view/calculator_results.dart` gates risk, labour, additional cost, and premium-only pricing rows by policy and active pricing state.
- Repositories/services:
  - `lib/database/repositories/calculator_preferences_repository.dart`
  - `lib/settings/services/settings_service.dart`
- Models:
  - `lib/calculator/model/material_usage_input.dart`
- Results/premium messaging:
  - `lib/calculator/view/calculator_results.dart` shows only rows available to the active calculation/access level; free tier uses a compact in-card footer that links into the support FAQ premium summary instead of locked promo rows
  - Footer `Learn more` opens `HelpSupportPage(initialFaqEntryId: premium)` in-app, not a website or paywall
- Tests:
  - `test/calculator/provider/`
  - `test/calculator/view/`
  - `test/calculator/helpers/`
- Common search terms:
  - `calculatorProvider`
  - `CalculatorPage`
  - `CalculatorState`
  - `applyImportedValues`
  - `loadFromHistory`
  - `material_usage_input`

## Settings / interface

- Main screens/widgets:
  - `lib/settings/settings_page.dart` — interface summary subtitle resolves to `Default view` or `Custom view` from `InterfaceSettingsModel`.
  - `lib/settings/interface_settings/interface_settings_page.dart` — interface settings card mirrors the same semantic subtitle.
- Providers/state:
  - `lib/settings/interface_settings/interface_settings_repository.dart` (`interfaceSettingsProvider`)
  - `lib/settings/interface_settings/interface_settings_service.dart`
  - `lib/settings/interface_settings/interface_settings_model.dart` (`isDefaultView`, `isCustomView`)
- Common search terms:
  - `interfaceSettingsProvider`
  - `isDefaultView`
  - `isCustomView`

## Materials

- Main screens/widgets:
  - `lib/materials/widgets/materials_page.dart` — materials browser tab (free access with quota limits), shared search bar, search/filter, swipe actions, delete/duplicate wiring; duplicate respects free-tier material cap
  - `lib/materials/widgets/material_card.dart` — list item with swipe-to-reveal actions (Edit/Duplicate/Delete), tap-to-edit
  - `lib/materials/widgets/material_filters.dart`
  - `lib/materials/csv_import/csv_import_page.dart`
  - `lib/settings/materials/materials.dart` — settings page list (separate, uses `SettingsSlidableItem`)
  - `lib/settings/materials/material_form.dart`
- Material list item behavior:
  - **Tap**: opens MaterialForm for editing (primary action)
  - **Swipe left**: reveals Edit, Duplicate, Delete actions
    - **Edit**: opens MaterialForm for editing
    - **Duplicate**: copies all material fields, appends localized "Duplicate" suffix to name, saves as new material, shows success snackbar; blocked for free users already at the material cap
    - **Delete**: shows confirmation dialog; on confirm, removes material, clears stale calculator state if it was in use, shows success snackbar
  - One-time inline dismissible banner on first visit introduces swipe actions
  - Settings materials list (non-premium) uses `SettingsSlidableItem` with edit/delete swipe actions
- Deleting material while in calculator use:
  - `CalculatorProvider.clearUsagesForDeletedMaterial()` removes usage rows referencing deleted ID and recomputes total weight
  - Clears persisted `selectedMaterial` in settings if deleted was the dropdown selection
  - Resets in-memory + persisted `spoolWeight`/`spoolCost` to empty so calculator doesn't price off stale defaults
  - Recalculates filament cost via `submit()`
  - History records referencing the material are preserved (cost is snapshot, not live reference)
- Providers/state:
  - `lib/materials/providers/materials_providers.dart`
  - `lib/settings/providers/materials_notifier.dart` (`materialsProvider`)
  - `lib/settings/state/material_state.dart`
- Repositories/services:
  - `lib/database/repositories/materials_repository.dart`
  - `lib/database/services/material_stock_service.dart`
- Models:
  - `lib/settings/model/material_model.dart`
  - `lib/materials/model/stock_status.dart`
- Tests:
  - `test/materials/widgets/material_card_test.dart` — swipe reveals actions, edit/duplicate/delete callbacks, confirmation dialog
  - `test/materials/widgets/materials_page_test.dart` — empty state, list rendering, FAB, duplicate wiring, free-tier duplicate cap enforcement
  - `test/calculator/provider/material_selection_recalculation_test.dart` — clearUsagesForDeletedMaterial weight recompute and stale-defaults cleanup
  - `test/settings/materials/`
  - `test/settings/providers/materials_notifier_test.dart`
- Analytics events:
  - `materials_view_opened` — tab opens on first frame (`lib/app/app_page.dart`)
  - `material_created` / `material_edited` — params: `has_tracking`, optional `material_type`, `brand` (`lib/settings/providers/materials_notifier.dart`)
  - `csv_import_started` / `csv_import_completed` — params: `rows_success`, `rows_failed` (`lib/materials/csv_import/csv_import_page.dart`)
  - `material_selected_in_calculator` — params: `has_tracking`, optional `material_type`, `brand` (`lib/calculator/provider/calculator_notifier.dart`)
- Common search terms:
  - `MaterialsPage`
  - `materialsStreamProvider`
  - `filteredMaterialsProvider`
  - `MaterialsProvider`
  - `material_card`
  - `material_form`
  - `csv_import`
  - `clearUsagesForDeletedMaterial`

## History

- Main screens/widgets:
  - `lib/history/history_page.dart`
  - `lib/history/components/history_list_view.dart`
  - `lib/history/components/history_item.dart`
  - `lib/history/components/history_search_bar.dart` — search shell around shared `AppSearchBar`
  - `lib/history/components/history_toolbar.dart` — tokenized search/header row using shared search padding rhythm
  - `lib/history/components/history_upsell_banner.dart`
- Providers/state:
  - `lib/history/provider/history_paged_notifier.dart`
  - `lib/history/provider/history_providers.dart`
  - `lib/history/index/history_search_index.dart`
  - `lib/history/index/printer_index.dart`
- Repositories/services:
  - `lib/database/repositories/history_repository.dart`
  - `lib/database/history_record_store.dart`
- Models:
  - `lib/history/model/history_entry.dart`
  - `lib/history/model/history_model.dart`
- Tests:
  - `test/history/`
  - `integration_test/premium_history_filtering_test.dart`
  - `patrol_test/premium_calculate_save_history_journey_test.dart`
- Common search terms:
  - `HistoryPage`
  - `HistoryPagedNotifier`
  - `historyRepositoryProvider`
  - `historySearchIndex`
  - `HistoryPageMode`
  - `history_upsell`

## Purchases / premium

- Main screens/widgets:
  - `lib/app/app_page.dart` — app-shell listener for RevenueCat premium state, cancellation feedback prompt trigger
  - `lib/purchases/cancel_feedback_sheet.dart` — dismissible bottom sheet for anonymous cancellation feedback reasons
- Providers/state:
  - `lib/purchases/premium_state.dart`
  - `lib/purchases/premium_state_notifier.dart`
  - `lib/purchases/premium_access_policy.dart`
  - `lib/shared/providers/app_providers.dart` (`premiumLocalStoreProvider`)
  - `lib/purchases/cancel_feedback_service.dart`
- Repositories/services:
  - `lib/purchases/purchases_gateway.dart` — RevenueCat SDK mapping into app premium state
  - `lib/shared/services/app_usage_service.dart` — premium-store calculation count / G-code usage analytics helpers, completed-costing counter, and `RateMyApp` eligibility gate (`completed_costing_count > 10` before review prompt init)
  - `lib/database/repositories/history_repository.dart` — history count + G-code-import history lookup for analytics payloads
- Analytics events:
  - `trial_cancel_feedback_submitted`
  - `trial_cancel_feedback_dismissed`
- Cancellation feedback prompt behavior:
  - **Trigger**: fires when premium state resolves with `hasActiveCanceledEntitlement == true` — entitlement is active but `cancellationDetectedAt != null` (or `willRenew == false`) and no billing issue
  - **Gate**: only if `cancellationStateKey` (user + entitlementType + productId + cancellation date + original purchase date) has not been previously shown or submitted
  - **Once-only**: per cancellation state. Both shown and submitted keys persisted via SharedPreferences. In-session duplicate prevention via `cancelFeedbackHandledStateKey` local ref.
  - **Route guard**: sheet only presents when `AppPage` route is current and lifecycle is resumed (same guard as What's New)
  - **Dismiss**: logs `trial_cancel_feedback_dismissed` with full payload
  - **Submit**: logs `trial_cancel_feedback_submitted` with selected reason + full payload
  - **Hidden test-tools preview**: Settings → tap version 5 times fast → "Preview renewal feedback" button shows sheet without analytics
- Common search terms:
  - `cancelFeedbackServiceProvider`
  - `cancellationStateKey`
  - `trial_cancel_feedback_submitted`
  - `hasActiveCanceledEntitlement`
  - `cancelFeedbackHandledStateKey`
  - `previewCancelFeedback`

## Premium / RevenueCat

- Main screens/widgets:
  - `lib/purchases/paywall_screen.dart` — custom paywall with comparison table, plan selector, purchase/restore flows
  - `lib/purchases/paywall_plan_selector.dart` — RevenueCat package cards with best-value chip
  - `lib/purchases/paywall_comparison_table.dart` — policy-driven free vs premium comparison table
  - `lib/purchases/premium_purchase_gateway.dart` — RevenueCat abstraction for offerings, purchase, restore
  - `lib/app/header_actions.dart`
- Providers/state:
  - `lib/purchases/premium_state_notifier.dart` (`premiumStateProvider`, `isPremiumProvider`)
  - `lib/purchases/premium_access_policy.dart` (`premiumAccessPolicyProvider`)
  - `lib/purchases/premium_state.dart`
  - `lib/shared/providers/app_providers.dart` (`premiumLocalStoreProvider`, `appNavigatorKey`)
  - `lib/purchases/premium_purchase_gateway.dart` (`premiumPurchaseGatewayProvider`)
- Repositories/services:
  - `lib/purchases/purchases_gateway.dart`
  - `lib/purchases/paywall_presenter.dart`
- Tests:
  - `test/purchases/`
  - `test_support/fake_purchases_gateway.dart`
  - `integration_test/premium_*.dart`
  - `patrol_test/premium_calculate_save_history_journey_test.dart`
- Common search terms:
  - `premiumAccessPolicyProvider`
  - `premiumPurchaseGatewayProvider`
  - `appNavigatorKey`
  - `PaywallScreen`
  - `PremiumPurchaseGateway`
  - `paywall_comparison_table`
  - `paywall_plan_selector`
  - `premiumStateProvider`
  - `RevenueCatPurchasesGateway`
  - `Purchases.configure`

## Batch costing

- Main screens/widgets:
  - `lib/batch_costing/batch_costing_page.dart` — main pricing table with items, material allocation, totals; manual add shows quota feedback instead of silently dropping capped free-tier items
  - `lib/batch_costing/batch_gcode_import_page.dart` — shell page for multi-file / single-file G-code import flow (447 LOC)
  - `lib/batch_costing/widgets/batch_gcode_import_body.dart` — body widget rendering file rows, single-import view, action buttons
  - `lib/batch_costing/widgets/batch_single_import_view.dart` — single-file import card with metadata + inline missing details form
  - `lib/batch_costing/widgets/batch_import_file_row.dart` — file row per status (importing/needs-details/ready/failed)
  - `lib/batch_costing/widgets/batch_missing_details_form.dart` — inline weight/duration form for partial-metadata imports
  - `lib/batch_costing/widgets/batch_gcode_import_details_sheet.dart` — modal bottom sheet with full import metadata/preview
  - `lib/batch_costing/widgets/batch_searchable_selector.dart`
  - `lib/batch_costing/widgets/material_allocation_row.dart`
  - `lib/batch_costing/widgets/material_allocation_card.dart`
  - `lib/batch_costing/widgets/batch_allocation_picker_dialog.dart`
  - `lib/batch_costing/widgets/batch_costing_item_editor_dialog.dart`
  - `lib/batch_costing/widgets/batch_split_copies_dialog.dart`
  - `lib/batch_costing/widgets/batch_anchor_selector.dart`
  - `lib/batch_costing/widgets/warning_box.dart`
- Shared UI usage:
  - batch summary and batch item cards use shared `AppExpansionCard` with compact density and shared token padding
  - batch source chips use shared `AppFilterChip`
  - batch action buttons use shared primary/secondary/tertiary buttons
- Providers/state:
  - `lib/batch_costing/providers/batch_costing_notifier.dart` (`batchCostingProvider`)
  - `lib/batch_costing/model/batch_costing_item.dart`
  - `lib/batch_costing/model/batch_import_state.dart` — `BatchSingleImport`, `BatchImportRow`, `ImportStatus`
- Tests:
  - `test/batch_costing/`
- Common search terms:
  - `batchCostingProvider`
  - `BatchCostingItem`
  - `BatchGCodeImportPage`
  - `BatchImportRow`
  - `ImportStatus`
  - `batchGcodeImport`

## G-code import

- Main screens/widgets:
  - `lib/gcode_import/gcode_import_page.dart`
  - `lib/gcode_import/gcode_import_button.dart`
  - `lib/gcode_import/feedback/gcode_import_feedback_page.dart`
- Current behavior:
  - Single-file `GCodeImportPage` remains calculator-only review/apply; batch creation now stays in the dedicated batch multi-file flow (see Batch costing section).
  - Accepts `.gcode`, `.gco`, and `.nc` files directly when payload looks text-like.
  - Android no longer uses `file_selector` byte payloads. `MainActivity` opens SAF, resolves URI metadata, copies to cache, and returns metadata + cache path only.
  - Treats Android/file picker `.bin` and other unknown/octet-stream picks as sniffable input; reads up to 64 KiB for common G-code markers before rejecting.
  - Rejects clearly binary payloads before parsing and rejects files above the 50 MiB guard before parse work starts.
  - Parser/service now support path-backed streamed line reads for imports, avoiding full-file byte transfer across the Android platform channel.
  - Uses picked filename for validation/error UX instead of cached path aliases.
  - Import flow logs analytics + Crashlytics breadcrumbs for start, metadata resolved, size/type rejection, parse failure, and success.
  - Preview summary now shows `Preview · {W}×{H}` for thumbnails smaller than 128 px on either axis, `Preview` for larger previews, and `No preview` when absent.
  - Low-resolution previews stay importable; inline thumbnail uses nearest-neighbour rendering on a dark background instead of blocking import.
  - `BatchGCodeImportPage` keeps list rows compact, captures missing weight/duration inline, and opens imported metadata/preview details in a modal sheet instead of inline preview rows.
- Providers/state:
  - `lib/gcode_import/gcode_import_controller.dart`
  - `lib/gcode_import/gcode_import_result.dart`
- Repositories/services:
  - `lib/gcode_import/gcode_import_service.dart`
  - `lib/gcode_import/gcode_import_file_picker.dart`
  - `lib/gcode_import/gcode_import_android_file_picker.dart`
  - `lib/gcode_import/gcode_import_file_reader.dart`
  - `lib/gcode_import/gcode_import_diagnostics.dart`
- Models:
  - `lib/gcode_import/gcode_import_result.dart`
  - `lib/gcode_import/feedback/gcode_import_feedback_models.dart`
- Tests:
  - `test/gcode_import/`
  - `docs/gcode/`
- Common search terms:
  - `GCodeImport`
  - `gcode_import_parser`
  - `pickAndParse`
  - `importPickedFile`
  - `gcode_preview`
  - `feedback_page`

## Analytics

- Main screens/widgets:
  - No dedicated screen. Events fire from feature screens.
- Providers/state:
  - Static facade in `lib/core/analytics/app_analytics.dart`
- Repositories/services:
  - `lib/core/analytics/analytics_service.dart`
  - `lib/core/analytics/firebase_analytics_service.dart`
- Models:
  - Event payload helpers in `lib/core/analytics/app_analytics.dart`
- Tests:
  - `test/core/analytics/app_analytics_test.dart`
  - Event catalogue: `docs/analytics.md`
- Common search terms:
  - `AppAnalytics`
  - `safeLog`
  - `logEvent`
  - `FirebaseAnalyticsService`
  - `paywall_viewed`
  - `gcode_import_`

## Monitoring / Sentry

- Init:
  - `lib/main.dart` runs `_runApp()` first, then starts `initSentry()` as best-effort background work.
  - Monitoring never blocks startup; Sentry init is detached from the critical launch path.
  - `lib/core/monitoring/sentry_monitoring.dart` holds DSN/environment config plus `_beforeSend` scrubbing logic.
  - Release/dist are always set (`FLUTTER_BUILD_NAME` / `FLUTTER_BUILD_NUMBER` when available, `dev` fallback otherwise), so Sentry does not need `PackageInfo` in the startup path.
  - iOS debug builds disable Sentry native auto-init to avoid early `sentry_flutter` method-channel failures.
  - Scrubbing logic in `_beforeSend` callback strips paths, file names, user data, and request info from events before transmission.
  - Bootstrap error hook in `lib/bootstrap.dart` chains to Sentry's `FlutterError.onError` handler and adds local logging via `log(...)`.
- Tests:
  - No dedicated test file; coverage indirect through app-level test helpers.
- Common search terms:
  - `configureSentryOptions`
  - `initSentry`
  - `_beforeSend`
  - `SentryFlutter.init`
  - `_runApp`

## Update checker

- Main screens/widgets:
  - `lib/app/app_page.dart` — renders the non-blocking update banner/card in the app shell
  - `lib/app/widgets/update_prompt_banner.dart` — app-owned prompt UI
- Providers/state:
  - `lib/shared/providers/update_checker_provider.dart`
- Repositories/services:
  - `update_available` package for availability checks
- Analytics events:
  - `update_prompt_shown`
  - `update_prompt_tapped`
  - `update_prompt_dismissed`
- Hidden debug controls:
  - `lib/shared/components/settings_version_tap_target.dart`
  - `lib/shared/test_tools/test_data_tools_dialog.dart`
- Common search terms:
  - `updateCheckerProvider`
  - `update_prompt`
  - `forceUpdateAvailable`

## Settings

- Main screens/widgets:
  - `lib/settings/settings_page.dart`
  - `lib/settings/settings_section.dart` — card wrapper with title + content; always expanded
  - `lib/settings/general_settings_form.dart`
  - `lib/settings/work_costs_form.dart`
  - `lib/settings/printers/printers.dart`
  - `lib/settings/printers/printer_list_item.dart`
  - `lib/settings/printers/add_printer.dart`
- Layout behavior:
  - Sections always visible (no accordion/collapse/chevrons)
  - Order: General → Pricing & Work Costs → Printers (matches usage frequency)
  - Premium-gated sections/actions are controlled by `premiumAccessPolicyProvider` (policy-led); General settings remain available
  - Free users also see a compact Premium card after Printers; the CTA opens the app-owned paywall. Premium users do not see this card.
  - Printer list is content-sized `Column` (no fixed-height `ListView`)
- Providers/state:
  - `lib/settings/providers/printers_notifier.dart` (`printersProvider`)
- Repositories/services:
  - `lib/settings/services/settings_service.dart`
  - `lib/database/repositories/settings_repository.dart`
  - `lib/database/repositories/printers_repository.dart`
- Models:
  - `lib/settings/model/general_settings_model.dart`
  - `lib/settings/model/printer_model.dart`
- Tests:
  - `test/settings/`
  - `integration_test/premium_settings_journey_test.dart`
- Common search terms:
  - `SettingsPage`
  - `SettingsSection`
  - `settingsServiceProvider`
  - `GeneralSettingsModel`
  - `PrintersNotifier`
  - `PrinterListItem`
  - `work_costs_form`

## Help & Support

- Main screens/widgets:
  - `lib/app/help_support/help_support_page.dart` — FAQ list, support card, app info, and footer links
  - `lib/app/help_support/widgets/help_support_faq_tile.dart` — individual FAQ entry with answer text, optional inline link, and optional action button
  - `lib/app/help_support/models/help_support_faq_entry.dart` — model with `id`, `question`, `answer`, `linkLabel`/`onLinkTap`, and optional `actionLabel`/`onActionTap`
  - `lib/app/help_support/help_support_links.dart` — external URLs for plans, roadmap, and social links
- Premium FAQ entry behavior:
  - Exists for all users; shows question and answer about free vs premium differences
  - Comparison link (`View full comparison →`) always visible, opens `https://printcostcalc.app/#plans-title`
  - Free users also see the upgrade CTA (`AppSecondaryButton`, full-width, `minHeight:42`) after the comparison link, triggering `paywallPresenter.present('pro', ...)` with analytics
  - CTA hidden for premium users
- Tests:
  - `test/app/view/help_support_page_test.dart` — free/premium FAQ CTA visibility and paywall trigger assertions

## Localization

- Main screens/widgets:
  - Root wiring: `lib/app/app.dart`
  - Common usage from feature screens via `AppLocalizations.of(context)!`
- Providers/state:
  - No Riverpod provider. Generated delegate access via `AppLocalizations`.
- Repositories/services:
  - Config file `l10n.yaml`
- Models:
  - Generated class `lib/l10n/app_localizations.dart`
- Tests:
  - Widget/integration helpers seed delegates:
    - `test/helpers/helpers.dart`
    - `integration_test/helpers/integration_test_harness.dart`
- Common search terms:
  - `AppLocalizations`
  - `localizationsDelegates`
  - `supportedLocales`
  - `intl_en.arb`
  - `gen-l10n`
  - `historyLoadSuccessMessage`
