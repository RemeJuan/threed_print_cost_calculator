import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<(ProviderContainer, SharedPreferences)> createContainer({
    required bool isPremium,
    Map<String, Object> initialValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(initialValues);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        isPremiumProvider.overrideWithValue(isPremium),
      ],
    );
    return (container, prefs);
  }

  test('defaults to showing pro promotions for free users', () async {
    final (container, _) = await createContainer(isPremium: false);
    addTearDown(container.dispose);

    expect(container.read(hideProPromotionsProvider), isFalse);
    expect(container.read(shouldShowProPromotionProvider), isTrue);
  });

  test('updating the preference persists to shared preferences', () async {
    final (container, prefs) = await createContainer(isPremium: false);
    addTearDown(container.dispose);

    await container
        .read(hideProPromotionsProvider.notifier)
        .setHideProPromotions(true);

    expect(container.read(hideProPromotionsProvider), isTrue);
    expect(prefs.getBool(hideProPromotionsPreferenceKey), isTrue);
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
            shouldShowHistoryTeaser: true,
            shouldShowToggle: true,
          ),
          (
            isPremium: false,
            hidePromos: true,
            shouldShowPromo: false,
            shouldShowHistoryTab: false,
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

      expect(container.read(shouldShowProPromotionProvider), c.shouldShowPromo);
      expect(
        container.read(shouldShowHistoryTabProvider),
        c.shouldShowHistoryTab,
      );
      expect(
        container.read(shouldShowHistoryTeaserProvider),
        c.shouldShowHistoryTeaser,
      );
      expect(
        container.read(shouldShowHideProPromotionsToggleProvider),
        c.shouldShowToggle,
      );
    }
  });
}
