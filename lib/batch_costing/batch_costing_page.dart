import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

class BatchCostingPage extends ConsumerWidget {
  const BatchCostingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(batchCostingEnabledProvider)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingAppBarTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.batchCostingIntro),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.batchCostingImportGcodeBatchButton),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.batchCostingManualBatchButton),
            ),
          ],
        ),
      ),
    );
  }
}
