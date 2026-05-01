import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/materials/model/stock_status.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

MaterialModel _mat({
  bool autoDeduct = false,
  double remaining = 0,
  double original = 0,
}) {
  return MaterialModel(
    id: '',
    name: 'Test',
    cost: '10',
    color: 'Black',
    weight: '1000',
    archived: false,
    autoDeductEnabled: autoDeduct,
    originalWeight: original,
    remainingWeight: remaining,
  );
}

void main() {
  group('calculateStockStatus', () {
    test('returns noTracking when autoDeduct disabled', () {
      expect(
        calculateStockStatus(_mat(autoDeduct: false)),
        StockStatus.noTracking,
      );
    });

    test('returns noTracking when originalWeight <= 0', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: 500, original: 0),
        ),
        StockStatus.noTracking,
      );
    });

    test('returns outOfStock when remaining <= 0', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: 0, original: 1000),
        ),
        StockStatus.outOfStock,
      );
    });

    test('returns outOfStock when remaining is negative', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: -10, original: 1000),
        ),
        StockStatus.outOfStock,
      );
    });

    test('returns lowStock when remaining <= 15%', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: 150, original: 1000),
        ),
        StockStatus.lowStock,
      );
    });

    test('returns lowStock at exactly 15% threshold', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: 150, original: 1000),
        ),
        StockStatus.lowStock,
      );
    });

    test('returns inStock when remaining > 15%', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: 151, original: 1000),
        ),
        StockStatus.inStock,
      );
    });

    test('returns inStock when remaining is full', () {
      expect(
        calculateStockStatus(
          _mat(autoDeduct: true, remaining: 1000, original: 1000),
        ),
        StockStatus.inStock,
      );
    });
  });

  group('stockPercent', () {
    test('returns 1 when autoDeduct disabled', () {
      expect(stockPercent(_mat(autoDeduct: false)), 1);
    });

    test('returns 1 when originalWeight <= 0', () {
      expect(
        stockPercent(_mat(autoDeduct: true, remaining: 500, original: 0)),
        1,
      );
    });

    test('returns correct ratio', () {
      expect(
        stockPercent(_mat(autoDeduct: true, remaining: 750, original: 1000)),
        closeTo(0.75, 0.001),
      );
    });

    test('clamps to 0 when remaining is negative', () {
      expect(
        stockPercent(_mat(autoDeduct: true, remaining: -100, original: 1000)),
        0,
      );
    });

    test('clamps to 1 when remaining exceeds original', () {
      expect(
        stockPercent(_mat(autoDeduct: true, remaining: 2000, original: 1000)),
        1,
      );
    });
  });
}
