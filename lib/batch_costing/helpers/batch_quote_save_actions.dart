import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_new_batch_dialog.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_quote_save_dialogs.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

Future<void> handleBatchQuoteSuccessAction(
  Ref ref,
  BuildContext context,
  BatchQuoteSuccessAction action,
) async {
  if (action == BatchQuoteSuccessAction.history) {
    ref
        .read(pendingTabNavigationProvider.notifier)
        .navigate(AppPageTab.history);
    Navigator.of(context).popUntil((route) => route.isFirst);
  } else if (action == BatchQuoteSuccessAction.returnToCalculator) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  } else {
    final confirmed = await showStartNewBatchDialog(context);
    if (!confirmed || !context.mounted) return;
    ref.read(batchCostingProvider.notifier).reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
