import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class ResetCalculationButton extends ConsumerWidget {
  final VoidCallback onResetRequested;

  const ResetCalculationButton({required this.onResetRequested, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppSecondaryButton(
      key: const ValueKey<String>('calculator.reset.button'),
      onPressed: () async {
        final shouldReset = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.resetCalculationTitle),
            content: Text(l10n.resetCalculationBody),
            actions: [
              AppTertiaryButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                label: l10n.cancelButton,
              ),
              AppPrimaryButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                label: l10n.resetButtonLabel,
              ),
            ],
          ),
        );

        if (shouldReset != true) return;
        onResetRequested();
        await ref.read(calculatorProvider.notifier).resetToDefaults();
      },
      icon: const Icon(Icons.refresh),
      label: l10n.resetButtonLabel,
    );
  }
}
