import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Util {
  static final String _sdkBuildNumber = '2.7.5';

  Util._();

  static String getSdkBuildNumber() {
    return _sdkBuildNumber;
  }

  static String generateUuid() {
    return Uuid().v4();
  }

  static String canonicalizedLocale(String locale) {
    return Intl.canonicalizedLocale(locale);
  }

  static String generateInstanceName(String className) {
    return className[0].toLowerCase() + className.substring(1);
  }
}
