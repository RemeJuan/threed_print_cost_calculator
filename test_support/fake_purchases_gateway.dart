import 'dart:async';

import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';

class FakePurchasesGateway implements PurchasesGateway {
  FakePurchasesGateway(this._currentState);

  factory FakePurchasesGateway.free({String userId = 'integration-free'}) {
    return FakePurchasesGateway(
      PremiumState(isPremium: false, isLoading: false, userId: userId),
    );
  }

  factory FakePurchasesGateway.premium({
    String userId = 'integration-premium',
  }) {
    return FakePurchasesGateway(
      PremiumState(isPremium: true, isLoading: false, userId: userId),
    );
  }

  PremiumState _currentState;
  final StreamController<PremiumState> _controller =
      StreamController<PremiumState>.broadcast();

  @override
  Future<PremiumState> fetchPremiumState() async => _currentState;

  @override
  Stream<PremiumState> watchPremiumState() => _controller.stream;

  void emit(PremiumState nextState) {
    _currentState = nextState;
    if (!_controller.isClosed) {
      _controller.add(nextState);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
