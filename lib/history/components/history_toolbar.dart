import 'package:flutter/material.dart';

class HistoryToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onExportPressed;

  const HistoryToolbar({
    super.key,
    required this.controller,
    required this.onExportPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, _) {
                return TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search by name or printer',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Export',
            onPressed: onExportPressed,
          ),
        ],
      ),
    );
  }
}
