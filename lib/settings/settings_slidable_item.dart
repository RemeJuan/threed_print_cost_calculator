import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class SettingsSlidableItem extends StatelessWidget {
  const SettingsSlidableItem({
    required this.itemKey,
    required this.onDelete,
    required this.onEdit,
    required this.child,
    this.editButtonKey,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Key itemKey;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Widget child;
  final Key? editButtonKey;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> confirmDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteDialogTitle),
          content: Text(l10n.deleteDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.deleteButton),
            ),
          ],
        ),
      );

      if (confirm != true) return;
      onDelete();
    }

    return Padding(
      padding: padding,
      child: Slidable(
        key: itemKey,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            const SizedBox(width: 12),
            SlidableAction(
              onPressed: (_) async => confirmDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
            ),
            const SizedBox(width: 12),
            SlidableAction(
              key: editButtonKey,
              onPressed: (_) => onEdit(),
              backgroundColor: LIGHT_BLUE,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              borderRadius: const BorderRadius.all(Radius.circular(40)),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
