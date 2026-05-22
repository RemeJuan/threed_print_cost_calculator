import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class GCodeImportActions extends StatelessWidget {
  const GCodeImportActions({
    super.key,
    required this.l10n,
    required this.onPressed,
  });
  final AppLocalizations l10n;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => AppPrimaryButton(
    key: const ValueKey<String>('gcode_import.apply.button'),
    onPressed: onPressed,
    label: l10n.importGcodeUseValuesButton,
  );
}
