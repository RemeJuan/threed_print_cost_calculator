// ignore_for_file: experimental_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/shared/ads/revenuecat_ad_revenue_tracker.dart';

void main() {
  group('trackAdMobBannerRevenue', () {
    test('maps AdMob paid event into RevenueCat revenue payload', () async {
      AdRevenueData? trackedData;

      await trackAdMobBannerRevenue(
        adUnitId: 'banner-unit',
        valueMicros: 1234567,
        precisionType: PrecisionType.precise,
        currencyCode: 'USD',
        impressionId: 'imp-123',
        networkName: 'AdMob Network',
        placement: kCalculatorBannerAdPlacement,
        reporter: (data) async => trackedData = data,
      );

      expect(trackedData, isNotNull);
      expect(trackedData!.mediatorName, AdMediatorName.adMob);
      expect(trackedData!.adFormat, AdFormat.banner);
      expect(trackedData!.adUnitId, 'banner-unit');
      expect(trackedData!.impressionId, 'imp-123');
      expect(trackedData!.revenueMicros, 1234567);
      expect(trackedData!.currency, 'USD');
      expect(trackedData!.precision, AdRevenuePrecision.exact);
      expect(trackedData!.networkName, 'AdMob Network');
      expect(trackedData!.placement, kCalculatorBannerAdPlacement);
    });

    test('maps publisher provided precision', () async {
      AdRevenueData? trackedData;

      await trackAdMobBannerRevenue(
        adUnitId: 'banner-unit',
        valueMicros: 1000,
        precisionType: PrecisionType.publisherProvided,
        currencyCode: 'EUR',
        impressionId: 'imp-precision',
        networkName: null,
        reporter: (data) async => trackedData = data,
      );

      expect(trackedData, isNotNull);
      expect(trackedData!.precision, AdRevenuePrecision.publisherDefined);
      expect(trackedData!.networkName, isNull);
    });

    test('skips tracking when impression id missing', () async {
      var called = false;

      await trackAdMobBannerRevenue(
        adUnitId: 'banner-unit',
        valueMicros: 1000,
        precisionType: PrecisionType.estimated,
        currencyCode: 'GBP',
        impressionId: ' ',
        networkName: 'AdMob',
        reporter: (data) async => called = true,
      );

      expect(called, isFalse);
    });

    test('skips tracking when value non-positive', () async {
      var called = false;

      await trackAdMobBannerRevenue(
        adUnitId: 'banner-unit',
        valueMicros: 0,
        precisionType: PrecisionType.unknown,
        currencyCode: 'USD',
        impressionId: 'imp-zero',
        networkName: 'AdMob',
        reporter: (data) async => called = true,
      );

      expect(called, isFalse);
    });
  });
}
