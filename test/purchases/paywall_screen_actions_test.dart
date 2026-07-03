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

ProviderContainer _makeContainer({
  required FakePremiumPurchaseGateway gateway,
  required PlayIntegrityDecisionLabel decision,
}) {
  final deviceIntegrity = decision == PlayIntegrityDecisionLabel.allow
      ? 'MEETS_DEVICE_INTEGRITY'
      : 'UNEVALUATED';

  return ProviderContainer(
    overrides: [
      premiumPurchaseGatewayProvider.overrideWithValue(gateway),
      playIntegrityServiceProvider.overrideWithValue(
        _FakeIntegrityService(
          PlayIntegritySnapshot(
            license: 'LICENSED',
            appIntegrity: 'PLAY_RECOGNIZED',
            deviceIntegrity: deviceIntegrity,
            virtualIntegrity: 'UNEVALUATED',
            recentDeviceActivity: 'UNEVALUATED',
            playProtect: 'NO_ISSUES',
            appAccessRisk: const <String>[],
            decision: decision,
          ),
        ),
      ),
    ],
  );
}

void main() {
  test('purchase proceeds on allow', () async {
    final gateway = FakePremiumPurchaseGateway();
    final container = _makeContainer(
      gateway: gateway,
      decision: PlayIntegrityDecisionLabel.allow,
    );

    addTearDown(container.dispose);

    await completePaywallPurchase(
      read: <T>(provider) => container.read(provider),
      package: _makePackage(),
      purchaseSource: 'source',
      defaultEntryPoint: 'entry',
      onSuccess: () {},
    );

    expect(gateway.purchasePackageCalls, 1);
  });

  test('restore blocked on soft gate', () async {
    final gateway = FakePremiumPurchaseGateway();
    final container = _makeContainer(
      gateway: gateway,
      decision: PlayIntegrityDecisionLabel.softGatePremium,
    );

    addTearDown(container.dispose);

    await expectLater(
      () => completePaywallRestore(
        read: <T>(provider) => container.read(provider),
        source: 'source',
        defaultEntryPoint: 'entry',
        onSuccess: () {},
      ),
      throwsA(isA<PlayIntegrityActionBlockedException>()),
    );

    expect(gateway.restorePurchasesCalls, 0);
  });

  test('purchase blocked on non-allow integrity decisions', () async {
    for (final decision in [
      PlayIntegrityDecisionLabel.softGatePremium,
      PlayIntegrityDecisionLabel.blockTampered,
      PlayIntegrityDecisionLabel.blockUnlicensed,
    ]) {
      final gateway = FakePremiumPurchaseGateway();
      final container = _makeContainer(gateway: gateway, decision: decision);

      addTearDown(container.dispose);

      await expectLater(
        () => completePaywallPurchase(
          read: <T>(provider) => container.read(provider),
          package: _makePackage(),
          purchaseSource: 'source',
          defaultEntryPoint: 'entry',
          onSuccess: () {},
        ),
        throwsA(isA<PlayIntegrityActionBlockedException>()),
      );

      expect(gateway.purchasePackageCalls, 0);
    }
  });

  test('restore proceeds on allow', () async {
    final gateway = FakePremiumPurchaseGateway();
    final container = _makeContainer(
      gateway: gateway,
      decision: PlayIntegrityDecisionLabel.allow,
    );

    addTearDown(container.dispose);

    await completePaywallRestore(
      read: <T>(provider) => container.read(provider),
      source: 'source',
      defaultEntryPoint: 'entry',
      onSuccess: () {},
    );

    expect(gateway.restorePurchasesCalls, 1);
  });
}

Package _makePackage() => Package(
  'monthly',
  PackageType.monthly,
  StoreProduct('sku', 'title', 'desc', 9.99, '9.99', 'USD'),
  PresentedOfferingContext('offering', null, null),
);
