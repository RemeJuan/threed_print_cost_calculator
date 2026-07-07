import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
}

class _RecordingSink extends AppLogSink {
  _RecordingSink(this.events);

  final List<AppLogEvent> events;

  @override
  void log(AppLogEvent event) => events.add(event);
}
