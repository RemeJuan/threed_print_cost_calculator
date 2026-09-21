import 'dart:async';

import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_data.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class CustomerViewPage extends StatefulWidget {
  const CustomerViewPage({
    required this.data,
    required this.settings,
    required this.currencySettings,
    super.key,
  });

  final CustomerViewData data;
  final InterfaceSettingsModel settings;
  final GeneralSettingsModel currencySettings;

  @override
  State<CustomerViewPage> createState() => _CustomerViewPageState();
}

class _CustomerViewPageState extends State<CustomerViewPage> {
  Timer? _tapTimer;
  var _tapCount = 0;

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  void _exit() => Navigator.of(context).maybePop();

  void _onTap() {
    final gesture = widget.settings.customerViewExitGesture;
    if (gesture == CustomerViewExitGesture.singleTap) {
      _exit();
      return;
    }
    if (gesture != CustomerViewExitGesture.tripleTap) return;
    _tapCount++;
    _tapTimer?.cancel();
    if (_tapCount == 3) {
      _exit();
      return;
    }
    _tapTimer = Timer(const Duration(milliseconds: 700), () => _tapCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = widget.settings;
    final data = widget.data;
    final price = _format(data.finalPrice);
    final costLines = _costLines(context, data, settings);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kAppSpace16),
          children: [
            Row(
              children: [
                _exitTarget(
                  context,
                  visible: settings.customerViewShowBackControl,
                ),
                Expanded(
                  child: Text(
                    settings.customerViewCompanyName.trim().isEmpty
                        ? l10n.customerViewTitle
                        : settings.customerViewCompanyName.trim(),
                    textAlign: settings.customerViewShowBackControl
                        ? TextAlign.center
                        : TextAlign.start,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: TEXT_PRIMARY,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: kAppSpace16 * 3),
              ],
            ),
            const SizedBox(height: kAppSpace16 + kAppSpace8),
            AppSurfaceCard(
              backgroundColor: RESULT_SURFACE,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.customerViewPriceLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: kAppSpace8),
                  Text(
                    price,
                    key: const ValueKey<String>('customer-view.final-price'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: TEXT_PRIMARY,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ...costLines,
            if (costLines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: kAppSpace16),
                child: Text(l10n.customerViewBreakdownLabel),
              ),
            if (settings.customerViewShowItemBreakdown &&
                data.items.isNotEmpty) ...[
              const SizedBox(height: kAppSpace16),
              AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customerViewItemsLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: kAppSpace8),
                    for (final item in data.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.name),
                        subtitle: Text(
                          l10n.customerViewQuantityLabel(item.quantity),
                        ),
                        trailing: Text(_format(item.total)),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _exitTarget(BuildContext context, {required bool visible}) {
    return GestureDetector(
      key: const ValueKey<String>('customer-view.exit-target'),
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      onLongPress:
          widget.settings.customerViewExitGesture ==
              CustomerViewExitGesture.longPress
          ? _exit
          : null,
      child: SizedBox(
        width: kAppSpace16 * 3,
        height: kAppSpace16 * 3,
        child: visible
            ? Icon(
                Icons.arrow_back,
                key: const ValueKey<String>('customer-view.back-button'),
                semanticLabel: MaterialLocalizations.of(
                  context,
                ).backButtonTooltip,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  List<Widget> _costLines(
    BuildContext context,
    CustomerViewData data,
    InterfaceSettingsModel settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final lines = <(String, num?, bool)>[
      (
        l10n.customerViewBaseCostLabel,
        data.baseCost,
        settings.customerViewShowBaseCost,
      ),
      (
        l10n.resultElectricityPrefix,
        data.electricity,
        settings.customerViewShowElectricity,
      ),
      (
        l10n.resultFilamentPrefix,
        data.filament,
        settings.customerViewShowMaterial,
      ),
      (l10n.riskTotalPrefix, data.risk, settings.customerViewShowFailureRisk),
      (l10n.labourCostPrefix, data.labour, settings.customerViewShowLabour),
      (
        l10n.additionalCostLabel,
        data.additionalCost,
        settings.customerViewShowAdditionalCost,
      ),
      (l10n.markupLabel, data.markup, settings.customerViewShowMarkup),
      (l10n.setupFeeLabel, data.setupFee, settings.customerViewShowSetupFee),
      (
        l10n.roundingAdjustmentLabel,
        data.roundingAdjustment,
        settings.customerViewShowRoundingAdjustment,
      ),
    ];
    return [
      for (final line in lines)
        if (line.$3 && line.$2 != null && line.$2 != 0)
          Padding(
            padding: const EdgeInsets.only(top: kAppSpace16),
            child: AppSurfaceCard(
              child: Row(
                children: [
                  Expanded(child: Text(line.$1)),
                  Text(_format(line.$2!)),
                ],
              ),
            ),
          ),
    ];
  }

  String _format(num value) => formatCurrencyValue(
    value,
    currencySymbol: widget.currencySettings.currencySymbol,
    currencyPosition: widget.currencySettings.currencyPosition,
    currencySpacing: widget.currencySettings.currencySpacing,
  );
}
