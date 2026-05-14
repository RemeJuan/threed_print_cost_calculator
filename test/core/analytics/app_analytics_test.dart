import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';

class MockAnalytics extends Mock implements AnalyticsService {}

class _AnalyticsEvent {
  final String name;
  final Map<String, Object>? params;

  _AnalyticsEvent(this.name, this.params);
}

class _FakeAnalytics implements AnalyticsService {
  final List<_AnalyticsEvent> events = [];

  String get lastName => events.last.name;

  Map<String, Object>? get lastParams => events.last.params;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(_AnalyticsEvent(name, params));
  }
}

void main() {
  late MockAnalytics mock;

  setUp(() {
    mock = MockAnalytics();
    AppAnalytics.service = mock;
    AppAnalytics.resetGcodeImportTrackingForTests();
    registerFallbackValue('test_event');
    registerFallbackValue(<String, Object>{});
  });

  test(
    'calculationCreated delegates and encodes booleans as numbers',
    () async {
      when(
        () => mock.logEvent(
          'calculation_created',
          params: any(named: 'params'),
        ),
      ).thenAnswer((_) async {});

      await AppAnalytics.calculationCreated(
        materialCount: 3,
        hasFailureRisk: true,
        hasLabour: false,
        hasPricing: true,
      );

      verify(
        () => mock.logEvent(
          'calculation_created',
          params: {
            'material_count': 3,
            'has_failure_risk': 1,
            'has_labour': 0,
            'has_pricing': 1,
          },
        ),
      ).called(1);
    },
  );

  test('log sanitizes nested maps, iterables and omits nulls', () async {
    when(
      () => mock.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    final nested = {'x': 1, 'y': true};
    final list = [1, false, 's'];

    await AppAnalytics.log(
      'complex_event',
      params: {'b': false, 'm': nested, 'l': list, 'n': null},
    );

    final captured = verify(
      () => mock.logEvent(
        'complex_event',
        params: captureAny(named: 'params'),
      ),
    ).captured.single as Map<String, Object?>;

    expect(captured['b'], 0);

    expect(captured['m'], isA<String>());
    final decodedMap =
        jsonDecode(captured['m'] as String) as Map<String, dynamic>;
    expect(decodedMap['x'], 1);
    expect(decodedMap['y'], 1);

    expect(captured['l'], isA<String>());
    final decodedList = jsonDecode(captured['l'] as String) as List<dynamic>;
    expect(decodedList[0], 1);
    expect(decodedList[1], 0);
    expect(decodedList[2], 's');

    expect(captured.containsKey('n'), isFalse);
  });

  test('whats new analytics wrappers use expected names and params', () async {
    when(
      () => mock.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    await AppAnalytics.whatsNewShown(
      wnId: 'wn_1',
      locale: 'en',
      isPremium: true,
    );
    verify(
      () => mock.logEvent(
        'whats_new_shown',
        params: {'wn_id': 'wn_1', 'locale': 'en', 'is_premium': 1},
      ),
    ).called(1);

    await AppAnalytics.whatsNewDismissed(
      wnId: 'wn_2',
      locale: 'de',
      isPremium: false,
    );
    verify(
      () => mock.logEvent(
        'whats_new_dismissed',
        params: {'wn_id': 'wn_2', 'locale': 'de', 'is_premium': 0},
      ),
    ).called(1);

    await AppAnalytics.whatsNewUnlockProTapped(
      wnId: 'wn_3',
      locale: 'fr',
      source: 'whats_new',
    );
    verify(
      () => mock.logEvent(
        'whats_new_unlock_pro_tapped',
        params: {'wn_id': 'wn_3', 'locale': 'fr', 'source': 'whats_new'},
      ),
    ).called(1);
  });

  test('cancel feedback analytics wrappers use expected payloads', () async {
    final fake = _FakeAnalytics();
    AppAnalytics.service = fake;

    await AppAnalytics.trialCancelFeedbackSubmitted(
      reason: 'too_expensive',
      platform: 'play_store',
      appVersion: '1.2.3+42',
      daysIntoTrial: 3,
      entitlementType: 'trial',
      calculationCountBucket: '2_4',
      hasUsedGcodeImport: true,
      hasSavedHistory: false,
    );

    expect(fake.events.last.name, 'trial_cancel_feedback_submitted');
    expect(fake.events.last.params, {
      'reason': 'too_expensive',
      'platform': 'play_store',
      'app_version': '1.2.3+42',
      'days_into_trial': 3,
      'entitlement_type': 'trial',
      'calculation_count_bucket': '2_4',
      'has_used_gcode_import': 1,
      'has_saved_history': 0,
    });

    await AppAnalytics.trialCancelFeedbackDismissed(
      platform: 'play_store',
      appVersion: '1.2.3+42',
      daysIntoTrial: 3,
      entitlementType: 'trial',
      calculationCountBucket: '2_4',
      hasUsedGcodeImport: false,
      hasSavedHistory: true,
    );

    expect(fake.events.last.name, 'trial_cancel_feedback_dismissed');
    expect(fake.events.last.params, {
      'platform': 'play_store',
      'app_version': '1.2.3+42',
      'days_into_trial': 3,
      'entitlement_type': 'trial',
      'calculation_count_bucket': '2_4',
      'has_used_gcode_import': 0,
      'has_saved_history': 1,
    });
  });

  test('gcode import analytics carry funnel context', () async {
    when(
      () => mock.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    await AppAnalytics.gcodeImportOpened();
    verify(
      () => mock.logEvent(
        'gcode_import_opened',
        params: {
          'slicer': 'unknown',
          'has_preview': 0,
          'parse_status': 'unknown',
          'file_size_bucket': 'unknown',
        },
      ),
    ).called(1);

    await AppAnalytics.gcodeImportStarted(source: 'calculator');
    verify(
      () => mock.logEvent(
        'gcode_import_started',
        params: {
          'slicer': 'unknown',
          'has_preview': 0,
          'parse_status': 'unknown',
          'file_size_bucket': 'unknown',
          'source': 'calculator',
        },
      ),
    ).called(1);

    await AppAnalytics.gcodeFileSelected(fileType: 'gcode');
    verify(
      () => mock.logEvent(
        'gcode_file_selected',
        params: {'file_type': 'gcode'},
      ),
    ).called(1);

    await AppAnalytics.gcodeParseFailed(
      slicer: 'unknown',
      hasPreview: false,
      fileSizeBytes: 10 * 1024 * 1024,
      failureReason: GCodeFailureReason.fileTooLarge,
    );
    verify(
      () => mock.logEvent(
        'gcode_parse_failed',
        params: {
          'slicer': 'unknown',
          'has_preview': 0,
          'parse_status': 'failed',
          'file_size_bucket': '5-20MB',
          'failure_reason': 'file_too_large',
        },
      ),
    ).called(1);

    await AppAnalytics.gcodeParseFailed(
      slicer: 'unknown',
      hasPreview: false,
      fileSizeBytes: 0,
      failureReason: GCodeFailureReason.unsupportedContent,
    );
    verify(
      () => mock.logEvent(
        'gcode_parse_failed',
        params: {
          'slicer': 'unknown',
          'has_preview': 0,
          'parse_status': 'failed',
          'file_size_bucket': '<1MB',
          'failure_reason': 'unsupported_content',
        },
      ),
    ).called(1);

    await AppAnalytics.gcodeParsePartial(
      slicer: 'prusaSlicer',
      hasPreview: true,
      fileSizeBytes: 2 * 1024 * 1024,
    );
    verify(
      () => mock.logEvent(
        'gcode_parse_partial',
        params: {
          'slicer': 'prusaSlicer',
          'has_preview': 1,
          'parse_status': 'partial',
          'file_size_bucket': '1-5MB',
        },
      ),
    ).called(1);

    await AppAnalytics.gcodeApplyToCalculator(
      slicer: 'prusaSlicer',
      hasPreview: true,
      fileSizeBytes: 2 * 1024 * 1024,
      parseStatus: 'partial',
    );
    final captured = verify(
      () => mock.logEvent(
        'gcode_apply_to_calculator',
        params: captureAny(named: 'params'),
      ),
    ).captured.single as Map<String, Object?>;
    expect(captured['gcode_time_to_value_ms'], isA<num>());

    await AppAnalytics.gcodeImportSuccess(
      hasPrintTime: true,
      hasFilamentUsage: true,
      hasPreview: true,
    );
    verify(
      () => mock.logEvent(
        'gcode_import_success',
        params: {
          'has_print_time': 1,
          'has_filament_usage': 1,
          'has_preview': 1,
        },
      ),
    ).called(1);

    await AppAnalytics.paywallViewed('subscriptions');
    final captured2 = verify(
      () => mock.logEvent(
        'paywall_viewed',
        params: captureAny(named: 'params'),
      ),
    ).captured.single as Map<String, Object?>;
    expect(captured2['entry_point'], 'gcode_import');

    await AppAnalytics.purchaseCompleted('subscriptions');
    final captured3 = verify(
      () => mock.logEvent(
        'purchase_completed',
        params: captureAny(named: 'params'),
      ),
    ).captured.single as Map<String, Object?>;
    expect(captured3['entry_point'], 'gcode_import');

    AppAnalytics.resetGcodeImportTrackingForTests();
    await AppAnalytics.gcodeImportOpened();
    await AppAnalytics.gcodeImportAbandoned(
      failureReason: GCodeFailureReason.cancelled,
    );
    verify(
      () => mock.logEvent(
        'gcode_import_abandoned',
        params: {
          'slicer': 'unknown',
          'has_preview': 0,
          'parse_status': 'unknown',
          'file_size_bucket': 'unknown',
          'failure_reason': 'cancelled',
        },
      ),
    ).called(1);
  });

  test('paywall analytics default to manual entry point', () async {
    when(
      () => mock.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    await AppAnalytics.paywallViewed('history');
    final captured = verify(
      () => mock.logEvent(
        'paywall_viewed',
        params: captureAny(named: 'params'),
      ),
    ).captured.single as Map<String, Object?>;
    expect(captured['entry_point'], 'manual');
  });

  test('premium feature tapped keeps optional source', () async {
    when(
      () => mock.logEvent(any(), params: any(named: 'params')),
    ).thenAnswer((_) async {});

    await AppAnalytics.premiumFeatureTapped(
      'history',
      isPro: false,
      source: 'history_teaser_primary',
    );
    verify(
      () => mock.logEvent(
        'premium_feature_tapped',
        params: {
          'feature': 'history',
          'is_pro': 0,
          'source': 'history_teaser_primary',
        },
      ),
    ).called(1);
  });

  test('update prompt analytics wrappers use expected payloads', () async {
    await AppAnalytics.updatePromptShown(
      currentVersion: '1.0.0',
      storeVersion: '1.1.0',
      platform: 'android',
      source: 'startup',
    );

    expect(fake.lastName, 'update_prompt_shown');
    expect(fake.lastParams, {
      'current_version': '1.0.0',
      'store_version': '1.1.0',
      'platform': 'android',
      'source': 'startup',
    });

    await AppAnalytics.updatePromptTapped(
      currentVersion: '1.0.0',
      platform: 'android',
      source: 'startup',
    );

    expect(fake.lastName, 'update_prompt_tapped');
    expect(fake.lastParams, {
      'current_version': '1.0.0',
      'platform': 'android',
      'source': 'startup',
    });

    await AppAnalytics.updatePromptDismissed(
      currentVersion: '1.0.0',
      platform: 'android',
      source: 'manual',
    );

    expect(fake.lastName, 'update_prompt_dismissed');
    expect(fake.lastParams, {
      'current_version': '1.0.0',
      'platform': 'android',
      'source': 'manual',
    });
  });

  test(
    'materials analytics wrappers keep payloads small and consistent',
    () async {
      when(
        () => mock.logEvent(any(), params: any(named: 'params')),
      ).thenAnswer((_) async {});

      await AppAnalytics.materialsViewOpened();
      verify(
        () => mock.logEvent('materials_view_opened', params: null),
      ).called(1);

      await AppAnalytics.materialCreated(
        hasTracking: true,
        materialType: 'PLA',
        brand: 'Sunlu',
      );
      verify(
        () => mock.logEvent(
          'material_created',
          params: {
            'has_tracking': 1,
            'material_type': 'PLA',
            'brand': 'Sunlu',
          },
        ),
      ).called(1);

      await AppAnalytics.materialEdited(hasTracking: false, materialType: '');
      verify(
        () => mock.logEvent(
          'material_edited',
          params: {'has_tracking': 0},
        ),
      ).called(1);

      await AppAnalytics.csvImportStarted();
      verify(
        () => mock.logEvent('csv_import_started', params: null),
      ).called(1);

      await AppAnalytics.csvImportCompleted(rowsSuccess: 3, rowsFailed: 1);
      verify(
        () => mock.logEvent(
          'csv_import_completed',
          params: {'rows_success': 3, 'rows_failed': 1},
        ),
      ).called(1);

      await AppAnalytics.materialSelectedInCalculator(
        hasTracking: true,
        materialType: 'PETG',
        brand: 'Overture',
      );
      verify(
        () => mock.logEvent(
          'material_selected_in_calculator',
          params: {
            'has_tracking': 1,
            'material_type': 'PETG',
            'brand': 'Overture',
          },
        ),
      ).called(1);
    },
  );
}
