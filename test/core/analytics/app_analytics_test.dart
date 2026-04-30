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
      );

      expect(fake.lastName, 'calculation_created');
      expect(fake.lastParams, isNotNull);
      expect(fake.lastParams!['material_count'], 3);
      expect(fake.lastParams!['has_failure_risk'], 1);
      expect(fake.lastParams!['has_labour_cost'], 0);
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

    await AppAnalytics.whatsNewUnlockProTapped(
      wnId: 'wn_3',
      locale: 'fr',
      source: 'whats_new',
    );

    expect(fake.lastName, 'whats_new_unlock_pro_tapped');
    expect(fake.lastParams, {
      'wn_id': 'wn_3',
      'locale': 'fr',
      'source': 'whats_new',
    });
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

    await AppAnalytics.gcodeImportStarted(source: 'calculator');
    expect(fake.lastName, 'gcode_import_started');
    expect(fake.lastParams, {
      'slicer': 'unknown',
      'has_preview': 0,
      'parse_status': 'unknown',
      'file_size_bucket': 'unknown',
      'source': 'calculator',
    });

    await AppAnalytics.gcodeFileSelected(fileType: 'gcode');
    expect(fake.lastName, 'gcode_file_selected');
    expect(fake.lastParams, {'file_type': 'gcode'});

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

    await AppAnalytics.gcodeImportSuccess(
      hasPrintTime: true,
      hasFilamentUsage: true,
      hasPreview: true,
    );
    expect(fake.lastName, 'gcode_import_success');
    expect(fake.lastParams, {
      'has_print_time': 1,
      'has_filament_usage': 1,
      'has_preview': 1,
    });

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

  test('premium feature tapped keeps optional source', () async {
    await AppAnalytics.premiumFeatureTapped(
      'history',
      isPro: false,
      source: 'history_teaser_primary',
    );

    expect(fake.lastName, 'premium_feature_tapped');
    expect(fake.lastParams, {
      'feature': 'history',
      'is_pro': 0,
      'source': 'history_teaser_primary',
    });
  });
}
