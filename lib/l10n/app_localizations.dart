import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('de'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pt'),
    Locale('th'),
    Locale('id'),
  ];

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

  /// No description provided for @calculatorNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculatorNavLabel;

  /// No description provided for @historyNavLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyNavLabel;

  /// No description provided for @settingsNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNavLabel;

  /// No description provided for @newAnnouncementBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newAnnouncementBadgeLabel;

  /// No description provided for @generalHeader.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalHeader;

  /// No description provided for @wattLabel.
  ///
  /// In en, this message translates to:
  /// **'Watt (3D Printer)'**
  String get wattLabel;

  /// No description provided for @printWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Print Weight'**
  String get printWeightLabel;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Printing time (hours)'**
  String get hoursLabel;

  /// No description provided for @durationHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get durationHoursLabel;

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
  /// **'Work time'**
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

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get durationMinutesLabel;

  /// No description provided for @printingTimeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Printing time'**
  String get printingTimeDialogTitle;

  /// No description provided for @workTimeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Work time'**
  String get workTimeDialogTitle;

  /// No description provided for @spoolWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Material weight'**
  String get spoolWeightLabel;

  /// No description provided for @spoolCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Material cost'**
  String get spoolCostLabel;

  /// No description provided for @electricityCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
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
  /// **'Electricity'**
  String get resultElectricityPrefix;

  /// No description provided for @resultFilamentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Filament'**
  String get resultFilamentPrefix;

  /// No description provided for @resultTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Total '**
  String get resultTotalPrefix;

  /// No description provided for @riskTotalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get riskTotalPrefix;

  /// No description provided for @premiumHeader.
  ///
  /// In en, this message translates to:
  /// **'Premium users only:'**
  String get premiumHeader;

  /// No description provided for @labourCostPrefix.
  ///
  /// In en, this message translates to:
  /// **'Labour/Materials'**
  String get labourCostPrefix;

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
  /// **'kWh'**
  String get kwh;

  /// No description provided for @savePrintButton.
  ///
  /// In en, this message translates to:
  /// **'Save Print'**
  String get savePrintButton;

  /// No description provided for @printNameHint.
  ///
  /// In en, this message translates to:
  /// **'Print Name'**
  String get printNameHint;

  /// No description provided for @printerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get printerNameLabel;

  /// No description provided for @bedSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Bed Size *'**
  String get bedSizeLabel;

  /// No description provided for @wattageLabel.
  ///
  /// In en, this message translates to:
  /// **'Wattage *'**
  String get wattageLabel;

  /// No description provided for @materialNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get materialNameLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color *'**
  String get colorLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight *'**
  String get weightLabel;

  /// No description provided for @costLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost *'**
  String get costLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteDialogContent;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @resetButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButtonLabel;

  /// No description provided for @resetCalculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset calculation?'**
  String get resetCalculationTitle;

  /// No description provided for @resetCalculationBody.
  ///
  /// In en, this message translates to:
  /// **'This will discard your current calculator values and reload current defaults.'**
  String get resetCalculationBody;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @selectMaterialHint.
  ///
  /// In en, this message translates to:
  /// **'Custom (unsaved)'**
  String get selectMaterialHint;

  /// No description provided for @materialNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get materialNone;

  /// No description provided for @gramsSuffix.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gramsSuffix;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining:'**
  String get remainingLabel;

  /// No description provided for @trackRemainingFilamentLabel.
  ///
  /// In en, this message translates to:
  /// **'Track remaining filament'**
  String get trackRemainingFilamentLabel;

  /// No description provided for @remainingFilamentLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining filament'**
  String get remainingFilamentLabel;

  /// No description provided for @savePrintErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error saving print'**
  String get savePrintErrorMessage;

  /// No description provided for @deleteRecordErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error removing record'**
  String get deleteRecordErrorMessage;

  /// No description provided for @savePrintSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Print saved'**
  String get savePrintSuccessMessage;

  /// Shown when a material is deleted successfully
  ///
  /// In en, this message translates to:
  /// **'Material deleted'**
  String get deleteMaterialSuccessMessage;

  /// No description provided for @historyLoadAction.
  ///
  /// In en, this message translates to:
  /// **'Use in calculator'**
  String get historyLoadAction;

  /// No description provided for @historyLoadSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Loaded from history'**
  String get historyLoadSuccessMessage;

  /// No description provided for @historyLoadReplacementWarning.
  ///
  /// In en, this message translates to:
  /// **'Some items were unavailable and replaced'**
  String get historyLoadReplacementWarning;

  /// No description provided for @numberExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 123'**
  String get numberExampleHint;

  /// No description provided for @materialsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load materials: {error}'**
  String materialsLoadError(Object error);

  /// No description provided for @printersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load printers: {error}'**
  String printersLoadError(Object error);

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @wattsSuffix.
  ///
  /// In en, this message translates to:
  /// **'w'**
  String get wattsSuffix;

  /// No description provided for @needHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelpTitle;

  /// No description provided for @helpSupportSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get helpSupportSupportTitle;

  /// No description provided for @helpSupportSupportIntro.
  ///
  /// In en, this message translates to:
  /// **'Use these details when contacting support.'**
  String get helpSupportSupportIntro;

  /// No description provided for @helpSupportWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get helpSupportWebsiteLabel;

  /// No description provided for @helpSupportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get helpSupportEmailLabel;

  /// No description provided for @helpSupportSupportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Support ID'**
  String get helpSupportSupportIdLabel;

  /// No description provided for @helpSupportCopySupportIdTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy support ID'**
  String get helpSupportCopySupportIdTooltip;

  /// No description provided for @helpSupportAppVersionRow.
  ///
  /// In en, this message translates to:
  /// **'App version {version}'**
  String helpSupportAppVersionRow(Object version);

  /// No description provided for @helpSupportContactSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get helpSupportContactSupportButton;

  /// No description provided for @helpSupportContactEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'3D Print Cost Calculator Support'**
  String get helpSupportContactEmailSubject;

  /// No description provided for @helpSupportContactEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Support ID: {supportId}\nApp version: {version}\n\nDescribe the issue here.'**
  String helpSupportContactEmailBody(Object supportId, Object version);

  /// No description provided for @helpSupportContactEmailBodyNoSupportId.
  ///
  /// In en, this message translates to:
  /// **'Support ID: (not available)\nApp version: {version}\n\nDescribe the issue here.'**
  String helpSupportContactEmailBodyNoSupportId(Object version);

  /// No description provided for @helpSupportFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get helpSupportFaqTitle;

  /// No description provided for @helpSupportFaqWeightQuestion.
  ///
  /// In en, this message translates to:
  /// **'What weight should I enter?'**
  String get helpSupportFaqWeightQuestion;

  /// No description provided for @helpSupportFaqWeightAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter the total spool weight, not the leftover filament. The app uses the full roll weight to calculate per-gram cost.'**
  String get helpSupportFaqWeightAnswer;

  /// No description provided for @helpSupportFaqElectricityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why does electricity matter?'**
  String get helpSupportFaqElectricityQuestion;

  /// No description provided for @helpSupportFaqElectricityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Long prints and high-wattage printers can add real cost. Skipping electricity usually underprices the job.'**
  String get helpSupportFaqElectricityAnswer;

  /// No description provided for @helpSupportFaqRiskQuestion.
  ///
  /// In en, this message translates to:
  /// **'How is failure risk calculated?'**
  String get helpSupportFaqRiskQuestion;

  /// No description provided for @helpSupportFaqRiskAnswer.
  ///
  /// In en, this message translates to:
  /// **'Risk is applied only to base print costs like filament and electricity. It estimates expected loss from failed prints.'**
  String get helpSupportFaqRiskAnswer;

  /// No description provided for @helpSupportFaqLabourQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is labour / processing time?'**
  String get helpSupportFaqLabourQuestion;

  /// No description provided for @helpSupportFaqLabourAnswer.
  ///
  /// In en, this message translates to:
  /// **'It covers preparation, cleanup, post-processing, and monitoring. Keep it on for services where your time matters.'**
  String get helpSupportFaqLabourAnswer;

  /// No description provided for @helpSupportFaqMarkupQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is markup?'**
  String get helpSupportFaqMarkupQuestion;

  /// No description provided for @helpSupportFaqMarkupAnswer.
  ///
  /// In en, this message translates to:
  /// **'Markup is the percentage added on top of total cost to reach your selling price. It covers margin, overhead, and profit.'**
  String get helpSupportFaqMarkupAnswer;

  /// No description provided for @helpSupportFaqSetupQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is a setup fee?'**
  String get helpSupportFaqSetupQuestion;

  /// No description provided for @helpSupportFaqSetupAnswer.
  ///
  /// In en, this message translates to:
  /// **'A setup fee is a fixed cost per job for calibration, machine prep, and admin. It helps small prints cover overhead.'**
  String get helpSupportFaqSetupAnswer;

  /// No description provided for @helpSupportLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get helpSupportLinksTitle;

  /// No description provided for @helpSupportPrivacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get helpSupportPrivacyPolicyLabel;

  /// No description provided for @helpSupportTermsOfUseLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get helpSupportTermsOfUseLabel;

  /// No description provided for @helpSupportXTwitterLabel.
  ///
  /// In en, this message translates to:
  /// **'X / Twitter'**
  String get helpSupportXTwitterLabel;

  /// No description provided for @helpSupportThreadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get helpSupportThreadsLabel;

  /// No description provided for @helpSupportAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get helpSupportAboutTitle;

  /// No description provided for @helpSupportAboutIntro.
  ///
  /// In en, this message translates to:
  /// **'3D Print Cost Calculator is built for local-first pricing. It helps makers and small print businesses quote work with fewer surprises.'**
  String get helpSupportAboutIntro;

  /// No description provided for @helpSupportTrustNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get helpSupportTrustNoAccounts;

  /// No description provided for @helpSupportTrustNoCloudSync.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync'**
  String get helpSupportTrustNoCloudSync;

  /// No description provided for @helpSupportTrustNoTracking.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get helpSupportTrustNoTracking;

  /// No description provided for @helpSupportTrustLocalData.
  ///
  /// In en, this message translates to:
  /// **'Local data'**
  String get helpSupportTrustLocalData;

  /// No description provided for @helpSupportAboutCalculator.
  ///
  /// In en, this message translates to:
  /// **'The calculator combines filament cost, electricity, failure risk, labour, and optional pricing tools like markup and setup fees.'**
  String get helpSupportAboutCalculator;

  /// No description provided for @helpSupportAboutOutcome.
  ///
  /// In en, this message translates to:
  /// **'That keeps quotes tied to true cost, not just material spend.'**
  String get helpSupportAboutOutcome;

  /// No description provided for @supportEmailPrefix.
  ///
  /// In en, this message translates to:
  /// **'For any issues, please mail me at '**
  String get supportEmailPrefix;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'3d@printcostcalc.app'**
  String get supportEmail;

  /// No description provided for @supportIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Please include your Support ID: '**
  String get supportIdLabel;

  /// No description provided for @supportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'3D Print Cost Calculator Support'**
  String get supportEmailSubject;

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

  /// No description provided for @supportIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Support ID Copied'**
  String get supportIdCopied;

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

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @websiteLink.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteLink;

  /// No description provided for @termsOfUseLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUseLink;

  /// No description provided for @separator.
  ///
  /// In en, this message translates to:
  /// **' | '**
  String get separator;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @testDataToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Test data tools'**
  String get testDataToolsTitle;

  /// No description provided for @testDataToolsBody.
  ///
  /// In en, this message translates to:
  /// **'These actions are for local testing only. Seeding replaces the current local setup with demo data. Purging permanently removes local app data on this device.'**
  String get testDataToolsBody;

  /// No description provided for @seedTestDataButton.
  ///
  /// In en, this message translates to:
  /// **'Seed test data'**
  String get seedTestDataButton;

  /// No description provided for @purgeLocalDataButton.
  ///
  /// In en, this message translates to:
  /// **'Purge local data'**
  String get purgeLocalDataButton;

  /// No description provided for @enablePremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Enable premium'**
  String get enablePremiumButton;

  /// No description provided for @enablePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable premium'**
  String get enablePremiumTitle;

  /// No description provided for @enablePremiumBody.
  ///
  /// In en, this message translates to:
  /// **'Enter confirmation code to enable local premium testing'**
  String get enablePremiumBody;

  /// No description provided for @invalidConfirmationCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid confirmation code'**
  String get invalidConfirmationCodeMessage;

  /// No description provided for @seedTestDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed test data?'**
  String get seedTestDataConfirmTitle;

  /// No description provided for @seedTestDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will replace the current local setup with deterministic demo data.'**
  String get seedTestDataConfirmBody;

  /// No description provided for @purgeLocalDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Purge local data?'**
  String get purgeLocalDataConfirmTitle;

  /// No description provided for @purgeLocalDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove all local app data on this device.'**
  String get purgeLocalDataConfirmBody;

  /// No description provided for @testDataSeededMessage.
  ///
  /// In en, this message translates to:
  /// **'Test data seeded'**
  String get testDataSeededMessage;

  /// No description provided for @testDataPurgedMessage.
  ///
  /// In en, this message translates to:
  /// **'Local data purged'**
  String get testDataPurgedMessage;

  /// No description provided for @testDataActionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Test data action failed'**
  String get testDataActionFailedMessage;

  /// No description provided for @mailClientError.
  ///
  /// In en, this message translates to:
  /// **'Could not open mail client'**
  String get mailClientError;

  /// No description provided for @offeringsError.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get offeringsError;

  /// No description provided for @currentOfferings.
  ///
  /// In en, this message translates to:
  /// **'Current Offerings'**
  String get currentOfferings;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'There was an error processing your purchase. Please try again later.'**
  String get purchaseError;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @printersHeader.
  ///
  /// In en, this message translates to:
  /// **'Printers'**
  String get printersHeader;

  /// No description provided for @materialsHeader.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsHeader;

  /// No description provided for @filamentCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Filament'**
  String get filamentCostLabel;

  /// No description provided for @labourCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get labourCostLabel;

  /// No description provided for @additionalCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional cost'**
  String get additionalCostLabel;

  /// No description provided for @additionalCostNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional cost note'**
  String get additionalCostNoteLabel;

  /// No description provided for @additionalCostNoteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional cost note'**
  String get additionalCostNoteDialogTitle;

  /// No description provided for @riskCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get riskCostLabel;

  /// No description provided for @totalCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalCostLabel;

  /// No description provided for @costTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total cost'**
  String get costTotalLabel;

  /// No description provided for @markupLabel.
  ///
  /// In en, this message translates to:
  /// **'Markup'**
  String get markupLabel;

  /// No description provided for @setupFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Setup fee'**
  String get setupFeeLabel;

  /// No description provided for @roundingAdjustmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Rounding adjustment'**
  String get roundingAdjustmentLabel;

  /// No description provided for @finalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Final price'**
  String get finalPriceLabel;

  /// No description provided for @jobPricingOverridesLabel.
  ///
  /// In en, this message translates to:
  /// **'Job settings'**
  String get jobPricingOverridesLabel;

  /// No description provided for @pricingOverridesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# override applied} other{# overrides applied}}'**
  String pricingOverridesSummary(num count);

  /// No description provided for @pricingMarkupPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Markup %'**
  String get pricingMarkupPercentLabel;

  /// No description provided for @pricingSetupFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Setup fee'**
  String get pricingSetupFeeLabel;

  /// No description provided for @pricingRoundingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rounding'**
  String get pricingRoundingLabel;

  /// No description provided for @pricingRoundingNoneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get pricingRoundingNoneLabel;

  /// No description provided for @pricingRoundingWholeDollarLabel.
  ///
  /// In en, this message translates to:
  /// **'Whole dollar'**
  String get pricingRoundingWholeDollarLabel;

  /// No description provided for @pricingRoundingPointNinetyNineLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends in .99'**
  String get pricingRoundingPointNinetyNineLabel;

  /// No description provided for @workCostsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pricing & Work Costs'**
  String get workCostsLabel;

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

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @validationEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validationEnterValidNumber;

  /// No description provided for @validationMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get validationMustBeGreaterThanZero;

  /// No description provided for @validationMustBeZeroOrMore.
  ///
  /// In en, this message translates to:
  /// **'Must be 0 or more'**
  String get validationMustBeZeroOrMore;

  /// No description provided for @lockedValuePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedValuePlaceholder;

  /// No description provided for @hideProPromotionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide Pro promotions'**
  String get hideProPromotionsTitle;

  /// No description provided for @hideProPromotionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide upgrade banners and prompts'**
  String get hideProPromotionsSubtitle;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or printer'**
  String get historySearchHint;

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

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved prints yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Re-use past prints in the calculator'**
  String get historyEmptyDescription;

  /// No description provided for @historyUpsellTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-use past prints instantly'**
  String get historyUpsellTitle;

  /// No description provided for @historyUpsellDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced edits and exports'**
  String get historyUpsellDescription;

  /// No description provided for @historyNoMoreRecords.
  ///
  /// In en, this message translates to:
  /// **'No more records'**
  String get historyNoMoreRecords;

  /// No description provided for @historyOverflowHint.
  ///
  /// In en, this message translates to:
  /// **'More actions in ⋯'**
  String get historyOverflowHint;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String historyLoadError(Object error);

  /// No description provided for @historyCsvHeader.
  ///
  /// In en, this message translates to:
  /// **'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total,Markup %,Markup Amount,Setup Fee,Rounding Mode,Subtotal Before Rounding,Rounding Adjustment,Final Price'**
  String get historyCsvHeader;

  /// No description provided for @historyExportShareText.
  ///
  /// In en, this message translates to:
  /// **'3D Print Cost History Export'**
  String get historyExportShareText;

  /// No description provided for @historyTeaserTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep every print estimate in one place'**
  String get historyTeaserTitle;

  /// No description provided for @historyTeaserDescription.
  ///
  /// In en, this message translates to:
  /// **'Review how history works before upgrading. Save completed estimates and export them any time with Pro.'**
  String get historyTeaserDescription;

  /// No description provided for @historyTeaserCta.
  ///
  /// In en, this message translates to:
  /// **'Save & export history with Pro'**
  String get historyTeaserCta;

  /// No description provided for @historyExportPreviewEntry.
  ///
  /// In en, this message translates to:
  /// **'Preview sample CSV export'**
  String get historyExportPreviewEntry;

  /// No description provided for @historyExportPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'CSV preview'**
  String get historyExportPreviewTitle;

  /// No description provided for @historyExportPreviewDescription.
  ///
  /// In en, this message translates to:
  /// **'See how your export will look. Download and share are unlocked with Pro.'**
  String get historyExportPreviewDescription;

  /// No description provided for @historyExportPreviewSampleLabel.
  ///
  /// In en, this message translates to:
  /// **'[Sample]'**
  String get historyExportPreviewSampleLabel;

  /// No description provided for @historyExportPreviewAction.
  ///
  /// In en, this message translates to:
  /// **'Download / Share with Pro'**
  String get historyExportPreviewAction;

  /// No description provided for @addMaterialButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addMaterialButton;

  /// No description provided for @useSingleTotalWeightAction.
  ///
  /// In en, this message translates to:
  /// **'Use single total weight'**
  String get useSingleTotalWeightAction;

  /// No description provided for @addAtLeastOneMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add at least one material.'**
  String get addAtLeastOneMaterial;

  /// No description provided for @searchMaterialsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or brand'**
  String get searchMaterialsHint;

  /// No description provided for @materialBreakdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Material breakdown'**
  String get materialBreakdownLabel;

  /// No description provided for @materialsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# material} other{# materials}}'**
  String materialsCountLabel(num count);

  /// No description provided for @totalMaterialWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Total material weight: {grams}g'**
  String totalMaterialWeightLabel(num grams);

  /// Label for showing app version
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @materialFallback.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get materialFallback;

  /// No description provided for @durationPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Printing time (hh:mm)'**
  String get durationPickerLabel;

  /// No description provided for @importGcodeButton.
  ///
  /// In en, this message translates to:
  /// **'Import G-code (Auto-fill)'**
  String get importGcodeButton;

  /// No description provided for @importGcodePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Import G-code (Beta)'**
  String get importGcodePageTitle;

  /// No description provided for @importGcodeIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick a local .gcode file. Supported slicers: PrusaSlicer, OrcaSlicer, Bambu Studio, and Cura.'**
  String get importGcodeIntro;

  /// No description provided for @importGcodeSelectFileButton.
  ///
  /// In en, this message translates to:
  /// **'Choose G-code file'**
  String get importGcodeSelectFileButton;

  /// No description provided for @importGcodePickAnotherButton.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importGcodePickAnotherButton;

  /// No description provided for @importGcodeSelectedFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected file'**
  String get importGcodeSelectedFileLabel;

  /// No description provided for @gcodeImportFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'G-code Import Beta Feedback'**
  String get gcodeImportFeedbackTitle;

  /// No description provided for @gcodeImportFeedbackBetaFeature.
  ///
  /// In en, this message translates to:
  /// **'Beta feature'**
  String get gcodeImportFeedbackBetaFeature;

  /// No description provided for @gcodeImportFeedbackBetaDescription.
  ///
  /// In en, this message translates to:
  /// **'Tell us what helped, what broke, or what still looks wrong.'**
  String get gcodeImportFeedbackBetaDescription;

  /// No description provided for @gcodeImportFeedbackSlicerLabel.
  ///
  /// In en, this message translates to:
  /// **'Slicer'**
  String get gcodeImportFeedbackSlicerLabel;

  /// No description provided for @gcodeImportFeedbackOtherSlicerLabel.
  ///
  /// In en, this message translates to:
  /// **'Which slicer?'**
  String get gcodeImportFeedbackOtherSlicerLabel;

  /// No description provided for @gcodeImportFeedbackPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview result'**
  String get gcodeImportFeedbackPreviewLabel;

  /// No description provided for @gcodeImportFeedbackMetadataLabel.
  ///
  /// In en, this message translates to:
  /// **'Metadata result'**
  String get gcodeImportFeedbackMetadataLabel;

  /// No description provided for @gcodeImportFeedbackDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What worked, what broke, or what looks wrong?'**
  String get gcodeImportFeedbackDescriptionLabel;

  /// No description provided for @gcodeImportFeedbackAttachmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach imported G-code file'**
  String get gcodeImportFeedbackAttachmentLabel;

  /// No description provided for @gcodeImportFeedbackNoAttachmentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No imported G-code file available to attach.'**
  String get gcodeImportFeedbackNoAttachmentAvailable;

  /// No description provided for @gcodeImportFeedbackSendCta.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get gcodeImportFeedbackSendCta;

  /// No description provided for @gcodeImportFeedbackSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get gcodeImportFeedbackSentMessage;

  /// No description provided for @gcodeFeedbackPreviewLoaded.
  ///
  /// In en, this message translates to:
  /// **'Preview loaded'**
  String get gcodeFeedbackPreviewLoaded;

  /// No description provided for @gcodeFeedbackPreviewMissing.
  ///
  /// In en, this message translates to:
  /// **'Preview missing'**
  String get gcodeFeedbackPreviewMissing;

  /// No description provided for @gcodeFeedbackPreviewIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect preview'**
  String get gcodeFeedbackPreviewIncorrect;

  /// No description provided for @gcodeFeedbackPreviewNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get gcodeFeedbackPreviewNotSure;

  /// No description provided for @gcodeFeedbackMetadataCorrect.
  ///
  /// In en, this message translates to:
  /// **'Looks correct'**
  String get gcodeFeedbackMetadataCorrect;

  /// No description provided for @gcodeFeedbackMetadataMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing data'**
  String get gcodeFeedbackMetadataMissing;

  /// No description provided for @gcodeFeedbackMetadataIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect data'**
  String get gcodeFeedbackMetadataIncorrect;

  /// No description provided for @gcodeFeedbackMetadataNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get gcodeFeedbackMetadataNotSure;

  /// No description provided for @importGcodeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Import summary'**
  String get importGcodeSummaryTitle;

  /// No description provided for @importGcodeSupportedSlicersNote.
  ///
  /// In en, this message translates to:
  /// **'Supported slicers: PrusaSlicer, OrcaSlicer, Bambu Studio, and Cura.'**
  String get importGcodeSupportedSlicersNote;

  /// No description provided for @importGcodeCalculatorNote.
  ///
  /// In en, this message translates to:
  /// **'Imported values only prefill time and total material weight. Printer, material, and final cost still come from your calculator settings.'**
  String get importGcodeCalculatorNote;

  /// No description provided for @importGcodeUseValuesButton.
  ///
  /// In en, this message translates to:
  /// **'Use these values'**
  String get importGcodeUseValuesButton;

  /// No description provided for @importGcodeSlicerLabel.
  ///
  /// In en, this message translates to:
  /// **'Slicer'**
  String get importGcodeSlicerLabel;

  /// No description provided for @importGcodeDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration'**
  String get importGcodeDurationLabel;

  /// No description provided for @importGcodeFilamentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Filament weight'**
  String get importGcodeFilamentWeightLabel;

  /// No description provided for @importGcodeFilamentLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Filament length'**
  String get importGcodeFilamentLengthLabel;

  /// No description provided for @importGcodeLayerHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Layer height'**
  String get importGcodeLayerHeightLabel;

  /// No description provided for @importGcodePreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importGcodePreviewLabel;

  /// No description provided for @importGcodePreviewAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get importGcodePreviewAvailable;

  /// No description provided for @importGcodePreviewView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get importGcodePreviewView;

  /// No description provided for @importGcodePreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get importGcodePreviewUnavailable;

  /// No description provided for @importGcodePreviewDecodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview metadata found, but image could not be displayed.'**
  String get importGcodePreviewDecodeFailed;

  /// No description provided for @importGcodePreviewCuraNote.
  ///
  /// In en, this message translates to:
  /// **'Cura previews may require a post-processing script to embed thumbnails in the G-code.'**
  String get importGcodePreviewCuraNote;

  /// No description provided for @importGcodeWarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get importGcodeWarningsTitle;

  /// No description provided for @importGcodeUnsupportedTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please choose a .gcode file.'**
  String get importGcodeUnsupportedTypeError;

  /// No description provided for @importGcodeUnsupportedFileError.
  ///
  /// In en, this message translates to:
  /// **'This file did not contain supported G-code metadata.'**
  String get importGcodeUnsupportedFileError;

  /// No description provided for @importGcodeReadError.
  ///
  /// In en, this message translates to:
  /// **'The selected file could not be read.'**
  String get importGcodeReadError;

  /// No description provided for @importGcodeUnknownSlicerValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get importGcodeUnknownSlicerValue;

  /// No description provided for @importGcodeMissingValue.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get importGcodeMissingValue;

  /// No description provided for @importGcodeWarningUnknownSlicer.
  ///
  /// In en, this message translates to:
  /// **'Slicer not identified. Review values before applying.'**
  String get importGcodeWarningUnknownSlicer;

  /// No description provided for @importGcodeWarningMissingDuration.
  ///
  /// In en, this message translates to:
  /// **'Could not detect print time.'**
  String get importGcodeWarningMissingDuration;

  /// No description provided for @importGcodeWarningMissingFilament.
  ///
  /// In en, this message translates to:
  /// **'Filament usage incomplete.'**
  String get importGcodeWarningMissingFilament;

  /// No description provided for @importGcodeWarningMissingFilamentWeight.
  ///
  /// In en, this message translates to:
  /// **'Filament weight missing.'**
  String get importGcodeWarningMissingFilamentWeight;

  /// No description provided for @importGcodeWarningPartialMetadata.
  ///
  /// In en, this message translates to:
  /// **'Some metadata missing.'**
  String get importGcodeWarningPartialMetadata;

  /// No description provided for @importGcodeWarningMixedMaterials.
  ///
  /// In en, this message translates to:
  /// **'Multiple material totals found. Review before applying.'**
  String get importGcodeWarningMixedMaterials;

  /// No description provided for @importGcodeAppliedMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported values applied to calculator'**
  String get importGcodeAppliedMessage;

  /// No description provided for @slicerPrusaSlicer.
  ///
  /// In en, this message translates to:
  /// **'PrusaSlicer'**
  String get slicerPrusaSlicer;

  /// No description provided for @slicerOrcaSlicer.
  ///
  /// In en, this message translates to:
  /// **'OrcaSlicer'**
  String get slicerOrcaSlicer;

  /// No description provided for @slicerBambuStudio.
  ///
  /// In en, this message translates to:
  /// **'Bambu Studio'**
  String get slicerBambuStudio;

  /// No description provided for @slicerCura.
  ///
  /// In en, this message translates to:
  /// **'Cura'**
  String get slicerCura;

  /// No description provided for @slicerCrealityPrint.
  ///
  /// In en, this message translates to:
  /// **'Creality Print'**
  String get slicerCrealityPrint;

  /// No description provided for @slicerSimplify3D.
  ///
  /// In en, this message translates to:
  /// **'Simplify3D'**
  String get slicerSimplify3D;

  /// No description provided for @slicerSuperSlicer.
  ///
  /// In en, this message translates to:
  /// **'SuperSlicer'**
  String get slicerSuperSlicer;

  /// No description provided for @slicerIdeaMaker.
  ///
  /// In en, this message translates to:
  /// **'IdeaMaker'**
  String get slicerIdeaMaker;

  /// No description provided for @slicerOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get slicerOther;

  /// No description provided for @slicerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get slicerUnknown;

  /// No description provided for @materialsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsAppBarTitle;

  /// No description provided for @materialsNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsNavLabel;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @materialTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Material type'**
  String get materialTypeLabel;

  /// No description provided for @colorHexLabel.
  ///
  /// In en, this message translates to:
  /// **'Color hex (optional)'**
  String get colorHexLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @materialsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No materials yet. Tap + to add one.'**
  String get materialsEmpty;

  /// No description provided for @materialsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get materialsFilterAll;

  /// No description provided for @materialsFilterInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get materialsFilterInStock;

  /// No description provided for @materialsFilterLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get materialsFilterLowStock;

  /// No description provided for @materialsFilterOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get materialsFilterOutOfStock;

  /// No description provided for @csvImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import materials'**
  String get csvImportTitle;

  /// No description provided for @csvTemplateButton.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get csvTemplateButton;

  /// No description provided for @csvTemplateShareText.
  ///
  /// In en, this message translates to:
  /// **'Material CSV Template'**
  String get csvTemplateShareText;

  /// No description provided for @csvTemplateError.
  ///
  /// In en, this message translates to:
  /// **'Could not share the template.'**
  String get csvTemplateError;

  /// No description provided for @csvImportIntro.
  ///
  /// In en, this message translates to:
  /// **'Import materials from a CSV file.'**
  String get csvImportIntro;

  /// No description provided for @csvSelectFileButton.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV file'**
  String get csvSelectFileButton;

  /// No description provided for @csvImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import valid rows'**
  String get csvImportButton;

  /// No description provided for @csvReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get csvReadError;

  /// No description provided for @csvFileTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select a .csv file'**
  String get csvFileTypeError;

  /// No description provided for @csvNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get csvNameRequiredError;

  /// No description provided for @csvColorRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Color is required'**
  String get csvColorRequiredError;

  /// No description provided for @csvSpoolWeightRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Spool weight is required'**
  String get csvSpoolWeightRequiredError;

  /// No description provided for @csvSpoolWeightPositiveError.
  ///
  /// In en, this message translates to:
  /// **'Spool weight must be > 0'**
  String get csvSpoolWeightPositiveError;

  /// No description provided for @csvCostRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Cost is required'**
  String get csvCostRequiredError;

  /// No description provided for @csvCostPositiveError.
  ///
  /// In en, this message translates to:
  /// **'Cost must be > 0'**
  String get csvCostPositiveError;

  /// No description provided for @csvImportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Imported 1 material} other{Imported {count} materials}}'**
  String csvImportSuccessMessage(int count);

  /// No description provided for @csvPreviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} rows: {valid} valid, {invalid} with errors'**
  String csvPreviewSummary(int total, int valid, int invalid);

  /// No description provided for @csvEmptyNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get csvEmptyNamePlaceholder;

  /// No description provided for @stockBadgeOut.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get stockBadgeOut;

  /// No description provided for @stockBadgeLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get stockBadgeLow;

  /// No description provided for @stockBadgeInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get stockBadgeInStock;

  /// No description provided for @stockBadgeNoTracking.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get stockBadgeNoTracking;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'nl',
    'pt',
    'th',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
