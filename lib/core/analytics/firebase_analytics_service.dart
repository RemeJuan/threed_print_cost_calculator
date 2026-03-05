import 'package:firebase_analytics/firebase_analytics.dart';
import 'analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService();

  Future<FirebaseAnalytics> get _instance async {
    // Lazily return the FirebaseAnalytics.instance. We keep it as a Future to
    // make it easier to swap for async mocks in tests if needed.
    return Future.value(FirebaseAnalytics.instance);
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    final analytics = await _instance;
    await analytics.logEvent(name: name, parameters: params);
  }
}
