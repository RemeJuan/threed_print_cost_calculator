import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';

class FakePaywallPresenter implements PaywallPresenter {
  int calls = 0;
  String? lastOfferingId;
  String? lastTriggerFeature;
  String? lastPurchaseSource;
  String? lastSource;
  String? lastDefaultEntryPoint;
  int? lastLaunchCount;
  @override
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  }) async {
    calls += 1;
    lastOfferingId = offeringId;
    lastTriggerFeature = triggerFeature;
    lastPurchaseSource = purchaseSource;
    lastSource = source;
    lastDefaultEntryPoint = defaultEntryPoint;
    lastLaunchCount = launchCount;
  }
}

class FakePremiumPurchaseGateway implements PremiumPurchaseGateway {
  FakePremiumPurchaseGateway({
    this.currentOffering,
    this.shouldThrowOnPurchase,
    this.shouldThrowOnRestore,
  });
  final Offering? currentOffering;
  final bool? shouldThrowOnPurchase;
  final bool? shouldThrowOnRestore;
  int getCurrentOfferingCalls = 0;
  int getOfferingCalls = 0;
  int purchasePackageCalls = 0;
  int restorePurchasesCalls = 0;
  Package? lastPurchasedPackage;
  @override
  Future<Offering?> getOffering(String offeringId) async {
    getOfferingCalls += 1;
    return currentOffering ??
        Offering(offeringId, offeringId, {}, [
          Package(
            '${offeringId}_monthly',
            PackageType.monthly,
            StoreProduct(
              '${offeringId}_sku',
              offeringId,
              offeringId,
              9.99,
              '\$9.99',
              'USD',
            ),
            PresentedOfferingContext(offeringId, null, null),
          ),
        ]);
  }

  @override
  Future<Offering?> getCurrentOffering() async {
    getCurrentOfferingCalls += 1;
    return currentOffering;
  }

  @override
  Future<void> purchasePackage(Package package) async {
    purchasePackageCalls += 1;
    lastPurchasedPackage = package;
    if (shouldThrowOnPurchase == true) throw Exception('Purchase failed');
  }

  @override
  Future<void> restorePurchases() async {
    restorePurchasesCalls += 1;
    if (shouldThrowOnRestore == true) throw Exception('Restore failed');
  }
}
