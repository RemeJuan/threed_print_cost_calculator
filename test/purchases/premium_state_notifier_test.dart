import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../test_support/fake_purchases_gateway.dart';

void main() {
  test(
    'updates premium state when gateway emits subscription changes',
    () async {
      final gateway = FakePurchasesGateway(
        const PremiumState(isPremium: false, isLoading: false, userId: 'free'),
      );
      final container = ProviderContainer(
        overrides: [purchasesGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);

      expect(container.read(premiumStateProvider).isLoading, isTrue);

      await Future<void>.delayed(Duration.zero);

      expect(container.read(premiumStateProvider).isPremium, isFalse);
      expect(container.read(premiumStateProvider).userId, 'free');

      gateway.emit(
        const PremiumState(isPremium: true, isLoading: false, userId: 'pro'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(container.read(premiumStateProvider).isPremium, isTrue);
      expect(container.read(premiumStateProvider).userId, 'pro');
    },
  );
}
