import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class BatchWidePrinterSection extends StatelessWidget {
  const BatchWidePrinterSection({
    super.key,
    required this.printers,
    required this.selectedPrinterId,
    required this.onChanged,
    required this.validatorText,
    required this.hintText,
  });

  final List<PrinterModel> printers;
  final String? selectedPrinterId;
  final ValueChanged<String?> onChanged;
  final String validatorText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: printers.any((printer) => printer.id == selectedPrinterId)
          ? selectedPrinterId
          : null,
      hint: Text(hintText),
      items: printers
          .map(
            (printer) => DropdownMenuItem<String>(
              value: printer.id,
              child: Text(printer.name),
            ),
          )
          .toList(),
      validator: (value) => value == null ? validatorText : null,
      onChanged: onChanged,
    );
  }
}
