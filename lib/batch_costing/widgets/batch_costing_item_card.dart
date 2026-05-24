import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/utils/format_utils.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_expansion_card.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_filter_chip.dart';

class BatchCostingItemCard extends ConsumerStatefulWidget {
  const BatchCostingItemCard({
    super.key,
    required this.item,
    required this.quantityController,
    required this.initiallyExpanded,
    required this.onExpansionChanged,
    required this.onEdit,
  });

  final BatchCostingItem item;
  final TextEditingController quantityController;
  final bool initiallyExpanded;
  final void Function(bool) onExpansionChanged;
  final VoidCallback onEdit;

  @override
  ConsumerState<BatchCostingItemCard> createState() => _BatchCostingItemCardState();
}

class _BatchCostingItemCardState extends ConsumerState<BatchCostingItemCard> {
  Timer? _quantityChangeTimer;

  @override
  void dispose() {
    _quantityChangeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final item = widget.item;
    final id = item.id;

    return AppExpansionCard(
      key: ValueKey<String>('batch-item-$id'),
      initiallyExpanded: widget.initiallyExpanded,
      onExpansionChanged: widget.onExpansionChanged,
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          _sourceChip(l10n, item),
        ],
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _itemDetailRow(
                    context,
                    l10n.batchCostingReviewWeightLabel,
                    item.printWeightG != null
                        ? Text(
                            '${formatWeight(item.printWeightG!)}${l10n.gramsSuffix}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        : Text(
                            l10n.batchCostingReviewWeightRequired,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                  ),
                  _itemDetailRow(
                    context,
                    l10n.batchCostingReviewDurationLabel,
                    item.printDuration != null
                        ? Text(
                            formatDuration(item.printDuration!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        : Text(
                            l10n.batchCostingReviewDurationRequired,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextField(
                controller: widget.quantityController,
                decoration: InputDecoration(
                  labelText: l10n.batchCostingReviewQuantityLabel,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 1) return;
                  if (!context.mounted) return;
                  final cleared = ref
                      .read(batchCostingProvider.notifier)
                      .updateItem(item.copyWith(quantity: parsed));
                  _quantityChangeTimer?.cancel();
                  if (cleared) {
                    _quantityChangeTimer = Timer(
                      const Duration(milliseconds: 1000),
                      () {
                        if (!context.mounted) return;
                        BotToast.showText(
                          text: l10n.batchCostingAssignmentQuantityChangedMessage,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                final src = item.sourceType == BatchCostingItemSourceType.gcode
                    ? 'gcode'
                    : 'manual';
                AppAnalytics.safeLog(
                  () => AppAnalytics.batchItemRemoved(source: src),
                );
                ref.read(batchCostingProvider.notifier).removeItem(item.id);
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.batchCostingReviewRemoveButton),
            ),
            const Spacer(),
            AppTertiaryButton(
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: l10n.editButton,
            ),
          ],
        ),
      ],
    );
  }

  Widget _itemDetailRow(BuildContext context, String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  Widget _sourceChip(AppLocalizations l10n, BatchCostingItem item) {
    final label = switch (item.sourceType) {
      BatchCostingItemSourceType.manual => l10n.batchCostingReviewSourceManual,
      BatchCostingItemSourceType.gcode => l10n.batchCostingReviewSourceGcode,
      null => l10n.batchCostingReviewSourceUnknown,
    };
    return AppFilterChip(label: label, selected: true);
  }
}
