import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class TestDataConfirmationDialog extends StatelessWidget {
  const TestDataConfirmationDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onDecision,
    super.key,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final ValueChanged<bool> onDecision;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => onDecision(false),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () => onDecision(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
