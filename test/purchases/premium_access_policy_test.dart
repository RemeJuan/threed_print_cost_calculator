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

    test('quota checks always allow', () {
      expect(policy.canCreateMaterial(999).allowed, isTrue);
      expect(policy.canCreatePrinter(999).allowed, isTrue);
      expect(policy.canSaveHistoryItem(999).allowed, isTrue);
      expect(policy.canAddBatchItem(999).allowed, isTrue);
    });
  });
}
