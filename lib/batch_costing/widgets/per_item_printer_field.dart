import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class PerItemPrinterField extends StatelessWidget {
  const PerItemPrinterField({
    super.key,
    required this.itemName,
    required this.printers,
    required this.selectedPrinterId,
    required this.onChanged,
    required this.hintText,
    required this.validatorText,
  });

  final String itemName;
  final List<PrinterModel> printers;
  final String? selectedPrinterId;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final String validatorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(itemName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
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
        ),
      ],
    );
  }
}
