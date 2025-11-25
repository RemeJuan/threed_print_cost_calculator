import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @calculatorAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'3D Print Calculator'**
  String get calculatorAppBarTitle;

  /// No description provided for @historyAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAppBarTitle;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppBarTitle;

  /// No description provided for @wattLabel.
  ///
  /// In en, this message translates to:
  /// **'Watt (3D Printer)'**
  String get wattLabel;

  /// No description provided for @printWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight of the print'**
  String get printWeightLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Printing time (hours)'**
  String get hoursLabel;

  /// No description provided for @wearAndTearLabel.
  ///
  /// In en, this message translates to:
  /// **'Materials/Wear + tear'**
  String get wearAndTearLabel;

  /// No description provided for @labourRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate'**
  String get labourRateLabel;

  /// No description provided for @labourTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Processing time'**
  String get labourTimeLabel;

  /// No description provided for @failureRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'Failure risk (%)'**
  String get failureRiskLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesLabel;

  /// No description provided for @spoolWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Spool/Resin weight'**
  String get spoolWeightLabel;

  /// No description provided for @spoolCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Spool/Resin cost'**
  String get spoolCostLabel;

  /// No description provided for @electricityCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Electricity cost'**
  String get electricityCostLabel;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get submitButton;

  /// No description provided for @resultElectricityPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total cost for Electricity: '**
  String get resultElectricityPrefix;

  /// No description provided for @resultFilamentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total cost for filament: '**
  String get resultFilamentPrefix;

  /// No description provided for @resultTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total cost: '**
  String get resultTotalPrefix;

  /// No description provided for @riskTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Risk cost: '**
  String get riskTotalPrefix;

  /// No description provided for @premiumHeader.
  ///
  /// In en, this message translates to:
  /// **'Premium users only:'**
  String get premiumHeader;

  /// No description provided for @labourCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Labour cost: '**
  String get labourCostPrefix;

  /// No description provided for @watt.
  ///
  /// In en, this message translates to:
  /// **'Watt'**
  String get watt;

  /// No description provided for @kwh.
  ///
  /// In en, this message translates to:
  /// **'kW/h'**
  String get kwh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
