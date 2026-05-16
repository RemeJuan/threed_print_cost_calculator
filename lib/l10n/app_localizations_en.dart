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
  String get newAnnouncementBadgeLabel => 'New';

  @override
  String get whatsNewSeeRecentUpdates => 'See recent updates';

  @override
  String get generalHeader => 'General';

  @override
  String get wattLabel => 'Watt (3D Printer)';

  @override
  String get printWeightLabel => 'Print Weight';

  @override
  String get hoursLabel => 'Printing time (hours)';

  @override
  String get durationHoursLabel => 'Hours';

  @override
  String get wearAndTearLabel => 'Materials/Wear + tear';

  @override
  String get labourRateLabel => 'Hourly rate';

  @override
  String get labourTimeLabel => 'Work time';

  @override
  String get failureRiskLabel => 'Failure risk (%)';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get durationMinutesLabel => 'Minutes';

  @override
  String get printingTimeDialogTitle => 'Printing time';

  @override
  String get workTimeDialogTitle => 'Work time';

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
  String get resetButtonLabel => 'Reset';

  @override
  String get resetCalculationTitle => 'Reset calculation?';

  @override
  String get resetCalculationBody =>
      'This will discard your current calculator values and reload current defaults.';

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
  String get deleteRecordErrorMessage => 'Error removing record';

  @override
  String get savePrintSuccessMessage => 'Print saved';

  @override
  String get deleteMaterialSuccessMessage => 'Material deleted';

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
  String get helpSupportSupportTitle => 'Support';

  @override
  String get helpSupportSupportIntro =>
      'Use these details when contacting support.';

  @override
  String get helpSupportWebsiteLabel => 'Website';

  @override
  String get helpSupportEmailLabel => 'Email';

  @override
  String get helpSupportSupportIdLabel => 'Support ID';

  @override
  String get helpSupportCopySupportIdTooltip => 'Copy support ID';

  @override
  String get helpSupportRoadmapLabel => 'Roadmap';

  @override
  String get helpSupportRoadmapValue => 'View what’s coming';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'App version $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Contact support';

  @override
  String get helpSupportContactEmailSubject =>
      '3D Print Cost Calculator Support';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'Support ID: $supportId\nApp version: $version\n\nDescribe the issue here.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'Support ID: (not available)\nApp version: $version\n\nDescribe the issue here.';
  }

  @override
  String get helpSupportFaqTitle => 'FAQs';

  @override
  String get helpSupportFaqWeightQuestion => 'What weight should I enter?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Enter the total spool weight, not the leftover filament. The app uses the full roll weight to calculate per-gram cost.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      'Why does electricity matter?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Long prints and high-wattage printers can add real cost. Skipping electricity usually underprices the job.';

  @override
  String get helpSupportFaqRiskQuestion => 'How is failure risk calculated?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'Risk is applied only to base print costs like filament and electricity. It estimates expected loss from failed prints.';

  @override
  String get helpSupportFaqLabourQuestion =>
      'What is labour / processing time?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'It covers preparation, cleanup, post-processing, and monitoring. Keep it on for services where your time matters.';

  @override
  String get helpSupportFaqMarkupQuestion => 'What is markup?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'Markup is the percentage added on top of total cost to reach your selling price. It covers margin, overhead, and profit.';

  @override
  String get helpSupportFaqSetupQuestion => 'What is a setup fee?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'A setup fee is a fixed cost per job for calibration, machine prep, and admin. It helps small prints cover overhead.';

  @override
  String get helpSupportLinksTitle => 'Links';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Privacy policy';

  @override
  String get helpSupportTermsOfUseLabel => 'Terms of use';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'About';

  @override
  String get helpSupportAboutIntro =>
      '3D Print Cost Calculator is built for local-first pricing. It helps makers and small print businesses quote work with fewer surprises.';

  @override
  String get helpSupportTrustNoAccounts => 'No accounts';

  @override
  String get helpSupportTrustNoCloudSync => 'No cloud sync';

  @override
  String get helpSupportTrustNoTracking => 'No tracking';

  @override
  String get helpSupportTrustLocalData => 'Local data';

  @override
  String get helpSupportAboutCalculator =>
      'The calculator combines filament cost, electricity, failure risk, labour, and optional pricing tools like markup and setup fees.';

  @override
  String get helpSupportAboutOutcome =>
      'That keeps quotes tied to true cost, not just material spend.';

  @override
  String get supportEmailPrefix => 'For any issues, please mail me at ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Please include your Support ID: ';

  @override
  String get supportEmailSubject => '3D Print Cost Calculator Support';

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
  String get websiteLink => 'Website';

  @override
  String get termsOfUseLink => 'Terms of Use';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Close';

  @override
  String get cancelFeedbackPromptTitle =>
      'Looks like you turned off renewal. Mind telling me why?';

  @override
  String get feedbackSubmitButton => 'Send feedback';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Too expensive';

  @override
  String get cancelFeedbackReasonMissingFeatures => 'Missing features';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'Not enough value';

  @override
  String get cancelFeedbackReasonConfusingToUse => 'Confusing to use';

  @override
  String get cancelFeedbackReasonJustTesting => 'Just testing the app';

  @override
  String get cancelFeedbackReasonOther => 'Other';

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
  String get forceUpdateAvailableButton => 'Force update available';

  @override
  String get forceNoUpdateButton => 'Force no update';

  @override
  String get clearUpdateCooldownButton => 'Clear update cooldown';

  @override
  String get previewCancelFeedbackButton => 'Preview renewal feedback';

  @override
  String get enableBatchCostingButton => 'Enable batch costing';

  @override
  String get showWhatsNewButton => 'Show What\'s New';

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
  String get updatePromptTitle => 'Update available';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'Version $storeVersion is available. You have $currentVersion installed.';
  }

  @override
  String get updatePromptBodyUnknown => 'A newer version is available.';

  @override
  String get updatePromptOpenStoreButton => 'Open store';

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
  String get additionalCostLabel => 'Additional cost';

  @override
  String get additionalCostNoteLabel => 'Additional cost note';

  @override
  String get additionalCostNoteDialogTitle => 'Additional cost note';

  @override
  String get riskCostLabel => 'Risk';

  @override
  String get totalCostLabel => 'Total';

  @override
  String get costTotalLabel => 'Cost';

  @override
  String get markupLabel => 'Markup';

  @override
  String get setupFeeLabel => 'Setup fee';

  @override
  String get roundingAdjustmentLabel => 'Rounding adjustment';

  @override
  String get finalPriceLabel => 'Final price';

  @override
  String get jobPricingOverridesLabel => 'Job settings';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# overrides applied',
      one: '# override applied',
    );
    return '$_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => 'Markup %';

  @override
  String get pricingSetupFeeLabel => 'Setup fee';

  @override
  String get pricingRoundingLabel => 'Rounding';

  @override
  String get pricingRoundingNoneLabel => 'None';

  @override
  String get pricingRoundingWholeDollarLabel => 'Whole unit';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Ends in .99';

  @override
  String get currencySymbolLabel => 'Currency symbol';

  @override
  String get currencyPositionLabel => 'Currency position';

  @override
  String get currencyPositionBeforeLabel => 'Before';

  @override
  String get currencyPositionAfterLabel => 'After';

  @override
  String get currencySpacingLabel => 'Space symbol';

  @override
  String get currencyPreviewLabel => 'Preview';

  @override
  String materialCostPerKilogramLabel(Object cost) {
    return '$cost/kg';
  }

  @override
  String historyTimeCompactLabel(Object hours, Object minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String historyWeightCompactLabel(Object weight) {
    return '$weight kg';
  }

  @override
  String historySummaryLabel(
    Object weight,
    Object time,
    Object printer,
    Object material,
  ) {
    return '$weight • $time • $printer • $material';
  }

  @override
  String historyMaterialUsageWeightLabel(Object weight) {
    return '${weight}g';
  }

  @override
  String get workCostsLabel => 'Pricing & Work Costs';

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
      'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total,Markup %,Markup Amount,Setup Fee,Rounding Mode,Subtotal Before Rounding,Rounding Adjustment,Final Price';

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
  String get searchMaterialsHint => 'Search by name or brand';

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

  @override
  String get durationPickerLabel => 'Printing time (hh:mm)';

  @override
  String get importGcodeButton => 'Import G-code (Auto-fill)';

  @override
  String get importGcodePageTitle => 'Import G-code (Beta)';

  @override
  String get importGcodeIntro =>
      'Pick a local .gcode file. Supported slicers: PrusaSlicer, OrcaSlicer, Bambu Studio, and Cura.';

  @override
  String get importGcodeSelectFileButton => 'Choose G-code file';

  @override
  String get importGcodePickAnotherButton => 'Choose another file';

  @override
  String get importGcodeSelectedFileLabel => 'Selected file';

  @override
  String get gcodeImportFeedbackTitle => 'G-code Import Beta Feedback';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Beta feature';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Tell us what helped, what broke, or what still looks wrong.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Which slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Preview result';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Metadata result';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'What worked, what broke, or what looks wrong?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Attach imported G-code file';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'No imported G-code file available to attach.';

  @override
  String get gcodeImportFeedbackSendCta => 'Send feedback';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback sent';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Preview loaded';

  @override
  String get gcodeFeedbackPreviewMissing => 'Preview missing';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Incorrect preview';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Not sure';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Looks correct';

  @override
  String get gcodeFeedbackMetadataMissing => 'Missing data';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Incorrect data';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Not sure';

  @override
  String get importGcodeSummaryTitle => 'Import summary';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Supported slicers: PrusaSlicer, OrcaSlicer, Bambu Studio, and Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Imported values only prefill time and total material weight. Printer, material, and final cost still come from your calculator settings.';

  @override
  String get importGcodeUseValuesButton => 'Use these values';

  @override
  String get importGcodeQuantityLabel => 'Quantity';

  @override
  String get importGcodeCreateBatchButton => 'Create batch';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'Batch creation needs both detected duration and filament weight.';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Estimated duration';

  @override
  String get importGcodeFilamentWeightLabel => 'Filament weight';

  @override
  String get importGcodeFilamentLengthLabel => 'Filament length';

  @override
  String get importGcodeLayerHeightLabel => 'Layer height';

  @override
  String get importGcodePreviewLabel => 'Preview';

  @override
  String get importGcodePreviewAvailable => 'Available';

  @override
  String get importGcodePreviewView => 'View';

  @override
  String get importGcodePreviewUnavailable => 'No preview';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Preview metadata found, but image could not be displayed.';

  @override
  String get importGcodePreviewCuraNote =>
      'Cura previews may require a post-processing script to embed thumbnails in the G-code.';

  @override
  String get importGcodeWarningsTitle => 'Warnings';

  @override
  String get importGcodeUnsupportedTypeError =>
      'This file does not look like a supported G-code file.';

  @override
  String get importGcodeUnsupportedFileError =>
      'This file does not look like a supported G-code file.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'This file is too large to import. Choose a file smaller than $maxSizeMb MB.';
  }

  @override
  String get importGcodeReadError => 'The selected file could not be read.';

  @override
  String get importGcodeUnknownSlicerValue => 'Unknown';

  @override
  String get importGcodeMissingValue => 'Not found';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer not identified. Review values before applying.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Could not detect print time.';

  @override
  String get importGcodeWarningMissingFilament => 'Filament usage incomplete.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Filament weight missing.';

  @override
  String get importGcodeWarningPartialMetadata => 'Some metadata missing.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Multiple material totals found. Review before applying.';

  @override
  String get importGcodeAppliedMessage =>
      'Imported values applied to calculator';

  @override
  String get slicerPrusaSlicer => 'PrusaSlicer';

  @override
  String get slicerOrcaSlicer => 'OrcaSlicer';

  @override
  String get slicerBambuStudio => 'Bambu Studio';

  @override
  String get slicerCura => 'Cura';

  @override
  String get slicerCrealityPrint => 'Creality Print';

  @override
  String get slicerSimplify3D => 'Simplify3D';

  @override
  String get slicerSuperSlicer => 'SuperSlicer';

  @override
  String get slicerIdeaMaker => 'IdeaMaker';

  @override
  String get slicerOther => 'Other';

  @override
  String get slicerUnknown => 'Unknown';

  @override
  String get materialsAppBarTitle => 'Materials';

  @override
  String get materialsNavLabel => 'Materials';

  @override
  String get brandLabel => 'Brand';

  @override
  String get materialTypeLabel => 'Material type';

  @override
  String get colorHexLabel => 'Color hex (optional)';

  @override
  String get notesLabel => 'Notes';

  @override
  String get materialsEmpty => 'No materials yet. Tap + to add one.';

  @override
  String get materialsFilterAll => 'All';

  @override
  String get materialsFilterInStock => 'In stock';

  @override
  String get materialsFilterLowStock => 'Low stock';

  @override
  String get materialsFilterOutOfStock => 'Out of stock';

  @override
  String get csvImportTitle => 'Import materials';

  @override
  String get csvTemplateButton => 'Template';

  @override
  String get csvTemplateShareText => 'Material CSV Template';

  @override
  String get csvTemplateError => 'Could not share the template.';

  @override
  String get csvImportIntro => 'Import materials from a CSV file.';

  @override
  String get csvSelectFileButton => 'Choose CSV file';

  @override
  String get csvImportButton => 'Import valid rows';

  @override
  String get csvReadError => 'Could not read the selected file.';

  @override
  String get csvFileTypeError => 'Please select a .csv file';

  @override
  String get csvNameRequiredError => 'Name is required';

  @override
  String get csvColorRequiredError => 'Color is required';

  @override
  String get csvSpoolWeightRequiredError => 'Spool weight is required';

  @override
  String get csvSpoolWeightPositiveError => 'Spool weight must be > 0';

  @override
  String get csvCostRequiredError => 'Cost is required';

  @override
  String get csvCostPositiveError => 'Cost must be > 0';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count materials',
      one: 'Imported 1 material',
    );
    return '$_temp0';
  }

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total rows: $valid valid, $invalid with errors';
  }

  @override
  String get csvEmptyNamePlaceholder => '(empty)';

  @override
  String get editButton => 'Edit';

  @override
  String get duplicateButton => 'Duplicate';

  @override
  String get duplicateMaterialSuccessMessage => 'Material duplicated';

  @override
  String get duplicateMaterialErrorMessage => 'Error duplicating material';

  @override
  String get materialsSwipeHint =>
      'Swipe a material for edit, duplicate, or delete.';

  @override
  String get stockBadgeOut => 'Out of stock';

  @override
  String get stockBadgeLow => 'Low stock';

  @override
  String get stockBadgeInStock => 'In stock';

  @override
  String get stockBadgeNoTracking => 'No tracking';

  @override
  String get batchCostingReviewAppBarTitle => 'Batch item review';

  @override
  String get batchCostingReviewSubtitle =>
      'Review batch items before printer assignment.';

  @override
  String get batchCostingReviewAddManualItemButton => 'Add manual item';

  @override
  String get batchCostingReviewEmptyTitle => 'No batch items yet';

  @override
  String get batchCostingReviewEmptyBody =>
      'Add imported or manual prints to continue.';

  @override
  String get batchCostingReviewContinueButton =>
      'Continue to printer assignment';

  @override
  String get batchCostingReviewQuantityLabel => 'Quantity';

  @override
  String get batchCostingReviewRemoveButton => 'Remove';

  @override
  String get batchCostingReviewSourceLabel => 'Source';

  @override
  String get batchCostingReviewSourceManual => 'Manual';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => 'Unknown';

  @override
  String get batchCostingReviewWeightLabel => 'Weight';

  @override
  String get batchCostingReviewDurationLabel => 'Duration';

  @override
  String get batchCostingItemEditorAddTitle => 'Add manual item';

  @override
  String get batchCostingItemEditorEditTitle => 'Edit batch item';

  @override
  String get batchCostingItemNameLabel => 'Item / model name';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle => 'Printer assignment';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Printer assignment continues in the next batch costing step.';
}
