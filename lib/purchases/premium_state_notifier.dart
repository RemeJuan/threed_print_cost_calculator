import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';

final purchasesGatewayProvider = Provider<PurchasesGateway>((ref) {
  final gateway = RevenueCatPurchasesGateway();
  ref.onDispose(gateway.dispose);
  return gateway;
});

final premiumStateProvider =
    NotifierProvider<PremiumStateNotifier, PremiumState>(
      PremiumStateNotifier.new,
    );

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumStateProvider).isPremium;
});

class PremiumStateNotifier extends Notifier<PremiumState> {
  StreamSubscription<PremiumState>? _subscription;
  bool _initialized = false;
  bool _disposed = false;
  bool _wasUsingLocalOverride = false;
  bool _scheduledExpiredOverrideCleanup = false;

  @override
  PremiumState build() {
    ref.watch(appRefreshProvider);
    _disposed = false;

    final hasLocalOverride = _hasLocalOverride();
    if (hasLocalOverride) {
      _wasUsingLocalOverride = true;
      if (_initialized) {
        state = PremiumState(
          isPremium: true,
          isLoading: state.isLoading,
          userId: state.userId,
        );
        return state;
      }
    }

    final gateway = ref.read(purchasesGatewayProvider);

    if (!_initialized) {
      _initialized = true;
      if (hasLocalOverride) {
        _wasUsingLocalOverride = true;
      }
      _subscription = gateway.watchPremiumState().listen((premiumState) {
        if (_disposed) return;
        state = _applyOverride(premiumState);
      });

      ref.onDispose(() {
        _disposed = true;
        unawaited(_subscription?.cancel());
      });

      unawaited(_loadInitialState(gateway));

      return _applyOverride(const PremiumState.loading());
    }

    if (_wasUsingLocalOverride && !hasLocalOverride) {
      _wasUsingLocalOverride = false;
      state = const PremiumState.loading();
      unawaited(_loadInitialState(gateway));
      return state;
    }

    return state;
  }

  PremiumState _applyOverride(PremiumState premiumState) {
    if (!_hasLocalOverride()) return premiumState;
    return PremiumState(
      isPremium: true,
      isLoading: premiumState.isLoading,
      userId: premiumState.userId,
    );
  }

  Future<void> _loadInitialState(PurchasesGateway gateway) async {
    try {
      final premiumState = await gateway.fetchPremiumState();
      if (_disposed) return;
      state = _applyOverride(premiumState);
    } catch (_) {
      if (_disposed) return;
      state = PremiumState(
        isPremium: _hasLocalOverride(),
        isLoading: false,
        userId: state.userId,
      );
    }
  }

  bool _hasLocalOverride() {
    final prefs = _maybePrefs();
    if (prefs == null) return false;

    final enabledOn = prefs.getString(
      testPremiumOverrideEnabledOnPreferenceKey,
    );

    if (enabledOn == null) return false;

    if (isTestPremiumOverrideActiveForDate(enabledOn, DateTime.now())) {
      return true;
    }

    _scheduleExpiredOverrideCleanup();
    return false;
  }

  void _scheduleExpiredOverrideCleanup() {
    if (_scheduledExpiredOverrideCleanup) return;
    _scheduledExpiredOverrideCleanup = true;

    () async {
      bool shouldRefresh = false;
      try {
        final service = _maybeTestDataService();
        if (service != null) {
          await service.purge();
        } else {
          final prefs = _maybePrefs();
          if (prefs != null) {
            await prefs.remove(testPremiumOverrideEnabledOnPreferenceKey);
          }
        }
        shouldRefresh = !_disposed;
      } finally {
        _scheduledExpiredOverrideCleanup = false;
        if (shouldRefresh) {
          ref.read(appRefreshProvider.notifier).refresh();
        }
      }
    }();
  }

  TestDataService? _maybeTestDataService() {
    try {
      return ref.read(testDataServiceProvider);
    } catch (_) {
      return null;
    }
  }

  SharedPreferences? _maybePrefs() {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }
}
