import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

enum BatchQuoteSuccessAction { history, returnToCalculator, startNewBatch }

Future<String?> showBatchQuoteNameDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<String>(
    context: context,
    builder: (_) => _BatchQuoteNameDialog(
      title: l10n.batchCostingSummaryQuoteNameDialogTitle,
      hintText: l10n.batchCostingSummaryDefaultQuoteName,
      labelText: l10n.batchCostingSummaryQuoteNameHint,
      cancelLabel: l10n.cancelButton,
      saveLabel: l10n.saveButton,
    ),
  );
}

class _BatchQuoteNameDialog extends StatefulWidget {
  const _BatchQuoteNameDialog({
    required this.title,
    required this.hintText,
    required this.labelText,
    required this.cancelLabel,
    required this.saveLabel,
  });

  final String title;
  final String hintText;
  final String labelText;
  final String cancelLabel;
  final String saveLabel;

  @override
  State<_BatchQuoteNameDialog> createState() => _BatchQuoteNameDialogState();
}

class _BatchQuoteNameDialogState extends State<_BatchQuoteNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.hintText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
        ),
        autofocus: true,
      ),
      actions: [
        AppTertiaryButton(
          onPressed: () => Navigator.of(context).pop(),
          label: widget.cancelLabel,
        ),
        AppPrimaryButton(
          onPressed: () {
            final name = _controller.text.trim();
            Navigator.of(context).pop(name.isEmpty ? widget.hintText : name);
          },
          label: widget.saveLabel,
        ),
      ],
    );
  }
}

Future<BatchQuoteSuccessAction?> showBatchQuoteSuccessDialog(
  BuildContext context,
) async {
  if (!context.mounted) return null;
  final l10n = AppLocalizations.of(context)!;
  return showDialog<BatchQuoteSuccessAction>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.batchCostingSummarySaveSuccessTitle),
      content: Text(l10n.batchCostingSummarySaveSuccessBody),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: kAppSpace8,
          children: [
            AppPrimaryButton(
              onPressed: () =>
                  Navigator.of(context).pop(BatchQuoteSuccessAction.history),
              label: l10n.batchCostingSummaryViewHistoryButton,
            ),
            AppSecondaryButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(BatchQuoteSuccessAction.returnToCalculator),
              label: l10n.batchCostingSummaryReturnToCalculatorButton,
            ),
            AppTertiaryButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(BatchQuoteSuccessAction.startNewBatch),
              label: l10n.batchCostingSummaryStartNewBatchButton,
            ),
          ],
        ),
      ],
    ),
  );
}
