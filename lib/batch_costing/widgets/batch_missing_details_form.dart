import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class MissingDetailsForm extends StatelessWidget {
  const MissingDetailsForm({
    super.key,
    required this.l10n,
    required this.missingWeight,
    required this.missingDuration,
    required this.weightController,
    required this.durationController,
    required this.onApply,
  });

  final AppLocalizations l10n;
  final bool missingWeight;
  final bool missingDuration;
  final TextEditingController weightController;
  final TextEditingController durationController;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (missingWeight) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: weightController,
            decoration: InputDecoration(
              labelText: l10n.batchGcodeImportNeedsWeight,
              suffixText: l10n.gramsSuffix,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onApply(),
          ),
        ],
        if (missingDuration) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: durationController,
            decoration: InputDecoration(
              labelText: l10n.batchGcodeImportNeedsDuration,
              suffixText: l10n.durationMinutesLabel,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onApply(),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: onApply,
          icon: const Icon(Icons.check, size: 18),
          label: Text(l10n.batchGcodeImportApply),
        ),
      ],
    );
  }
}
