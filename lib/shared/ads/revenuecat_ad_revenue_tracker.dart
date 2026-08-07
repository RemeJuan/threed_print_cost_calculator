// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

typedef RevenueCatAdRevenueReporter = Future<void> Function(AdRevenueData data);

const kCalculatorBannerAdPlacement = 'calculator_banner';

Future<void> trackAdMobBannerRevenue({
  required String adUnitId,
  required double valueMicros,
  required PrecisionType precisionType,
  required String currencyCode,
  required String? impressionId,
  required String? networkName,
  String? placement,
  RevenueCatAdRevenueReporter? reporter,
}) async {
  if (!valueMicros.isFinite || valueMicros <= 0) return;

  final normalizedImpressionId = impressionId?.trim();
  if (normalizedImpressionId == null || normalizedImpressionId.isEmpty) return;

  final normalizedCurrencyCode = currencyCode.trim();
  if (normalizedCurrencyCode.isEmpty) return;

  try {
    await (reporter ?? Purchases.adTracker.trackAdRevenue)(
      AdRevenueData(
        networkName: _normalizedOrNull(networkName),
        mediatorName: AdMediatorName.adMob,
        adFormat: AdFormat.banner,
        placement: _normalizedOrNull(placement),
        adUnitId: adUnitId,
        impressionId: normalizedImpressionId,
        revenueMicros: valueMicros.round(),
        currency: normalizedCurrencyCode,
        precision: _mapPrecisionType(precisionType),
      ),
    );
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'revenuecat_ad_monetization',
        context: ErrorDescription('while tracking AdMob banner revenue'),
      ),
    );
  }
}

String? _normalizedOrNull(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

AdRevenuePrecision _mapPrecisionType(PrecisionType precisionType) {
  switch (precisionType) {
    case PrecisionType.precise:
      return AdRevenuePrecision.exact;
    case PrecisionType.estimated:
      return AdRevenuePrecision.estimated;
    case PrecisionType.publisherProvided:
      return AdRevenuePrecision.publisherDefined;
    case PrecisionType.unknown:
      return AdRevenuePrecision.unknown;
  }
}
