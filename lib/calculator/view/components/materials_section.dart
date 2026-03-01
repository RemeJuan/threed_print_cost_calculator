import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class MaterialsSection extends HookConsumerWidget {
  const MaterialsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    final usages = state.materialUsages;

    // ── Single-material (legacy) controllers ──────────────────────────────────
    final spoolWeightController = useTextEditingController(
      text: state.spoolWeight.value?.toString() ?? '',
    );
    final spoolCostController = useTextEditingController(
      text: state.spoolCostText.isNotEmpty
          ? state.spoolCostText
          : (state.spoolCost.value?.toString() ?? ''),
    );
    final printWeightController = useTextEditingController(
      text: state.printWeight.value?.toString() ?? '',
    );

    final spoolWeightFocus = useFocusNode();
    final spoolCostFocus = useFocusNode();
    final printWeightFocus = useFocusNode();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Multi-material rows ──────────────────────────────────────────────
        if (usages.isNotEmpty) ...[
          ...usages.asMap().entries.map((entry) {
            return _MaterialUsageRow(
              index: entry.key,
              usage: entry.value,
              onWeightChanged: (w) =>
                  notifier.updateMaterialUsageWeight(entry.key, w),
              onRemove: () => notifier.removeMaterialUsage(entry.key),
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Total: ${usages.fold(0, (s, u) => s + u.weightGrams)} g',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
        // ── Single-material (legacy) fields shown when no usages ─────────────
        if (usages.isEmpty) ...[
          Row(
            children: [
              Expanded(
                child: FocusSafeTextField(
                  controller: spoolWeightController,
                  externalText: state.spoolWeight.value?.toString() ?? '',
                  focusNode: spoolWeightFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.spoolWeightLabel,
                    suffixText: l10n.gramsSuffix,
                  ),
                  onChanged: (value) async {
                    notifier
                      ..updateSpoolWeight(num.tryParse(value) ?? 0)
                      ..submitDebounced();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FocusSafeTextField(
                  controller: spoolCostController,
                  externalText: state.spoolCostText.isNotEmpty
                      ? state.spoolCostText
                      : (state.spoolCost.value?.toString() ?? ''),
                  focusNode: spoolCostFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: l10n.spoolCostLabel),
                  onChanged: (value) async {
                    notifier
                      ..updateSpoolCost(value)
                      ..submitDebounced();
                  },
                ),
              ),
            ],
          ),
          FocusSafeTextField(
            controller: printWeightController,
            externalText: state.printWeight.value?.toString() ?? '',
            focusNode: printWeightFocus,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.printWeightLabel),
            onChanged: (value) {
              notifier
                ..updatePrintWeight(value)
                ..submitDebounced();
            },
          ),
        ],
        // ── "Add material" button ────────────────────────────────────────────
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _showMaterialPicker(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add material'),
            style: TextButton.styleFrom(foregroundColor: LIGHT_BLUE),
          ),
        ),
      ],
    );
  }

  Future<void> _showMaterialPicker(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MaterialPickerSheet(
        onMaterialSelected: (material) {
          ref.read(calculatorProvider.notifier).addMaterialUsage(material);
        },
      ),
    );
  }
}

// ── Per-usage row widget ──────────────────────────────────────────────────────

class _MaterialUsageRow extends StatefulWidget {
  const _MaterialUsageRow({
    required this.index,
    required this.usage,
    required this.onWeightChanged,
    required this.onRemove,
  });

  final int index;
  final MaterialUsage usage;
  final ValueChanged<int> onWeightChanged;
  final VoidCallback onRemove;

  @override
  State<_MaterialUsageRow> createState() => _MaterialUsageRowState();
}

class _MaterialUsageRowState extends State<_MaterialUsageRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.usage.weightGrams > 0
          ? widget.usage.weightGrams.toString()
          : '',
    );
  }

  @override
  void didUpdateWidget(_MaterialUsageRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller text when the underlying weight changes from outside
    // (e.g., another widget removes a row and indices shift). Only update
    // when the field does not have focus to avoid interrupting user input.
    if (widget.usage.weightGrams != oldWidget.usage.weightGrams) {
      final newText = widget.usage.weightGrams > 0
          ? widget.usage.weightGrams.toString()
          : '';
      if (_controller.text != newText) {
        _controller.value = _controller.value.copyWith(text: newText);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Material name
          Expanded(
            flex: 3,
            child: Text(
              widget.usage.materialName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Weight input
          Expanded(
            flex: 2,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                suffixText: 'g',
                isDense: true,
              ),
              onChanged: (value) {
                final w = int.tryParse(value) ?? 0;
                widget.onWeightChanged(w);
              },
            ),
          ),
          // Remove button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: Colors.redAccent,
            onPressed: widget.onRemove,
            tooltip: 'Remove material',
          ),
        ],
      ),
    );
  }
}

// ── Material picker bottom sheet ──────────────────────────────────────────────

class _MaterialPickerSheet extends HookConsumerWidget {
  const _MaterialPickerSheet({required this.onMaterialSelected});

  final ValueChanged<MaterialModel> onMaterialSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store(DBName.materials.name);
    final searchController = useTextEditingController();
    final query = store.query();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search materials…',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: query.onSnapshots(db),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No materials found'));
                  }
                  final materials = snapshot.data!
                      .map((e) => MaterialModel.fromMap(e.value, e.key))
                      .toList();

                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, searchValue, _) {
                      final query = searchValue.text.toLowerCase();
                      final filtered = query.isEmpty
                          ? materials
                          : materials
                                .where(
                                  (m) =>
                                      m.name.toLowerCase().contains(query) ||
                                      m.color.toLowerCase().contains(query),
                                )
                                .toList();

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final material = filtered[index];
                          return ListTile(
                            title: Text(material.name),
                            subtitle: Text(material.color),
                            trailing: Text(
                              material.cost.isNotEmpty
                                  ? '\$${material.cost}'
                                  : '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () {
                              onMaterialSelected(material);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
