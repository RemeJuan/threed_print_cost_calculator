import 'platform_stub.dart'
    if (dart.library.js_interop) 'browser_platform.dart'
    if (dart.library.io) 'io_platform.dart';
import '../model/persisted_release_data.dart';

abstract class Platform {
  factory Platform() => createPlatform();

  String getLocale();

  Future<PersistedReleaseData?> getPersistedReleaseData();

  Future<void> savePersistedReleaseData(PersistedReleaseData data);

  Future<void> removePersistedReleaseData();
}
