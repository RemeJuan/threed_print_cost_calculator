import 'label.dart';

class ReleaseData {
  final int version;
  final Map<String, Map<String, Label>> data;

  ReleaseData({required this.version, required this.data});

  ReleaseData.fromJson(Map<String, dynamic> json)
    : version = json['version'],
      data = {
        for (var localeCode in json['data'].keys)
          localeCode: {
            for (var labelKey in json['data'][localeCode].keys)
              labelKey: Label.fromJson(json['data'][localeCode][labelKey]),
          },
      };

  Map<String, dynamic> toJson() => {'version': version, 'data': data};
}
