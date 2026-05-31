import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, InMemoryPremiumLocalStore)> createContainer({
    required bool isPremium,
    Map<String, Object> initialValues = const {},
  }) async {
    final store = InMemoryPremiumLocalStore(
      initialValues.map((key, value) => MapEntry(key, value.toString())),
    );
    final container = ProviderContainer(
      overrides: [
        isPremiumProvider.overrideWithValue(isPremium),
        premiumLocalStoreProvider.overrideWithValue(store),
      ],
    );
    return (container, store);
  }

  test('defaults to showing pro promotions for free users', () async {
    final (container, _) = await createContainer(isPremium: false);
    addTearDown(container.dispose);

    expect(container.read(hideProPromotionsProvider), isFalse);
    expect(
      container.read(premiumAccessPolicyProvider).shouldShowPromotions,
      isTrue,
    );
  });

  test('updating the preference persists to shared preferences', () async {
    final (container, store) = await createContainer(isPremium: false);
    addTearDown(container.dispose);

    await container
        .read(hideProPromotionsProvider.notifier)
        .setHideProPromotions(true);

    expect(container.read(hideProPromotionsProvider), isTrue);
    expect(store.readSync(hideProPromotionsPreferenceKey), 'true');
  });

  test('derived helpers follow entitlement and preference state', () async {
    final cases =
        <
          ({
            bool isPremium,
            bool hidePromos,
            bool shouldShowPromo,
            bool shouldShowHistoryTab,
            bool shouldShowHistoryTeaser,
            bool shouldShowToggle,
          })
        >[
          (
            isPremium: false,
            hidePromos: false,
            shouldShowPromo: true,
            shouldShowHistoryTab: true,
            shouldShowHistoryTeaser: false,
            shouldShowToggle: true,
          ),
          (
            isPremium: false,
            hidePromos: true,
            shouldShowPromo: false,
            shouldShowHistoryTab: true,
            shouldShowHistoryTeaser: false,
            shouldShowToggle: true,
          ),
          (
            isPremium: true,
            hidePromos: false,
            shouldShowPromo: false,
            shouldShowHistoryTab: true,
            shouldShowHistoryTeaser: false,
            shouldShowToggle: false,
          ),
          (
            isPremium: true,
            hidePromos: true,
            shouldShowPromo: false,
            shouldShowHistoryTab: true,
            shouldShowHistoryTeaser: false,
            shouldShowToggle: false,
          ),
        ];

    for (final c in cases) {
      final (container, _) = await createContainer(
        isPremium: c.isPremium,
        initialValues: {hideProPromotionsPreferenceKey: c.hidePromos},
      );
      addTearDown(container.dispose);

      final policy = container.read(premiumAccessPolicyProvider);
      expect(policy.shouldShowPromotions, c.shouldShowPromo);
      expect(policy.shouldShowHistoryTab, c.shouldShowHistoryTab);
      expect(policy.shouldShowHistoryTeaser, c.shouldShowHistoryTeaser);
      expect(
        container.read(shouldShowHideProPromotionsToggleProvider),
        c.shouldShowToggle,
      );
    }
  });
}
