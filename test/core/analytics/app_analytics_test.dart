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
}
