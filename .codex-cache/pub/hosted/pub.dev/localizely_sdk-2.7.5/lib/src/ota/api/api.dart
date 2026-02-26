import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import '../model/bundle_info.dart';
import '../model/bundle_data.dart';
import '../util/util.dart';

class Api {
  static final String _baseUrl = 'https://ota.localizely.com';

  Api._();

  static Future<BundleInfo> getBundleInfo(
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
    var uri = '$_baseUrl/ota/v1/distributions/$distributionId/flutter';
    var headers = _getHeaders(
      sdkToken,
      currentLocale,
      appInstallationId,
      sdkBuildNumber,
      appBuildNumber,
      deviceLocale: deviceLocale,
      preRelease: preRelease,
      releaseVersion: releaseVersion,
    );

    var response = await http.get(Uri.parse(uri), headers: headers);
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to fetch bundle info',
        response.statusCode,
        Util.formatJsonMessage(response.body),
      );
    }

    var jsonResponse = convert.jsonDecode(response.body);

    return BundleInfo.fromJson(jsonResponse);
  }

  static Map<String, String> _getHeaders(
    String sdkToken,
    String currentLocale,
    String appInstallationId,
    String sdkBuildNumber,
    String appBuildNumber, {
    String? deviceLocale,
    bool? preRelease,
    int? releaseVersion,
  }) {
    var headers = {
      'X-Localizely-Api-Token': sdkToken,
      'X-Localizely-Current-Locale': currentLocale,
      'X-Localizely-UID': appInstallationId,
      'X-Localizely-SDK-Build': sdkBuildNumber,
      'X-Localizely-App-Build': appBuildNumber,
    };

    if (deviceLocale != null) {
      headers.putIfAbsent('X-Localizely-Device-Locale', () => deviceLocale);
    }

    if (preRelease != null) {
      headers.putIfAbsent(
        'X-Localizely-Prerelease',
        () => preRelease.toString(),
      );
    }

    if (releaseVersion != null) {
      headers.putIfAbsent(
        'X-Localizely-Current-Version',
        () => releaseVersion.toString(),
      );
    }

    return headers;
  }

  static Future<BundleData> getBundleData(String uri) async {
    var response = await http.get(Uri.parse(uri));

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to fetch bundle data',
        response.statusCode,
        Util.formatJsonMessage(response.body),
      );
    }

    var jsonResponse = convert.jsonDecode(response.body);

    return BundleData.fromJson(jsonResponse);
  }
}
