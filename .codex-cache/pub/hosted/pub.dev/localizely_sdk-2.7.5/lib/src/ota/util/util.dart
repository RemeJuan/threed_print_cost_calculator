import 'dart:convert' as convert;

import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:logger/logger.dart';

import '../platform/platform.dart';
import '../../sdk_data.dart';
import '../../../localizely_sdk.dart';

enum CodeGenerator { flutterIntl, genL10n }

class Util {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  static Future<String?> getAppBuildNumber() async {
    String? appBuildNumber;

    try {
      var packageInfo = await PackageInfo.fromPlatform();
      appBuildNumber = packageInfo.version;
    } catch (e) {
      _logger.w('Failed to detect app version');
    }

    return appBuildNumber;
  }

  static String? getDeviceLocale() {
    String? deviceLocale;

    try {
      var platform = Platform();
      deviceLocale = platform.getLocale();
    } catch (e) {
      _logger.w('Failed to detect device locale');
    }

    return deviceLocale;
  }

  /// Converts to inline json message.
  static String formatJsonMessage(String jsonMessage) {
    try {
      var decoded = convert.jsonDecode(jsonMessage);
      return convert.jsonEncode(decoded);
    } catch (e) {
      return jsonMessage;
    }
  }

  static bool isValidSemanticVersion(String value) {
    final maxSegmentValue = 2147483647;
    final semanticVersionRegExp = RegExp(r'^([0-9]+)\.([0-9]+)\.([0-9]+)$');

    if (semanticVersionRegExp.hasMatch(value)) {
      var segments = value.split('.');
      var exceededSegments = segments.where(
        (segment) => int.parse(segment) > maxSegmentValue,
      );

      return exceededSegments.isEmpty;
    }

    return false;
  }

  static CodeGenerator? detectCodeGenerator() {
    if (SdkData.metadata != null) {
      return CodeGenerator.flutterIntl;
    }

    if (LocalizelyGenL10n.getCurrentLocale() != null) {
      return CodeGenerator.genL10n;
    }

    return null;
  }

  static bool isMetadataSet() => detectCodeGenerator() != null;

  static String getCurrentLocale() {
    var codeGenerator = detectCodeGenerator();
    if (codeGenerator == null) {
      return '';
    }

    return codeGenerator == CodeGenerator.genL10n
        ? LocalizelyGenL10n.getCurrentLocale()!
        : Intl.getCurrentLocale();
  }
}
