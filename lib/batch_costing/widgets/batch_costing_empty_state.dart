import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class BatchCostingEmptyState extends StatelessWidget {
  const BatchCostingEmptyState({
    super.key,
    required this.title,
    required this.body,
    required this.importLabel,
    required this.addManualLabel,
    required this.batchImportAllowed,
    required this.onImport,
    required this.onAddManual,
  });

  final String title;
  final String body;
  final String importLabel;
  final String addManualLabel;
  final bool batchImportAllowed;
  final VoidCallback onImport;
  final VoidCallback onAddManual;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: batchImportAllowed ? 1 : 0.55,
            child: AppPrimaryButton(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file),
              label: importLabel,
            ),
          ),
          const SizedBox(height: 12),
          AppSecondaryButton(
            onPressed: onAddManual,
            icon: const Icon(Icons.add),
            label: addManualLabel,
          ),
        ],
      ),
    );
  }
}
