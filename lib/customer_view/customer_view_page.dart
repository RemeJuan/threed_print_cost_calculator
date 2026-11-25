import 'dart:async';

import 'package:material_ui/material_ui.dart';
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
    final costLines = settings.customerViewShowCostBreakdown
        ? _costLines(context, data, settings)
        : const <Widget>[];
    final textTheme = Theme.of(context).textTheme;
    final hasItems =
        settings.customerViewShowItemBreakdown && data.items.isNotEmpty;
    final priceCard = AppSurfaceCard(
      backgroundColor: RESULT_SURFACE,
      padding: const EdgeInsets.all(kAppSpace16 + kAppSpace8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customerViewPriceLabel,
            style: textTheme.titleMedium?.copyWith(color: TEXT_SECONDARY),
          ),
          const SizedBox(height: kAppSpace12),
          Text(
            price,
            key: const ValueKey<String>('customer-view.final-price'),
            style: textTheme.displayLarge?.copyWith(
              color: TEXT_PRIMARY,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    final breakdown = AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.customerViewBreakdownLabel, style: textTheme.titleMedium),
          const SizedBox(height: kAppSpace8),
          ...costLines,
        ],
      ),
    );
    final presentation = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        priceCard,
        if (hasItems) ...[
          const SizedBox(height: kAppSpace12),
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.customerViewItemsLabel, style: textTheme.titleMedium),
                const SizedBox(height: kAppSpace8),
                for (var i = 0; i < data.items.length; i++) ...[
                  if (i > 0)
                    const Divider(height: kAppSpace16, color: DIVIDER_SUBTLE),
                  _detailRow(
                    context,
                    label: data.items[i].name,
                    value: _format(data.items[i].total),
                    subtitle: l10n.customerViewQuantityLabel(
                      data.items[i].quantity,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep presentation readable on tablets without stretching cost rows.
            final wide =
                constraints.maxWidth >= 720 &&
                MediaQuery.textScalerOf(context).scale(1) <= 1.3;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(kAppSpace16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _exitTarget(
                            context,
                            visible: settings.customerViewShowBackControl,
                          ),
                          const SizedBox(width: kAppSpace8),
                          Expanded(
                            child: Text(
                              settings.customerViewCompanyName.trim().isEmpty
                                  ? l10n.customerViewTitle
                                  : settings.customerViewCompanyName.trim(),
                              style: textTheme.titleLarge?.copyWith(
                                color: TEXT_PRIMARY,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kAppSpace16),
                      if (wide && costLines.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: presentation),
                            const SizedBox(width: kAppSpace16),
                            Expanded(flex: 6, child: breakdown),
                          ],
                        )
                      else ...[
                        presentation,
                        if (costLines.isNotEmpty) ...[
                          const SizedBox(height: kAppSpace12),
                          breakdown,
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required String label,
    required String value,
    String? subtitle,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kAppSpace8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: subtitle == null ? TEXT_SECONDARY : TEXT_PRIMARY,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: kAppSpace4),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: kAppSpace12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                color: TEXT_PRIMARY,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
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
          _detailRow(context, label: line.$1, value: _format(line.$2!)),
    ];
  }

  String _format(num value) => formatCurrencyValue(
    value,
    currencySymbol: widget.currencySettings.currencySymbol,
    currencyPosition: widget.currencySettings.currencyPosition,
    currencySpacing: widget.currencySettings.currencySpacing,
  );
}
