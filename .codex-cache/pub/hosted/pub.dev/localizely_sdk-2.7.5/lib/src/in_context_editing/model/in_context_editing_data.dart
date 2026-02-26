import 'translation_change_typed.dart';

class InContextEditingData {
  final Map<String, Map<String, TranslationChangeTyped>> data;

  InContextEditingData() : data = {};

  void add(TranslationChangeTyped translationChangeTyped) {
    data.putIfAbsent(translationChangeTyped.locale, () => {});
    data[translationChangeTyped.locale]!.update(
      translationChangeTyped.key,
      (value) => translationChangeTyped,
      ifAbsent: () => translationChangeTyped,
    );
  }

  TranslationChangeTyped? getEditedData(String locale, String key) =>
      data[locale]?[key];
}
