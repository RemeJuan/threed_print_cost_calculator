import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final appUsageServiceProvider = Provider<AppUsageService>((ref) {
  final service = AppUsageService(ref)..initialize();
  ref.onDispose(service.dispose);
  return service;
});
final completedCostingCountProvider = StateProvider<int>((ref) {
  try {
    final store = ref.read(premiumLocalStoreProvider);
    return int.tryParse(
          store.readSync(completedCostingCountPreferenceKey) ?? '',
        ) ??
        0;
  } catch (_) {
    return 0;
  }
});
final rateMyAppEligibilityProvider = Provider<bool>(
  (ref) => ref.watch(completedCostingCountProvider) > 10,
);

class AppUsageService with WidgetsBindingObserver {
  AppUsageService(this.ref);

  final Ref ref;
  var _pendingCompletedCostingCount = 0;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  bool get _isAppResumed {
    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }

  PremiumLocalStore? get _store {
    try {
      return ref.read(premiumLocalStoreProvider);
    } catch (_) {
      return null;
    }
  }

  int get calculationCount =>
      int.tryParse(_store?.readSync(calculationCountPreferenceKey) ?? '') ?? 0;

  int get completedCostingCount =>
      int.tryParse(
        _store?.readSync(completedCostingCountPreferenceKey) ?? '',
      ) ??
      0;

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

  Future<void> recordCompletedCosting() async {
    final store = _store;
    if (store == null) {
      return;
    }

    if (!_isAppResumed) {
      _pendingCompletedCostingCount += 1;
      return;
    }

    await _applyCompletedCostingIncrement(store, additionalCount: 1);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    unawaited(_flushPendingCompletedCosting());
  }

  Future<void> _flushPendingCompletedCosting() async {
    final store = _store;
    if (store == null || !_isAppResumed || _pendingCompletedCostingCount == 0) {
      return;
    }

    await _applyCompletedCostingIncrement(store);
  }

  Future<void> _applyCompletedCostingIncrement(
    PremiumLocalStore store, {
    int additionalCount = 0,
  }) async {
    final incrementBy = _pendingCompletedCostingCount + additionalCount;
    if (incrementBy <= 0) {
      return;
    }

    _pendingCompletedCostingCount = 0;

    final nextCount = completedCostingCount + incrementBy;
    await store.write(completedCostingCountPreferenceKey, nextCount.toString());
    ref.read(completedCostingCountProvider.notifier).state = nextCount;
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
