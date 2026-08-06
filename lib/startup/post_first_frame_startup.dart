import 'dart:async';

import 'package:flutter/widgets.dart';

typedef PostFirstFrameTask = Future<void> Function();
typedef StartupErrorReporter = void Function(FlutterErrorDetails details);

void schedulePostFirstFrameStartupTasks({
  required PostFirstFrameTask enableAnalyticsCollection,
  required PostFirstFrameTask activateAppCheck,
  StartupErrorReporter reportError = FlutterError.reportError,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _runProtectedTask(
      enableAnalyticsCollection,
      reportError: reportError,
      library: 'postFirstFrameStartupTasks',
      context: ErrorDescription('Firebase Analytics collection enablement'),
    );
    _runProtectedTask(
      activateAppCheck,
      reportError: reportError,
      library: 'postFirstFrameStartupTasks',
      context: ErrorDescription('Firebase App Check activation'),
    );
  });
}

void _runProtectedTask(
  PostFirstFrameTask task, {
  required StartupErrorReporter reportError,
  required String library,
  required DiagnosticsNode context,
}) {
  unawaited(() async {
    try {
      await task();
    } catch (error, stackTrace) {
      reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: library,
          context: context,
        ),
      );
    }
  }());
}
