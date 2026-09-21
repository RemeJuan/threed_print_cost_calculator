import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_data.dart';
import 'package:threed_print_cost_calculator/customer_view/customer_view_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

import 'package:threed_print_cost_calculator/shared/theme.dart';

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

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
    const Size(1024, 768),
  ]) {
    for (final showDetails in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('presentation fits $size details=$showDetails text=$scale', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpApp(
            Theme(
              data: theme(),
              child: MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                ),
                child: CustomerViewPage(
                  data: const CustomerViewData(
                    finalPrice: 1234567.89,
                    baseCost: 30,
                    electricity: 2.5,
                    filament: 20,
                    risk: 3,
                    labour: 4.5,
                    additionalCost: 5,
                    markup: 6,
                    setupFee: 7,
                    roundingAdjustment: -0.1,
                    items: [
                      CustomerViewLineItem(
                        name:
                            'A detailed custom print with a long descriptive name',
                        quantity: 200,
                        total: 1234567.89,
                      ),
                    ],
                  ),
                  settings: InterfaceSettingsModel(
                    customerViewCompanyName:
                        'A long company name for custom printing and design',
                    customerViewShowBaseCost: showDetails,
                    customerViewShowElectricity: showDetails,
                    customerViewShowMaterial: showDetails,
                    customerViewShowFailureRisk: showDetails,
                    customerViewShowLabour: showDetails,
                    customerViewShowAdditionalCost: showDetails,
                    customerViewShowMarkup: showDetails,
                    customerViewShowSetupFee: showDetails,
                    customerViewShowRoundingAdjustment: showDetails,
                    customerViewShowItemBreakdown: showDetails,
                  ),
                  currencySettings: _currencySettings,
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(
            find.text('Breakdown'),
            showDetails ? findsOneWidget : findsNothing,
          );
          expect(
            find.text('Items'),
            showDetails ? findsOneWidget : findsNothing,
          );
          expect(
            find.byKey(const ValueKey('customer-view.final-price')),
            findsOneWidget,
          );
        });
      }
    }
  }

  testWidgets('individual visibility preserves total and omits absent values', (
    tester,
  ) async {
    await tester.pumpApp(
      const CustomerViewPage(
        data: CustomerViewData(
          finalPrice: 42.5,
          baseCost: 30,
          filament: 20,
          electricity: 2.5,
          risk: 3,
          labour: 0,
          setupFee: null,
          roundingAdjustment: -0.5,
        ),
        settings: InterfaceSettingsModel(
          customerViewShowMaterial: true,
          customerViewShowLabour: true,
          customerViewShowSetupFee: true,
          customerViewShowRoundingAdjustment: true,
        ),
        currencySettings: _currencySettings,
      ),
    );
    expect(find.text('Filament'), findsOneWidget);
    expect(find.text('Electricity'), findsNothing);
    expect(find.text('Base cost'), findsNothing);
    expect(find.text('Risk'), findsNothing);
    expect(find.text('Labour/Materials'), findsNothing);
    expect(find.text('-0.50'), findsOneWidget);
    expect(find.text('42.50'), findsOneWidget);
    expect(find.text('Items'), findsNothing);
  });

  for (final width in [390.0, 1024.0]) {
    testWidgets('items precede costs at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = CustomerViewData.preview();
      await tester.pumpApp(
        CustomerViewPage(
          data: data,
          settings: const InterfaceSettingsModel(
            customerViewShowItemBreakdown: true,
            customerViewShowMaterial: true,
          ),
          currencySettings: _currencySettings,
        ),
      );

      final price = tester.getTopLeft(
        find.byKey(const ValueKey('customer-view.final-price')),
      );
      final items = tester.getTopLeft(find.text('Items'));
      final costs = tester.getTopLeft(find.text('Breakdown'));
      expect(items.dy, greaterThan(price.dy));
      if (width < 720) {
        expect(items.dy, lessThan(costs.dy));
      } else {
        expect(items.dx, lessThan(costs.dx));
      }
      for (final item in data.items) {
        expect(find.text(item.name), findsOneWidget);
      }
      expect(
        data.items.fold<num>(0, (sum, item) => sum + item.total),
        data.finalPrice,
      );
      expect(tester.takeException(), isNull);
    });
  }

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
