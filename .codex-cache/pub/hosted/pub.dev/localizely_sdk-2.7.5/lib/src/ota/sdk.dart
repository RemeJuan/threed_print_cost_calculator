// ignore_for_file:implementation_imports
import 'package:intl/src/intl_helpers.dart';

import 'service/labels_service.dart';
import 'proxy/proxy.dart';
import 'model/translations_update_result.dart';
import 'store/store.dart';
import 'sdk_exception.dart';
import 'util/util.dart';
import '../sdk_data.dart';
import '../common/util/util.dart' as util;

/// The Localizely SDK.
class Localizely {
  static String? _sdkToken;
  static String? _distributionId;
  static bool? _preRelease;

  Localizely._();

  /// Initializes Localizely SDK.
  ///
  /// Values for [sdkToken] and [distributionId] are generated on the Localizely platform.
  static void init(String sdkToken, String distributionId) {
    _sdkToken = sdkToken;
    _distributionId = distributionId;

    messageLookup = MessageLookupProxy.from(messageLookup);
  }

  /// Sets the pre-release config.
  ///
  /// Set to `true` to fetch the pre-release bundle.
  static void setPreRelease(bool preRelease) {
    _preRelease = preRelease;
  }

  /// Sets the metadata config.
  ///
  /// Flutter Intl IDE plugin should automatically set metadata config.
  /// To enable this, please ensure `ota_enabled` is set to `true` within `flutter_intl/localizely` section of the `pubspec.yaml` file.
  static void setMetadata(Map<String, List<String>> metadata) {
    SdkData.metadata = metadata;
  }

  /// Checks if metadata is set.
  static bool hasMetadata() {
    return SdkData.metadata != null;
  }

  /// Sets the application version.
  ///
  /// Use this to explicitly set the application version, or in cases when automatic detection is not possible (e.g. Flutter web apps).
  /// Throws [SdkException] in case provided value does not comply with semantic versioning specification.
  static void setAppVersion(String version) {
    if (!Util.isValidSemanticVersion(version)) {
      throw SdkException(
        'Localizely SDK expects a valid version of the app which complies with semantic versioning specification.',
      );
    }

    SdkData.appBuildNumber = version;
  }

  /// Updates existing translations with the ones from the Localizely platform.
  ///
  /// This method should be called after localization delegates initialization.
  ///
  /// ```
  /// Localizely.updateTranslations().then((response) => setState(() => print('Translations fetched')), onError: (error) => print('Error occurred'));
  /// ```
  ///
  /// Throws [SdkException] in case sdk token, distribution id, metadata, or application version is not set or can't be detected.
  /// Throws [ApiException] in case of http request failure.
  static Future<TranslationsUpdateResult> updateTranslations() async {
    if (_sdkToken == null) {
      throw SdkException(
        'Localizely SDK has not been initialized or SDK token has not been provided during SDK initialization.',
      );
    }

    if (_distributionId == null) {
      throw SdkException(
        'Localizely SDK has not been initialized or distribution ID has not been provided during SDK initialization.',
      );
    }

    if (!Util.isMetadataSet()) {
      throw SdkException(
        "Localizely SDK missing metadata configuration. In case you are using the Flutter Intl IDE plugin for localization, please ensure 'ota_enabled' is set to 'true' within the 'flutter_intl/localizely' section of the 'pubspec.yaml' file. In case you are using the gen_l10n tool for localization, please ensure that the required localization code is generated via 'flutter pub run localizely_sdk:generate' command. If all the requirements are met and you still see this error, please ensure that the 'updateTranslations' method is called after localization delegates initialization.",
      );
    }

    var appBuildNumber =
        SdkData.appBuildNumber ?? await Util.getAppBuildNumber();
    if (appBuildNumber == null) {
      throw SdkException(
        "The application version can't be detected. Please use the 'setAppVersion' method for setting up the required parameter.",
      );
    }

    if (!SdkData.hasReleaseData) {
      SdkData.releaseData = await LabelsService.getPersistedReleaseData(
        _distributionId!,
      );
    }

    var currentLocale = Util.getCurrentLocale();
    var appInstallationId = await Store.getAppInstallationId();
    var sdkBuildNumber = util.Util.getSdkBuildNumber();
    var deviceLocale = Util.getDeviceLocale();
    var currentReleaseVersion = SdkData.releaseVersion;

    var newReleaseVersion = await LabelsService.getLabels(
      _sdkToken!,
      _distributionId!,
      currentLocale,
      appInstallationId,
      sdkBuildNumber,
      appBuildNumber,
      deviceLocale: deviceLocale,
      preRelease: _preRelease,
      releaseVersion: currentReleaseVersion,
    );

    return TranslationsUpdateResult(currentReleaseVersion, newReleaseVersion);
  }
}
