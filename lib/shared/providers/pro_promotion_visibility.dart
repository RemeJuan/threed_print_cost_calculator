import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

const hideProPromotionsPreferenceKey = 'hideProPromotions';

final hideProPromotionsProvider =
    NotifierProvider<HideProPromotionsNotifier, bool>(
      HideProPromotionsNotifier.new,
    );

final shouldShowProPromotionProvider = Provider<bool>((ref) {
  if (ref.watch(isPremiumProvider)) {
    return false;
  }

  return !ref.watch(hideProPromotionsProvider);
});

final shouldShowHistoryTabProvider = Provider<bool>((ref) {
  return ref.watch(isPremiumProvider) ||
      ref.watch(shouldShowProPromotionProvider);
});

final shouldShowHistoryTeaserProvider = Provider<bool>((ref) {
  return !ref.watch(isPremiumProvider) &&
      ref.watch(shouldShowHistoryTabProvider);
});

final shouldShowHideProPromotionsToggleProvider = Provider<bool>((ref) {
  return !ref.watch(isPremiumProvider);
});

class HideProPromotionsNotifier extends Notifier<bool> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  bool build() {
    return _prefs.getBool(hideProPromotionsPreferenceKey) ?? false;
  }

  Future<void> setHideProPromotions(bool value) async {
    state = value;
    await _prefs.setBool(hideProPromotionsPreferenceKey, value);
  }
}
