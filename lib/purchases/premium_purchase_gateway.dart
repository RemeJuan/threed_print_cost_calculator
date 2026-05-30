import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class PremiumPurchaseGateway {
  Future<Offering?> getCurrentOffering();
  Future<void> purchasePackage(Package package);
  Future<void> restorePurchases();
}

class RevenueCatPremiumPurchaseGateway implements PremiumPurchaseGateway {
  const RevenueCatPremiumPurchaseGateway();

  @override
  Future<Offering?> getCurrentOffering() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current;
  }

  @override
  Future<void> purchasePackage(Package package) async {
    await Purchases.purchase(PurchaseParams.package(package));
  }

  @override
  Future<void> restorePurchases() async {
    await Purchases.restorePurchases();
  }
}

final premiumPurchaseGatewayProvider = Provider<PremiumPurchaseGateway>((ref) {
  return const RevenueCatPremiumPurchaseGateway();
});
