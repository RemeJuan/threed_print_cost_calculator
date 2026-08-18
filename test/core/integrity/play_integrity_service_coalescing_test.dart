import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';

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
}
