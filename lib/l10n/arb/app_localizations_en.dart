// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get calculatorAppBarTitle => '3D Print Calculator';

  @override
  String get historyAppBarTitle => 'History';

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get wattLabel => 'Watt (3D Printer)';

  @override
  String get printWeightLabel => 'Weight of the print';

  @override
  String get hoursLabel => 'Printing time (hours)';

  @override
  String get wearAndTearLabel => 'Materials/Wear + tear';

  @override
  String get labourRateLabel => 'Hourly rate';

  @override
  String get labourTimeLabel => 'Processing time';

  @override
  String get failureRiskLabel => 'Failure risk (%)';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get spoolWeightLabel => 'Spool/Resin weight';

  @override
  String get spoolCostLabel => 'Spool/Resin cost';

  @override
  String get electricityCostLabel => 'Electricity cost';

  @override
  String get electricityCostSettingsLabel => 'Electricity cost';

  @override
  String get submitButton => 'Calculate';

  @override
  String get resultElectricityPrefix => 'Total cost for Electricity: ';

  @override
  String get resultFilamentPrefix => 'Total cost for filament: ';

  @override
  String get resultTotalPrefix => 'Total cost: ';

  @override
  String get riskTotalPrefix => 'Risk cost: ';

  @override
  String get premiumHeader => 'Premium users only:';

  @override
  String get labourCostPrefix => 'Labour/Materials: ';

  @override
  String get selectPrinterHint => 'Select Printer';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kW/h';

  @override
  String get enterNumber => 'Please enter a number';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get supportEmailPrefix => 'For any issues, please mail me at ';

  @override
  String get supportEmail => 'google@remej.dev';

  @override
  String get supportIdLabel => 'Please include your Support ID: ';

  @override
  String get clickToCopy => '(click to copy)';

  @override
  String get materialWeightExplanation =>
      'Material weight is the total weight for the source material, so the entire roll of filament. The cost is the cost of the entire unit.';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportError => 'Export failed';

  @override
  String get exportButton => 'Export';
}
