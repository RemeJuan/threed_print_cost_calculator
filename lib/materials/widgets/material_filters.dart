import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/materials/providers/materials_providers.dart';

class MaterialFilters extends ConsumerWidget {
  const MaterialFilters({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final types = ref.watch(materialTypesProvider).toList()..sort();
    final selectedType = ref.watch(materialsTypeFilterProvider);
    final selectedStock = ref.watch(materialsStockFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (types.isNotEmpty)
          _FilterSection(
            chips: [
              ...types.map(
                (t) => _FilterChipData(label: t, selected: selectedType == t),
              ),
            ],
            onSelected: (index) {
              final type = types[index];
              ref.read(materialsTypeFilterProvider.notifier).state =
                  selectedType == type ? null : type;
            },
          ),
        _FilterSection(
          chips: [
            _FilterChipData(
              label: l10n.materialsFilterInStock,
              selected: selectedStock == StockStatus.inStock,
            ),
            _FilterChipData(
              label: l10n.materialsFilterLowStock,
              selected: selectedStock == StockStatus.lowStock,
            ),
            _FilterChipData(
              label: l10n.materialsFilterOutOfStock,
              selected: selectedStock == StockStatus.outOfStock,
            ),
          ],
          onSelected: (index) {
            final status = switch (index) {
              0 => StockStatus.inStock,
              1 => StockStatus.lowStock,
              2 => StockStatus.outOfStock,
              _ => null,
            };
            ref.read(materialsStockFilterProvider.notifier).state =
                selectedStock == status ? null : status;
          },
        ),
      ],
    );
  }
}

class _FilterChipData {
  final String label;
  final bool selected;
  const _FilterChipData({required this.label, required this.selected});
}

class _FilterSection extends StatelessWidget {
  final List<_FilterChipData> chips;
  final void Function(int index) onSelected;

  const _FilterSection({required this.chips, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...chips.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(entry.value.label),
                  selected: entry.value.selected,
                  onSelected: (_) => onSelected(entry.key),
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: entry.value.selected ? Colors.white : Colors.white70,
                  ),
                  selectedColor: const Color.fromRGBO(84, 153, 254, 0.3),
                  checkmarkColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(26, 28, 43, 1),
                  side: BorderSide(
                    color: entry.value.selected
                        ? const Color.fromRGBO(84, 153, 254, 0.6)
                        : Colors.white24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
