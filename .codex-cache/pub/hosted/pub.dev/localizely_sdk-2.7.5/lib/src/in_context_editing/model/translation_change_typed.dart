import '../../common/util/util.dart';

class TranslationChangeTyped {
  final String type;
  final String locale;
  final String key;
  final String value;

  TranslationChangeTyped({
    required this.type,
    required this.locale,
    required this.key,
    required this.value,
  });

  TranslationChangeTyped.fromJson(Map<String, dynamic> json)
    : type = json['type'],
      locale = Util.canonicalizedLocale(json['locale']),
      key = json['stringKey'],
      value = json['newTranslation'];
}
