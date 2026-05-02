import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/settings/settings_slidable_item.dart';

class PrinterListItem extends StatelessWidget {
  const PrinterListItem({
    super.key,
    required this.index,
    required this.name,
    required this.bedSize,
    required this.wattage,
    required this.wattsSuffix,
    required this.onDelete,
    required this.onEdit,
  });

  final int index;
  final String name;
  final String bedSize;
  final String wattage;
  final String wattsSuffix;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SettingsSlidableItem(
      itemKey: ValueKey<String>('settings.printers.item.$index'),
      editButtonKey: ValueKey<String>(
        'settings.printers.item.$index.edit.button',
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      onDelete: onDelete,
      onEdit: onEdit,
      child: Row(
        children: [
          Expanded(
            child: Text(
              key: ValueKey<String>('settings.printers.item.$index.name'),
              name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              key: ValueKey<String>('settings.printers.item.$index.summary'),
              '$bedSize ($wattage$wattsSuffix)',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
