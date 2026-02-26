import '../../sdk_data.dart';

String? getText(String locale, String stringKey) {
  if (!SdkData.hasReleaseData) {
    return null;
  }

  var labels = SdkData.getData(locale);
  var label = labels?[stringKey];
  var text = label?.value;

  return text;
}
