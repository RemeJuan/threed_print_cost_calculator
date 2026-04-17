import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

enum TestDataAction { seed, purge, enablePremium }

class TestDataToolsDialog extends StatelessWidget {
  const TestDataToolsDialog({required this.onAction, super.key});

  final ValueChanged<TestDataAction?> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      key: const ValueKey<String>('settings.testData.tools.dialog'),
      title: Text(l10n.testDataToolsTitle),
      content: Text(l10n.testDataToolsBody),
      actions: [
        TextButton(
          key: const ValueKey<String>('settings.testData.seed.button'),
          onPressed: () => onAction(TestDataAction.seed),
          child: Text(l10n.seedTestDataButton),
        ),
        TextButton(
          key: const ValueKey<String>('settings.testData.purge.button'),
          onPressed: () => onAction(TestDataAction.purge),
          child: Text(l10n.purgeLocalDataButton),
        ),
        TextButton(
          key: const ValueKey<String>('settings.testData.enablePremium.button'),
          onPressed: () => onAction(TestDataAction.enablePremium),
          child: Text(l10n.enablePremiumButton),
        ),
        TextButton(
          key: const ValueKey<String>('settings.testData.cancel.button'),
          onPressed: () => onAction(null),
          child: Text(l10n.cancelButton),
        ),
      ],
    );
  }
}
