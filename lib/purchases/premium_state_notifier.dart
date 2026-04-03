import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';

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

  @override
  PremiumState build() {
    if (!_initialized) {
      _initialized = true;

      final gateway = ref.read(purchasesGatewayProvider);
      _subscription = gateway.watchPremiumState().listen((premiumState) {
        if (_disposed) return;
        state = premiumState;
      });

      ref.onDispose(() {
        _disposed = true;
        unawaited(_subscription?.cancel());
      });

      unawaited(_loadInitialState(gateway));
    }

    return const PremiumState.loading();
  }

  Future<void> _loadInitialState(PurchasesGateway gateway) async {
    try {
      final premiumState = await gateway.fetchPremiumState();
      if (_disposed) return;
      state = premiumState;
    } catch (_) {
      if (_disposed) return;
      state = const PremiumState(isPremium: false, isLoading: false);
    }
  }
}
