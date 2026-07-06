import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';

Future<void> migrateFromSecureToSharedPrefs({
  required SharedPreferences sharedPreferences,
}) async {
  final storage = const FlutterSecureStorage();
  Map<String, String> values;
  try {
    values = await storage.readAll();
  } catch (_) {
    return;
  }

  for (final entry in values.entries) {
    await sharedPreferences.setString(entry.key, entry.value);
  }

  try {
    await storage.deleteAll();
  } catch (_) {}
}

Future<void> cleanupSecureStorage() async {
  final storage = const FlutterSecureStorage();
  try {
    await storage.deleteAll();
  } catch (_) {}
}

Future<void> migratePremiumLocalStore({
  required SharedPreferences sharedPreferences,
  required PremiumLocalStore premiumLocalStore,
}) async {
  const keys = [
    testPremiumOverrideEnabledOnPreferenceKey,
    calculationCountPreferenceKey,
    completedCostingCountPreferenceKey,
    hasUsedGcodeImportPreferenceKey,
    cancelFeedbackPromptShownStatePreferenceKey,
    cancelFeedbackPromptSubmittedStatePreferenceKey,
    runCountPreferenceKey,
    paywallPreferenceKey,
  ];

  for (final key in keys) {
    if (!sharedPreferences.containsKey(key)) continue;

    final value = sharedPreferences.get(key);
    if (value == null) {
      await sharedPreferences.remove(key);
      continue;
    }

    await premiumLocalStore.write(key, value.toString());
    await sharedPreferences.remove(key);
  }
}
