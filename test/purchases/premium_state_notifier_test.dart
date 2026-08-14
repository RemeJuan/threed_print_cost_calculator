import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_memory.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_api.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/seed_loader.dart';

import '../../test_support/fake_purchases_gateway.dart';

void main() {
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
      final overrideValue = formatTestPremiumOverrideDay(DateTime.now());
      final store = InMemoryPremiumLocalStore({
        testPremiumOverrideEnabledOnPreferenceKey: overrideValue,
      });
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
          premiumLocalStoreProvider.overrideWithValue(store),
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

      await store.delete(testPremiumOverrideEnabledOnPreferenceKey);
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

  test('expired local premium override cleans up once and refreshes', () async {
    final store = _CountingStore({
      testPremiumOverrideEnabledOnPreferenceKey: '2000-01-01',
    });
    late final _NoopTestDataService testDataService;
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );
    final container = ProviderContainer(
      overrides: [
        purchasesGatewayProvider.overrideWithValue(gateway),
        premiumLocalStoreProvider.overrideWithValue(store),
        testDataServiceProvider.overrideWith((ref) {
          testDataService = _NoopTestDataService(ref, store);
          return testDataService;
        }),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(premiumStateProvider).isLoading, isTrue);

    final states = <PremiumState>[];
    final sub = container.listen(
      premiumStateProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(sub.close);

    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
      if (container.read(premiumStateProvider).isLoading == false) break;
    }

    expect(testDataService.purgeCalls, 1);

    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
      final state = container.read(premiumStateProvider);
      if (!state.isLoading && !state.isPremium) break;
    }
    expect(testDataService.purgeCalls, 1);
    expect(container.read(premiumStateProvider).isPremium, isFalse);
    expect(container.read(premiumStateProvider).isLoading, isFalse);
    expect(states.last.isPremium, isFalse);
    expect(states.last.isLoading, isFalse);
  });
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

class _CountingStore implements PremiumLocalStore {
  _CountingStore(Map<String, String> values) : _values = {...values};

  final Map<String, String> _values;
  int deleteCalls = 0;

  @override
  String? readSync(String key) => _values[key];

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    deleteCalls++;
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.unmodifiable(_values);
}

class _NoopTestDataService extends TestDataService {
  _NoopTestDataService(super.ref, this._store)
    : super(loader: const _NoopSeedLoader());

  final PremiumLocalStore _store;

  int purgeCalls = 0;

  @override
  Future<TestDataOperationResult> purge() async {
    purgeCalls++;
    await _store.delete(testPremiumOverrideEnabledOnPreferenceKey);
    return const TestDataOperationResult.success();
  }
}

class _NoopSeedLoader implements SeedLoader {
  const _NoopSeedLoader();

  @override
  Future<SeedDataBundle> load({String subdirectory = 'free'}) async =>
      throw UnimplementedError();
}
