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

  /// `Select Material`
  String get selectMaterialHint {
    return Intl.message(
      'Select Material',
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
