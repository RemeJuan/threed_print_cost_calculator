import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';

import '../helpers/helpers.dart';
import 'settings_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free users see general and printers settings content', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const NoopLogSink()),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.general.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.general.body')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.section')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.workCost.section')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
      findsOneWidget,
    );
    await tester.dragUntilVisible(
      find.byKey(const ValueKey<String>('settings.premium.title')),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(
      find.byKey(const ValueKey<String>('settings.premium.title')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.premium.button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.materials.add.button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('support.version.tapTarget')),
      findsNothing,
    );
  });

  testWidgets('free users at printer limit see disabled add action', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository();
    final db = await tester.pumpApp(const SettingsPage(), [
      isPremiumProvider.overrideWithValue(false),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      appLogSinkProvider.overrideWithValue(const NoopLogSink()),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value([
          PrinterModel(
            id: 'p1',
            name: 'P1',
            bedSize: '220 x 220',
            wattage: '120',
            archived: false,
          ),
          PrinterModel(
            id: 'p2',
            name: 'P2',
            bedSize: '220 x 220',
            wattage: '120',
            archived: false,
          ),
        ]),
      ),
    ]);
    addTearDown(db.close);
    addTearDown(settingsRepo.dispose);

    settingsRepo.emit(GeneralSettingsModel.initial());

    await tester.pumpAndSettle();

    final addButton = tester.widget<IconButton>(
      find.byKey(const ValueKey<String>('settings.printers.add.button')),
    );
    expect(addButton.onPressed, isNull);
    expect(
      find.text(
        'You can save up to 2 printers on Free. Upgrade to Premium for unlimited printers.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'premium users see printers and work cost sections but not materials',
    (tester) async {
      final settingsRepo = FakeSettingsRepository();
      final db = await tester.pumpApp(const SettingsPage(), [
        isPremiumProvider.overrideWithValue(true),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        appLogSinkProvider.overrideWithValue(const NoopLogSink()),
      ]);
      addTearDown(db.close);
      addTearDown(settingsRepo.dispose);

      settingsRepo.emit(GeneralSettingsModel.initial());

      await tester.pumpAndSettle();

      final generalTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey<String>('settings.general.section')),
      );
      final workCostsTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey<String>('settings.workCost.section')),
      );

      await tester.dragUntilVisible(
        find.byKey(const ValueKey<String>('settings.printers.section')),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('settings.printers.section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.materials.section')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.workCost.section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.printers.add.button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.premium.title')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.materials.add.button')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>('settings.workCost.currencySpacing.toggle'),
        ),
        findsOneWidget,
      );
      expect(generalTopLeft.dy, lessThan(workCostsTopLeft.dy));
      expect(workCostsTopLeft.dy, greaterThan(generalTopLeft.dy));
    },
  );
}
