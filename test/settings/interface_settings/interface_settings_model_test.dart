import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';

void main() {
  test('default interface settings are default view', () {
    const model = InterfaceSettingsModel();
    expect(model.isDefaultView, isTrue);
    expect(model.isCustomView, isFalse);
  });

  test('disabled toggle flips to custom view', () {
    const model = InterfaceSettingsModel(showCurrency: false);
    expect(model.isDefaultView, isFalse);
    expect(model.isCustomView, isTrue);
  });
}
