import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../platform/platform.dart';
import '../platform/platform_exception.dart';
import '../model/persisted_release_data.dart';
import '../model/release_data.dart';
import '../../common/util/util.dart';

class Store {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  static final String _appInstallationIdKey =
      'LOCALIZELY_SDK_APP_INSTALLATION_ID';

  Store._();

  static Future<String> getAppInstallationId() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_appInstallationIdKey)) {
      await prefs.setString(_appInstallationIdKey, Util.generateUuid());
    }

    return prefs.getString(_appInstallationIdKey)!;
  }

  static Future<ReleaseData?> getReleaseData(String distributionId) async {
    ReleaseData? releaseData;

    try {
      var platform = Platform();
      var persistedReleaseData = await platform.getPersistedReleaseData();

      if (persistedReleaseData == null) {
        return null;
      }

      if (persistedReleaseData.distributionId != distributionId) {
        await platform.removePersistedReleaseData();
        return null;
      }

      releaseData = persistedReleaseData.releaseData;
    } on PlatformException {
      _logger.i(
        'This platform does not support translations caching hence relying on translations fetched from Localizely server.',
      );
    } catch (e) {
      _logger.w('Failed to load cached translations.', error: e);
    }

    return releaseData;
  }

  static Future<void> persistReleaseData(
    String distributionId,
    ReleaseData releaseData,
  ) async {
    try {
      var platform = Platform();

      var persistedReleaseData = PersistedReleaseData(
        distributionId,
        releaseData,
      );

      await platform.savePersistedReleaseData(persistedReleaseData);
    } on PlatformException {
      // ignore log message
      return;
    } catch (e) {
      _logger.w('Failed to cache translations.', error: e);
    }
  }

  static Future<void> removePersistedReleaseData() async {
    try {
      var platform = Platform();
      await platform.removePersistedReleaseData();
    } on PlatformException {
      // ignore log message
      return;
    } catch (e) {
      _logger.w('Failed to clear cached translations.', error: e);
    }
  }
}
