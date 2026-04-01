import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

enum AppLogLevel { debug, info, warn, error }

enum AppLogCategory { db, provider, ui, migration, billing }

typedef AppLogContext = Map<String, Object?>;

@immutable
class AppLogEvent {
  const AppLogEvent({
    required this.level,
    required this.category,
    required this.message,
    this.context = const {},
    this.error,
    this.stackTrace,
  });

  final AppLogLevel level;
  final AppLogCategory category;
  final String message;
  final AppLogContext context;
  final Object? error;
  final StackTrace? stackTrace;

  String format() {
    final buffer = StringBuffer(
      '${level.name.toUpperCase()} [${category.name}] $message',
    );

    if (context.isNotEmpty) {
      final entries = context.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      buffer.write(
        ' | ${entries.map((entry) => '${entry.key}=${entry.value}').join(', ')}',
      );
    }

    if (error != null) {
      buffer.write(' | error=$error');
    }

    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }

    return buffer.toString();
  }
}

abstract class AppLogSink {
  const AppLogSink();

  void log(AppLogEvent event);
}

class DebugPrintAppLogSink extends AppLogSink {
  const DebugPrintAppLogSink();

  @override
  void log(AppLogEvent event) {
    debugPrint(event.format());
  }
}

@immutable
class AppLoggerConfig {
  const AppLoggerConfig({required this.minLevel});

  const AppLoggerConfig.defaults()
    : minLevel = kDebugMode ? AppLogLevel.debug : AppLogLevel.warn;

  final AppLogLevel minLevel;
}

class AppLogger {
  const AppLogger({required AppLogSink sink, required AppLoggerConfig config})
    : _sink = sink,
      _config = config;

  final AppLogSink _sink;
  final AppLoggerConfig _config;

  void debug(
    AppLogCategory category,
    String message, {
    AppLogContext context = const {},
  }) {
    _log(AppLogLevel.debug, category, message, context: context);
  }

  void info(
    AppLogCategory category,
    String message, {
    AppLogContext context = const {},
  }) {
    _log(AppLogLevel.info, category, message, context: context);
  }

  void warn(
    AppLogCategory category,
    String message, {
    AppLogContext context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      AppLogLevel.warn,
      category,
      message,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    AppLogCategory category,
    String message, {
    AppLogContext context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      AppLogLevel.error,
      category,
      message,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    AppLogLevel level,
    AppLogCategory category,
    String message, {
    AppLogContext context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _config.minLevel.index) return;

    _sink.log(
      AppLogEvent(
        level: level,
        category: category,
        message: message,
        context: context,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

final appLogSinkProvider = Provider<AppLogSink>(
  (_) => const DebugPrintAppLogSink(),
);

final appLoggerConfigProvider = Provider<AppLoggerConfig>(
  (_) => const AppLoggerConfig.defaults(),
);

final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger(
    sink: ref.read(appLogSinkProvider),
    config: ref.read(appLoggerConfigProvider),
  );
});
