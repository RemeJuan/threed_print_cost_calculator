import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

class BatchPricingScopePage extends ConsumerStatefulWidget {
  const BatchPricingScopePage({super.key});

  @override
  ConsumerState<BatchPricingScopePage> createState() =>
      _BatchPricingScopePageState();
}

class _BatchPricingScopePageState extends ConsumerState<BatchPricingScopePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _failureRiskController;
  late final TextEditingController _markupPercentController;
  late final TextEditingController _labourRateController;
  late final TextEditingController _additionalCostController;
  late final FocusNode _failureRiskFocus;
  late final FocusNode _markupPercentFocus;
  late final FocusNode _labourRateFocus;
  late final FocusNode _additionalCostFocus;

  @override
  void initState() {
    super.initState();
    final state = ref.read(batchCostingProvider);
    _failureRiskController = TextEditingController(
      text: state.pricing.failureRisk.value,
    );
    _markupPercentController = TextEditingController(
      text: state.pricing.markupPercent.value,
    );
    _labourRateController = TextEditingController(
      text: state.pricing.labourRate.value,
    );
    _additionalCostController = TextEditingController(
      text: state.pricing.additionalCostAmount.value,
    );
    _failureRiskFocus = FocusNode();
    _markupPercentFocus = FocusNode();
    _labourRateFocus = FocusNode();
    _additionalCostFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDefaults());
  }

  @override
  void dispose() {
    _failureRiskController.dispose();
    _markupPercentController.dispose();
    _labourRateController.dispose();
    _additionalCostController.dispose();
    _failureRiskFocus.dispose();
    _markupPercentFocus.dispose();
    _labourRateFocus.dispose();
    _additionalCostFocus.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    if (!ref.read(batchCostingEnabledProvider)) return;

    late final GeneralSettingsModel settings;
    try {
      settings = await ref.read(settingsServiceProvider).get();
    } catch (_) {
      return;
    }
    if (!mounted) return;
    final notifier = ref.read(batchCostingProvider.notifier);
    final state = ref.read(batchCostingProvider);

    if (settings.failureRisk.isNotEmpty &&
        state.pricing.failureRisk.value.isEmpty) {
      notifier.setFailureRisk(settings.failureRisk);
      _failureRiskController.text = settings.failureRisk;
    }
    if (settings.labourRate.isNotEmpty &&
        state.pricing.labourRate.value.isEmpty) {
      notifier.setLabourRate(settings.labourRate);
      _labourRateController.text = settings.labourRate;
    }
    if (settings.pricingMarkupPercent.isNotEmpty &&
        state.pricing.markupPercent.value.isEmpty) {
      notifier.setMarkupPercent(settings.pricingMarkupPercent);
      _markupPercentController.text = settings.pricingMarkupPercent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(batchCostingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingPricingScopeAppBarTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.batchCostingPricingScopeSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _pricingFieldCard(
                          context: context,
                          label: l10n.failureRiskLabel,
                          controller: _failureRiskController,
                          focusNode: _failureRiskFocus,
                          value: state.pricing.failureRisk.value,
                          scope: state.pricing.failureRisk.scope,
                          onValueChanged: (value) => ref
                              .read(batchCostingProvider.notifier)
                              .setFailureRisk(value),
                          onScopeChanged: (scope) => ref
                              .read(batchCostingProvider.notifier)
                              .setFailureRiskScope(scope),
                          validator: _percentValidator(l10n),
                          scopeItemLabel: l10n.batchCostingPricingScopeItemMode,
                          scopeBatchLabel:
                              l10n.batchCostingPricingScopeBatchMode,
                        ),
                        _pricingFieldCard(
                          context: context,
                          label: l10n.pricingMarkupPercentLabel,
                          controller: _markupPercentController,
                          focusNode: _markupPercentFocus,
                          value: state.pricing.markupPercent.value,
                          scope: state.pricing.markupPercent.scope,
                          onValueChanged: (value) => ref
                              .read(batchCostingProvider.notifier)
                              .setMarkupPercent(value),
                          onScopeChanged: (scope) => ref
                              .read(batchCostingProvider.notifier)
                              .setMarkupPercentScope(scope),
                          validator: _percentValidator(l10n),
                          scopeItemLabel: l10n.batchCostingPricingScopeItemMode,
                          scopeBatchLabel:
                              l10n.batchCostingPricingScopeBatchMode,
                        ),
                        _pricingFieldCard(
                          context: context,
                          label: l10n.labourRateLabel,
                          controller: _labourRateController,
                          focusNode: _labourRateFocus,
                          value: state.pricing.labourRate.value,
                          scope: state.pricing.labourRate.scope,
                          onValueChanged: (value) => ref
                              .read(batchCostingProvider.notifier)
                              .setLabourRate(value),
                          onScopeChanged: (scope) => ref
                              .read(batchCostingProvider.notifier)
                              .setLabourRateScope(scope),
                          validator: _amountValidator(l10n),
                          scopeItemLabel: l10n.batchCostingPricingScopeItemMode,
                          scopeBatchLabel:
                              l10n.batchCostingPricingScopeBatchMode,
                        ),
                        _pricingFieldCard(
                          context: context,
                          label: l10n.additionalCostLabel,
                          controller: _additionalCostController,
                          focusNode: _additionalCostFocus,
                          value: state.pricing.additionalCostAmount.value,
                          scope: state.pricing.additionalCostAmount.scope,
                          onValueChanged: (value) => ref
                              .read(batchCostingProvider.notifier)
                              .setAdditionalCostAmount(value),
                          onScopeChanged: (scope) => ref
                              .read(batchCostingProvider.notifier)
                              .setAdditionalCostAmountScope(scope),
                          validator: _amountValidator(l10n),
                          scopeItemLabel: l10n.batchCostingPricingScopeItemMode,
                          scopeBatchLabel:
                              l10n.batchCostingPricingScopeBatchMode,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.batchCostingPrinterAssignmentPreviousButton,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => _continue(context),
                      child: Text(l10n.batchCostingPrinterAssignmentNextButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pricingFieldCard({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String value,
    required BatchPricingScope scope,
    required ValueChanged<String> onValueChanged,
    required ValueChanged<BatchPricingScope> onScopeChanged,
    required FormFieldValidator<String> validator,
    required String scopeItemLabel,
    required String scopeBatchLabel,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 48,
              child: FocusSafeTextField(
                controller: controller,
                focusNode: focusNode,
                externalText: value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: localizedDecimalInputFormatters,
                inputNormalizer: normalizeLeadingZeroNumericInput,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: validator,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  label: Text(label),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                onChanged: onValueChanged,
              ),
            ),
            const Spacer(flex: 4),
            Expanded(
              flex: 48,
              child: SegmentedButton<BatchPricingScope>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: BatchPricingScope.item,
                    label: Text(scopeItemLabel),
                  ),
                  ButtonSegment(
                    value: BatchPricingScope.batch,
                    label: Text(scopeBatchLabel),
                  ),
                ],
                selected: {scope},
                onSelectionChanged: (selected) =>
                    onScopeChanged(selected.first),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FormFieldValidator<String> _percentValidator(AppLocalizations l10n) {
    return (value) {
      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
      if (parsed == null || parsed < 0 || parsed > 100) {
        return l10n.invalidNumber;
      }
      return null;
    };
  }

  FormFieldValidator<String> _amountValidator(AppLocalizations l10n) {
    return (value) {
      final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
      if (parsed == null || parsed < 0) {
        return l10n.invalidNumber;
      }
      return null;
    };
  }

  void _continue(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const BatchSummaryPage()));
  }
}
