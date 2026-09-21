import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';

class CustomerViewLineItem {
  const CustomerViewLineItem({
    required this.name,
    required this.quantity,
    required this.total,
  });

  final String name;
  final int quantity;
  final num total;
}

class CustomerViewData {
  const CustomerViewData({
    required this.finalPrice,
    this.baseCost,
    this.electricity,
    this.filament,
    this.risk,
    this.labour,
    this.additionalCost,
    this.markup,
    this.setupFee,
    this.roundingAdjustment,
    this.items = const [],
  });

  factory CustomerViewData.fromCalculator({
    required CalculationResult results,
    required PricingResult pricing,
    num additionalCost = 0,
  }) => CustomerViewData(
    finalPrice: pricing.isEnabled ? pricing.finalPrice : results.total,
    baseCost: results.total,
    electricity: results.electricity,
    filament: results.filament,
    risk: results.risk,
    labour: results.labour,
    additionalCost: additionalCost,
    markup: pricing.markupAmount,
    setupFee: pricing.setupFee,
    roundingAdjustment: pricing.roundingAdjustment,
  );

  factory CustomerViewData.preview() => const CustomerViewData(
    finalPrice: 42.50,
    baseCost: 30,
    electricity: 2.50,
    filament: 20,
    risk: 3,
    labour: 4.50,
    additionalCost: 0,
    markup: 0,
    setupFee: 0,
    roundingAdjustment: 0,
    items: [
      CustomerViewLineItem(name: 'Sample print', quantity: 1, total: 42.50),
    ],
  );

  final num finalPrice;
  final num? baseCost;
  final num? electricity;
  final num? filament;
  final num? risk;
  final num? labour;
  final num? additionalCost;
  final num? markup;
  final num? setupFee;
  final num? roundingAdjustment;
  final List<CustomerViewLineItem> items;
}
