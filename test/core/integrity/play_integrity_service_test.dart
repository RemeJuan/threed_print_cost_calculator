import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.threed_print_calculator/play_integrity');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('coalesces overlapping evaluations into one native request', () async {
    final completer = Completer<String>();
    var requestTokenCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') {
            requestTokenCalls += 1;
            return completer.future;
          }
          return null;
        });

    final service = DefaultPlayIntegrityService(
      targetPlatform: TargetPlatform.android,
      requestTokenTimeout: const Duration(seconds: 1),
      decodeIntegrity: (_, _) async => {
        'license': 'LICENSED',
        'appIntegrity': 'PLAY_RECOGNIZED',
        'deviceIntegrity': 'MEETS_DEVICE_INTEGRITY',
        'virtualIntegrity': 'UNEVALUATED',
        'recentDeviceActivity': 'UNEVALUATED',
        'playProtect': 'NO_ISSUES',
        'appAccessRisk': <String>[],
        'decision': 'allow',
      },
    );

    final first = service.evaluate(PlayIntegrityFlow.purchase);
    final second = service.evaluate(PlayIntegrityFlow.purchase);
    completer.complete('token');

    await expectLater(first, completes);
    await expectLater(second, completes);
    expect(requestTokenCalls, 1);
  });

  test('shares one in-flight evaluation across different flows', () async {
    final completer = Completer<String>();
    var requestTokenCalls = 0;
    final decodeFlows = <PlayIntegrityFlow>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') {
            requestTokenCalls += 1;
            return completer.future;
          }
          return null;
        });

    final service = DefaultPlayIntegrityService(
      targetPlatform: TargetPlatform.android,
      requestTokenTimeout: const Duration(seconds: 1),
      decodeIntegrity: (_, flow) async {
        decodeFlows.add(flow);
        return {
          'license': 'LICENSED',
          'appIntegrity': 'PLAY_RECOGNIZED',
          'deviceIntegrity': 'MEETS_DEVICE_INTEGRITY',
          'virtualIntegrity': 'UNEVALUATED',
          'recentDeviceActivity': 'UNEVALUATED',
          'playProtect': 'NO_ISSUES',
          'appAccessRisk': <String>[],
          'decision': 'allow',
        };
      },
    );

    final purchase = service.evaluate(PlayIntegrityFlow.purchase);
    final restore = service.evaluate(PlayIntegrityFlow.restore);
    completer.complete('token');
    await expectLater(purchase, completes);
    await expectLater(restore, completes);
    expect(requestTokenCalls, 1);
    expect(decodeFlows, [PlayIntegrityFlow.purchase]);
  });

  test(
    'throttle error maps to typed exception and cooldown blocks channel',
    () async {
      var now = DateTime(2026, 1, 1);
      var requestTokenCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'requestToken') {
              requestTokenCalls += 1;
              throw PlatformException(
                code: 'play_integrity_in_flight',
                details: {'errorCode': -8},
              );
            }
            return null;
          });

      final service = DefaultPlayIntegrityService(
        targetPlatform: TargetPlatform.android,
        now: () => now,
      );

      final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);
      expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
      expect(requestTokenCalls, 1);

      final cooldownSnapshot = await service.evaluate(
        PlayIntegrityFlow.restore,
      );
      expect(cooldownSnapshot.decision, PlayIntegrityDecisionLabel.allow);
      expect(requestTokenCalls, 1);

      now = now.add(const Duration(seconds: 61));
      final retrySnapshot = await service.evaluate(PlayIntegrityFlow.restore);
      expect(retrySnapshot.decision, PlayIntegrityDecisionLabel.allow);
      expect(requestTokenCalls, 2);
    },
  );

  test('falls back when token request fails', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') {
            throw PlatformException(code: 'fail', message: 'token');
          }
          return null;
        });

    final captured = <AppLogEvent>[];
    final service = DefaultPlayIntegrityService(
      targetPlatform: TargetPlatform.android,
      logger: AppLogger(
        sink: _RecordingSink(captured),
        config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
      ),
    );

    final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);

    expect(snapshot.license, 'UNEVALUATED');
    expect(snapshot.appIntegrity, 'UNEVALUATED');
    expect(snapshot.deviceIntegrity, 'UNEVALUATED');
    expect(snapshot.virtualIntegrity, 'UNEVALUATED');
    expect(snapshot.recentDeviceActivity, 'UNEVALUATED');
    expect(snapshot.playProtect, 'UNEVALUATED');
    expect(snapshot.appAccessRisk, isEmpty);
    expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
    expect(captured.single.message, 'Play Integrity fallback');
  });

  test('falls back when decode response is invalid', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') return 'token';
          return null;
        });

    final service = DefaultPlayIntegrityService(
      targetPlatform: TargetPlatform.android,
      decodeIntegrity: (_, _) async => 'bad-response',
    );

    final snapshot = await service.evaluate(PlayIntegrityFlow.restore);

    expect(snapshot.license, 'UNEVALUATED');
    expect(snapshot.appIntegrity, 'UNEVALUATED');
    expect(snapshot.deviceIntegrity, 'UNEVALUATED');
    expect(snapshot.virtualIntegrity, 'UNEVALUATED');
    expect(snapshot.recentDeviceActivity, 'UNEVALUATED');
    expect(snapshot.playProtect, 'UNEVALUATED');
    expect(snapshot.appAccessRisk, isEmpty);
    expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
  });

  test(
    'falls back on request token timeout without reporting to sentry',
    () async {
      final sentryEvents = <SentryEvent>[];
      final tokenRequest = Completer<String>();
      addTearDown(Sentry.close);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'requestToken') {
              return tokenRequest.future;
            }
            return null;
          });

      await SentryFlutter.init(
        (options) {
          options.dsn = 'https://public@example.invalid/1';
          options.beforeSend = (event, hint) {
            sentryEvents.add(event);
            return null;
          };
        },
        appRunner: () async {
          final captured = <AppLogEvent>[];
          final service = DefaultPlayIntegrityService(
            targetPlatform: TargetPlatform.android,
            requestTokenTimeout: const Duration(milliseconds: 1),
            logger: AppLogger(
              sink: _RecordingSink(captured),
              config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
            ),
          );

          final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);

          expect(snapshot.license, 'UNEVALUATED');
          expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
          expect(captured.single.message, 'Play Integrity fallback');
          expect(captured.single.error, isA<TimeoutException>());
        },
      );

      expect(sentryEvents, isEmpty);
    },
  );

  test('reports non-timeout token request failures to sentry', () async {
    final sentryEvents = <SentryEvent>[];
    addTearDown(Sentry.close);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') {
            throw PlatformException(code: 'fail', message: 'token');
          }
          return null;
        });

    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://public@example.invalid/1';
        options.beforeSend = (event, hint) {
          sentryEvents.add(event);
          return null;
        };
      },
      appRunner: () async {
        final service = DefaultPlayIntegrityService(
          targetPlatform: TargetPlatform.android,
        );

        final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);

        expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
      },
    );

    expect(sentryEvents, hasLength(1));
  });

  test(
    'falls back on play integrity timeout without reporting to sentry',
    () async {
      final sentryEvents = <SentryEvent>[];
      addTearDown(Sentry.close);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'requestToken') {
              throw PlatformException(
                code: 'play_integrity_timeout',
                message: 'token',
              );
            }
            return null;
          });

      await SentryFlutter.init(
        (options) {
          options.dsn = 'https://public@example.invalid/1';
          options.beforeSend = (event, hint) {
            sentryEvents.add(event);
            return null;
          };
        },
        appRunner: () async {
          final captured = <AppLogEvent>[];
          final service = DefaultPlayIntegrityService(
            targetPlatform: TargetPlatform.android,
            logger: AppLogger(
              sink: _RecordingSink(captured),
              config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
            ),
          );

          final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);

          expect(snapshot.license, 'UNEVALUATED');
          expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
          expect(captured.single.message, 'Play Integrity fallback');
          expect(captured.single.error, isA<PlatformException>());
        },
      );

      expect(sentryEvents, isEmpty);
    },
  );

  test('uses limited-use App Check token for callable decode', () {
    expect(
      DefaultPlayIntegrityService
          .limitedUseAppCheckOptions
          .limitedUseAppCheckToken,
      isTrue,
    );
  });

  test('falls back on unauthenticated decode failures', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') return 'token';
          return null;
        });

    final sentryEvents = <SentryEvent>[];
    addTearDown(Sentry.close);
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://public@example.invalid/1';
        options.beforeSend = (event, hint) {
          sentryEvents.add(event);
          return null;
        };
      },
      appRunner: () async {
        final captured = <AppLogEvent>[];
        final service = DefaultPlayIntegrityService(
          targetPlatform: TargetPlatform.android,
          logger: AppLogger(
            sink: _RecordingSink(captured),
            config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
          ),
          decodeIntegrity: (_, _) async {
            throw FirebaseFunctionsException(
              code: 'unauthenticated',
              message: 'app check',
            );
          },
        );

        final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);
        expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
        expect(captured, isEmpty);
      },
    );
    expect(sentryEvents, isEmpty);
  });

  test('skips token request on non-Android platforms', () async {
    var requestedToken = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') requestedToken = true;
          return null;
        });

    final captured = <AppLogEvent>[];
    final service = DefaultPlayIntegrityService(
      targetPlatform: TargetPlatform.iOS,
      logger: AppLogger(
        sink: _RecordingSink(captured),
        config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
      ),
    );

    final snapshot = await service.evaluate(PlayIntegrityFlow.purchase);

    expect(requestedToken, isFalse);
    expect(captured, isEmpty);
    expect(snapshot.license, 'UNEVALUATED');
    expect(snapshot.appIntegrity, 'UNEVALUATED');
    expect(snapshot.deviceIntegrity, 'UNEVALUATED');
    expect(snapshot.virtualIntegrity, 'UNEVALUATED');
    expect(snapshot.recentDeviceActivity, 'UNEVALUATED');
    expect(snapshot.playProtect, 'UNEVALUATED');
    expect(snapshot.appAccessRisk, isEmpty);
    expect(snapshot.decision, PlayIntegrityDecisionLabel.allow);
  });
}

class _RecordingSink extends AppLogSink {
  _RecordingSink(this.events);

  final List<AppLogEvent> events;

  @override
  void log(AppLogEvent event) => events.add(event);
}
