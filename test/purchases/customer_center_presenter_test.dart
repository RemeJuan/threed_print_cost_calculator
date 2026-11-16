import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/customer_center_presenter.dart';

void main() {
  test('serializes duplicate presentations', () async {
    final completer = Completer<void>();
    var calls = 0;
    final presenter = CustomerCenterPresenterImpl(
      presentCustomerCenter: () {
        calls++;
        return completer.future;
      },
    );

    final first = presenter.present();
    final second = presenter.present();

    expect(calls, 1);
    expect(identical(first, second), isTrue);

    completer.complete();
    await first;
  });

  test('allows another presentation after completion', () async {
    var calls = 0;
    final presenter = CustomerCenterPresenterImpl(
      presentCustomerCenter: () async {
        calls++;
      },
    );

    await presenter.present();
    await presenter.present();

    expect(calls, 2);
  });

  test('surfaces native presentation errors and releases the gate', () async {
    var calls = 0;
    final presenter = CustomerCenterPresenterImpl(
      presentCustomerCenter: () async {
        calls++;
        if (calls == 1) throw StateError('Native presentation failed');
      },
    );

    await expectLater(presenter.present(), throwsStateError);
    await presenter.present();

    expect(calls, 2);
  });
}
