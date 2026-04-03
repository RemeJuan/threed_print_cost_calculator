import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';

abstract class PurchasesGateway {
  Future<PremiumState> fetchPremiumState();
  Stream<PremiumState> watchPremiumState();
  void dispose();
}

class RevenueCatPurchasesGateway implements PurchasesGateway {
  RevenueCatPurchasesGateway();

  final StreamController<PremiumState> _controller =
      StreamController<PremiumState>.broadcast();
  CustomerInfoUpdateListener? _listener;

  @override
  Future<PremiumState> fetchPremiumState() async {
    final info = await Purchases.getCustomerInfo();
    return _mapCustomerInfo(info);
  }

  @override
  Stream<PremiumState> watchPremiumState() {
    if (_listener == null) {
      _listener = (info) {
        if (!_controller.isClosed) {
          _controller.add(_mapCustomerInfo(info));
        }
      };

      Purchases.addCustomerInfoUpdateListener(_listener!);
    }

    return _controller.stream;
  }

  @override
  void dispose() {
    if (_listener != null) {
      Purchases.removeCustomerInfoUpdateListener(_listener!);
      _listener = null;
    }

    _controller.close();
  }

  PremiumState _mapCustomerInfo(CustomerInfo info) {
    return PremiumState(
      isPremium: info.entitlements.active.isNotEmpty,
      isLoading: false,
      userId: info.originalAppUserId,
    );
  }
}
