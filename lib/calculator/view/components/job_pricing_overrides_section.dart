import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

import 'additional_cost_note_dialog.dart';

class JobPricingOverridesSection extends HookConsumerWidget {
  const JobPricingOverridesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final wearController = useTextEditingController();
    final failureController = useTextEditingController();
    final labourRateController = useTextEditingController();
    final markupController = useTextEditingController();
    final additionalCostController = useTextEditingController();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: const ValueKey<String>('calculator.jobPricingOverrides.section'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(l10n.jobPricingOverridesLabel),
        children: [
          _twoColumnRow(
            left: _numberField(
              controller: wearController,
              externalText: (state.wearAndTear.value ?? 0).toString(),
              label: l10n.wearAndTearLabel,
              fieldKey: const ValueKey<String>(
                'calculator.rates.wearAndTear.input',
              ),
              onChanged: (value) {
                final parsed = tryParseLocalizedNum(value);
                if (parsed == null) return;
                notifier
                  ..setWearAndTear(parsed)
                  ..submitDebounced();
                AppAnalytics.safeLog(
                  () => AppAnalytics.pricingOverrideUsed(
                    field: 'wear_and_tear',
                    hasOverrides: true,
                  ),
                );
              },
            ),
            right: _numberField(
              controller: failureController,
              externalText: (state.failureRisk.value ?? 0).toString(),
              label: l10n.failureRiskLabel,
              fieldKey: const ValueKey<String>(
                'calculator.rates.failureRisk.input',
              ),
              onChanged: (value) {
                final parsed = tryParseLocalizedNum(value);
                if (parsed == null) return;
                notifier
                  ..setFailureRisk(parsed)
                  ..submitDebounced();
                AppAnalytics.safeLog(
                  () => AppAnalytics.pricingOverrideUsed(
                    field: 'failure_risk',
                    hasOverrides: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _twoColumnRow(
            left: _numberField(
              controller: labourRateController,
              externalText: (state.labourRate.value ?? 0).toString(),
              label: l10n.labourRateLabel,
              fieldKey: const ValueKey<String>(
                'calculator.adjustments.labourRate.input',
              ),
              onChanged: (value) {
                final parsed = tryParseLocalizedNum(value);
                if (parsed == null) return;
                notifier
                  ..setLabourRate(parsed)
                  ..submitDebounced();
                AppAnalytics.safeLog(
                  () => AppAnalytics.pricingOverrideUsed(
                    field: 'labour_rate',
                    hasOverrides: true,
                  ),
                );
              },
            ),
            right: _numberField(
              controller: markupController,
              externalText: (state.markupPercent.value ?? 0).toString(),
              label: l10n.pricingMarkupPercentLabel,
              fieldKey: const ValueKey<String>(
                'calculator.pricing.markup.input',
              ),
              onChanged: (value) {
                final parsed = tryParseLocalizedNum(value);
                if (parsed == null) return;
                notifier
                  ..setMarkupPercent(parsed)
                  ..submitDebounced();
                AppAnalytics.safeLog(
                  () => AppAnalytics.pricingOverrideUsed(
                    field: 'markup_percent',
                    hasOverrides: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _numberField(
                  controller: additionalCostController,
                  externalText:
                      (state.additionalCostAmount.value ?? 0).toString(),
                  label: l10n.additionalCostLabel,
                  fieldKey: const ValueKey<String>(
                    'calculator.additionalCost.input',
                  ),
                  onChanged: (value) {
                    final parsed = tryParseLocalizedNum(value);
                    if (parsed == null) return;
                    notifier
                      ..setAdditionalCostAmount(parsed)
                      ..submitDebounced();
                    AppAnalytics.safeLog(
                      () => AppAnalytics.pricingOverrideUsed(
                        field: 'additional_cost',
                        hasOverrides: true,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey<String>('calculator.additionalCost.note.button'),
                tooltip: l10n.additionalCostNoteLabel,
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
                icon: Icon(
                  state.additionalCostNote == null
                      ? Icons.edit_outlined
                      : Icons.sticky_note_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _twoColumnRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String externalText,
    required String label,
    required ValueKey<String> fieldKey,
    required ValueChanged<String> onChanged,
  }) {
    return FocusSafeTextField(
      key: fieldKey,
      controller: controller,
      externalText: externalText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: localizedDecimalInputFormatters,
      inputNormalizer: normalizeLeadingZeroNumericInput,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}
