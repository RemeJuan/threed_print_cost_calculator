import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

List<BatchAssignmentAllocation> batchAllocationsFor({
  required BatchCostingState state,
  required BatchCostingItem item,
  required Map<String, List<BatchAssignmentAllocation>> Function(
    BatchCostingState,
  )
  itemAllocations,
  required String? Function(BatchCostingItem) itemFallback,
  required String? Function(BatchCostingState) batchId,
}) {
  final allocations = itemAllocations(state)[item.id];
  if (allocations != null && allocations.isNotEmpty) return allocations;

  final id = itemFallback(item) ?? batchId(state);
  if (id == null) {
    return [const BatchAssignmentAllocation(targetId: '', quantity: 1)];
  }

  return [BatchAssignmentAllocation(targetId: id, quantity: item.quantity)];
}

bool batchNextEnabled({
  required BatchCostingState state,
  required bool hasData,
  required bool Function(BatchCostingState) isBatchWide,
  required String? Function(BatchCostingState) batchId,
}) {
  if (!hasData) return false;
  if (isBatchWide(state)) return batchId(state) != null;
  return state.items.isNotEmpty;
}

void batchContinueFlow({
  required BuildContext context,
  required BatchCostingState state,
  required bool Function(BatchCostingState) isBatchWide,
  required Map<String, List<BatchAssignmentAllocation>> Function(
    BatchCostingState,
  )
  itemAllocations,
  required String? Function(BatchCostingState) batchId,
  required String Function(AppLocalizations) errorText,
  required String analyticsType,
  required Widget nextPage,
}) {
  final missing = state.items.where((item) {
    final allocations =
        itemAllocations(state)[item.id] ?? const <BatchAssignmentAllocation>[];
    return isBatchWide(state)
        ? batchId(state) == null
        : allocations.isEmpty || allocations.any((a) => a.targetId.isEmpty);
  });
  if (missing.isNotEmpty) {
    BotToast.showText(text: errorText(AppLocalizations.of(context)!));
    return;
  }

  final mode = isBatchWide(state) ? 'batch' : 'split';
  final hasSplit =
      !isBatchWide(state) &&
      state.items.any((item) {
        final allocs = itemAllocations(state)[item.id];
        if (allocs == null || allocs.length <= 1) return false;
        return allocs.map((a) => a.targetId).toSet().length > 1;
      });

  AppAnalytics.safeLog(
    () => AppAnalytics.batchAssignmentCompleted(
      type: analyticsType,
      mode: mode,
      hasSplitAllocations: hasSplit,
    ),
  );

  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => nextPage));
}
