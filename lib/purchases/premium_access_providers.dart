import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

final premiumAccessPolicyProvider = Provider<PremiumAccessPolicy>((ref) {
  final isPremium = ref.watch(isPremiumProvider);

  return DefaultPremiumAccessPolicy(isPremium: isPremium);
});
