import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localizely_sdk/localizely_sdk.dart';

import 'app_localizations.dart';

// ignore_for_file: type=lint

class LocalizelyLocalizations extends AppLocalizations {
  final AppLocalizations _fallback;

  LocalizelyLocalizations(String locale, AppLocalizations fallback) : _fallback = fallback, super(locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _LocalizelyLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;

  @override
  String get calculatorAppBarTitle => LocalizelyGenL10n.getText(localeName, 'calculatorAppBarTitle') ?? _fallback.calculatorAppBarTitle;

  @override
  String get historyAppBarTitle => LocalizelyGenL10n.getText(localeName, 'historyAppBarTitle') ?? _fallback.historyAppBarTitle;

  @override
  String get settingsAppBarTitle => LocalizelyGenL10n.getText(localeName, 'settingsAppBarTitle') ?? _fallback.settingsAppBarTitle;

  @override
  String get wattLabel => LocalizelyGenL10n.getText(localeName, 'wattLabel') ?? _fallback.wattLabel;

  @override
  String get printWeightLabel => LocalizelyGenL10n.getText(localeName, 'printWeightLabel') ?? _fallback.printWeightLabel;

  @override
  String get hoursLabel => LocalizelyGenL10n.getText(localeName, 'hoursLabel') ?? _fallback.hoursLabel;

  @override
  String get wearAndTearLabel => LocalizelyGenL10n.getText(localeName, 'wearAndTearLabel') ?? _fallback.wearAndTearLabel;

  @override
  String get labourRateLabel => LocalizelyGenL10n.getText(localeName, 'labourRateLabel') ?? _fallback.labourRateLabel;

  @override
  String get labourTimeLabel => LocalizelyGenL10n.getText(localeName, 'labourTimeLabel') ?? _fallback.labourTimeLabel;

  @override
  String get failureRiskLabel => LocalizelyGenL10n.getText(localeName, 'failureRiskLabel') ?? _fallback.failureRiskLabel;

  @override
  String get minutesLabel => LocalizelyGenL10n.getText(localeName, 'minutesLabel') ?? _fallback.minutesLabel;

  @override
  String get spoolWeightLabel => LocalizelyGenL10n.getText(localeName, 'spoolWeightLabel') ?? _fallback.spoolWeightLabel;

  @override
  String get spoolCostLabel => LocalizelyGenL10n.getText(localeName, 'spoolCostLabel') ?? _fallback.spoolCostLabel;

  @override
  String get electricityCostLabel => LocalizelyGenL10n.getText(localeName, 'electricityCostLabel') ?? _fallback.electricityCostLabel;

  @override
  String get electricityCostSettingsLabel => LocalizelyGenL10n.getText(localeName, 'electricityCostSettingsLabel') ?? _fallback.electricityCostSettingsLabel;

  @override
  String get submitButton => LocalizelyGenL10n.getText(localeName, 'submitButton') ?? _fallback.submitButton;

  @override
  String get resultElectricityPrefix => LocalizelyGenL10n.getText(localeName, 'resultElectricityPrefix') ?? _fallback.resultElectricityPrefix;

  @override
  String get resultFilamentPrefix => LocalizelyGenL10n.getText(localeName, 'resultFilamentPrefix') ?? _fallback.resultFilamentPrefix;

  @override
  String get resultTotalPrefix => LocalizelyGenL10n.getText(localeName, 'resultTotalPrefix') ?? _fallback.resultTotalPrefix;

  @override
  String get riskTotalPrefix => LocalizelyGenL10n.getText(localeName, 'riskTotalPrefix') ?? _fallback.riskTotalPrefix;

  @override
  String get premiumHeader => LocalizelyGenL10n.getText(localeName, 'premiumHeader') ?? _fallback.premiumHeader;

  @override
  String get labourCostPrefix => LocalizelyGenL10n.getText(localeName, 'labourCostPrefix') ?? _fallback.labourCostPrefix;

  @override
  String get selectPrinterHint => LocalizelyGenL10n.getText(localeName, 'selectPrinterHint') ?? _fallback.selectPrinterHint;

  @override
  String get watt => LocalizelyGenL10n.getText(localeName, 'watt') ?? _fallback.watt;

  @override
  String get kwh => LocalizelyGenL10n.getText(localeName, 'kwh') ?? _fallback.kwh;

  @override
  String get enterNumber => LocalizelyGenL10n.getText(localeName, 'enterNumber') ?? _fallback.enterNumber;

  @override
  String get invalidNumber => LocalizelyGenL10n.getText(localeName, 'invalidNumber') ?? _fallback.invalidNumber;

  @override
  String get supportEmailPrefix => LocalizelyGenL10n.getText(localeName, 'supportEmailPrefix') ?? _fallback.supportEmailPrefix;

  @override
  String get supportEmail => LocalizelyGenL10n.getText(localeName, 'supportEmail') ?? _fallback.supportEmail;

  @override
  String get supportIdLabel => LocalizelyGenL10n.getText(localeName, 'supportIdLabel') ?? _fallback.supportIdLabel;

  @override
  String get clickToCopy => LocalizelyGenL10n.getText(localeName, 'clickToCopy') ?? _fallback.clickToCopy;

  @override
  String get materialWeightExplanation => LocalizelyGenL10n.getText(localeName, 'materialWeightExplanation') ?? _fallback.materialWeightExplanation;

  @override
  String get exportSuccess => LocalizelyGenL10n.getText(localeName, 'exportSuccess') ?? _fallback.exportSuccess;

  @override
  String get exportError => LocalizelyGenL10n.getText(localeName, 'exportError') ?? _fallback.exportError;

  @override
  String get exportButton => LocalizelyGenL10n.getText(localeName, 'exportButton') ?? _fallback.exportButton;
}

class _LocalizelyLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _LocalizelyLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.delegate.load(locale).then((appLocalizations) {
    LocalizelyGenL10n.setCurrentLocale(appLocalizations.localeName);
    return LocalizelyLocalizations(appLocalizations.localeName, appLocalizations);
  });

  @override
  bool isSupported(Locale locale) => AppLocalizations.delegate.isSupported(locale);

  @override
  bool shouldReload(_LocalizelyLocalizationsDelegate old) => false;
}
