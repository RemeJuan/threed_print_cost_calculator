import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class GCodeImportActions extends StatelessWidget {
  const GCodeImportActions({
    super.key,
    required this.l10n,
    required this.quantity,
    required this.onPressed,
  });
  final AppLocalizations l10n;
  final int quantity;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: const ValueKey<String>('gcode_import.apply.button'),
    onPressed: onPressed,
    child: Text(
      quantity > 1
          ? l10n.importGcodeCreateBatchButton
          : l10n.importGcodeUseValuesButton,
    ),
  );
}
