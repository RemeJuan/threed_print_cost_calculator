import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_page.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';

import '../../helpers/helpers.dart';

class TestMaterialsRepository extends MaterialsRepository {
  TestMaterialsRepository(super.ref);

  @override
  Future<Map<String, bool>> existingIds(Set<String> ids) async => {
    for (final id in ids) id: id == 'existing-1',
  };
}

class RecordingImportService extends CsvImportService {
  RecordingImportService(super.ref);

  bool called = false;

  @override
  Future<CsvImportResult> importRows(List<CsvImportRow> rows) async {
    called = true;
    return CsvImportResult(
      created: 1,
      updated: 1,
      invalidRows: rows.where((row) => row.errors.isNotEmpty).toList(),
      skippedRows: const [],
      saveFailures: const [],
    );
  }
}

class ThrowingImportService extends CsvImportService {
  ThrowingImportService(super.ref);

  @override
  Future<CsvImportResult> importRows(List<CsvImportRow> rows) {
    throw StateError('save failed');
  }
}

ClassifiedCsvImport _review() {
  final csv = [
    materialsCsvHeader,
    'existing-1,Updated PLA,Brand,PLA,Black,#000000,1000,900,20,true,false,Notes',
    ',New PETG,Brand,PETG,White,#ffffff,1000,1000,25,false,false,Notes',
    'broken-1,,Brand,PLA,Black,#000000,1000,900,20,true,false,Notes',
  ].join('\n');
  return const CsvImportParser().classify(
    file: parseCsvImportFile(csv),
    existingIds: {'existing-1': true},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('CsvImportPage', () {
    testWidgets('shows intro state with upload button', (tester) async {
      final db = await tester.pumpApp(const CsvImportPage());
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.csvImportTitle), findsOneWidget);
      expect(find.text(l10n.csvImportIntro), findsOneWidget);
      expect(find.text(l10n.csvSelectFileButton), findsOneWidget);
      expect(find.text(l10n.csvTemplateButton), findsOneWidget);
    });

    test('maps header and read failures to distinct localized messages', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(
        csvImportFileErrorMessage(l10n, CsvImportHeaderException()),
        l10n.csvInvalidHeaderError,
      );
      expect(
        csvImportFileErrorMessage(l10n, StateError('read')),
        l10n.csvReadError,
      );
    });

    testWidgets(
      'reviews counts in needs-fixing, updating, and creating accordions',
      (tester) async {
        final db = await tester
            .pumpApp(CsvImportPage(initialReview: _review()), [
              premiumAccessPolicyProvider.overrideWithValue(
                DefaultPremiumAccessPolicy(isPremium: true),
              ),
              materialsRepositoryProvider.overrideWith(
                (ref) => TestMaterialsRepository(ref),
              ),
            ]);
        addTearDown(db.close);
        await tester.pumpAndSettle();

        final l10n = lookupAppLocalizations(const Locale('en'));
        expect(
          find.text(l10n.csvImportReviewSummary(1, 1, 3, 1)),
          findsOneWidget,
        );
        expect(find.text(l10n.csvImportNeedsFixingSection(1)), findsOneWidget);
        expect(find.text(l10n.csvImportUpdatingSection(1)), findsOneWidget);
        expect(find.text(l10n.csvImportCreatingSection(1)), findsOneWidget);
        expect(find.text(l10n.csvEmptyNamePlaceholder), findsOneWidget);
        expect(find.text(l10n.csvNameRequiredError), findsOneWidget);
        expect(find.text(l10n.csvImportApplyButton(1, 1)), findsOneWidget);
      },
    );

    testWidgets('shows persistent import result before returning', (
      tester,
    ) async {
      final service = await tester.pumpAppWithContainer(
        CsvImportPage(initialReview: _review()),
        overrides: [
          premiumAccessPolicyProvider.overrideWithValue(
            DefaultPremiumAccessPolicy(isPremium: true),
          ),
          materialsRepositoryProvider.overrideWith(
            (ref) => TestMaterialsRepository(ref),
          ),
          csvImportServiceProvider.overrideWith(
            (ref) => RecordingImportService(ref),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('csv_import.apply.button')),
      );
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.csvImportResultTitle), findsOneWidget);
      expect(find.text(l10n.csvImportResultUpdated(1)), findsOneWidget);
      expect(find.text(l10n.csvImportResultCreated(1)), findsOneWidget);
      expect(find.text(l10n.csvImportResultSkipped(1)), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('csv_import.return.button')),
        findsOneWidget,
      );
      expect(
        service.read(csvImportServiceProvider),
        isA<RecordingImportService>(),
      );
      expect(
        (service.read(csvImportServiceProvider) as RecordingImportService)
            .called,
        isTrue,
      );
    });

    testWidgets('uses save error feedback for import failures', (tester) async {
      final db = await tester.pumpApp(CsvImportPage(initialReview: _review()), [
        premiumAccessPolicyProvider.overrideWithValue(
          DefaultPremiumAccessPolicy(isPremium: true),
        ),
        csvImportServiceProvider.overrideWith(
          (ref) => ThrowingImportService(ref),
        ),
      ]);
      addTearDown(db.close);
      await tester.tap(
        find.byKey(const ValueKey<String>('csv_import.apply.button')),
      );
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.csvImportSaveError), findsOneWidget);
      expect(find.text(l10n.csvReadError), findsNothing);
    });
  });
}
