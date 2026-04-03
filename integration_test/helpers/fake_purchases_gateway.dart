import 'dart:async';

import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';

class FakePurchasesGateway implements PurchasesGateway {
  FakePurchasesGateway(this._currentState);

  factory FakePurchasesGateway.free() {
    return FakePurchasesGateway(
      const PremiumState(
        isPremium: false,
        isLoading: false,
        userId: 'integration-free',
      ),
    );
  }

  factory FakePurchasesGateway.premium() {
    return FakePurchasesGateway(
      const PremiumState(
        isPremium: true,
        isLoading: false,
        userId: 'integration-premium',
      ),
    );
  }

  final StreamController<PremiumState> _controller =
      StreamController<PremiumState>.broadcast();
  PremiumState _currentState;

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Future<PremiumState> fetchPremiumState() async => _currentState;

  void emit(PremiumState next) {
    _currentState = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  @override
  Stream<PremiumState> watchPremiumState() => _controller.stream;
}
