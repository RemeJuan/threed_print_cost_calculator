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
    final name =
        (locale.countryCode?.isEmpty ?? false)
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

  /// `Electricity cost`
  String get electricityCostLabel {
    return Intl.message(
      'Electricity cost',
      name: 'electricityCostLabel',
      desc: '',
      args: [],
    );
  }

  /// `Calculate`
  String get submitButton {
    return Intl.message('Calculate', name: 'submitButton', desc: '', args: []);
  }

  /// `Total cost for Electricity: `
  String get resultElectricityPrefix {
    return Intl.message(
      'Total cost for Electricity: ',
      name: 'resultElectricityPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Total cost for filament: `
  String get resultFilamentPrefix {
    return Intl.message(
      'Total cost for filament: ',
      name: 'resultFilamentPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Total cost: `
  String get resultTotalPrefix {
    return Intl.message(
      'Total cost: ',
      name: 'resultTotalPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Risk cost: `
  String get riskTotalPrefix {
    return Intl.message(
      'Risk cost: ',
      name: 'riskTotalPrefix',
      desc: '',
      args: [],
    );
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

  /// `Labour cost: `
  String get labourCostPrefix {
    return Intl.message(
      'Labour cost: ',
      name: 'labourCostPrefix',
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
