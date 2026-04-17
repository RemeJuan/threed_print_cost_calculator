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
  String get calculatorNavLabel => 'Calculator';

  @override
  String get historyNavLabel => 'History';

  @override
  String get settingsNavLabel => 'Settings';

  @override
  String get generalHeader => 'General';

  @override
  String get wattLabel => 'Watt (3D Printer)';

  @override
  String get printWeightLabel => 'Print Weight';

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
  String get spoolWeightLabel => 'Material weight';

  @override
  String get spoolCostLabel => 'Material cost';

  @override
  String get electricityCostLabel => 'Electricity';

  @override
  String get electricityCostSettingsLabel => 'Electricity cost';

  @override
  String get submitButton => 'Calculate';

  @override
  String get resultElectricityPrefix => 'Electricity';

  @override
  String get resultFilamentPrefix => 'Filament';

  @override
  String get resultTotalPrefix => 'Total ';

  @override
  String get riskTotalPrefix => 'Risk';

  @override
  String get premiumHeader => 'Premium users only:';

  @override
  String get labourCostPrefix => 'Labour/Materials';

  @override
  String get selectPrinterHint => 'Select Printer';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Save Print';

  @override
  String get printNameHint => 'Print Name';

  @override
  String get printerNameLabel => 'Name *';

  @override
  String get bedSizeLabel => 'Bed Size *';

  @override
  String get wattageLabel => 'Wattage *';

  @override
  String get materialNameLabel => 'Name *';

  @override
  String get colorLabel => 'Color *';

  @override
  String get weightLabel => 'Weight *';

  @override
  String get costLabel => 'Cost *';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteDialogTitle => 'Delete';

  @override
  String get deleteDialogContent =>
      'Are you sure you want to delete this item?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get selectMaterialHint => 'Custom (unsaved)';

  @override
  String get materialNone => 'None';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => 'Remaining:';

  @override
  String get trackRemainingFilamentLabel => 'Track remaining filament';

  @override
  String get remainingFilamentLabel => 'Remaining filament';

  @override
  String get savePrintErrorMessage => 'Error saving print';

  @override
  String get savePrintSuccessMessage => 'Print saved';

  @override
  String get historyLoadAction => 'Use in calculator';

  @override
  String get historyLoadSuccessMessage => 'Loaded from history';

  @override
  String get historyLoadReplacementWarning =>
      'Some items were unavailable and replaced';

  @override
  String get numberExampleHint => 'e.g. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Failed to load materials: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Failed to load printers: $error';
  }

  @override
  String get retryButton => 'Retry';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Need Help?';

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
  String get supportIdCopied => 'Support ID Copied';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportError => 'Export failed';

  @override
  String get exportButton => 'Export';

  @override
  String get privacyPolicyLink => 'Privacy Policy';

  @override
  String get termsOfUseLink => 'Terms of Use';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Close';

  @override
  String get testDataToolsTitle => 'Test data tools';

  @override
  String get testDataToolsBody =>
      'These actions are for local testing only. Seeding replaces the current local setup with demo data. Purging permanently removes local app data on this device.';

  @override
  String get seedTestDataButton => 'Seed test data';

  @override
  String get purgeLocalDataButton => 'Purge local data';

  @override
  String get enablePremiumButton => 'Enable premium';

  @override
  String get enablePremiumTitle => 'Enable premium';

  @override
  String get enablePremiumBody =>
      'Enter confirmation code to enable local premium testing';

  @override
  String get invalidConfirmationCodeMessage => 'Invalid confirmation code';

  @override
  String get seedTestDataConfirmTitle => 'Seed test data?';

  @override
  String get seedTestDataConfirmBody =>
      'This will replace the current local setup with deterministic demo data.';

  @override
  String get purgeLocalDataConfirmTitle => 'Purge local data?';

  @override
  String get purgeLocalDataConfirmBody =>
      'This will permanently remove all local app data on this device.';

  @override
  String get testDataSeededMessage => 'Test data seeded';

  @override
  String get testDataPurgedMessage => 'Local data purged';

  @override
  String get testDataActionFailedMessage => 'Test data action failed';

  @override
  String get mailClientError => 'Could not open mail client';

  @override
  String get offeringsError => 'Error: ';

  @override
  String get currentOfferings => 'Current Offerings';

  @override
  String get purchaseError =>
      'There was an error processing your purchase. Please try again later.';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get printersHeader => 'Printers';

  @override
  String get materialsHeader => 'Materials';

  @override
  String get filamentCostLabel => 'Filament';

  @override
  String get labourCostLabel => 'Labour';

  @override
  String get riskCostLabel => 'Risk';

  @override
  String get totalCostLabel => 'Total';

  @override
  String get workCostsLabel => 'Work Costs';

  @override
  String get enterNumber => 'Please enter a number';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationEnterValidNumber => 'Enter a valid number';

  @override
  String get validationMustBeGreaterThanZero => 'Must be greater than 0';

  @override
  String get validationMustBeZeroOrMore => 'Must be 0 or more';

  @override
  String get lockedValuePlaceholder => 'Locked';

  @override
  String get hideProPromotionsTitle => 'Hide Pro promotions';

  @override
  String get hideProPromotionsSubtitle => 'Hide upgrade banners and prompts';

  @override
  String get historySearchHint => 'Search by name or printer';

  @override
  String get historyExportMenuTitle => 'Export Prints';

  @override
  String get historyExportRangeAll => 'All';

  @override
  String get historyExportRangeLast7Days => 'Last 7 days';

  @override
  String get historyExportRangeLast30Days => 'Last 30 days';

  @override
  String get historyEmptyTitle => 'No saved prints yet';

  @override
  String get historyEmptyDescription => 'Re-use past prints in the calculator';

  @override
  String get historyUpsellTitle => 'Re-use past prints instantly';

  @override
  String get historyUpsellDescription => 'Unlock advanced edits and exports';

  @override
  String get historyNoMoreRecords => 'No more records';

  @override
  String get historyOverflowHint => 'More actions in ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Error loading history: $error';
  }

  @override
  String get historyCsvHeader =>
      'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total';

  @override
  String get historyExportShareText => '3D Print Cost History Export';

  @override
  String get historyTeaserTitle => 'Keep every print estimate in one place';

  @override
  String get historyTeaserDescription =>
      'Review how history works before upgrading. Save completed estimates and export them any time with Pro.';

  @override
  String get historyTeaserCta => 'Save & export history with Pro';

  @override
  String get historyExportPreviewEntry => 'Preview sample CSV export';

  @override
  String get historyExportPreviewTitle => 'CSV preview';

  @override
  String get historyExportPreviewDescription =>
      'See how your export will look. Download and share are unlocked with Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Sample]';

  @override
  String get historyExportPreviewAction => 'Download / Share with Pro';

  @override
  String get addMaterialButton => 'Add';

  @override
  String get useSingleTotalWeightAction => 'Use single total weight';

  @override
  String get addAtLeastOneMaterial => 'Add at least one material.';

  @override
  String get searchMaterialsHint => 'Search materials';

  @override
  String get materialBreakdownLabel => 'Material breakdown';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# materials',
      one: '# material',
    );
    return '$_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Total material weight: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get materialFallback => 'Material';
}
