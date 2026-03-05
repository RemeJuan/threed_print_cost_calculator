abstract class AnalyticsService {
  /// Log an event with optional parameters. Parameter values should be
  /// primitives (String or num) — callers or the implementation may sanitize
  /// as needed.
  Future<void> logEvent(String name, {Map<String, Object>? params});
}
