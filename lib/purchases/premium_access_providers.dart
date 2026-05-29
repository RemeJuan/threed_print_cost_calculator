import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

const hideProPromotionsPreferenceKey = 'hideProPromotions';

final premiumAccessPolicyProvider = Provider<PremiumAccessPolicy>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final hideProPromotions = ref.watch(hideProPromotionsProvider);

  return DefaultPremiumAccessPolicy(
    isPremium: isPremium,
    hideProPromotions: hideProPromotions,
  );
});

final premiumLocalStoreProvider = Provider<SharedPreferences>((ref) {
  return ref.watch(sharedPreferencesProvider);
});

final hideProPromotionsProvider =
    NotifierProvider<HideProPromotionsNotifier, bool>(
      HideProPromotionsNotifier.new,
    );

final shouldShowHideProPromotionsToggleProvider = Provider<bool>((ref) {
  return !ref.watch(premiumAccessPolicyProvider).isPremium;
});

class HideProPromotionsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(hideProPromotionsPreferenceKey) ?? false;
  }

  Future<void> setHideProPromotions(bool value) async {
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(hideProPromotionsPreferenceKey, value);
  }
}

final shouldShowProPromotionProvider = Provider<bool>((ref) {
  return ref.watch(premiumAccessPolicyProvider).shouldShowPromotions;
});

final shouldShowHistoryTabProvider = Provider<bool>((ref) {
  return ref.watch(premiumAccessPolicyProvider).shouldShowHistoryTab;
});

final shouldShowHistoryTeaserProvider = Provider<bool>((ref) {
  return ref.watch(premiumAccessPolicyProvider).shouldShowHistoryTeaser;
});
