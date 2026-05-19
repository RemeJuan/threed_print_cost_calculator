import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_anchor_selector.dart';

class BatchSearchableSelector extends StatefulWidget {
  const BatchSearchableSelector({
    super.key,
    required this.entries,
    required this.value,
    required this.onChanged,
    this.searchHintText,
  });

  final List<BatchAnchorSelectorEntry> entries;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? searchHintText;

  @override
  State<BatchSearchableSelector> createState() =>
      _BatchSearchableSelectorState();
}

class _BatchSearchableSelectorState extends State<BatchSearchableSelector> {
  String _query = '';

  List<BatchAnchorSelectorEntry> get _filtered {
    final q = _query.toLowerCase();
    return widget.entries.where((e) {
      return e.label.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          autofocus: false,
          decoration: InputDecoration(
            hintText: widget.searchHintText,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              final isSelected = entry.value == widget.value;
              return ListTile(
                selected: isSelected,
                title: Text(entry.label),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => widget.onChanged(entry.value),
              );
            },
          ),
        ),
      ],
    );
  }
}
