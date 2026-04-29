import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';

class _FakeAnalytics implements AnalyticsService {
  String? lastName;
  Map<String, Object>? lastParams;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    lastName = name;
    lastParams = params;
  }
}

void main() {
  late _FakeAnalytics fake;

  setUp(() {
    fake = _FakeAnalytics();
    AppAnalytics.service = fake;
    AppAnalytics.resetGcodeImportTrackingForTests();
  });

  test(
    'calculationCreated delegates and encodes booleans as numbers',
    () async {
      await AppAnalytics.calculationCreated(
        materialCount: 3,
        hasFailureRisk: true,
        hasLabour: false,
        hasPricing: true,
      );

      expect(fake.lastName, 'calculation_created');
      expect(fake.lastParams, isNotNull);
      expect(fake.lastParams!['material_count'], 3);
      expect(fake.lastParams!['has_failure_risk'], 1);
      expect(fake.lastParams!['has_labour_cost'], 0);
      expect(fake.lastParams!['has_pricing'], 1);
    },
  );

  test('log sanitizes nested maps, iterables and omits nulls', () async {
    final nested = {'x': 1, 'y': true};
    final list = [1, false, 's'];

    await AppAnalytics.log(
      'complex_event',
      params: {'b': false, 'm': nested, 'l': list, 'n': null},
    );

    expect(fake.lastName, 'complex_event');
    final params = fake.lastParams!;

    // bool -> 0
    expect(params['b'], 0);

    // nested map should be JSON-encoded string with sanitized values
    expect(params['m'], isA<String>());
    final decodedMap =
        jsonDecode(params['m'] as String) as Map<String, dynamic>;
    expect(decodedMap['x'], 1);
    expect(decodedMap['y'], 1);

    // list should be JSON-encoded
    expect(params['l'], isA<String>());
    final decodedList = jsonDecode(params['l'] as String) as List<dynamic>;
    expect(decodedList[0], 1);
    expect(decodedList[1], 0);
    expect(decodedList[2], 's');

    // null key omitted
    expect(params.containsKey('n'), isFalse);
  });

  test('whats new analytics wrappers use expected names and params', () async {
    await AppAnalytics.whatsNewShown(
      wnId: 'wn_1',
      locale: 'en',
      isPremium: true,
    );

    expect(fake.lastName, 'whats_new_shown');
    expect(fake.lastParams, {'wn_id': 'wn_1', 'locale': 'en', 'is_premium': 1});

    await AppAnalytics.whatsNewDismissed(
      wnId: 'wn_2',
      locale: 'de',
      isPremium: false,
    );

    expect(fake.lastName, 'whats_new_dismissed');
    expect(fake.lastParams, {'wn_id': 'wn_2', 'locale': 'de', 'is_premium': 0});

    await AppAnalytics.whatsNewUnlockProTapped(wnId: 'wn_3', locale: 'fr');

    expect(fake.lastName, 'whats_new_unlock_pro_tapped');
    expect(fake.lastParams, {'wn_id': 'wn_3', 'locale': 'fr'});
  });

  test('gcode import analytics carry funnel context', () async {
    await AppAnalytics.gcodeImportOpened();
    expect(fake.lastName, 'gcode_import_opened');
    expect(fake.lastParams, {
      'slicer': 'unknown',
      'has_preview': 0,
      'parse_status': 'unknown',
      'file_size_bucket': 'unknown',
    });

    await AppAnalytics.gcodeFileSelected(
      fileSizeBytes: 512 * 1024,
      slicer: 'unknown',
      hasPreview: false,
    );
    expect(fake.lastName, 'gcode_file_selected');
    expect(fake.lastParams, {
      'slicer': 'unknown',
      'has_preview': 0,
      'parse_status': 'unknown',
      'file_size_bucket': '<1MB',
    });

    await AppAnalytics.gcodeParsePartial(
      slicer: 'prusaSlicer',
      hasPreview: true,
      fileSizeBytes: 2 * 1024 * 1024,
    );
    expect(fake.lastName, 'gcode_parse_partial');
    expect(fake.lastParams, {
      'slicer': 'prusaSlicer',
      'has_preview': 1,
      'parse_status': 'partial',
      'file_size_bucket': '1-5MB',
    });

    await AppAnalytics.gcodeApplyToCalculator(
      slicer: 'prusaSlicer',
      hasPreview: true,
      fileSizeBytes: 2 * 1024 * 1024,
      parseStatus: 'partial',
    );
    expect(fake.lastName, 'gcode_apply_to_calculator');
    expect(fake.lastParams!['gcode_time_to_value_ms'], isA<num>());

    await AppAnalytics.paywallViewed('subscriptions');
    expect(fake.lastName, 'paywall_viewed');
    expect(fake.lastParams!['entry_point'], 'gcode_import');

    await AppAnalytics.purchaseCompleted('subscriptions');
    expect(fake.lastName, 'purchase_completed');
    expect(fake.lastParams!['entry_point'], 'gcode_import');
  });

  test('paywall analytics default to manual entry point', () async {
    await AppAnalytics.paywallViewed('history');

    expect(fake.lastName, 'paywall_viewed');
    expect(fake.lastParams!['entry_point'], 'manual');
  });

  test('pricing analytics wrappers use expected param shapes', () async {
    await AppAnalytics.pricingSettingsChanged(
      markupPercent: 12.5,
      setupFee: 3,
      roundingMode: '.99',
    );
    expect(fake.lastName, 'pricing_settings_changed');
    expect(fake.lastParams, {
      'pricing_enabled': 1,
      'markup_percent': 12.5,
      'setup_fee': 3,
      'rounding_mode': '.99',
    });

    await AppAnalytics.pricingOverrideUsed(field: 'markup', hasOverrides: true);
    expect(fake.lastName, 'pricing_override_used');
    expect(fake.lastParams, {'field': 'markup', 'has_overrides': 1});

    await AppAnalytics.pricingSaved(
      hasPricing: true,
      usedOverrides: false,
      roundingMode: '.00',
    );
    expect(fake.lastName, 'pricing_saved');
    expect(fake.lastParams, {
      'has_pricing': 1,
      'used_overrides': 0,
      'rounding_mode': '.00',
    });

    await AppAnalytics.pricingRoundingUsed(roundingMode: 'none');
    expect(fake.lastName, 'pricing_rounding_used');
    expect(fake.lastParams, {'rounding_mode': 'none'});
  });
}
