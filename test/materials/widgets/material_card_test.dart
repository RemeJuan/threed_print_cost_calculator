import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_card.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

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
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PLA Pro'), findsOneWidget);
      expect(find.text('24.99/kg'), findsOneWidget);
    });

    testWidgets('merges brand, type and cost into single line', (tester) async {
      final m = base.copyWith(brand: 'Sunlu', materialType: 'PLA');
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: m,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PLA · Sunlu · 24.99/kg'), findsOneWidget);
    });

    testWidgets('shows remaining weight when tracking enabled', (tester) async {
      final m = base.copyWith(
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 750,
      );
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: m,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('750'), findsOneWidget);
    });

    testWidgets('fires onEdit callback on tap', (tester) async {
      var edited = false;
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () => edited = true,
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PLA Pro'));
      expect(edited, isTrue);
    });

    testWidgets('swipe reveals edit duplicate delete actions', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slidable), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.content_copy), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('swipe edit button fires onEdit', (tester) async {
      var edited = false;
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () => edited = true,
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slidable), const Offset(-300, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      expect(edited, isTrue);
    });

    testWidgets('swipe duplicate button fires onDuplicate', (tester) async {
      var duplicated = false;
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () => duplicated = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slidable), const Offset(-300, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.content_copy));
      expect(duplicated, isTrue);
    });

    testWidgets('swipe delete shows confirmation then fires onDelete', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: base,
            onEdit: () {},
            onDelete: () => deleted = true,
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Slidable), const Offset(-300, 0));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text(l10n.deleteDialogContent), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, l10n.deleteButton));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('shows In Stock badge when full', (tester) async {
      final m = base.copyWith(
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 1000,
      );
      await tester.pumpWidget(
        _wrap(
          MaterialCard(
            material: m,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
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
        _wrap(
          MaterialCard(
            material: m,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
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
        _wrap(
          MaterialCard(
            material: m,
            onEdit: () {},
            onDelete: () {},
            onDuplicate: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(lookupAppLocalizations(const Locale('en')).stockBadgeOut),
        findsOneWidget,
      );
    });
  });
}
