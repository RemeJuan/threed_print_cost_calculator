import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

class _RecordingSink extends AppLogSink {
  _RecordingSink(this.events);

  final List<AppLogEvent> events;

  @override
  void log(AppLogEvent event) => events.add(event);
}

AppLogger recordingLogger(List<AppLogEvent> events) => AppLogger(
  sink: _RecordingSink(events),
  config: const AppLoggerConfig(minLevel: AppLogLevel.debug),
);
