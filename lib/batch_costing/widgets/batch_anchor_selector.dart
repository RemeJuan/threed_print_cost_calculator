import 'package:flutter/material.dart';

class BatchAnchorSelector extends StatelessWidget {
  const BatchAnchorSelector({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.entries,
    required this.value,
    required this.onChanged,
  });

  final String labelText;
  final String hintText;
  final List<BatchAnchorSelectorEntry> entries;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: entries.any((e) => e.value == value) ? value : null,
      hint: Text(hintText),
      decoration: InputDecoration(labelText: labelText),
      selectedItemBuilder: (context) =>
          entries.map((entry) => Text(entry.label)).toList(),
      items: entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(entry.label),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class BatchAnchorSelectorEntry {
  const BatchAnchorSelectorEntry({required this.value, required this.label});

  final String value;
  final String label;
}
