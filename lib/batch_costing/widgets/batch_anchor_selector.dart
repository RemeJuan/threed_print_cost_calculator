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
    final selected = entries.where((entry) => entry.value == value).toList(growable: false);
    final selectedLabel = selected.isEmpty ? hintText : selected.first.label;

    return MenuAnchor(
      menuChildren: [
        for (final entry in entries)
          MenuItemButton(
            onPressed: () => onChanged(entry.value),
            child: Text(entry.label),
          ),
      ],
      builder: (context, controller, child) {
        return InkWell(
          onTap: entries.isEmpty
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
            child: Row(
              children: [
                Expanded(child: Text(selectedLabel)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BatchAnchorSelectorEntry {
  const BatchAnchorSelectorEntry({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}
