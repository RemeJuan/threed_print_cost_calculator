import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

Future<bool> showStartNewBatchDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.batchCostingNewBatchDialogTitle),
      content: Text(l10n.batchCostingNewBatchDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.batchCostingSummaryStartNewBatchButton),
        ),
      ],
    ),
  );
  return confirmed == true;
}
