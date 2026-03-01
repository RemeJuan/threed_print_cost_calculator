import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

/// Displays the multi-material picker section in the calculator.
///
/// Shows a list of [MaterialUsage] rows with per-material weight inputs,
/// an "Add material" button that opens a bottom-sheet picker, and a total
/// weight summary when more than one material is present.
class MultiMaterialSection extends HookConsumerWidget {
  const MultiMaterialSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final l10n = S.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // List of added materials
        ...state.materialUsages.asMap().entries.map((entry) {
          final index = entry.key;
          final usage = entry.value;
          return _MaterialUsageRow(
            key: ValueKey('${usage.materialId}_$index'),
            usage: usage,
            onWeightChanged: (grams) {
              notifier.updateMaterialWeight(index, grams);
              notifier.submitDebounced();
            },
            onRemove: state.materialUsages.length > 1
                ? () => notifier.removeMaterial(index)
                : null,
          );
        }),

        // Total weight row (only shown when multiple materials are present)
        if (state.materialUsages.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalMaterialWeightLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${state.totalMaterialWeight} ${l10n.gramsSuffix}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

        // Add material button
        TextButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.addMaterialButton),
          style: TextButton.styleFrom(
            foregroundColor: LIGHT_BLUE,
            alignment: Alignment.centerLeft,
          ),
          onPressed: () => _showMaterialPicker(context, ref),
        ),
      ],
    );
  }

  void _showMaterialPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1C2B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MaterialPickerSheet(
        onSelected: (material) {
          Navigator.pop(ctx);
          ref.read(calculatorProvider.notifier).addMaterial(material);
        },
      ),
    );
  }
}

// ── Per-material row ──────────────────────────────────────────────────────────

class _MaterialUsageRow extends HookWidget {
  final MaterialUsage usage;
  final ValueChanged<int> onWeightChanged;
  final VoidCallback? onRemove;

  const _MaterialUsageRow({
    required this.usage,
    required this.onWeightChanged,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(
      text: usage.weightGrams > 0 ? usage.weightGrams.toString() : '',
    );
    final l10n = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Material name + cost info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usage.materialName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (usage.spoolCost > 0 || usage.spoolWeight > 0)
                  Text(
                    '${usage.spoolCost} / ${usage.spoolWeight}${l10n.gramsSuffix}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white38,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Weight input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                suffixText: l10n.gramsSuffix,
                isDense: true,
              ),
              onChanged: (v) {
                final grams = int.tryParse(v) ?? 0;
                onWeightChanged(grams);
              },
            ),
          ),
          // Remove button (hidden when only one material remains)
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: Colors.redAccent,
              onPressed: onRemove,
              tooltip: 'Remove material',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Material picker bottom sheet ──────────────────────────────────────────────

class _MaterialPickerSheet extends HookConsumerWidget {
  final ValueChanged<MaterialModel> onSelected;

  const _MaterialPickerSheet({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final store = stringMapStoreFactory.store(DBName.materials.name);
    final searchController = useTextEditingController();
    final query = useState('');
    final l10n = S.of(context);

    useEffect(() {
      searchController.addListener(() {
        query.value = searchController.text.toLowerCase();
      });
      return null;
    }, [searchController]);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Text(
                l10n.selectMaterialHint,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: TextField(
                controller: searchController,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Search materials…',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
              ),
            ),
            // Material list
            Expanded(
              child: StreamBuilder(
                stream: store.query().onSnapshots(db),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No materials saved yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final allMaterials = snapshot.data!
                      .map((e) => MaterialModel.fromMap(e.value, e.key))
                      .toList();

                  final filtered = query.value.isEmpty
                      ? allMaterials
                      : allMaterials.where((m) {
                          return m.name.toLowerCase().contains(query.value) ||
                              m.color.toLowerCase().contains(query.value);
                        }).toList();

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final material = filtered[index];
                      return ListTile(
                        title: Text(
                          material.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${material.color}  •  ${material.cost} / ${material.weight}g',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () => onSelected(material),
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
