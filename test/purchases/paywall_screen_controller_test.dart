import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_provider.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_actions.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_controller.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';

class _DelayedGateway implements PremiumPurchaseGateway {
  _DelayedGateway(this.offeringCompleter);

  Completer<Offering?> offeringCompleter;
  int getOfferingCalls = 0;
  int purchasePackageCalls = 0;
  int restorePurchasesCalls = 0;

  @override
  Future<Offering?> getOffering(String offeringId) async {
    getOfferingCalls += 1;
    return offeringCompleter.future;
  }

  @override
  Future<Offering?> getCurrentOffering() async => null;

  @override
  Future<void> purchasePackage(Package package) async {
    purchasePackageCalls += 1;
  }

  @override
  Future<void> restorePurchases() async {
    restorePurchasesCalls += 1;
  }
}

class _SequenceGateway implements PremiumPurchaseGateway {
  _SequenceGateway(this.offerings);

  final List<Offering?> offerings;
  int getOfferingCalls = 0;

  @override
  Future<Offering?> getOffering(String offeringId) async {
    getOfferingCalls += 1;
    if (offerings.isEmpty) return null;
    return offerings.removeAt(0);
  }

  @override
  Future<Offering?> getCurrentOffering() async => null;

  @override
  Future<void> purchasePackage(Package package) async {}

  @override
  Future<void> restorePurchases() async {}
}

class _BlockingGateway extends FakePremiumPurchaseGateway {
  _BlockingGateway({
    required this.purchaseCompleter,
    required this.restoreCompleter,
    super.currentOffering,
  });

  final Completer<void> purchaseCompleter;
  final Completer<void> restoreCompleter;

  @override
  Future<void> purchasePackage(Package package) async {
    purchasePackageCalls += 1;
    await purchaseCompleter.future;
  }

  @override
  Future<void> restorePurchases() async {
    restorePurchasesCalls += 1;
    await restoreCompleter.future;
  }
}

class _CountingLogger implements AppLogger {
  int purchaseWarnings = 0;
  int restoreWarnings = 0;

  @override
  void debug(
    AppLogCategory category,
    String message, {
    Map<String, Object?> context = const {},
  }) {}

  @override
  void error(
    AppLogCategory category,
    String message, {
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void info(
    AppLogCategory category,
    String message, {
    Map<String, Object?> context = const {},
  }) {}

  @override
  void warn(
    AppLogCategory category,
    String message, {
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (message == 'Purchase failed') purchaseWarnings += 1;
    if (message == 'Restore failed') restoreWarnings += 1;
  }
}

class _AllowIntegrityService implements PlayIntegrityService {
  @override
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow) async {
    return const PlayIntegritySnapshot(
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'UNEVALUATED',
      recentDeviceActivity: 'UNEVALUATED',
      playProtect: 'NO_ISSUES',
      appAccessRisk: <String>[],
      decision: PlayIntegrityDecisionLabel.allow,
    );
  }
}

void main() {
  setUp(() async => setupTest());

  ProviderContainer makeContainer({
    required PremiumPurchaseGateway gateway,
    PlayIntegrityService? integrity,
    AppLogger? logger,
  }) {
    return ProviderContainer(
      overrides: [
        premiumPurchaseGatewayProvider.overrideWithValue(gateway),
        playIntegrityServiceProvider.overrideWithValue(
          integrity ?? _AllowIntegrityService(),
        ),
        if (logger != null) appLoggerProvider.overrideWithValue(logger),
      ],
    );
  }

  test('delayed load ignores stale retry result', () async {
    final first = Completer<Offering?>();
    final second = Completer<Offering?>();
    final gateway = _DelayedGateway(first);
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);

    final args = PaywallScreenControllerArgs(
      offerId: 'pro',
      purchaseSource: 'source',
      defaultEntryPoint: 'entry',
      source: 'src',
    );
    final listener = container.listen(
      paywallScreenControllerProvider(args),
      (_, _) {},
    );
    addTearDown(listener.close);

    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(paywallScreenControllerProvider(args)).loadingOfferings,
      true,
    );

    gateway.offeringCompleter = second;
    final retry = container
        .read(paywallScreenControllerProvider(args).notifier)
        .retryOfferings();
    await Future<void>.delayed(Duration.zero);
    first.complete(Offering('old', 'Old', {}, []));
    second.complete(Offering('new', 'New', {}, [_pkg()]));
    await retry;

    await Future<void>.delayed(Duration.zero);
    final state = container.read(paywallScreenControllerProvider(args));
    expect(state.offering?.identifier, 'new');
    expect(state.selectedPackage?.identifier, 'monthly');
  });

  test('selected preferred package from loaded offering', () async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('pro', 'Pro', {}, [
        _pkgAnnual(),
        _pkgMonthly(),
      ]),
    );
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final state = container.read(paywallScreenControllerProvider(args));
    expect(state.selectedPackage?.packageType, PackageType.annual);
  });

  test('unavailable load retry sets typed error', () async {
    final gateway = _NullOfferingGateway();
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final state = container.read(paywallScreenControllerProvider(args));
    expect(state.offeringsError, PaywallOfferingsLoadError.unavailable);
  });

  test('purchase returns ignored with no selection', () async {
    final gateway = FakePremiumPurchaseGateway();
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    final controller = container.read(
      paywallScreenControllerProvider(args).notifier,
    );

    expect(await controller.purchase(), isA<PaywallActionIgnored>());
    expect(gateway.purchasePackageCalls, 0);
  });

  test('busy rejects second purchase and restore', () async {
    final purchaseCompleter = Completer<void>();
    final restoreCompleter = Completer<void>();
    final gateway = _BlockingGateway(
      currentOffering: Offering('pro', 'Pro', {}, [_pkg()]),
      purchaseCompleter: purchaseCompleter,
      restoreCompleter: restoreCompleter,
    );
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    final controller = container.read(
      paywallScreenControllerProvider(args).notifier,
    );
    controller.selectPackage(_pkg());

    final firstPurchase = controller.purchase();
    expect(await controller.purchase(), isA<PaywallActionIgnored>());
    expect(await controller.restore(), isA<PaywallActionIgnored>());
    purchaseCompleter.complete();
    await firstPurchase;

    final firstRestore = controller.restore();
    expect(await controller.purchase(), isA<PaywallActionIgnored>());
    expect(await controller.restore(), isA<PaywallActionIgnored>());
    restoreCompleter.complete();
    await firstRestore;
  });

  test('retry loads after unavailable and updates state', () async {
    final gateway = _SequenceGateway([
      null,
      Offering('pro', 'Pro', {}, [_pkgAnnual(), _pkgMonthly()]),
    ]);
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    await Future<void>.delayed(Duration.zero);

    var state = container.read(paywallScreenControllerProvider(args));
    expect(state.offeringsError, PaywallOfferingsLoadError.unavailable);
    expect(gateway.getOfferingCalls, 1);

    await container
        .read(paywallScreenControllerProvider(args).notifier)
        .retryOfferings();
    state = container.read(paywallScreenControllerProvider(args));
    expect(gateway.getOfferingCalls, 2);
    expect(state.offeringsError, isNull);
    expect(state.offering?.identifier, 'pro');
    expect(state.selectedPackage?.packageType, PackageType.annual);
  });

  test('purchase and restore typed outcomes', () async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('pro', 'Pro', {}, [_pkg()]),
    );
    final container = makeContainer(gateway: gateway);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 1));
    final controller = container.read(
      paywallScreenControllerProvider(args).notifier,
    );
    controller.selectPackage(_pkg());

    expect(await controller.purchase(), isA<PaywallActionSuccess>());
    expect(gateway.purchasePackageCalls, 1);

    expect(await controller.restore(), isA<PaywallActionSuccess>());
    expect(gateway.restorePurchasesCalls, 1);
  });

  test('restore generic failure logs once', () async {
    final gateway = FakePremiumPurchaseGateway(shouldThrowOnRestore: true);
    final logger = _CountingLogger();
    final container = makeContainer(gateway: gateway, logger: logger);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final controller = container.read(
      paywallScreenControllerProvider(args).notifier,
    );
    expect(await controller.restore(), isA<PaywallActionFailure>());
    expect(logger.restoreWarnings, 1);
  });

  test('purchase generic failure logs once', () async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('pro', 'Pro', {}, [_pkg()]),
      shouldThrowOnPurchase: true,
    );
    final logger = _CountingLogger();
    final container = makeContainer(gateway: gateway, logger: logger);
    addTearDown(container.dispose);
    final args = _controllerArgs;
    container.listen(paywallScreenControllerProvider(args), (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final controller = container.read(
      paywallScreenControllerProvider(args).notifier,
    );
    controller.selectPackage(_pkg());

    expect(await controller.purchase(), isA<PaywallActionFailure>());
    expect(logger.purchaseWarnings, 1);
  });

  test('dispose blocks stale async write', () async {
    final gate = Completer<Offering?>();
    final gateway = _DelayedGateway(gate);
    final container = makeContainer(gateway: gateway);
    final args = _controllerArgs;
    final sub = container.listen(
      paywallScreenControllerProvider(args),
      (_, _) {},
    );
    await Future<void>.delayed(Duration.zero);
    container.dispose();
    sub.close();
    gate.complete(Offering('pro', 'Pro', {}, [_pkg()]));
    await Future<void>.delayed(Duration.zero);
  });
}

Package _pkg() => Package(
  'monthly',
  PackageType.monthly,
  StoreProduct('sku', 'title', 'desc', 9.99, '9.99', 'USD'),
  PresentedOfferingContext('pro', null, null),
);

Package _pkgAnnual() => Package(
  'annual',
  PackageType.annual,
  StoreProduct('sku2', 'title2', 'desc', 9.99, '9.99', 'USD'),
  PresentedOfferingContext('pro', null, null),
);

Package _pkgMonthly() => Package(
  'monthly2',
  PackageType.monthly,
  StoreProduct('sku3', 'title3', 'desc', 9.99, '9.99', 'USD'),
  PresentedOfferingContext('pro', null, null),
);

class _NullOfferingGateway implements PremiumPurchaseGateway {
  int getOfferingCalls = 0;

  @override
  Future<Offering?> getOffering(String offeringId) async {
    getOfferingCalls += 1;
    return null;
  }

  @override
  Future<Offering?> getCurrentOffering() async => null;

  @override
  Future<void> purchasePackage(Package package) async {}

  @override
  Future<void> restorePurchases() async {}
}

const _controllerArgs = PaywallScreenControllerArgs(
  offerId: 'pro',
  purchaseSource: 'source',
  defaultEntryPoint: 'entry',
  source: 'src',
);
