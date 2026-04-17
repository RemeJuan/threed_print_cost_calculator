import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_tools_gate.dart';

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

  @override
  PremiumState build() {
    ref.watch(appRefreshProvider);

    final hasLocalOverride = _hasLocalOverride();

    if (hasLocalOverride) {
      _wasUsingLocalOverride = true;
      return const PremiumState(isPremium: true, isLoading: false);
    }

    final gateway = ref.read(purchasesGatewayProvider);

    if (!_initialized) {
      _initialized = true;
      _subscription = gateway.watchPremiumState().listen((premiumState) {
        if (_disposed) return;
        if (_hasLocalOverride()) return;
        state = premiumState;
      });

      ref.onDispose(() {
        _disposed = true;
        unawaited(_subscription?.cancel());
      });

      unawaited(_loadInitialState(gateway));

      return const PremiumState.loading();
    }

    if (_wasUsingLocalOverride) {
      _wasUsingLocalOverride = false;
      unawaited(_loadInitialState(gateway));
      return const PremiumState.loading();
    }

    return state;
  }

  Future<void> _loadInitialState(PurchasesGateway gateway) async {
    try {
      final premiumState = await gateway.fetchPremiumState();
      if (_disposed) return;
      if (_hasLocalOverride()) return;
      state = premiumState;
    } catch (_) {
      if (_disposed) return;
      if (_hasLocalOverride()) return;
      state = const PremiumState(isPremium: false, isLoading: false);
    }
  }

  bool _hasLocalOverride() {
    final prefs = _maybePrefs();
    return testDataToolsEnabled &&
        prefs != null &&
        (prefs.getBool(testPremiumOverridePreferenceKey) ?? false);
  }

  SharedPreferences? _maybePrefs() {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }
}
