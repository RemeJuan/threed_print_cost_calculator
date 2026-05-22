import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

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

  static Widget _actionContent(IconData icon, Color color) {
    return Center(child: Icon(icon, size: 18, color: color));
  }

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
            AppTertiaryButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              label: l10n.cancelButton,
            ),
            AppTertiaryButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              label: l10n.deleteButton,
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
          extentRatio: 0.35,
          children: [
            const SizedBox(width: 12),
            CustomSlidableAction(
              flex: 1,
              onPressed: (_) async => confirmDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(28),
              ),
              child: _actionContent(Icons.delete, Colors.white),
            ),
            CustomSlidableAction(
              key: editButtonKey,
              flex: 1,
              onPressed: (_) => onEdit(),
              backgroundColor: LIGHT_BLUE,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(28),
              ),
              child: _actionContent(Icons.edit, Colors.white),
            ),
            const SizedBox(width: 12),
          ],
        ),
        child: child,
      ),
    );
  }
}
