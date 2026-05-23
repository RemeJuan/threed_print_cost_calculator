import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';

Future<void> resetBatchFlow(BuildContext context, WidgetRef ref) async {
  ref.read(batchCostingProvider.notifier).reset();
  if (!context.mounted) return;

  Navigator.of(context).pushAndRemoveUntil<void>(
    MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()),
    (route) => route.isFirst,
  );
}
