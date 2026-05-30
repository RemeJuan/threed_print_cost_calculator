import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

final materialsSearchQueryProvider = StateProvider<String>((ref) => '');

final materialsTypeFilterProvider = StateProvider<String?>((ref) => null);

final materialsStockFilterProvider = StateProvider<StockStatus?>((ref) => null);

List<MaterialModel> _materialsOrEmpty(Ref ref) {
  return ref
      .watch(materialsStreamProvider)
      .when(
        data: (m) => m,
        loading: () => <MaterialModel>[],
        error: (_, _) => <MaterialModel>[],
      );
}

final materialTypesProvider = Provider<Set<String>>((ref) {
  final materials = _materialsOrEmpty(ref);
  return materials
      .map((m) => m.materialType)
      .where((t) => t.isNotEmpty)
      .toSet();
});

final materialBrandsProvider = Provider<Set<String>>((ref) {
  final materials = _materialsOrEmpty(ref);
  return materials.map((m) => m.brand).where((b) => b.isNotEmpty).toSet();
});

int _stockSortPriority(StockStatus status) => switch (status) {
  StockStatus.inStock => 0,
  StockStatus.lowStock => 1,
  StockStatus.noTracking => 2,
  StockStatus.outOfStock => 3,
};

final filteredMaterialsProvider = Provider<List<MaterialModel>>((ref) {
  final materials = _materialsOrEmpty(ref);
  final query = ref.watch(materialsSearchQueryProvider).toLowerCase().trim();
  final typeFilter = ref.watch(materialsTypeFilterProvider);
  final stockTrackingAllowed =
      ref.watch(premiumAccessPolicyProvider).stockTracking().allowed;
  final stockFilter =
      stockTrackingAllowed ? ref.watch(materialsStockFilterProvider) : null;

  final result = materials.where((m) {
    if (query.isNotEmpty) {
      final name = m.name.toLowerCase();
      final brand = m.brand.toLowerCase();
      if (!name.contains(query) && !brand.contains(query)) return false;
    }

    if (typeFilter != null && m.materialType != typeFilter) return false;

    if (stockFilter != null && calculateStockStatus(m) != stockFilter) {
      return false;
    }

    return true;
  }).toList();

  result.sort((a, b) {
    final pa = _stockSortPriority(calculateStockStatus(a));
    final pb = _stockSortPriority(calculateStockStatus(b));
    return pa.compareTo(pb);
  });

  return result;
});
