import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';

import '../../test_support/fake_purchases_gateway.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fetch failure falls back to free state', () async {
    final container = ProviderContainer(
      overrides: [
        purchasesGatewayProvider.overrideWithValue(_FailingGateway()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(premiumStateProvider).isLoading, isTrue);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(premiumStateProvider);
    expect(state.isLoading, isFalse);
    expect(state.isPremium, isFalse);
    expect(state.userId, isEmpty);
  });

  test('initial loading state is replaced by fetched state', () async {
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    final container = ProviderContainer(
      overrides: [purchasesGatewayProvider.overrideWithValue(gateway)],
    );
    addTearDown(container.dispose);

    expect(container.read(premiumStateProvider).isLoading, isTrue);

    await Future<void>.delayed(Duration.zero);

    final state = container.read(premiumStateProvider);
    expect(state.isLoading, isFalse);
    expect(state.isPremium, isTrue);
    expect(state.userId, 'pro-1');
  });

  test('stream events after dispose are ignored', () async {
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );
    final container = ProviderContainer(
      overrides: [purchasesGatewayProvider.overrideWithValue(gateway)],
    );
    final updates = <PremiumState>[];
    final sub = container.listen(
      premiumStateProvider,
      (_, next) => updates.add(next),
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await Future<void>.delayed(Duration.zero);
    expect(updates.last.userId, 'free-1');

    container.dispose();
    gateway.emit(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-2'),
    );
    await Future<void>.delayed(Duration.zero);

    expect(updates.last.userId, 'free-1');
  });

  test(
    'stream updates can be superseded by the initial fetch result',
    () async {
      final gateway = _ControllableGateway();
      final container = ProviderContainer(
        overrides: [purchasesGatewayProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);

      expect(container.read(premiumStateProvider).isLoading, isTrue);

      gateway.emit(
        const PremiumState(
          isPremium: true,
          isLoading: false,
          userId: 'stream-1',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(container.read(premiumStateProvider).userId, 'stream-1');

      gateway.completeFetch(
        const PremiumState(
          isPremium: false,
          isLoading: false,
          userId: 'fetch-1',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final state = container.read(premiumStateProvider);
      expect(state.userId, 'fetch-1');
      expect(state.isPremium, isFalse);
    },
  );

  test(
    'local premium override ignores gateway updates until removed',
    () async {
      SharedPreferences.setMockInitialValues({
        testPremiumOverridePreferenceKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final gateway = FakePurchasesGateway(
        const PremiumState(
          isPremium: false,
          isLoading: false,
          userId: 'free-1',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          purchasesGatewayProvider.overrideWithValue(gateway),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(premiumStateProvider).isPremium, isTrue);

      gateway.emit(
        const PremiumState(
          isPremium: false,
          isLoading: false,
          userId: 'free-2',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      var state = container.read(premiumStateProvider);
      expect(state.isPremium, isTrue);

      await prefs.remove(testPremiumOverridePreferenceKey);
      container.read(appRefreshProvider.notifier).refresh();
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
        state = container.read(premiumStateProvider);
        if (!state.isLoading) break;
      }

      state = container.read(premiumStateProvider);
      expect(state.isLoading, isFalse);
      expect(state.isPremium, isFalse);
    },
  );
}

class _FailingGateway implements PurchasesGateway {
  @override
  Future<PremiumState> fetchPremiumState() async {
    throw StateError('boom');
  }

  @override
  Stream<PremiumState> watchPremiumState() =>
      const Stream<PremiumState>.empty();

  @override
  void dispose() {}
}

class _ControllableGateway implements PurchasesGateway {
  final _controller = StreamController<PremiumState>.broadcast();
  final Completer<PremiumState> _fetch = Completer<PremiumState>();

  @override
  Future<PremiumState> fetchPremiumState() => _fetch.future;

  @override
  Stream<PremiumState> watchPremiumState() => _controller.stream;

  void emit(PremiumState state) {
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  void completeFetch(PremiumState state) {
    if (!_fetch.isCompleted) {
      _fetch.complete(state);
    }
  }

  @override
  void dispose() {
    _controller.close();
    if (!_fetch.isCompleted) {
      _fetch.complete(const PremiumState(isPremium: false, isLoading: false));
    }
  }
}
