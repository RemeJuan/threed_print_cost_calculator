import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class MissingDetailsForm extends StatefulWidget {
  const MissingDetailsForm({
    super.key,
    required this.l10n,
    required this.missingWeight,
    required this.missingDuration,
    required this.onApply,
  });

  final AppLocalizations l10n;
  final bool missingWeight;
  final bool missingDuration;
  final void Function(String weightText, String durationText) onApply;

  @override
  State<MissingDetailsForm> createState() => _MissingDetailsFormState();
}

class _MissingDetailsFormState extends State<MissingDetailsForm> {
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _handleApply() {
    widget.onApply(_weightController.text, _durationController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.missingWeight) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            decoration: InputDecoration(
              labelText: widget.l10n.batchGcodeImportNeedsWeight,
              suffixText: widget.l10n.gramsSuffix,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleApply(),
          ),
        ],
        if (widget.missingDuration) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: widget.l10n.batchGcodeImportNeedsDuration,
              suffixText: widget.l10n.durationMinutesLabel,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleApply(),
          ),
        ],
        const SizedBox(height: 12),
        AppPrimaryButton(
          onPressed: _handleApply,
          icon: const Icon(Icons.check, size: 18),
          label: widget.l10n.batchGcodeImportApply,
        ),
      ],
    );
  }
}
