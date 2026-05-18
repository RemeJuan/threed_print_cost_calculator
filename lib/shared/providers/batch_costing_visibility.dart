import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

const batchCostingEnabledPreferenceKey = 'batchCostingEnabled';

final batchCostingEnabledProvider =
    NotifierProvider<BatchCostingEnabledNotifier, bool>(
      BatchCostingEnabledNotifier.new,
    );

class BatchCostingEnabledNotifier extends Notifier<bool> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build() {
    if (!ref.watch(isPremiumProvider)) return false;
    return _prefs.getBool(batchCostingEnabledPreferenceKey) ?? false;
  }

  Future<void> setBatchCostingEnabled(bool value) async {
    state = value;
    await _prefs.setBool(batchCostingEnabledPreferenceKey, value);
  }
}
