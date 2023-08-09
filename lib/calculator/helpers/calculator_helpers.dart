class CalculatorHelpers {
  static double electricityCost(
    String watts,
    String hours,
    String minutes,
    String cost,
  ) {
    //Wattage in Watts / 1,000 × Hours Used × Electricity Price per kWh = Cost of Electricity
    final hrs = int.tryParse(hours, radix: 10) ?? 0;
    final mins = int.tryParse(minutes, radix: 10) ?? 0;

    final w = int.parse(watts) / 1000;
    final m = hrs + (mins / 60);
    final c = double.parse(cost.replaceAll(',', '.'));

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
    final c = double.parse(cost.replaceAll(',', '.'));

    final totalFixed = (w * c).toStringAsFixed(2);

    return double.parse(totalFixed);
  }

  static double labourCost(
    double labourRate,
    double labourTime,
  ) {
    //Labour Rate * Labour Time = Labour Cost
    final totalFixed = (labourRate * labourTime).toStringAsFixed(2);
    return double.parse(totalFixed);
  }
}
