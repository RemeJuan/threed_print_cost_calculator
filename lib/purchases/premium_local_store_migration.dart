import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';

Future<void> migratePremiumLocalStore({
  required SharedPreferences sharedPreferences,
  required PremiumLocalStore premiumLocalStore,
}) async {
  const keys = [
    hideProPromotionsPreferenceKey,
    testPremiumOverrideEnabledOnPreferenceKey,
    calculationCountPreferenceKey,
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
