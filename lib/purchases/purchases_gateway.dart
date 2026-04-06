import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';

class RevenueCatCustomerInfo {
  const RevenueCatCustomerInfo({
    required this.hasActiveEntitlements,
    required this.originalAppUserId,
  });

  final bool hasActiveEntitlements;
  final String originalAppUserId;
}

abstract class PurchasesSdkAdapter {
  Future<RevenueCatCustomerInfo> getCustomerInfo();
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  );
  void removeCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  );
}

class RevenueCatPurchasesSdkAdapter implements PurchasesSdkAdapter {
  RevenueCatPurchasesSdkAdapter();

  final Map<
    void Function(RevenueCatCustomerInfo info),
    CustomerInfoUpdateListener
  >
  _listeners =
      <
        void Function(RevenueCatCustomerInfo info),
        CustomerInfoUpdateListener
      >{};

  @override
  Future<RevenueCatCustomerInfo> getCustomerInfo() async {
    final info = await Purchases.getCustomerInfo();
    return RevenueCatCustomerInfo(
      hasActiveEntitlements: info.entitlements.active.isNotEmpty,
      originalAppUserId: info.originalAppUserId,
    );
  }

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  ) {
    void sdkListener(CustomerInfo info) {
      listener(
        RevenueCatCustomerInfo(
          hasActiveEntitlements: info.entitlements.active.isNotEmpty,
          originalAppUserId: info.originalAppUserId,
        ),
      );
    }

    _listeners[listener] = sdkListener;
    Purchases.addCustomerInfoUpdateListener(sdkListener);
  }

  @override
  void removeCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  ) {
    final sdkListener = _listeners.remove(listener);
    if (sdkListener != null) {
      Purchases.removeCustomerInfoUpdateListener(sdkListener);
    }
  }
}

abstract class PurchasesGateway {
  Future<PremiumState> fetchPremiumState();
  Stream<PremiumState> watchPremiumState();
  void dispose();
}

class RevenueCatPurchasesGateway implements PurchasesGateway {
  RevenueCatPurchasesGateway({PurchasesSdkAdapter? sdkAdapter})
    : _sdkAdapter = sdkAdapter ?? RevenueCatPurchasesSdkAdapter();

  final PurchasesSdkAdapter _sdkAdapter;
  final StreamController<PremiumState> _controller =
      StreamController<PremiumState>.broadcast();
  void Function(RevenueCatCustomerInfo info)? _listener;

  @override
  Future<PremiumState> fetchPremiumState() async {
    final info = await _sdkAdapter.getCustomerInfo();
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

      _sdkAdapter.addCustomerInfoUpdateListener(_listener!);
    }

    return _controller.stream;
  }

  @override
  void dispose() {
    if (_listener != null) {
      _sdkAdapter.removeCustomerInfoUpdateListener(_listener!);
      _listener = null;
    }

    _controller.close();
  }

  PremiumState _mapCustomerInfo(RevenueCatCustomerInfo info) {
    return PremiumState(
      isPremium: info.hasActiveEntitlements,
      isLoading: false,
      userId: info.originalAppUserId,
    );
  }
}
