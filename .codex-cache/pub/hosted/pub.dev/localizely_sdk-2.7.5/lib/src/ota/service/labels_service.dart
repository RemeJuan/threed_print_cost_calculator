import '../api/api.dart';
import '../api/api_exception.dart';
import '../model/release_data.dart';
import '../../sdk_data.dart';
import '../store/store.dart';

class LabelsService {
  static Future<ReleaseData?> getPersistedReleaseData(String distributionId) {
    return Store.getReleaseData(distributionId);
  }

  static Future<int> getLabels(
    String sdkToken,
    String distributionId,
    String currentLocale,
    String appInstallationId,
    String sdkBuildNumber,
    String appBuildNumber, {
    String? deviceLocale,
    bool? preRelease,
    int? releaseVersion,
  }) async {
    int newReleaseVersion;

    try {
      var bundleInfo = await Api.getBundleInfo(
        sdkToken,
        distributionId,
        currentLocale,
        appInstallationId,
        sdkBuildNumber,
        appBuildNumber,
        deviceLocale: deviceLocale,
        preRelease: preRelease,
        releaseVersion: releaseVersion,
      );

      // The new release version can be lower (deleted release on Localizely), the same (nothing changed), or higher (new release available).
      if (bundleInfo.version != releaseVersion) {
        var bundleData = await Api.getBundleData(bundleInfo.file);
        var releaseData = ReleaseData(
          version: bundleInfo.version,
          data: bundleData.data,
        );

        SdkData.releaseData = releaseData;
        await Store.persistReleaseData(distributionId, releaseData);
      }

      newReleaseVersion = bundleInfo.version;
    } on ApiException catch (e) {
      // clear cached data if necessary
      if (e.errorCode == 'release_not_found') {
        SdkData.releaseData = null;
        await Store.removePersistedReleaseData();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }

    return newReleaseVersion;
  }
}
