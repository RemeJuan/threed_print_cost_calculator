import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_decision.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_provider.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';

typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

class PlayIntegrityActionBlockedException implements Exception {
  const PlayIntegrityActionBlockedException();
}

class PaywallOfferingsLoadResult {
  const PaywallOfferingsLoadResult({
    required this.offering,
    required this.error,
  });

  final Offering? offering;
  final PaywallOfferingsLoadError? error;
}

enum PaywallOfferingsLoadError {
  unavailable,
}

Future<PaywallOfferingsLoadResult> loadPaywallOfferings({
  required ProviderReader read,
  required String offeringId,
}) async {
  try {
    final gateway = read(premiumPurchaseGatewayProvider);
    final offering = await gateway.getOffering(offeringId);
    if (offering == null) {
      return const PaywallOfferingsLoadResult(
        offering: null,
        error: PaywallOfferingsLoadError.unavailable,
      );
    }
    return PaywallOfferingsLoadResult(offering: offering, error: null);
  } catch (e, st) {
    logPaywallOfferingsLoadFailure(
      read: read,
      error: e,
      stackTrace: st,
    );
    return const PaywallOfferingsLoadResult(
      offering: null,
      error: PaywallOfferingsLoadError.unavailable,
    );
  }
}

void logPaywallOfferingsLoadFailure({
  required ProviderReader read,
  required Object error,
  required StackTrace stackTrace,
}) {
  read(appLoggerProvider).warn(
    AppLogCategory.billing,
    'Paywall offerings load failed',
    error: error,
    stackTrace: stackTrace,
  );
}

Future<void> completePaywallPurchase({
  required ProviderReader read,
  required Package package,
  required String purchaseSource,
  required String defaultEntryPoint,
  required VoidCallback onSuccess,
}) async {
  await _ensurePlayIntegrityAllowed(
    read: read,
    flow: PlayIntegrityFlow.purchase,
  );
  final gateway = read(premiumPurchaseGatewayProvider);
  await gateway.purchasePackage(package);
  AppAnalytics.safeLog(
    () => AppAnalytics.purchaseCompleted(
      purchaseSource,
      defaultEntryPoint: defaultEntryPoint,
    ),
  );
  onSuccess();
}

Future<void> completePaywallRestore({
  required ProviderReader read,
  required String source,
  required String defaultEntryPoint,
  required VoidCallback onSuccess,
}) async {
  await _ensurePlayIntegrityAllowed(
    read: read,
    flow: PlayIntegrityFlow.restore,
  );
  final gateway = read(premiumPurchaseGatewayProvider);
  await gateway.restorePurchases();
  AppAnalytics.safeLog(
    () => AppAnalytics.restoreCompleted(
      source: source,
      defaultEntryPoint: defaultEntryPoint,
    ),
  );
  onSuccess();
}

void logPaywallRestoreFailure({
  required ProviderReader read,
  required Object error,
  required StackTrace stackTrace,
}) {
  read(appLoggerProvider).warn(
    AppLogCategory.billing,
    'Restore failed',
    error: error,
    stackTrace: stackTrace,
  );
}

void showPaywallPurchaseError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.purchaseError)),
  );
}

void showPaywallRestoreError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.paywallRestoreError)),
  );
}

Future<void> _ensurePlayIntegrityAllowed({
  required ProviderReader read,
  required PlayIntegrityFlow flow,
}) async {
  final integrity = await read(playIntegrityServiceProvider).evaluate(flow);
  if (isPlayIntegrityHardBlocked(integrity) ||
      isPlayIntegritySoftGated(integrity)) {
    throw const PlayIntegrityActionBlockedException();
  }
}

void showPlayIntegrityActionBlocked(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context)!.playIntegrityActionBlocked),
    ),
  );
}
