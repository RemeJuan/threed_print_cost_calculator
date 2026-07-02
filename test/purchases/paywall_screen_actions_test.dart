import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_provider.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_actions.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';
import '../helpers/lower_level_test_fakes.dart';

class _FakeIntegrityService implements PlayIntegrityService {
  _FakeIntegrityService(this.snapshot);
  final PlayIntegritySnapshot snapshot;

  @override
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow) async =>
      snapshot;
}

void main() {
  test('purchase proceeds on allow', () async {
    final gateway = FakePremiumPurchaseGateway();
    final container = ProviderContainer(
      overrides: [
        premiumPurchaseGatewayProvider.overrideWithValue(gateway),
        playIntegrityServiceProvider.overrideWithValue(
          _FakeIntegrityService(
            const PlayIntegritySnapshot(
              license: 'LICENSED',
              appIntegrity: 'PLAY_RECOGNIZED',
              deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
              virtualIntegrity: 'UNEVALUATED',
              recentDeviceActivity: 'UNEVALUATED',
              playProtect: 'NO_ISSUES',
              appAccessRisk: <String>[],
              decision: PlayIntegrityDecisionLabel.allow,
            ),
          ),
        ),
      ],
    );

    addTearDown(container.dispose);

    await completePaywallPurchase(
      read: (provider) => container.read(provider),
      package: _makePackage(),
      purchaseSource: 'source',
      defaultEntryPoint: 'entry',
      onSuccess: () {},
    );

    expect(gateway.purchasePackageCalls, 1);
  });

  test('restore blocked on soft gate', () async {
    final gateway = FakePremiumPurchaseGateway();
    final container = ProviderContainer(
      overrides: [
        premiumPurchaseGatewayProvider.overrideWithValue(gateway),
        playIntegrityServiceProvider.overrideWithValue(
          _FakeIntegrityService(
            const PlayIntegritySnapshot(
              license: 'LICENSED',
              appIntegrity: 'PLAY_RECOGNIZED',
              deviceIntegrity: 'UNEVALUATED',
              virtualIntegrity: 'UNEVALUATED',
              recentDeviceActivity: 'UNEVALUATED',
              playProtect: 'NO_ISSUES',
              appAccessRisk: <String>[],
              decision: PlayIntegrityDecisionLabel.softGatePremium,
            ),
          ),
        ),
      ],
    );

    addTearDown(container.dispose);

    await expectLater(
      () => completePaywallRestore(
        read: (provider) => container.read(provider),
        source: 'source',
        defaultEntryPoint: 'entry',
        onSuccess: () {},
      ),
      throwsA(isA<PlayIntegrityActionBlockedException>()),
    );

    expect(gateway.restorePurchasesCalls, 0);
  });
}

Package _makePackage() => Package(
  'monthly',
  PackageType.monthly,
  StoreProduct('sku', 'title', 'desc', 9.99, '9.99', 'USD'),
  PresentedOfferingContext('offering', null, null),
);
