import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_data.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_page.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_service.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class CustomerViewSettingsPage extends ConsumerWidget {
  const CustomerViewSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(interfaceSettingsProvider);
    final service = ref.read(interfaceSettingsServiceProvider);
    Widget toggle(String label, bool value, void Function(bool) update) =>
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: value,
          onChanged: update,
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerViewSettingsHeader)),
      body: ListView(
        padding: const EdgeInsets.all(kAppSpace16),
        children: [
          AppSurfaceCard(
            child: Column(
              children: [
                toggle(
                  l10n.customerViewEnabledLabel,
                  settings.customerViewEnabled,
                  (v) =>
                      service.update((s) => s.copyWith(customerViewEnabled: v)),
                ),
                TextFormField(
                  initialValue: settings.customerViewCompanyName,
                  decoration: InputDecoration(
                    labelText: l10n.customerViewCompanyNameLabel,
                  ),
                  onFieldSubmitted: (v) => service.update(
                    (s) => s.copyWith(customerViewCompanyName: v.trim()),
                  ),
                ),
                const SizedBox(height: kAppSpace8),
                toggle(
                  l10n.customerViewBackControlLabel,
                  settings.customerViewShowBackControl,
                  (v) => service.update(
                    (s) => s.copyWith(customerViewShowBackControl: v),
                  ),
                ),
                DropdownButtonFormField<CustomerViewExitGesture>(
                  initialValue: settings.customerViewExitGesture,
                  decoration: InputDecoration(
                    labelText: l10n.customerViewExitGestureLabel,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: CustomerViewExitGesture.singleTap,
                      child: Text(l10n.customerViewExitSingleTapLabel),
                    ),
                    DropdownMenuItem(
                      value: CustomerViewExitGesture.tripleTap,
                      child: Text(l10n.customerViewExitTripleTapLabel),
                    ),
                    DropdownMenuItem(
                      value: CustomerViewExitGesture.longPress,
                      child: Text(l10n.customerViewExitLongPressLabel),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      service.update(
                        (s) => s.copyWith(customerViewExitGesture: v),
                      );
                    }
                  },
                ),
                const SizedBox(height: kAppSpace8),
                const Divider(height: kAppSpace16 + kAppSpace8),
                for (final entry in <(String, bool, void Function(bool))>[
                  (
                    l10n.customerViewBaseCostLabel,
                    settings.customerViewShowBaseCost,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowBaseCost: v),
                    ),
                  ),
                  (
                    l10n.resultElectricityPrefix,
                    settings.customerViewShowElectricity,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowElectricity: v),
                    ),
                  ),
                  (
                    l10n.resultFilamentPrefix,
                    settings.customerViewShowMaterial,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowMaterial: v),
                    ),
                  ),
                  (
                    l10n.riskTotalPrefix,
                    settings.customerViewShowFailureRisk,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowFailureRisk: v),
                    ),
                  ),
                  (
                    l10n.labourCostPrefix,
                    settings.customerViewShowLabour,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowLabour: v),
                    ),
                  ),
                  (
                    l10n.additionalCostLabel,
                    settings.customerViewShowAdditionalCost,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowAdditionalCost: v),
                    ),
                  ),
                  (
                    l10n.markupLabel,
                    settings.customerViewShowMarkup,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowMarkup: v),
                    ),
                  ),
                  (
                    l10n.setupFeeLabel,
                    settings.customerViewShowSetupFee,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowSetupFee: v),
                    ),
                  ),
                  (
                    l10n.roundingAdjustmentLabel,
                    settings.customerViewShowRoundingAdjustment,
                    (v) => service.update(
                      (s) => s.copyWith(customerViewShowRoundingAdjustment: v),
                    ),
                  ),
                ])
                  toggle(entry.$1, entry.$2, entry.$3),
                toggle(
                  l10n.customerViewItemBreakdownLabel,
                  settings.customerViewShowItemBreakdown,
                  (v) => service.update(
                    (s) => s.copyWith(customerViewShowItemBreakdown: v),
                  ),
                ),
                AppSecondaryButton(
                  key: const ValueKey('customer-view.settings.preview'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CustomerViewPage(
                        data: CustomerViewData.preview(),
                        settings: settings,
                        currencySettings: ref.read(generalSettingsProvider),
                      ),
                    ),
                  ),
                  label: l10n.customerViewPreviewButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
