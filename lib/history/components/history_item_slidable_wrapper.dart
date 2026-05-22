import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class HistoryItemSlidableWrapper extends StatelessWidget {
  const HistoryItemSlidableWrapper({
    required this.dbKey,
    required this.deleteLabel,
    required this.onDelete,
    required this.child,
    super.key,
  });

  final String dbKey;
  final String deleteLabel;
  final Future<void> Function() onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kAppSpace12,
        vertical: kAppSpace8,
      ),
      child: Slidable(
        key: ValueKey(dbKey),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.3,
          children: [
            const SizedBox(width: kAppSpace12),
            CustomSlidableAction(
              flex: 1,
              onPressed: (_) async => onDelete(),
              backgroundColor: STATUS_ERROR,
              foregroundColor: TEXT_INVERSE,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(kAppSurfaceRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: kAppSpace8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete, size: 20, color: TEXT_INVERSE),
                    const SizedBox(height: kAppSpace4),
                    Text(
                      deleteLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TEXT_INVERSE,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: kAppSpace12),
          ],
        ),
        child: child,
      ),
    );
  }
}
