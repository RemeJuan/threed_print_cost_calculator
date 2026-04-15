// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `3D Print Calculator`
  String get calculatorAppBarTitle {
    return Intl.message(
      '3D Print Calculator',
      name: 'calculatorAppBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get historyAppBarTitle {
    return Intl.message(
      'History',
      name: 'historyAppBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsAppBarTitle {
    return Intl.message(
      'Settings',
      name: 'settingsAppBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Calculator`
  String get calculatorNavLabel {
    return Intl.message(
      'Calculator',
      name: 'calculatorNavLabel',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get historyNavLabel {
    return Intl.message('History', name: 'historyNavLabel', desc: '', args: []);
  }

  /// `Keep every print estimate in one place`
  String get historyTeaserTitle {
    return Intl.message(
      'Keep every print estimate in one place',
      name: 'historyTeaserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Review how history works before upgrading. Save completed estimates and export them any time with Pro.`
  String get historyTeaserDescription {
    return Intl.message(
      'Review how history works before upgrading. Save completed estimates and export them any time with Pro.',
      name: 'historyTeaserDescription',
      desc: '',
      args: [],
    );
  }

  /// `Save & export history with Pro`
  String get historyTeaserCta {
    return Intl.message(
      'Save & export history with Pro',
      name: 'historyTeaserCta',
      desc: '',
      args: [],
    );
  }

  /// `Preview sample CSV export`
  String get historyExportPreviewEntry {
    return Intl.message(
      'Preview sample CSV export',
      name: 'historyExportPreviewEntry',
      desc: '',
      args: [],
    );
  }

  /// `CSV preview`
  String get historyExportPreviewTitle {
    return Intl.message(
      'CSV preview',
      name: 'historyExportPreviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `See how your export will look. Download and share are unlocked with Pro.`
  String get historyExportPreviewDescription {
    return Intl.message(
      'See how your export will look. Download and share are unlocked with Pro.',
      name: 'historyExportPreviewDescription',
      desc: '',
      args: [],
    );
  }

  /// `[Sample]`
  String get historyExportPreviewSampleLabel {
    return Intl.message(
      '[Sample]',
      name: 'historyExportPreviewSampleLabel',
      desc: '',
      args: [],
    );
  }

  /// `Download / Share with Pro`
  String get historyExportPreviewAction {
    return Intl.message(
      'Download / Share with Pro',
      name: 'historyExportPreviewAction',
      desc: '',
      args: [],
    );
  }

  /// `Export Prints`
  String get historyExportMenuTitle {
    return Intl.message(
      'Export Prints',
      name: 'historyExportMenuTitle',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get historyExportRangeAll {
    return Intl.message(
      'All',
      name: 'historyExportRangeAll',
      desc: '',
      args: [],
    );
  }

  /// `Last 7 days`
  String get historyExportRangeLast7Days {
    return Intl.message(
      'Last 7 days',
      name: 'historyExportRangeLast7Days',
      desc: '',
      args: [],
    );
  }

  /// `Last 30 days`
  String get historyExportRangeLast30Days {
    return Intl.message(
      'Last 30 days',
      name: 'historyExportRangeLast30Days',
      desc: '',
      args: [],
    );
  }

  /// `No saved prints yet`
  String get historyEmptyTitle {
    return Intl.message(
      'No saved prints yet',
      name: 'historyEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Re-use past prints in the calculator`
  String get historyEmptyDescription {
    return Intl.message(
      'Re-use past prints in the calculator',
      name: 'historyEmptyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Re-use past prints instantly`
  String get historyUpsellTitle {
    return Intl.message(
      'Re-use past prints instantly',
      name: 'historyUpsellTitle',
      desc: '',
      args: [],
    );
  }

  /// `Unlock advanced edits and exports`
  String get historyUpsellDescription {
    return Intl.message(
      'Unlock advanced edits and exports',
      name: 'historyUpsellDescription',
      desc: '',
      args: [],
    );
  }

  /// `No more records`
  String get historyNoMoreRecords {
    return Intl.message(
      'No more records',
      name: 'historyNoMoreRecords',
      desc: '',
      args: [],
    );
  }

  /// `More actions in ⋯`
  String get historyOverflowHint {
    return Intl.message(
      'More actions in ⋯',
      name: 'historyOverflowHint',
      desc: '',
      args: [],
    );
  }

  /// `Error loading history: {error}`
  String historyLoadError(Object error) {
    return Intl.message(
      'Error loading history: $error',
      name: 'historyLoadError',
      desc: '',
      args: [error],
    );
  }

  /// `Date,Printer,Name,Description,Weight(g),Time(min),Price,Material cost,Electricity cost,Processing cost,Risk cost,Total`
  String get historyCsvHeader {
    return Intl.message(
      'Date,Printer,Name,Description,Weight(g),Time(min),Price,Material cost,Electricity cost,Processing cost,Risk cost,Total',
      name: 'historyCsvHeader',
      desc: '',
      args: [],
    );
  }

  /// `3D Print Cost History Export`
  String get historyExportShareText {
    return Intl.message(
      '3D Print Cost History Export',
      name: 'historyExportShareText',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsNavLabel {
    return Intl.message(
      'Settings',
      name: 'settingsNavLabel',
      desc: '',
      args: [],
    );
  }

  /// `Watt (3D Printer)`
  String get wattLabel {
    return Intl.message(
      'Watt (3D Printer)',
      name: 'wattLabel',
      desc: '',
      args: [],
    );
  }

  /// `Print Weight`
  String get printWeightLabel {
    return Intl.message(
      'Print Weight',
      name: 'printWeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Printing time (hours)`
  String get hoursLabel {
    return Intl.message(
      'Printing time (hours)',
      name: 'hoursLabel',
      desc: '',
      args: [],
    );
  }

  /// `Materials/Wear + tear`
  String get wearAndTearLabel {
    return Intl.message(
      'Materials/Wear + tear',
      name: 'wearAndTearLabel',
      desc: '',
      args: [],
    );
  }

  /// `Hourly rate`
  String get labourRateLabel {
    return Intl.message(
      'Hourly rate',
      name: 'labourRateLabel',
      desc: '',
      args: [],
    );
  }

  /// `Processing time`
  String get labourTimeLabel {
    return Intl.message(
      'Processing time',
      name: 'labourTimeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Failure risk (%)`
  String get failureRiskLabel {
    return Intl.message(
      'Failure risk (%)',
      name: 'failureRiskLabel',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get minutesLabel {
    return Intl.message('Minutes', name: 'minutesLabel', desc: '', args: []);
  }

  /// `Material weight`
  String get spoolWeightLabel {
    return Intl.message(
      'Material weight',
      name: 'spoolWeightLabel',
      desc: '',
      args: [],
    );
  }

  /// `Material cost`
  String get spoolCostLabel {
    return Intl.message(
      'Material cost',
      name: 'spoolCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Electricity`
  String get electricityCostLabel {
    return Intl.message(
      'Electricity',
      name: 'electricityCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Electricity cost`
  String get electricityCostSettingsLabel {
    return Intl.message(
      'Electricity cost',
      name: 'electricityCostSettingsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Calculate`
  String get submitButton {
    return Intl.message('Calculate', name: 'submitButton', desc: '', args: []);
  }

  /// `Electricity`
  String get resultElectricityPrefix {
    return Intl.message(
      'Electricity',
      name: 'resultElectricityPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Filament`
  String get resultFilamentPrefix {
    return Intl.message(
      'Filament',
      name: 'resultFilamentPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Total `
  String get resultTotalPrefix {
    return Intl.message(
      'Total ',
      name: 'resultTotalPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Risk`
  String get riskTotalPrefix {
    return Intl.message('Risk', name: 'riskTotalPrefix', desc: '', args: []);
  }

  /// `Premium users only:`
  String get premiumHeader {
    return Intl.message(
      'Premium users only:',
      name: 'premiumHeader',
      desc: '',
      args: [],
    );
  }

  /// `Labour/Materials`
  String get labourCostPrefix {
    return Intl.message(
      'Labour/Materials',
      name: 'labourCostPrefix',
      desc: '',
      args: [],
    );
  }

  /// `—`
  String get lockedValuePlaceholder {
    return Intl.message(
      '—',
      name: 'lockedValuePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Select Printer`
  String get selectPrinterHint {
    return Intl.message(
      'Select Printer',
      name: 'selectPrinterHint',
      desc: '',
      args: [],
    );
  }

  /// `Watt`
  String get watt {
    return Intl.message('Watt', name: 'watt', desc: '', args: []);
  }

  /// `kW/h`
  String get kwh {
    return Intl.message('kW/h', name: 'kwh', desc: '', args: []);
  }

  /// `Save Print`
  String get savePrintButton {
    return Intl.message(
      'Save Print',
      name: 'savePrintButton',
      desc: '',
      args: [],
    );
  }

  /// `Print Name`
  String get printNameHint {
    return Intl.message(
      'Print Name',
      name: 'printNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Name *`
  String get printerNameLabel {
    return Intl.message('Name *', name: 'printerNameLabel', desc: '', args: []);
  }

  /// `Bed Size *`
  String get bedSizeLabel {
    return Intl.message('Bed Size *', name: 'bedSizeLabel', desc: '', args: []);
  }

  /// `Wattage *`
  String get wattageLabel {
    return Intl.message('Wattage *', name: 'wattageLabel', desc: '', args: []);
  }

  /// `Name *`
  String get materialNameLabel {
    return Intl.message(
      'Name *',
      name: 'materialNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Color *`
  String get colorLabel {
    return Intl.message('Color *', name: 'colorLabel', desc: '', args: []);
  }

  /// `Weight *`
  String get weightLabel {
    return Intl.message('Weight *', name: 'weightLabel', desc: '', args: []);
  }

  /// `Cost *`
  String get costLabel {
    return Intl.message('Cost *', name: 'costLabel', desc: '', args: []);
  }

  /// `Save`
  String get saveButton {
    return Intl.message('Save', name: 'saveButton', desc: '', args: []);
  }

  /// `Delete`
  String get deleteDialogTitle {
    return Intl.message(
      'Delete',
      name: 'deleteDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this item?`
  String get deleteDialogContent {
    return Intl.message(
      'Are you sure you want to delete this item?',
      name: 'deleteDialogContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButton {
    return Intl.message('Cancel', name: 'cancelButton', desc: '', args: []);
  }

  /// `Delete`
  String get deleteButton {
    return Intl.message('Delete', name: 'deleteButton', desc: '', args: []);
  }

  /// `Custom (unsaved)`
  String get selectMaterialHint {
    return Intl.message(
      'Custom (unsaved)',
      name: 'selectMaterialHint',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get materialNone {
    return Intl.message('None', name: 'materialNone', desc: '', args: []);
  }

  /// `g`
  String get gramsSuffix {
    return Intl.message('g', name: 'gramsSuffix', desc: '', args: []);
  }

  /// `Remaining:`
  String get remainingLabel {
    return Intl.message(
      'Remaining:',
      name: 'remainingLabel',
      desc: '',
      args: [],
    );
  }

  /// `Track remaining filament`
  String get trackRemainingFilamentLabel {
    return Intl.message(
      'Track remaining filament',
      name: 'trackRemainingFilamentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Remaining filament`
  String get remainingFilamentLabel {
    return Intl.message(
      'Remaining filament',
      name: 'remainingFilamentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Error saving print`
  String get savePrintErrorMessage {
    return Intl.message(
      'Error saving print',
      name: 'savePrintErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Print saved`
  String get savePrintSuccessMessage {
    return Intl.message(
      'Print saved',
      name: 'savePrintSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Use in calculator`
  String get historyLoadAction {
    return Intl.message(
      'Use in calculator',
      name: 'historyLoadAction',
      desc: '',
      args: [],
    );
  }

  /// `Loaded from history`
  String get historyLoadSuccessMessage {
    return Intl.message(
      'Loaded from history',
      name: 'historyLoadSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Some items were unavailable and replaced`
  String get historyLoadReplacementWarning {
    return Intl.message(
      'Some items were unavailable and replaced',
      name: 'historyLoadReplacementWarning',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 123`
  String get numberExampleHint {
    return Intl.message(
      'e.g. 123',
      name: 'numberExampleHint',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retryButton {
    return Intl.message('Retry', name: 'retryButton', desc: '', args: []);
  }

  /// `w`
  String get wattsSuffix {
    return Intl.message('w', name: 'wattsSuffix', desc: '', args: []);
  }

  /// `Need Help?`
  String get needHelpTitle {
    return Intl.message(
      'Need Help?',
      name: 'needHelpTitle',
      desc: '',
      args: [],
    );
  }

  /// `For any issues, please mail me at `
  String get supportEmailPrefix {
    return Intl.message(
      'For any issues, please mail me at ',
      name: 'supportEmailPrefix',
      desc: '',
      args: [],
    );
  }

  /// `google@remej.dev`
  String get supportEmail {
    return Intl.message(
      'google@remej.dev',
      name: 'supportEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please include your Support ID: `
  String get supportIdLabel {
    return Intl.message(
      'Please include your Support ID: ',
      name: 'supportIdLabel',
      desc: '',
      args: [],
    );
  }

  /// `(click to copy)`
  String get clickToCopy {
    return Intl.message(
      '(click to copy)',
      name: 'clickToCopy',
      desc: '',
      args: [],
    );
  }

  /// `Material weight is the total weight for the source material, so the entire roll of filament. The cost is the cost of the entire unit.`
  String get materialWeightExplanation {
    return Intl.message(
      'Material weight is the total weight for the source material, so the entire roll of filament. The cost is the cost of the entire unit.',
      name: 'materialWeightExplanation',
      desc:
          'Explanation shown in the support/help dialog about what \'Material weight\' and \'Material cost\' refer to.',
      args: [],
    );
  }

  /// `Support ID Copied`
  String get supportIdCopied {
    return Intl.message(
      'Support ID Copied',
      name: 'supportIdCopied',
      desc: '',
      args: [],
    );
  }

  /// `Export successful`
  String get exportSuccess {
    return Intl.message(
      'Export successful',
      name: 'exportSuccess',
      desc: 'Shown when a history export completes successfully',
      args: [],
    );
  }

  /// `Export failed`
  String get exportError {
    return Intl.message(
      'Export failed',
      name: 'exportError',
      desc: 'Shown when a history export fails',
      args: [],
    );
  }

  /// `Export`
  String get exportButton {
    return Intl.message(
      'Export',
      name: 'exportButton',
      desc: 'Label for export action in history list',
      args: [],
    );
  }

  /// `Hide Pro feature promotions`
  String get hideProPromotionsTitle {
    return Intl.message(
      'Hide Pro feature promotions',
      name: 'hideProPromotionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Hide upgrade prompts and previews for premium features`
  String get hideProPromotionsSubtitle {
    return Intl.message(
      'Hide upgrade prompts and previews for premium features',
      name: 'hideProPromotionsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicyLink {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicyLink',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get termsOfUseLink {
    return Intl.message(
      'Terms of Use',
      name: 'termsOfUseLink',
      desc: '',
      args: [],
    );
  }

  /// ` | `
  String get separator {
    return Intl.message(' | ', name: 'separator', desc: '', args: []);
  }

  /// `Close`
  String get closeButton {
    return Intl.message('Close', name: 'closeButton', desc: '', args: []);
  }

  /// `Could not open mail client`
  String get mailClientError {
    return Intl.message(
      'Could not open mail client',
      name: 'mailClientError',
      desc: '',
      args: [],
    );
  }

  /// `Error: `
  String get offeringsError {
    return Intl.message('Error: ', name: 'offeringsError', desc: '', args: []);
  }

  /// `Current Offerings`
  String get currentOfferings {
    return Intl.message(
      'Current Offerings',
      name: 'currentOfferings',
      desc: '',
      args: [],
    );
  }

  /// `There was an error processing your purchase. Please try again later.`
  String get purchaseError {
    return Intl.message(
      'There was an error processing your purchase. Please try again later.',
      name: 'purchaseError',
      desc: '',
      args: [],
    );
  }

  /// `Restore Purchases`
  String get restorePurchases {
    return Intl.message(
      'Restore Purchases',
      name: 'restorePurchases',
      desc: '',
      args: [],
    );
  }

  /// `Printers`
  String get printersHeader {
    return Intl.message('Printers', name: 'printersHeader', desc: '', args: []);
  }

  /// `Materials`
  String get materialsHeader {
    return Intl.message(
      'Materials',
      name: 'materialsHeader',
      desc: '',
      args: [],
    );
  }

  /// `Filament`
  String get filamentCostLabel {
    return Intl.message(
      'Filament',
      name: 'filamentCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Labour`
  String get labourCostLabel {
    return Intl.message('Labour', name: 'labourCostLabel', desc: '', args: []);
  }

  /// `Risk`
  String get riskCostLabel {
    return Intl.message('Risk', name: 'riskCostLabel', desc: '', args: []);
  }

  /// `Total`
  String get totalCostLabel {
    return Intl.message('Total', name: 'totalCostLabel', desc: '', args: []);
  }

  /// `Work Costs`
  String get workCostsLabel {
    return Intl.message(
      'Work Costs',
      name: 'workCostsLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a number`
  String get enterNumber {
    return Intl.message(
      'Please enter a number',
      name: 'enterNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid number`
  String get invalidNumber {
    return Intl.message(
      'Invalid number',
      name: 'invalidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Search by name or printer`
  String get historySearchHint {
    return Intl.message(
      'Search by name or printer',
      name: 'historySearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addMaterialButton {
    return Intl.message('Add', name: 'addMaterialButton', desc: '', args: []);
  }

  /// `Use single total weight`
  String get useSingleTotalWeightAction {
    return Intl.message(
      'Use single total weight',
      name: 'useSingleTotalWeightAction',
      desc: '',
      args: [],
    );
  }

  /// `Add at least one material.`
  String get addAtLeastOneMaterial {
    return Intl.message(
      'Add at least one material.',
      name: 'addAtLeastOneMaterial',
      desc: '',
      args: [],
    );
  }

  /// `Search materials`
  String get searchMaterialsHint {
    return Intl.message(
      'Search materials',
      name: 'searchMaterialsHint',
      desc: '',
      args: [],
    );
  }

  /// `Material breakdown`
  String get materialBreakdownLabel {
    return Intl.message(
      'Material breakdown',
      name: 'materialBreakdownLabel',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{# material} other{# materials}}`
  String materialsCountLabel(num count) {
    return Intl.plural(
      count,
      one: '# material',
      other: '# materials',
      name: 'materialsCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `Failed to load materials: {error}`
  String materialsLoadError(Object error) {
    return Intl.message(
      'Failed to load materials: $error',
      name: 'materialsLoadError',
      desc: '',
      args: [error],
    );
  }

  /// `Total material weight: {grams}g`
  String totalMaterialWeightLabel(Object grams) {
    return Intl.message(
      'Total material weight: ${grams}g',
      name: 'totalMaterialWeightLabel',
      desc: '',
      args: [grams],
    );
  }

  /// `Version {version}`
  String versionLabel(Object version) {
    return Intl.message(
      'Version $version',
      name: 'versionLabel',
      desc: 'Label for showing app version',
      args: [version],
    );
  }

  /// `Material`
  String get materialFallback {
    return Intl.message(
      'Material',
      name: 'materialFallback',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'th'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
