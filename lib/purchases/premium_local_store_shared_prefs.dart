import 'package:shared_preferences/shared_preferences.dart';

import 'premium_local_store_api.dart';
import 'premium_local_store_keys.dart';

class SharedPrefsPremiumLocalStore implements PremiumLocalStore {
  SharedPrefsPremiumLocalStore(this._prefs);

  final SharedPreferences _prefs;

  String? _readAsString(String key) {
    final value = _prefs.get(key);
    return value?.toString();
  }

  @override
  String? readSync(String key) => _readAsString(key);

  @override
  Future<String?> read(String key) async => _readAsString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final result = <String, String>{};
    for (final key in _knownKeys) {
      final value = _readAsString(key);
      if (value != null) result[key] = value;
    }
    return Map<String, String>.unmodifiable(result);
  }
}

const _knownKeys = [
  testPremiumOverrideEnabledOnPreferenceKey,
  calculationCountPreferenceKey,
  completedCostingCountPreferenceKey,
  hasUsedGcodeImportPreferenceKey,
  cancelFeedbackPromptShownStatePreferenceKey,
  cancelFeedbackPromptSubmittedStatePreferenceKey,
  runCountPreferenceKey,
  paywallPreferenceKey,
];
