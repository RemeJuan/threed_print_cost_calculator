import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';

void main() {
  test('maps sdk customer info into premium state', () async {
    final adapter = FakePurchasesSdkAdapter(
      const RevenueCatCustomerInfo(
        hasActiveEntitlements: true,
        originalAppUserId: 'pro-1',
      ),
    );
    final gateway = RevenueCatPurchasesGateway(sdkAdapter: adapter);

    final state = await gateway.fetchPremiumState();

    expect(state, isA<PremiumState>());
    expect(state.isPremium, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.userId, 'pro-1');
  });

  test('registers and removes a single sdk listener', () async {
    final adapter = FakePurchasesSdkAdapter(
      const RevenueCatCustomerInfo(
        hasActiveEntitlements: false,
        originalAppUserId: 'free-1',
      ),
    );
    final gateway = RevenueCatPurchasesGateway(sdkAdapter: adapter);

    gateway.watchPremiumState();
    gateway.watchPremiumState();

    expect(adapter.addListenerCalls, 1);

    gateway.dispose();

    expect(adapter.removeListenerCalls, 1);
  });

  test('forwards sdk updates through the premium state stream', () async {
    final adapter = FakePurchasesSdkAdapter(
      const RevenueCatCustomerInfo(
        hasActiveEntitlements: false,
        originalAppUserId: 'free-1',
      ),
    );
    final gateway = RevenueCatPurchasesGateway(sdkAdapter: adapter);
    final states = <PremiumState>[];
    final subscription = gateway.watchPremiumState().listen(states.add);
    addTearDown(subscription.cancel);
    addTearDown(gateway.dispose);

    adapter.emit(
      const RevenueCatCustomerInfo(
        hasActiveEntitlements: true,
        originalAppUserId: 'pro-2',
      ),
    );

    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(1));
    expect(states.single.isPremium, isTrue);
    expect(states.single.userId, 'pro-2');
  });

  test('propagates fetch failures from the sdk adapter', () async {
    final gateway = RevenueCatPurchasesGateway(
      sdkAdapter: FakePurchasesSdkAdapter(
        const RevenueCatCustomerInfo(
          hasActiveEntitlements: false,
          originalAppUserId: 'free-1',
        ),
        fetchError: StateError('boom'),
      ),
    );

    await expectLater(gateway.fetchPremiumState(), throwsStateError);
  });
}

class FakePurchasesSdkAdapter implements PurchasesSdkAdapter {
  FakePurchasesSdkAdapter(this.customerInfo, {this.fetchError});

  RevenueCatCustomerInfo customerInfo;
  final Object? fetchError;
  int addListenerCalls = 0;
  int removeListenerCalls = 0;
  void Function(RevenueCatCustomerInfo info)? _listener;

  @override
  Future<RevenueCatCustomerInfo> getCustomerInfo() async {
    if (fetchError != null) {
      throw fetchError!;
    }
    return customerInfo;
  }

  @override
  void addCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  ) {
    addListenerCalls += 1;
    _listener = listener;
  }

  @override
  void removeCustomerInfoUpdateListener(
    void Function(RevenueCatCustomerInfo info) listener,
  ) {
    removeListenerCalls += 1;
    if (identical(_listener, listener)) {
      _listener = null;
    }
  }

  void emit(RevenueCatCustomerInfo info) {
    _listener?.call(info);
  }
}
