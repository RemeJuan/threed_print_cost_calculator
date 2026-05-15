import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';
import 'package:threed_print_cost_calculator/shared/utils/weight_formatting.dart';

class BatchCostingPage extends ConsumerStatefulWidget {
  const BatchCostingPage({super.key});

  @override
  ConsumerState<BatchCostingPage> createState() => _BatchCostingPageState();
}

class _BatchCostingPageState extends ConsumerState<BatchCostingPage> {
  final Map<String, TextEditingController> _quantityControllers =
      <String, TextEditingController>{};
  final Map<String, FocusNode> _quantityFocusNodes = <String, FocusNode>{};
  bool _initialSyncDone = false;

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _quantityFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(batchCostingEnabledProvider)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final batchState = ref.watch(batchCostingProvider);
    final items = batchState.items;

    if (!_initialSyncDone) {
      _initialSyncDone = true;
      _syncControllers(items);
    }

    ref.listen(batchCostingProvider, (prev, next) {
      _syncControllers(next.items);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batchCostingReviewAppBarTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.batchCostingReviewSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: items.isEmpty
                    ? _emptyState(context, l10n)
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _batchItemCard(context, l10n, item);
                        },
                      ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _continueToPrinterAssignment(context),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l10n.batchCostingReviewContinueButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _syncControllers(List<BatchCostingItem> items) {
    final activeIds = items.map((item) => item.id).toSet();

    final removedIds = _quantityControllers.keys
        .where((itemId) => !activeIds.contains(itemId))
        .toList(growable: false);
    for (final itemId in removedIds) {
      _quantityControllers.remove(itemId)?.dispose();
      _quantityFocusNodes.remove(itemId)?.dispose();
    }

    for (final item in items) {
      final controller = _quantityControllers.putIfAbsent(
        item.id,
        () => TextEditingController(text: item.quantity.toString()),
      );
      final focusNode = _quantityFocusNodes.putIfAbsent(item.id, FocusNode.new);

      if (!focusNode.hasFocus) {
        final quantityText = item.quantity.toString();
        if (controller.text != quantityText) {
          controller.value = TextEditingValue(
            text: quantityText,
            selection: TextSelection.collapsed(offset: quantityText.length),
          );
        }
      }
    }
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.batchCostingReviewEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.batchCostingReviewEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _batchItemCard(
    BuildContext context,
    AppLocalizations l10n,
    BatchCostingItem item,
  ) {
    final controller = _quantityControllers[item.id]!;
    final focusNode = _quantityFocusNodes[item.id]!;

    return Card(
      child: ExpansionTile(
        key: ValueKey<String>('batch-item-${item.id}'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          item.displayName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          _batchItemSubtitle(l10n, item),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          _itemDetailRow(
            context,
            l10n.batchCostingReviewWeightLabel,
            '${formatWeight(item.printWeightG)} g',
          ),
          const SizedBox(height: 8),
          _itemDetailRow(
            context,
            l10n.batchCostingReviewDurationLabel,
            _formatDuration(item.printDuration),
          ),
          const SizedBox(height: 16),
          FocusSafeTextField(
            controller: controller,
            focusNode: focusNode,
            externalText: item.quantity.toString(),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            inputNormalizer: (value) =>
                normalizeLeadingZeroNumericInput(value, allowDecimal: false),
            decoration: InputDecoration(
              labelText: l10n.batchCostingReviewQuantityLabel,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed == null || parsed < 1) return;
              ref
                  .read(batchCostingProvider.notifier)
                  .updateItem(item.copyWith(quantity: parsed));
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () =>
                  ref.read(batchCostingProvider.notifier).removeItem(item.id),
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.batchCostingReviewRemoveButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemDetailRow(BuildContext context, String label, String value) {
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
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  String _batchItemSubtitle(AppLocalizations l10n, BatchCostingItem item) {
    final source = switch (item.sourceType) {
      BatchCostingItemSourceType.manual => l10n.batchCostingReviewSourceManual,
      BatchCostingItemSourceType.gcode => l10n.batchCostingReviewSourceGcode,
      null => l10n.batchCostingReviewSourceUnknown,
    };
    final sourceFile = item.sourceFileName;
    if (sourceFile == null || sourceFile.isEmpty) {
      return '${l10n.batchCostingReviewSourceLabel}: $source';
    }

    return '${l10n.batchCostingReviewSourceLabel}: $source · $sourceFile';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _continueToPrinterAssignment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BatchPrinterAssignmentPage(),
      ),
    );
  }
}
