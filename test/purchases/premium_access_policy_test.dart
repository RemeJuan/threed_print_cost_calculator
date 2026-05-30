import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';

void main() {
  group('DefaultPremiumAccessPolicy free tier', () {
    final policy = DefaultPremiumAccessPolicy(
      isPremium: false,
      hideProPromotions: false,
    );

    test('uses free-tier limits', () {
      expect(policy.materialLimit, 5);
      expect(policy.printerLimit, 2);
      expect(policy.historyLimit, 7);
      expect(policy.batchItemLimit, 3);
    });

    test('allows free features', () {
      expect(policy.multiMaterial().allowed, isTrue);
      expect(policy.printers().allowed, isTrue);
      expect(policy.printersList().allowed, isFalse);
      expect(policy.historyView().allowed, isTrue);
      expect(policy.gcodeImport().allowed, isTrue);
      expect(policy.batchCosting().allowed, isTrue);
      expect(policy.saveToHistory().allowed, isTrue);
    });

    test('keeps premium-only features gated', () {
      expect(policy.materialsLibrary().allowed, isFalse);
      expect(policy.csvMaterialImport().allowed, isFalse);
      expect(policy.batchExport().allowed, isFalse);
      expect(policy.bulkHistoryExport().allowed, isFalse);
      expect(policy.historyExport().allowed, isFalse);
      expect(policy.labourPricing().allowed, isFalse);
      expect(policy.riskPricing().allowed, isFalse);
      expect(policy.advancedPricingConfig().allowed, isFalse);
      expect(policy.stockTracking().allowed, isFalse);
      expect(policy.batchGcodeImport().allowed, isFalse);
    });

    test('keeps single-job export free', () {
      expect(policy.singleJobExport().allowed, isTrue);
    });

    test('enforces quota deny reason at limits', () {
      expect(policy.canCreateMaterial(4).allowed, isTrue);
      expect(policy.canCreateMaterial(5).allowed, isFalse);
      expect(
        policy.canCreateMaterial(5).denyReason,
        AccessDenyReason.quotaExceeded,
      );

      expect(policy.canCreatePrinter(1).allowed, isTrue);
      expect(policy.canCreatePrinter(2).allowed, isFalse);

      expect(policy.canSaveHistoryItem(6).allowed, isTrue);
      expect(policy.canSaveHistoryItem(7).allowed, isFalse);

      expect(policy.canAddBatchItem(2).allowed, isTrue);
      expect(policy.canAddBatchItem(3).allowed, isFalse);
    });

    test('lists paywall premium features', () {
      final features = policy.paywallFeatures;
      expect(features, contains(PremiumFeature.materials));
      expect(features, contains(PremiumFeature.printers));
      expect(features, contains(PremiumFeature.historyExport));
      expect(features, contains(PremiumFeature.bulkHistoryExport));
      expect(features, contains(PremiumFeature.batchExport));
      expect(features, contains(PremiumFeature.advancedPricingConfig));
      expect(features, contains(PremiumFeature.stockTracking));
    });

    test('paywall comparison rows exist for concise ordered features', () {
      final rows = policy.paywallComparisonRows;
      expect(rows.length, 7);
      expect(rows.any((r) => r.id == 'materials'), isTrue);
      expect(rows.any((r) => r.id == 'printers'), isTrue);
      expect(rows.any((r) => r.id == 'history'), isTrue);
      expect(rows.any((r) => r.id == 'batchCosting'), isTrue);
      expect(rows.any((r) => r.id == 'advancedPricing'), isTrue);
      expect(rows.any((r) => r.id == 'exportTools'), isTrue);
      expect(rows.any((r) => r.id == 'inventoryTracking'), isTrue);
    });

    test('quota-backed free values match policy limits', () {
      for (final row in policy.paywallComparisonRows) {
        if (row.id == 'printers') {
          expect(row.freeCell.type, CellType.count);
          expect(row.freeCell.limit, policy.printerLimit);
        }
        if (row.id == 'materials') {
          expect(row.freeCell.type, CellType.count);
          expect(row.freeCell.limit, policy.materialLimit);
        }
        if (row.id == 'history') {
          expect(row.freeCell.type, CellType.saves);
          expect(row.freeCell.limit, policy.historyLimit);
        }
        if (row.id == 'batchCosting') {
          expect(row.freeCell.type, CellType.upTo);
          expect(row.freeCell.limit, policy.batchItemLimit);
        }
      }
    });

    test('premium column values reflect upgrade', () {
      for (final row in policy.paywallComparisonRows) {
        if (row.id == 'batchCosting' ||
            row.id == 'printers' ||
            row.id == 'materials' ||
            row.id == 'history') {
          expect(row.premiumCell.textKey, 'paywallValueUnlimited');
        }
        if (row.id == 'advancedPricing') {
          expect(row.freeCell.textKey, 'paywallValueBasic');
          expect(row.premiumCell.textKey, 'paywallValueFull');
        }
        if (row.id == 'exportTools') {
          expect(row.freeCell.textKey, 'paywallValueSingleJob');
          expect(row.premiumCell.textKey, 'paywallValueFullSuite');
        }
        if (row.id == 'inventoryTracking') {
          expect(row.freeCell.textKey, 'paywallValueNo');
          expect(row.premiumCell.textKey, 'paywallValueYes');
        }
      }
    });

    test('history tab visible without teaser mode', () {
      expect(policy.shouldShowHistoryTab, isTrue);
      expect(policy.shouldShowHistoryTeaser, isFalse);
    });
  });

  group('DefaultPremiumAccessPolicy premium tier', () {
    final policy = DefaultPremiumAccessPolicy(
      isPremium: true,
      hideProPromotions: false,
    );

    test('has no limits', () {
      expect(policy.materialLimit, isNull);
      expect(policy.printerLimit, isNull);
      expect(policy.historyLimit, isNull);
      expect(policy.batchItemLimit, isNull);
    });

    test('lists same paywall features as free tier', () {
      expect(policy.paywallFeatures.length, 7);
    });

    test('quota checks always allow', () {
      expect(policy.canCreateMaterial(999).allowed, isTrue);
      expect(policy.canCreatePrinter(999).allowed, isTrue);
      expect(policy.canSaveHistoryItem(999).allowed, isTrue);
      expect(policy.canAddBatchItem(999).allowed, isTrue);
    });
  });
}
