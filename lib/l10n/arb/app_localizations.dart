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

  /// No description provided for @electricityCostSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Electricity cost'**
  String get electricityCostSettingsLabel;

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
  /// **'Labour/Materials: '**
  String get labourCostPrefix;

  /// Placeholder shown for locked premium result values.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get lockedValuePlaceholder;

  /// No description provided for @selectPrinterHint.
  ///
  /// In en, this message translates to:
  /// **'Select Printer'**
  String get selectPrinterHint;

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

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number'**
  String get enterNumber;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @supportEmailPrefix.
  ///
  /// In en, this message translates to:
  /// **'For any issues, please mail me at '**
  String get supportEmailPrefix;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'google@remej.dev'**
  String get supportEmail;

  /// No description provided for @supportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Please include your Support ID: '**
  String get supportIdLabel;

  /// No description provided for @clickToCopy.
  ///
  /// In en, this message translates to:
  /// **'(click to copy)'**
  String get clickToCopy;

  /// Explanation shown in the support/help dialog about what 'Material weight' and 'Material cost' refer to.
  ///
  /// In en, this message translates to:
  /// **'Material weight is the total weight for the source material, so the entire roll of filament. The cost is the cost of the entire unit.'**
  String get materialWeightExplanation;

  /// Shown when a history export completes successfully
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get exportSuccess;

  /// Shown when a history export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportError;

  /// Label for export action in history list
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// Title for the free-user toggle that hides upgrade prompts and premium previews.
  ///
  /// In en, this message translates to:
  /// **'Hide Pro feature promotions'**
  String get hideProPromotionsTitle;

  /// Subtitle for the free-user toggle that hides premium promotional surfaces.
  ///
  /// In en, this message translates to:
  /// **'Hide upgrade prompts and previews for premium features'**
  String get hideProPromotionsSubtitle;

  /// Headline for the free-user history teaser state.
  ///
  /// In en, this message translates to:
  /// **'Keep every print estimate in one place'**
  String get historyTeaserTitle;

  /// Short explanation of the history feature value in the teaser state.
  ///
  /// In en, this message translates to:
  /// **'Save past print costs and export them as CSV with Pro.'**
  String get historyTeaserDescription;

  /// Primary CTA shown in the free-user history teaser state.
  ///
  /// In en, this message translates to:
  /// **'Save & export history with Pro'**
  String get historyTeaserCta;

  /// Entry point label for the free-user export teaser flow.
  ///
  /// In en, this message translates to:
  /// **'Preview sample CSV export'**
  String get historyExportPreviewEntry;

  /// Title for the export preview teaser sheet.
  ///
  /// In en, this message translates to:
  /// **'CSV preview'**
  String get historyExportPreviewTitle;

  /// Helper copy shown above the sample CSV preview for free users.
  ///
  /// In en, this message translates to:
  /// **'Example rows only. Download and sharing unlock with Pro.'**
  String get historyExportPreviewDescription;

  /// Label marking the teaser CSV preview as sample data.
  ///
  /// In en, this message translates to:
  /// **'[Sample]'**
  String get historyExportPreviewSampleLabel;

  /// Button label for the gated action in the export teaser flow.
  ///
  /// In en, this message translates to:
  /// **'Download / Share with Pro'**
  String get historyExportPreviewAction;

  /// No description provided for @historyExportMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Prints'**
  String get historyExportMenuTitle;

  /// No description provided for @historyExportRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyExportRangeAll;

  /// No description provided for @historyExportRangeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get historyExportRangeLast7Days;

  /// No description provided for @historyExportRangeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get historyExportRangeLast30Days;

  /// No description provided for @historyNoMoreRecords.
  ///
  /// In en, this message translates to:
  /// **'No more records'**
  String get historyNoMoreRecords;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String historyLoadError(Object error);

  /// No description provided for @historyCsvHeader.
  ///
  /// In en, this message translates to:
  /// **'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total'**
  String get historyCsvHeader;

  /// No description provided for @historyExportShareText.
  ///
  /// In en, this message translates to:
  /// **'3D Print Cost History Export'**
  String get historyExportShareText;
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
