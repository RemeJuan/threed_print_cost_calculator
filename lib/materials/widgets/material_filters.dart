import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/materials/providers/materials_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_filter_chip.dart';

class MaterialFilters extends ConsumerWidget {
  const MaterialFilters({super.key});

  @override
  Widget build(context, ref) {
    ref.listen(premiumAccessPolicyProvider, (prev, next) {
      if (prev != null && prev.stockTracking().allowed && !next.stockTracking().allowed) {
        ref.read(materialsStockFilterProvider.notifier).state = null;
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final types = ref.watch(materialTypesProvider).toList()..sort();
    final selectedType = ref.watch(materialsTypeFilterProvider);
    final selectedStock = ref.watch(materialsStockFilterProvider);
    final stockTrackingAllowed = ref
        .watch(premiumAccessPolicyProvider)
        .stockTracking()
        .allowed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (types.isNotEmpty)
          _FilterSection(
            chips: [
              ...types.map((t) => (label: t, selected: selectedType == t)),
            ],
            onSelected: (index) {
              final type = types[index];
              ref.read(materialsTypeFilterProvider.notifier).state =
                  selectedType == type ? null : type;
            },
          ),
        if (stockTrackingAllowed)
          _FilterSection(
            chips: [
              (
                label: l10n.materialsFilterInStock,
                selected: selectedStock == StockStatus.inStock,
              ),
              (
                label: l10n.materialsFilterLowStock,
                selected: selectedStock == StockStatus.lowStock,
              ),
              (
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

class _FilterSection extends StatelessWidget {
  final List<({String label, bool selected})> chips;
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
                child: AppFilterChip(
                  label: entry.value.label,
                  selected: entry.value.selected,
                  onTap: () => onSelected(entry.key),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
