import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const materialsSwipeHintShownPreferenceKey = 'materials_swipe_hint_shown';

abstract class MaterialsSwipeHintStore {
  bool get shown;

  void markShown();
}

class SharedPreferencesMaterialsSwipeHintStore
    implements MaterialsSwipeHintStore {
  SharedPreferencesMaterialsSwipeHintStore(this.prefs);

  final SharedPreferences prefs;

  @override
  bool get shown =>
      prefs.getBool(materialsSwipeHintShownPreferenceKey) ?? false;

  @override
  void markShown() {
    prefs.setBool(materialsSwipeHintShownPreferenceKey, true);
  }
}

class MaterialsSwipeHintController extends ValueNotifier<bool> {
  MaterialsSwipeHintController({required bool shown, required this.store})
    : super(!shown);

  final MaterialsSwipeHintStore store;

  bool get isVisible => value;

  void dismiss() {
    if (!value) return;
    value = false;
    store.markShown();
  }
}
