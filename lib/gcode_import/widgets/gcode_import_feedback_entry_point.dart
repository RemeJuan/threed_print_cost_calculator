import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_section.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';

class GCodeImportFeedbackEntryPoint extends StatelessWidget {
  const GCodeImportFeedbackEntryPoint({
    super.key,
    required this.state,
    required this.importFailureContext,
  });

  final GCodeImportState state;
  final String? importFailureContext;

  @override
  Widget build(BuildContext context) {
    return GCodeImportFeedbackSection(
      importState: state,
      importFailureContext: importFailureContext,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GCodeImportFeedbackPage(
              importedFileName: state.selectedFileName,
              importedFilePath: state.selectedFilePath,
              importFailureContext: importFailureContext,
            ),
          ),
        );
      },
    );
  }
}
