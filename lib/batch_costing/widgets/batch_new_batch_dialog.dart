import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

Future<bool> showStartNewBatchDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.batchCostingNewBatchDialogTitle),
      content: Text(l10n.batchCostingNewBatchDialogBody),
      actions: [
        AppTertiaryButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          label: l10n.cancelButton,
        ),
        AppPrimaryButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          label: l10n.batchCostingSummaryStartNewBatchButton,
        ),
      ],
    ),
  );
  return confirmed == true;
}
