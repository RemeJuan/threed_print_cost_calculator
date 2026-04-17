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

  /// No description provided for @savePrintSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Print saved'**
  String get savePrintSuccessMessage;

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

  /// No description provided for @workCostsLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Costs'**
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
  /// **'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total'**
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
  /// **'Search materials'**
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
