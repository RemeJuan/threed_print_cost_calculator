import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

enum TestDataAction {
  seed,
  purge,
  enablePremium,
  forceUpdateAvailable,
  forceNoUpdate,
  clearUpdateCooldown,
  previewCancelFeedback,
  showWhatsNew,
  previewCustomPaywall,
  sendHandledSentryTest,
  sendUnhandledSentryTest,
}

class TestDataToolsDialog extends StatelessWidget {
  const TestDataToolsDialog({required this.onAction, super.key});

  final ValueChanged<TestDataAction?> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      key: const ValueKey<String>('settings.testData.tools.dialog'),
      title: Text(l10n.testDataToolsTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.testDataToolsBody),
              const SizedBox(height: 12),
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
                key: const ValueKey<String>(
                  'settings.testData.enablePremium.button',
                ),
                onPressed: () => onAction(TestDataAction.enablePremium),
                child: Text(l10n.enablePremiumButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.forceUpdate.button',
                ),
                onPressed: () => onAction(TestDataAction.forceUpdateAvailable),
                child: Text(l10n.forceUpdateAvailableButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.forceNoUpdate.button',
                ),
                onPressed: () => onAction(TestDataAction.forceNoUpdate),
                child: Text(l10n.forceNoUpdateButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.clearUpdateCooldown.button',
                ),
                onPressed: () => onAction(TestDataAction.clearUpdateCooldown),
                child: Text(l10n.clearUpdateCooldownButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.previewCancelFeedback.button',
                ),
                onPressed: () => onAction(TestDataAction.previewCancelFeedback),
                child: Text(l10n.previewCancelFeedbackButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.showWhatsNew.button',
                ),
                onPressed: () => onAction(TestDataAction.showWhatsNew),
                child: Text(l10n.showWhatsNewButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.previewCustomPaywall.button',
                ),
                onPressed: () => onAction(TestDataAction.previewCustomPaywall),
                child: Text(l10n.previewCustomPaywallButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.sentryHandled.button',
                ),
                onPressed: () => onAction(TestDataAction.sendHandledSentryTest),
                child: Text(l10n.sendHandledSentryTestButton),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'settings.testData.sentryUnhandled.button',
                ),
                onPressed: () =>
                    onAction(TestDataAction.sendUnhandledSentryTest),
                child: Text(l10n.sendUnhandledSentryTestButton),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey<String>('settings.testData.cancel.button'),
          onPressed: () => onAction(null),
          child: Text(l10n.cancelButton),
        ),
      ],
    );
  }
}
