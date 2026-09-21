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

  test(
    'customer view defaults are private and require a long press to exit',
    () {
      const model = InterfaceSettingsModel();

      expect(model.customerViewEnabled, isFalse);
      expect(model.customerViewShowCostBreakdown, isFalse);
      expect(model.customerViewShowItemBreakdown, isFalse);
      expect(model.customerViewShowBackControl, isFalse);
      expect(model.customerViewDisplayStyle, CustomerViewDisplayStyle.summary);
      expect(model.customerViewExitGesture, CustomerViewExitGesture.longPress);
    },
  );

  test('customer view settings survive storage round trip', () {
    const model = InterfaceSettingsModel(
      customerViewEnabled: true,
      customerViewCompanyName: 'Print Co',
      customerViewShowCostBreakdown: true,
      customerViewShowItemBreakdown: true,
      customerViewDisplayStyle: CustomerViewDisplayStyle.breakdown,
      customerViewExitGesture: CustomerViewExitGesture.tripleTap,
      customerViewShowBackControl: true,
    );

    expect(InterfaceSettingsModel.fromMap(model.toMap()), model);
  });
}
