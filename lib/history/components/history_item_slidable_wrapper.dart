import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Slidable(
        key: ValueKey(dbKey),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.3,
          children: [
            const SizedBox(width: 12),
            CustomSlidableAction(
              flex: 1,
              onPressed: (_) async => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.white),
                    const SizedBox(height: 4),
                    Text(
                      deleteLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        child: child,
      ),
    );
  }
}
