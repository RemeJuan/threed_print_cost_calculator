import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

class _RecordingLogSink extends AppLogSink {
  final events = <AppLogEvent>[];

  @override
  void log(AppLogEvent event) {
    events.add(event);
  }
}

void main() {
  test('suppresses messages below configured minimum level', () {
    final sink = _RecordingLogSink();
    final logger = AppLogger(
      sink: sink,
      config: const AppLoggerConfig(minLevel: AppLogLevel.warn),
    );

    logger.debug(AppLogCategory.provider, 'debug message');
    logger.info(AppLogCategory.db, 'info message');
    logger.warn(AppLogCategory.ui, 'warn message');
    logger.error(AppLogCategory.db, 'error message');

    expect(sink.events, hasLength(2));
    expect(sink.events.first.level, AppLogLevel.warn);
    expect(sink.events.last.level, AppLogLevel.error);
  });

  test(
    'formats structured output with severity, category, context, and error',
    () {
      final event = AppLogEvent(
        level: AppLogLevel.error,
        category: AppLogCategory.db,
        message: 'Database read failed',
        context: {'key': 'settings', 'store': 'settings'},
        error: StateError('broken'),
      );

      final formatted = event.format();

      expect(formatted, contains('ERROR [db] Database read failed'));
      expect(formatted, contains('key=settings'));
      expect(formatted, contains('store=settings'));
      expect(formatted, contains('error=Bad state: broken'));
    },
  );
}
