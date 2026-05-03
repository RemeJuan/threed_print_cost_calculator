import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_card.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

import '../../helpers/helpers.dart';

Widget _wrap(Widget w) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: w),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('MaterialCard', () {
    final base = MaterialModel(
      id: 'm1',
      name: 'PLA Pro',
      cost: '24.99',
      color: 'Black',
      weight: '1000',
      archived: false,
    );

    testWidgets('renders name and cost-per-kg', (tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final db = await tester.pumpApp(
        MaterialCard(material: base, onEdit: () {}, onDelete: () {}),
        [
          settingsStreamProvider.overrideWith(
            (ref) => Stream.value(
              const GeneralSettingsModel(
                electricityCost: '',
                wattage: '',
                activePrinter: '',
                selectedMaterial: '',
                wearAndTear: '',
                failureRisk: '',
                labourRate: '',
                pricingMarkupPercent: '',
                pricingSetupFee: '',
                pricingRoundingMode: 'none',
                currencySymbol: 'R',
                currencyPosition: 'before',
                currencySpacing: false,
              ),
            ),
          ),
        ],
      );
      addTearDown(db.close);
      await tester.pumpAndSettle();

      expect(find.text('PLA Pro'), findsOneWidget);
      expect(find.text(l10n.materialCostPerKilogramLabel('R24.99')), findsOneWidget);
    });

    testWidgets('merges brand, type and cost into single line', (tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final m = base.copyWith(brand: 'Sunlu', materialType: 'PLA');
      await tester.pumpWidget(
        _wrap(MaterialCard(material: m, onEdit: () {}, onDelete: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(l10n.materialCostPerKilogramLabel('24.99')), findsOneWidget);
    });

    testWidgets('shows remaining weight when tracking enabled', (tester) async {
      final m = base.copyWith(
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 750,
      );
      await tester.pumpWidget(
        _wrap(MaterialCard(material: m, onEdit: () {}, onDelete: () {})),
      );
      await tester.pumpAndSettle();

      expect(find.text('750g'), findsOneWidget);
    });

    testWidgets('fires onEdit callback on tap', (tester) async {
      var edited = false;
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () => edited = true,
            onDelete: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PLA Pro'));
      expect(edited, isTrue);
    });

    testWidgets('shows In Stock badge when full', (tester) async {
      final m = base.copyWith(
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 1000,
      );
      await tester.pumpWidget(
        _wrap(MaterialCard(material: m, onEdit: () {}, onDelete: () {})),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(lookupAppLocalizations(const Locale('en')).stockBadgeInStock),
        findsOneWidget,
      );
    });

    testWidgets('shows Low badge near threshold', (tester) async {
      final m = base.copyWith(
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 100,
      );
      await tester.pumpWidget(
        _wrap(MaterialCard(material: m, onEdit: () {}, onDelete: () {})),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(lookupAppLocalizations(const Locale('en')).stockBadgeLow),
        findsOneWidget,
      );
    });

    testWidgets('shows Out badge when empty', (tester) async {
      final m = base.copyWith(
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 0,
      );
      await tester.pumpWidget(
        _wrap(MaterialCard(material: m, onEdit: () {}, onDelete: () {})),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(lookupAppLocalizations(const Locale('en')).stockBadgeOut),
        findsOneWidget,
      );
    });
  });
}
