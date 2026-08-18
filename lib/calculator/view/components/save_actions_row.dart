import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class SaveActionsRow extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onOpenSave;

  const SaveActionsRow({
    required this.isVisible,
    required this.onOpenSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: AppPrimaryButton(
        key: const ValueKey<String>('calculator.save.open.button'),
        onPressed: onOpenSave,
        icon: const Icon(Icons.save),
        label: l10n.savePrintButton,
      ),
    );
  }
}
