import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_service.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class InterfaceSettingsPage extends ConsumerWidget {
  const InterfaceSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(interfaceSettingsProvider);
    final service = ref.read(interfaceSettingsServiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.interfaceSettingsHeader)),
      body: ListView(
        padding: const EdgeInsets.all(kAppSpace16),
        children: [
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.isDefaultView
                      ? l10n.interfaceSettingsDefaultView
                      : l10n.interfaceSettingsCustomView,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: TEXT_PRIMARY,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: kAppSpace8),
                Text(
                  l10n.interfaceSettingsSubtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
                ),
                const SizedBox(height: kAppSpace12),
                ..._tiles(
                  context,
                  l10n,
                  settings,
                  service,
                  policy: ref.read(premiumAccessPolicyProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _tiles(
    BuildContext context,
    AppLocalizations l10n,
    InterfaceSettingsModel settings,
    InterfaceSettingsService service, {
    required PremiumAccessPolicy policy,
  }) {
    Widget tile(
      String toggle,
      String label,
      bool value,
      Future<void> Function(bool) onChanged,
    ) => SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (v) async {
        try {
          await onChanged(v);
          AppAnalytics.safeLog(
            () => AppAnalytics.interfaceVisibilityChanged(
              setting: toggle,
              visible: v,
            ),
          );
        } catch (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'interface_settings',
              context: ErrorDescription('while updating an interface setting'),
            ),
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.interfaceSettingsSaveError)),
          );
        }
      },
    );
    return [
      tile(
        'printer_select',
        l10n.interfaceShowPrinterSelectLabel,
        settings.showPrinterSelect,
        (v) => service.update((s) => s.copyWith(showPrinterSelect: v)),
      ),
      tile(
        'batch_button',
        l10n.interfaceShowBatchButtonLabel,
        settings.showBatchButton,
        (v) => service.update((s) => s.copyWith(showBatchButton: v)),
      ),
      tile(
        'history_tab',
        l10n.interfaceShowHistoryTabLabel,
        settings.showHistoryTab,
        (v) => service.update((s) => s.copyWith(showHistoryTab: v)),
      ),
      tile(
        'materials_tab',
        l10n.interfaceShowMaterialsTabLabel,
        settings.showMaterialsTab,
        (v) => service.update((s) => s.copyWith(showMaterialsTab: v)),
      ),
      tile(
        'gcode_action',
        l10n.interfaceShowGcodeActionLabel,
        settings.showGcodeAction,
        (v) => service.update((s) => s.copyWith(showGcodeAction: v)),
      ),
      if (policy.advancedPricingConfig().allowed)
        tile(
          'advanced_breakdown',
          l10n.interfaceShowAdvancedBreakdownLabel,
          settings.showAdvancedBreakdown,
          (v) => service.update((s) => s.copyWith(showAdvancedBreakdown: v)),
        ),
      if (policy.labourPricing().allowed)
        tile(
          'labour_fields',
          l10n.interfaceShowLabourFieldsLabel,
          settings.showLabourFields,
          (v) => service.update((s) => s.copyWith(showLabourFields: v)),
        ),
      if (policy.riskPricing().allowed)
        tile(
          'failure_risk',
          l10n.interfaceShowFailureRiskLabel,
          settings.showFailureRisk,
          (v) => service.update((s) => s.copyWith(showFailureRisk: v)),
        ),
      if (policy.advancedPricingConfig().allowed)
        tile(
          'wear_and_tear',
          l10n.interfaceShowWearAndTearLabel,
          settings.showWearAndTear,
          (v) => service.update((s) => s.copyWith(showWearAndTear: v)),
        ),
      if (policy.advancedPricingConfig().allowed)
        tile(
          'markup',
          l10n.interfaceShowMarkupLabel,
          settings.showMarkup,
          (v) => service.update((s) => s.copyWith(showMarkup: v)),
        ),
      tile(
        'currency',
        l10n.interfaceShowCurrencyLabel,
        settings.showCurrency,
        (v) => service.update((s) => s.copyWith(showCurrency: v)),
      ),
    ];
  }
}
