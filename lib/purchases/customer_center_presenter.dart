import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

abstract class CustomerCenterPresenter {
  Future<void> present();
}

typedef CustomerCenterPresentation = Future<void> Function();

final customerCenterPresenterProvider = Provider<CustomerCenterPresenter>((
  ref,
) {
  return CustomerCenterPresenterImpl();
});

class CustomerCenterPresenterImpl implements CustomerCenterPresenter {
  CustomerCenterPresenterImpl({
    CustomerCenterPresentation presentCustomerCenter =
        RevenueCatUI.presentCustomerCenter,
  }) : _presentCustomerCenter = presentCustomerCenter;

  final CustomerCenterPresentation _presentCustomerCenter;
  Future<void>? _pendingPresentation;

  @override
  Future<void> present() {
    return _pendingPresentation ??= _present().whenComplete(() {
      _pendingPresentation = null;
    });
  }

  Future<void> _present() => _presentCustomerCenter();
}
