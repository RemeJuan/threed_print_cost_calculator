import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';

class PaywallOfferingsLoadResult {
  const PaywallOfferingsLoadResult({
    required this.offering,
    required this.error,
  });

  final Offering? offering;
  final String? error;
}

Future<PaywallOfferingsLoadResult> loadPaywallOfferings({
  required WidgetRef ref,
  required String offeringId,
}) async {
  try {
    final gateway = ref.read(premiumPurchaseGatewayProvider);
    final offering = await gateway.getOffering(offeringId);
    return PaywallOfferingsLoadResult(offering: offering, error: null);
  } catch (e) {
    return PaywallOfferingsLoadResult(offering: null, error: e.toString());
  }
}

Future<void> completePaywallPurchase({
  required WidgetRef ref,
  required Package package,
  required String purchaseSource,
  required String defaultEntryPoint,
  required VoidCallback onSuccess,
}) async {
  final gateway = ref.read(premiumPurchaseGatewayProvider);
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
  required WidgetRef ref,
  required String source,
  required String defaultEntryPoint,
  required VoidCallback onSuccess,
}) async {
  final gateway = ref.read(premiumPurchaseGatewayProvider);
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
  required WidgetRef ref,
  required Object error,
  required StackTrace stackTrace,
}) {
  ref
      .read(appLoggerProvider)
      .warn(
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
