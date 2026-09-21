import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_data.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

import '../helpers/helpers.dart';

const _currencySettings = GeneralSettingsModel(
  electricityCost: '',
  wattage: '',
  activePrinter: '',
  selectedMaterial: '',
  wearAndTear: '',
  failureRisk: '',
  labourRate: '',
);

void main() {
  setUp(setupTest);

  Future<void> pumpRoute(
    WidgetTester tester,
    InterfaceSettingsModel settings,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CustomerViewPage(
                  data: const CustomerViewData(finalPrice: 36),
                  settings: settings,
                  currencySettings: _currencySettings,
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('defaults expose final price but hide internal details', (
    tester,
  ) async {
    await tester.pumpApp(
      const CustomerViewPage(
        data: CustomerViewData(
          finalPrice: 36,
          filament: 20,
          electricity: 2,
          risk: 3,
          labour: 5,
        ),
        settings: InterfaceSettingsModel(),
        currencySettings: _currencySettings,
      ),
    );

    expect(
      find.byKey(const ValueKey('customer-view.final-price')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('customer-view.back-button')),
      findsNothing,
    );
    expect(find.text('Breakdown'), findsNothing);
    expect(find.text('Filament'), findsNothing);
  });

  testWidgets('configured view shows business, details and back control', (
    tester,
  ) async {
    await tester.pumpApp(
      const CustomerViewPage(
        data: CustomerViewData(
          finalPrice: 36,
          filament: 20,
          electricity: 2,
          risk: 3,
          labour: 5,
          items: [CustomerViewLineItem(name: 'Cube', quantity: 2, total: 36)],
        ),
        settings: InterfaceSettingsModel(
          customerViewCompanyName: 'Print Co',
          customerViewShowCostBreakdown: true,
          customerViewShowItemBreakdown: true,
          customerViewShowMaterial: true,
          customerViewShowElectricity: true,
          customerViewShowFailureRisk: true,
          customerViewShowLabour: true,
          customerViewDisplayStyle: CustomerViewDisplayStyle.breakdown,
          customerViewShowBackControl: true,
        ),
        currencySettings: _currencySettings,
      ),
    );

    expect(find.text('Print Co'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('customer-view.back-button')),
      findsOneWidget,
    );
    expect(find.text('Breakdown'), findsOneWidget);
    expect(find.text('Cube'), findsOneWidget);
  });

  testWidgets('configured exit gesture returns to the previous screen', (
    tester,
  ) async {
    await pumpRoute(tester, const InterfaceSettingsModel());
    await tester.longPress(
      find.byKey(const ValueKey('customer-view.exit-target')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);

    await pumpRoute(
      tester,
      const InterfaceSettingsModel(
        customerViewExitGesture: CustomerViewExitGesture.singleTap,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('customer-view.exit-target')));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);

    await pumpRoute(
      tester,
      const InterfaceSettingsModel(
        customerViewExitGesture: CustomerViewExitGesture.tripleTap,
      ),
    );
    final target = find.byKey(const ValueKey('customer-view.exit-target'));
    await tester.tap(target);
    await tester.tap(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
