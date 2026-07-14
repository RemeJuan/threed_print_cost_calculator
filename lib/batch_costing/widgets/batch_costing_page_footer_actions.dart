import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class BatchCostingPageFooterActions extends StatelessWidget {
  const BatchCostingPageFooterActions({
    super.key,
    required this.continueEnabled,
    required this.onContinue,
    required this.onStartNewBatch,
    required this.continueLabel,
    required this.startNewBatchLabel,
  });

  final bool continueEnabled;
  final VoidCallback? onContinue;
  final VoidCallback onStartNewBatch;
  final String continueLabel;
  final String startNewBatchLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPrimaryButton(
            onPressed: continueEnabled ? onContinue : null,
            icon: const Icon(Icons.arrow_forward),
            label: continueLabel,
          ),
          const SizedBox(height: kAppSpace12),
          AppSecondaryButton(
            onPressed: onStartNewBatch,
            label: startNewBatchLabel,
          ),
        ],
      ),
    );
  }
}
