import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final premiumAccessPolicyProvider = Provider<PremiumAccessPolicy>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  final hideProPromotions = ref.watch(hideProPromotionsProvider);

  return DefaultPremiumAccessPolicy(
    isPremium: isPremium,
    hideProPromotions: hideProPromotions,
  );
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
    final store = ref.read(premiumLocalStoreProvider);
    return store.readSync(hideProPromotionsPreferenceKey) == 'true';
  }

  Future<void> setHideProPromotions(bool value) async {
    state = value;
    final store = ref.read(premiumLocalStoreProvider);
    await store.write(hideProPromotionsPreferenceKey, value.toString());
  }
}
