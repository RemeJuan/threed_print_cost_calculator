import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/shared/providers/update_checker_provider.dart';

class _TestAppLogSink extends AppLogSink {
  final List<AppLogEvent> events = [];

  @override
  void log(AppLogEvent event) {
    events.add(event);
  }
}

void main() {
  group('StoreUpdateLookupService', () {
    test(
      'returns available with store version for newer iOS release',
      () async {
        final service = StoreUpdateLookupService(
          client: MockClient((request) async {
            expect(request.url.host, 'itunes.apple.com');
            expect(request.url.queryParameters['country'], 'US');
            return http.Response('{"results":[{"version":"3.2.2"}]}', 200);
          }),
        );

        final result = await service.lookup(
          currentVersion: '3.2.1',
          platform: TargetPlatform.iOS,
        );

        expect(result.isAvailable, isTrue);
        expect(result.storeVersion, '3.2.2');
        expect(result.showStoreVersion, isTrue);
      },
    );

    test(
      'returns unavailable when Android store version matches current',
      () async {
        final service = StoreUpdateLookupService(
          client: MockClient((request) async {
            expect(request.url.host, 'play.google.com');
            return http.Response(
              'prefix [[["3.2.2"]],[[[36]],[[[24,"7.0"]]]]] suffix',
              200,
            );
          }),
        );

        final result = await service.lookup(
          currentVersion: '3.2.2',
          platform: TargetPlatform.android,
        );

        expect(result.isAvailable, isFalse);
        expect(result.storeVersion, isNull);
        expect(result.showStoreVersion, isFalse);
      },
    );

    test('returns unknown when store response cannot be parsed', () async {
      final sink = _TestAppLogSink();
      final service = StoreUpdateLookupService(
        logger: AppLogger(
          sink: sink,
          config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
        client: MockClient((_) async => http.Response('no version here', 200)),
      );

      final result = await service.lookup(
        currentVersion: '3.2.1',
        platform: TargetPlatform.android,
      );

      expect(result.isAvailable, isFalse);
      expect(result.storeVersion, isNull);
      expect(result.showStoreVersion, isFalse);
      expect(sink.events, hasLength(1));
      expect(
        sink.events.single.message,
        'Unable to parse Play Store update response',
      );
    });

    test('returns unknown when store request is not successful', () async {
      final sink = _TestAppLogSink();
      final service = StoreUpdateLookupService(
        logger: AppLogger(
          sink: sink,
          config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
        ),
        client: MockClient((_) async => http.Response('nope', 500)),
      );

      final result = await service.lookup(
        currentVersion: '3.2.1',
        platform: TargetPlatform.iOS,
      );

      expect(result.isAvailable, isFalse);
      expect(result.storeVersion, isNull);
      expect(result.showStoreVersion, isFalse);
      expect(sink.events, hasLength(1));
      expect(
        sink.events.single.message,
        'Store update lookup returned non-success status',
      );
    });
  });
}
