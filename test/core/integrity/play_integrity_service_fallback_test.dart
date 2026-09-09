import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'play_integrity_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.threed_print_calculator/play_integrity');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

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
      logger: recordingLogger(captured),
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
            logger: recordingLogger(captured),
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
            logger: recordingLogger(captured),
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

  test('falls back on unauthenticated decode failures', () async {
    final sentryEvents = <SentryEvent>[];
    addTearDown(Sentry.close);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestToken') return 'token';
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
          logger: recordingLogger(captured),
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

  test(
    'does not fall back on unauthenticated decode failures with casing',
    () async {
      final sentryEvents = <SentryEvent>[];
      addTearDown(Sentry.close);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'requestToken') return 'token';
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
            logger: recordingLogger(captured),
            decodeIntegrity: (_, _) async {
              throw FirebaseFunctionsException(
                code: 'Unauthenticated',
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
    },
  );
}
