import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_plan_selector.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen_actions.dart';

class PaywallScreenControllerArgs {
  const PaywallScreenControllerArgs({
    required this.offerId,
    required this.purchaseSource,
    required this.defaultEntryPoint,
    required this.source,
  });

  final String offerId;
  final String purchaseSource;
  final String defaultEntryPoint;
  final String source;

  @override
  bool operator ==(Object other) =>
      other is PaywallScreenControllerArgs &&
      other.offerId == offerId &&
      other.purchaseSource == purchaseSource &&
      other.defaultEntryPoint == defaultEntryPoint &&
      other.source == source;

  @override
  int get hashCode =>
      Object.hash(offerId, purchaseSource, defaultEntryPoint, source);
}

class PaywallScreenState {
  const PaywallScreenState({
    required this.loadingOfferings,
    required this.purchasing,
    required this.offering,
    required this.selectedPackage,
    required this.offeringsError,
  });

  const PaywallScreenState.initial()
    : loadingOfferings = true,
      purchasing = false,
      offering = null,
      selectedPackage = null,
      offeringsError = null;

  final bool loadingOfferings;
  final bool purchasing;
  final Offering? offering;
  final Package? selectedPackage;
  final PaywallOfferingsLoadError? offeringsError;

  PaywallScreenState copyWith({
    bool? loadingOfferings,
    bool? purchasing,
    Object? offering = _unset,
    Object? selectedPackage = _unset,
    Object? offeringsError = _unset,
  }) {
    return PaywallScreenState(
      loadingOfferings: loadingOfferings ?? this.loadingOfferings,
      purchasing: purchasing ?? this.purchasing,
      offering: offering == _unset ? this.offering : offering as Offering?,
      selectedPackage: selectedPackage == _unset
          ? this.selectedPackage
          : selectedPackage as Package?,
      offeringsError: offeringsError == _unset
          ? this.offeringsError
          : offeringsError as PaywallOfferingsLoadError?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PaywallScreenState &&
      other.loadingOfferings == loadingOfferings &&
      other.purchasing == purchasing &&
      other.offering == offering &&
      other.selectedPackage == selectedPackage &&
      other.offeringsError == offeringsError;

  @override
  int get hashCode => Object.hash(
    loadingOfferings,
    purchasing,
    offering,
    selectedPackage,
    offeringsError,
  );
}

const _unset = Object();

final paywallScreenControllerProvider = NotifierProvider.autoDispose
    .family<
      PaywallScreenController,
      PaywallScreenState,
      PaywallScreenControllerArgs
    >(PaywallScreenController.new);

class PaywallScreenController extends Notifier<PaywallScreenState> {
  PaywallScreenController(this.arg);

  final PaywallScreenControllerArgs arg;
  int _generation = 0;

  @override
  PaywallScreenState build() {
    ref.onDispose(() {
      _generation += 1;
    });
    unawaited(Future<void>.microtask(_loadOfferings));
    return const PaywallScreenState.initial();
  }

  Future<void> retryOfferings() => _loadOfferings();

  void selectPackage(Package pkg) {
    state = state.copyWith(selectedPackage: pkg);
  }

  Future<PaywallActionOutcome> purchase() async {
    if (state.purchasing || state.selectedPackage == null) {
      return const PaywallActionIgnored();
    }
    final release = ref.keepAlive();
    state = state.copyWith(purchasing: true);
    try {
      await completePaywallPurchase(
        read: ref.read,
        package: state.selectedPackage!,
        purchaseSource: arg.purchaseSource,
        defaultEntryPoint: arg.defaultEntryPoint,
      );
      return const PaywallActionSuccess();
    } on PlayIntegrityActionBlockedException {
      return const PaywallActionIntegrityBlocked();
    } catch (error, st) {
      logPaywallPurchaseFailure(read: ref.read, error: error, stackTrace: st);
      return const PaywallActionFailure.purchase();
    } finally {
      if (ref.mounted) {
        state = state.copyWith(purchasing: false);
      }
      release.close();
    }
  }

  Future<PaywallActionOutcome> restore() async {
    if (state.purchasing) return const PaywallActionIgnored();
    final release = ref.keepAlive();
    state = state.copyWith(purchasing: true);
    try {
      await completePaywallRestore(
        read: ref.read,
        source: arg.source,
        defaultEntryPoint: arg.defaultEntryPoint,
      );
      return const PaywallActionSuccess();
    } on PlayIntegrityActionBlockedException {
      return const PaywallActionIntegrityBlocked();
    } catch (error, st) {
      logPaywallRestoreFailure(read: ref.read, error: error, stackTrace: st);
      return const PaywallActionFailure.restore();
    } finally {
      if (ref.mounted) {
        state = state.copyWith(purchasing: false);
      }
      release.close();
    }
  }

  Future<void> _loadOfferings() async {
    final generation = ++_generation;
    final release = ref.keepAlive();
    state = state.copyWith(loadingOfferings: true, offeringsError: null);
    try {
      final result = await loadPaywallOfferings(
        read: ref.read,
        offeringId: arg.offerId,
      );
      if (generation != _generation) return;
      if (!ref.mounted) return;
      state = state.copyWith(
        loadingOfferings: false,
        offering: result.offering,
        selectedPackage: preferredPackage(result.offering?.availablePackages),
        offeringsError: result.error,
      );
    } finally {
      release.close();
      if (generation == _generation && ref.mounted) {
        state = state.copyWith(loadingOfferings: false);
      }
    }
  }
}

sealed class PaywallActionOutcome {
  const PaywallActionOutcome();
}

class PaywallActionSuccess extends PaywallActionOutcome {
  const PaywallActionSuccess();
}

class PaywallActionIntegrityBlocked extends PaywallActionOutcome {
  const PaywallActionIntegrityBlocked();
}

class PaywallActionFailure extends PaywallActionOutcome {
  const PaywallActionFailure.purchase() : isRestore = false;

  const PaywallActionFailure.restore() : isRestore = true;

  final bool isRestore;
}

class PaywallActionIgnored extends PaywallActionOutcome {
  const PaywallActionIgnored();
}
