class CalculatorHelpers {
  static double electricityCost(
    String watts,
    String minutes,
    String cost,
  ) {
    //Wattage in Watts / 1,000 × Hours Used × Electricity Price per kWh = Cost of Electricity

    final w = int.parse(watts) / 1000;
    final m = int.parse(minutes) / 60;
    final c = double.parse(cost);

    final totalFixed = (w * m * c).toStringAsFixed(2);

    return double.parse(totalFixed);
  }

  static double filamentCost(
    String itemWeight,
    String spoolWeight,
    String cost,
  ) {
    //Weight in grams / 1,000 × Cost per kg = Cost of filament

    final w = double.parse(itemWeight) / double.parse(spoolWeight);
    final c = double.parse(cost);

    final totalFixed = (w * c).toStringAsFixed(2);

    return double.parse(totalFixed);
  }
}
