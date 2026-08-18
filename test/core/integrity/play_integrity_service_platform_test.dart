import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('uses limited-use App Check token for callable decode', () {
    expect(
      DefaultPlayIntegrityService
          .limitedUseAppCheckOptions
          .limitedUseAppCheckToken,
      isTrue,
    );
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
      logger: recordingLogger(captured),
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
