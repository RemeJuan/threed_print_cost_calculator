import 'label.dart';
import '../../common/util/util.dart';

class BundleData {
  final Map<String, Map<String, Label>> data;

  BundleData({required this.data});

  BundleData.fromJson(List<dynamic> json)
    : data = {
        for (var localeData in json)
          Util.canonicalizedLocale(localeData['locale']): {
            for (var labelData in localeData['data'] as List)
              labelData['key']: Label.fromJson(labelData),
          },
      };
}
