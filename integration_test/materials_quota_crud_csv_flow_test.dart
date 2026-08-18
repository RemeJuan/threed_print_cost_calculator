import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_page.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_export_service.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

class RecordingMaterialsCsvExportService extends MaterialsCsvExportService {
  RecordingMaterialsCsvExportService(super.ref);

  bool called = false;

  @override
  Future<String> buildCsv() async {
    called = true;
    return materialsCsvHeader;
  }
}

class RecordingCsvImportService extends CsvImportService {
  RecordingCsvImportService(super.ref);

  bool called = false;

  @override
  Future<CsvImportResult> importRows(List<CsvImportRow> rows) async {
    called = true;
    return CsvImportResult(
      created: rows.where((row) => row.kind == CsvImportRowKind.create).length,
      updated: rows.where((row) => row.kind == CsvImportRowKind.update).length,
      invalidRows: rows.where((row) => row.errors.isNotEmpty).toList(),
      skippedRows: const [],
      saveFailures: const [],
    );
  }
}

CsvImportParser _parser() => const CsvImportParser();

ClassifiedCsvImport _review() {
  final csv = [
    materialsCsvHeader,
    'existing-1,Updated PLA,Brand,PLA,Black,#000000,1000,900,20,true,false,Notes',
    ',New PETG,Brand,PETG,White,#ffffff,1000,1000,25,false,false,Notes',
    'broken-1,,Brand,PLA,Black,#000000,1000,900,20,true,false,Notes',
  ].join('\n');
  return _parser().classify(
    file: parseCsvImportFile(csv),
    existingIds: {'existing-1': true},
  );
}

Future<void> _openMaterialsTab(WidgetTester tester) async {
  await tester.tapByKey('nav.materials.button');
  expect(
    find.byKey(const ValueKey<String>('materials.search.input')),
    findsOneWidget,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const originalName = 'Integration PLA';
  const updatedName = 'Integration PLA v2';

  testWidgets('free materials quota disables create at limit', (tester) async {
    final harness = await IntegrationTestHarness.free(
      seed: (harness) async {
        await harness.seedMaterials(
          List.generate(
            5,
            (index) => IntegrationFixtures.buildMaterial(
              id: 'free-material-$index',
              name: 'Free Material $index',
              cost: '20',
              color: 'Black',
              weight: '1000',
            ),
          ),
        );
      },
    );
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await _openMaterialsTab(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.materialLimitReachedMessage), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(
            find.byKey(const ValueKey<String>('materials.create.button')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('premium materials CRUD works in tab', (tester) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await _openMaterialsTab(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('materials.create.button')),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.enterTextByKey('settings.materials.name.input', originalName);
    await tester.enterTextByKey('settings.materials.color.input', 'Black');
    await tester.enterTextByKey('settings.materials.weight.input', '1000');
    await tester.enterTextByKey('settings.materials.cost.input', '20');
    await tester.tapByKey('settings.materials.save.button');

    expect(find.text(originalName), findsOneWidget);

    await tester.drag(find.text(originalName), const Offset(-500, 0));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(
      find.byKey(
        const ValueKey<String>('materials.edit.button.free-material-0'),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.enterTextByKey('settings.materials.name.input', updatedName);
    await tester.tapByKey('settings.materials.save.button');

    expect(find.text(updatedName), findsOneWidget);

    await tester.drag(find.text(updatedName), const Offset(-500, 0));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(
      find.byKey(
        const ValueKey<String>('materials.delete.button.free-material-0'),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(
      find.byKey(
        const ValueKey<String>(
          'materials.delete.confirm.button.free-material-0',
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text(updatedName), findsNothing);
  });

  testWidgets('premium csv import review and export seam stay callable', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium(
      overrides: [
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
        materialsCsvExportServiceProvider.overrideWith(
          (ref) => RecordingMaterialsCsvExportService(ref),
        ),
        csvImportServiceProvider.overrideWith(
          (ref) => RecordingCsvImportService(ref),
        ),
      ],
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: harness.container,
        child: MaterialApp(
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CsvImportPage(initialReview: _review()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('csv_import.needs_fixing.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('csv_import.updating.section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('csv_import.creating.section')),
      findsOneWidget,
    );
    await tester.tapByKey('csv_import.apply.button');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final importService =
        harness.container.read(csvImportServiceProvider)
            as RecordingCsvImportService;
    expect(importService.called, isTrue);
    expect(
      find.byKey(const ValueKey<String>('csv_import.return.button')),
      findsOneWidget,
    );
  });

  testWidgets('premium materials export seam is callable from tab', (
    tester,
  ) async {
    RecordingMaterialsCsvExportService? exportService;
    final harness = await IntegrationTestHarness.premium(
      overrides: [
        materialsCsvExportServiceProvider.overrideWith((ref) {
          final service = RecordingMaterialsCsvExportService(ref);
          exportService = service;
          return service;
        }),
      ],
    );
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await _openMaterialsTab(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('materials.export.button')),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(exportService?.called, isTrue);
  });
}
