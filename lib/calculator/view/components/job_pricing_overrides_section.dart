import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/additional_cost_note_dialog.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class JobPricingOverridesSection extends HookConsumerWidget {
  const JobPricingOverridesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final currencySettings = ref.watch(generalSettingsProvider);
    final interfaceSettings = ref.watch(interfaceSettingsProvider);

    final wearController = useTextEditingController(
      text: (state.wearAndTear.value ?? 0).toString(),
    );
    final failureController = useTextEditingController(
      text: (state.failureRisk.value ?? 0).toString(),
    );
    final labourRateController = useTextEditingController(
      text: (state.labourRate.value ?? 0).toString(),
    );
    final markupController = useTextEditingController(
      text: (state.markupPercent.value ?? 0).toString(),
    );
    final additionalCostController = useTextEditingController(
      text: (state.additionalCostAmount.value ?? 0).toString(),
    );

    return ExpansionTile(
      key: const ValueKey<String>('calculator.jobPricingOverrides.section'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(l10n.jobPricingOverridesLabel),
      children: [
        Row(
          children: [
            if (interfaceSettings.showWearAndTear)
              Expanded(
                child: _numberField(
                  controller: wearController,
                  externalText: (state.wearAndTear.value ?? 0).toString(),
                  label: l10n.wearAndTearLabel,
                  fieldKey: const ValueKey<String>(
                    'calculator.jobPricingOverrides.wearAndTear.input',
                  ),
                  onChanged: (value) {
                    notifier
                      ..setWearAndTear(tryParseLocalizedNum(value) ?? 0)
                      ..submit(trackCompletedCosting: true);
                  },
                  currencySettings: null,
                ),
              ),
            if (interfaceSettings.showWearAndTear &&
                interfaceSettings.showFailureRisk)
              const SizedBox(width: 12),
            if (interfaceSettings.showFailureRisk)
              Expanded(
                child: _numberField(
                  controller: failureController,
                  externalText: (state.failureRisk.value ?? 0).toString(),
                  label: l10n.failureRiskLabel,
                  fieldKey: const ValueKey<String>(
                    'calculator.jobPricingOverrides.failureRisk.input',
                  ),
                  onChanged: (value) {
                    notifier
                      ..setFailureRisk(tryParseLocalizedNum(value) ?? 0)
                      ..submit(trackCompletedCosting: true);
                  },
                  currencySettings: null,
                ),
              ),
          ],
        ),
        if (interfaceSettings.showLabourFields ||
            interfaceSettings.showMarkup) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (interfaceSettings.showLabourFields)
                Expanded(
                  child: _numberField(
                    controller: labourRateController,
                    externalText: (state.labourRate.value ?? 0).toString(),
                    label: l10n.labourRateLabel,
                    fieldKey: const ValueKey<String>(
                      'calculator.jobPricingOverrides.labourRate.input',
                    ),
                    onChanged: (value) {
                      notifier
                        ..setLabourRate(tryParseLocalizedNum(value) ?? 0)
                        ..submit(trackCompletedCosting: true);
                    },
                    currencySettings: currencySettings,
                  ),
                ),
              if (interfaceSettings.showLabourFields &&
                  interfaceSettings.showMarkup)
                const SizedBox(width: 12),
              if (interfaceSettings.showMarkup)
                Expanded(
                  child: _numberField(
                    controller: markupController,
                    externalText: (state.markupPercent.value ?? 0).toString(),
                    label: l10n.pricingMarkupPercentLabel,
                    fieldKey: const ValueKey<String>(
                      'calculator.jobPricingOverrides.markupPercent.input',
                    ),
                    onChanged: (value) {
                      notifier
                        ..setMarkupPercent(tryParseLocalizedNum(value) ?? 0)
                        ..submit(trackCompletedCosting: true);
                    },
                    currencySettings: null,
                  ),
                ),
            ],
          ),
        ],
        if (interfaceSettings.showWearAndTear) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  controller: additionalCostController,
                  externalText: (state.additionalCostAmount.value ?? 0)
                      .toString(),
                  label: l10n.additionalCostLabel,
                  fieldKey: const ValueKey<String>(
                    'calculator.jobPricingOverrides.additionalCost.input',
                  ),
                  onChanged: (value) {
                    notifier
                      ..setAdditionalCostAmount(
                        tryParseLocalizedNum(value) ?? 0,
                      )
                      ..submit(trackCompletedCosting: true);
                  },
                  currencySettings: currencySettings,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey<String>(
                  'calculator.jobPricingOverrides.additionalCost.note.button',
                ),
                onPressed: () async {
                  final note = await showDialog<String>(
                    context: context,
                    builder: (_) => AdditionalCostNoteDialog(
                      initialValue: state.additionalCostNote,
                    ),
                  );
                  if (note == null) return;
                  notifier.setAdditionalCostNote(note);
                },
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String externalText,
    required String label,
    required ValueKey<String> fieldKey,
    required ValueChanged<String> onChanged,
    required GeneralSettingsModel? currencySettings,
  }) {
    return FocusSafeTextField(
      key: fieldKey,
      controller: controller,
      externalText: externalText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: localizedDecimalInputFormatters,
      inputNormalizer: normalizeLeadingZeroNumericInput,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixText:
            currencySettings != null &&
                currencySettings.currencySymbol.isNotEmpty &&
                currencySettings.currencyPosition == 'before'
            ? '${currencySettings.currencySymbol}${currencySettings.currencySpacing ? ' ' : ''}'
            : null,
        suffixText:
            currencySettings != null &&
                currencySettings.currencySymbol.isNotEmpty &&
                currencySettings.currencyPosition == 'after'
            ? (currencySettings.currencySpacing
                  ? ' ${currencySettings.currencySymbol}'
                  : currencySettings.currencySymbol)
            : null,
      ),
    );
  }
}
