import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import 'gcode_import_page.dart';

class GCodeImportButton extends StatelessWidget {
  const GCodeImportButton({super.key, this.source = 'calculator'});

  final String source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      key: const ValueKey<String>('calculator.gcode_import.open.button'),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GCodeImportPage(source: source),
          ),
        );
      },
      icon: const Icon(Icons.upload_file_outlined),
      label: Text(l10n.importGcodeButton),
    );
  }
}
