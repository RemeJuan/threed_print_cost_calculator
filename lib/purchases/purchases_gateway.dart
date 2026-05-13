import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';

class RevenueCatCustomerInfo {
  const RevenueCatCustomerInfo({
    required this.hasActiveEntitlements,
    required this.originalAppUserId,
    this.platform = 'unknown',
    this.entitlementType = 'none',
    this.productId = '',
    this.willRenew = true,
    this.cancellationDetectedAt,
    this.billingIssueDetectedAt,
    this.originalPurchaseDate,
    this.expirationDate,
  });

  final bool hasActiveEntitlements;
  final String originalAppUserId;
  final String platform;
  final String entitlementType;
  final String productId;
  final bool willRenew;
  final DateTime? cancellationDetectedAt;
  final DateTime? billingIssueDetectedAt;
  final DateTime? originalPurchaseDate;
  final DateTime? expirationDate;
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
    return _mapCustomerInfo(info);
  }

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  ) {
    void sdkListener(CustomerInfo info) {
      listener(_mapCustomerInfo(info));
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

  RevenueCatCustomerInfo _mapCustomerInfo(CustomerInfo info) {
    final entitlement = _activeEntitlement(info);

    return RevenueCatCustomerInfo(
      hasActiveEntitlements: entitlement?.isActive ?? false,
      originalAppUserId: info.originalAppUserId,
      platform: _mapStore(entitlement?.store),
      entitlementType: _mapEntitlementType(entitlement?.periodType),
      productId: entitlement?.productIdentifier ?? '',
      willRenew: entitlement?.willRenew ?? true,
      cancellationDetectedAt: _parseDate(entitlement?.unsubscribeDetectedAt),
      billingIssueDetectedAt: _parseDate(entitlement?.billingIssueDetectedAt),
      originalPurchaseDate: _parseDate(entitlement?.originalPurchaseDate),
      expirationDate: _parseDate(entitlement?.expirationDate),
    );
  }

  EntitlementInfo? _activeEntitlement(CustomerInfo info) {
    final entitlements = info.entitlements.active.values;
    if (entitlements.isEmpty) return null;
    return entitlements.first;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static String _mapEntitlementType(PeriodType? periodType) {
    if (periodType == null) return 'none';
    return periodType.name == 'trial' ? 'trial' : 'subscription';
  }

  static String _mapStore(Store? store) {
    return switch (store?.name) {
      'appStore' => 'app_store',
      'macAppStore' => 'mac_app_store',
      'playStore' => 'play_store',
      'amazon' => 'amazon',
      'stripe' => 'stripe',
      'promotional' => 'promotional',
      'rcBilling' => 'rc_billing',
      final name? => name,
      null => 'unknown',
    };
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
      platform: info.platform,
      entitlementType: info.entitlementType,
      productId: info.productId,
      willRenew: info.willRenew,
      cancellationDetectedAt: info.cancellationDetectedAt,
      billingIssueDetectedAt: info.billingIssueDetectedAt,
      originalPurchaseDate: info.originalPurchaseDate,
      expirationDate: info.expirationDate,
    );
  }
}
