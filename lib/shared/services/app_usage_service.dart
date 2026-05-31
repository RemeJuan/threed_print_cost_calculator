import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final appUsageServiceProvider = Provider<AppUsageService>(AppUsageService.new);

class AppUsageService {
  AppUsageService(this.ref);

  final Ref ref;

  PremiumLocalStore? get _store {
    try {
      return ref.read(premiumLocalStoreProvider);
    } catch (_) {
      return null;
    }
  }

  int get calculationCount =>
      int.tryParse(_store?.readSync(calculationCountPreferenceKey) ?? '') ?? 0;

  bool get hasUsedGcodeImport =>
      _store?.readSync(hasUsedGcodeImportPreferenceKey) == 'true';

  Future<void> recordCalculation() async {
    final store = _store;
    if (store == null) {
      return;
    }

    await store.write(
      calculationCountPreferenceKey,
      (calculationCount + 1).toString(),
    );
  }

  Future<void> markGcodeImportUsed() async {
    final store = _store;
    if (store == null) {
      return;
    }

    await store.write(hasUsedGcodeImportPreferenceKey, 'true');
  }

  static String calculationCountBucket(int count) {
    if (count <= 0) return '0';
    if (count == 1) return '1';
    if (count <= 4) return '2_4';
    if (count <= 9) return '5_9';
    return '10_plus';
  }
}
