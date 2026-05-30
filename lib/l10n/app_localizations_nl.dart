// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get calculatorAppBarTitle => '3D-printcalculator';

  @override
  String get historyAppBarTitle => 'Geschiedenis';

  @override
  String get settingsAppBarTitle => 'Instellingen';

  @override
  String get calculatorNavLabel => 'Rekenmachine';

  @override
  String get historyNavLabel => 'Geschiedenis';

  @override
  String get settingsNavLabel => 'Instellingen';

  @override
  String get newAnnouncementBadgeLabel => 'Nieuw';

  @override
  String get whatsNewSeeRecentUpdates => 'Zie recente updates';

  @override
  String get generalHeader => 'Algemeen';

  @override
  String get wattLabel => 'Watt (3D-printer)';

  @override
  String get printWeightLabel => 'Gewicht van de afdruk';

  @override
  String get hoursLabel => 'Afdruktijd (uren)';

  @override
  String get durationHoursLabel => 'Uren';

  @override
  String get wearAndTearLabel => 'Materialen/Slijtage';

  @override
  String get labourRateLabel => 'Uurtarief';

  @override
  String get labourTimeLabel => 'Verwerkingstijd';

  @override
  String get failureRiskLabel => 'Risico op falen (%)';

  @override
  String get minutesLabel => 'Minuten';

  @override
  String get durationMinutesLabel => 'Minuten';

  @override
  String get printingTimeDialogTitle => 'Afdruktijd';

  @override
  String get workTimeDialogTitle => 'Werktijd';

  @override
  String get spoolWeightLabel => 'Spoel/harsgewicht';

  @override
  String get spoolCostLabel => 'Spoel/hars kosten';

  @override
  String get electricityCostLabel => 'Elektriciteitskosten';

  @override
  String get electricityCostSettingsLabel => 'Elektriciteitskosten';

  @override
  String get submitButton => 'Berekenen';

  @override
  String get resultElectricityPrefix => 'Totale kosten voor elektriciteit:';

  @override
  String get resultFilamentPrefix => 'Totale kosten voor filament:';

  @override
  String get resultTotalPrefix => 'Totale kosten:';

  @override
  String get riskTotalPrefix => 'Risicokosten:';

  @override
  String get premiumHeader => 'Alleen voor Premium-gebruikers:';

  @override
  String get labourCostPrefix => 'Arbeid/Materialen:';

  @override
  String get selectPrinterHint => 'Selecteer printer';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Print opslaan';

  @override
  String get printNameHint => 'Printnaam';

  @override
  String get printerNameLabel => 'Naam *';

  @override
  String get bedSizeLabel => 'Bedgrootte *';

  @override
  String get wattageLabel => 'Vermogen *';

  @override
  String get materialNameLabel => 'Materiaalnaam *';

  @override
  String get colorLabel => 'Kleur *';

  @override
  String get weightLabel => 'Gewicht *';

  @override
  String get costLabel => 'Kosten *';

  @override
  String get saveButton => 'Opslaan';

  @override
  String get deleteDialogTitle => 'Verwijderen';

  @override
  String get deleteDialogContent =>
      'Weet je zeker dat je dit item wilt verwijderen?';

  @override
  String get cancelButton => 'Annuleren';

  @override
  String get resetButtonLabel => 'Resetten';

  @override
  String get resetCalculationTitle => 'Berekening resetten?';

  @override
  String get resetCalculationBody =>
      'Hiermee worden de huidige calculatorwaarden verwijderd en de huidige standaardwaarden opnieuw geladen.';

  @override
  String get deleteButton => 'Verwijderen';

  @override
  String get selectMaterialHint => 'Aangepast (niet opgeslagen)';

  @override
  String get materialNone => 'Geen';

  @override
  String get gramsSuffix => 'g';

  @override
  String get millimetersSuffix => 'mm';

  @override
  String get remainingLabel => 'Resterend:';

  @override
  String get trackRemainingFilamentLabel => 'Resterend filament bijhouden';

  @override
  String get remainingFilamentLabel => 'Resterend filament';

  @override
  String get savePrintErrorMessage => 'Fout bij opslaan van print';

  @override
  String get deleteRecordErrorMessage => 'Fout bij verwijderen van record';

  @override
  String get savePrintSuccessMessage => 'Print opgeslagen';

  @override
  String get deleteMaterialSuccessMessage => 'Materiaal verwijderd';

  @override
  String get historyLoadAction => 'Bewerken in calculator';

  @override
  String get historyLoadSuccessMessage => 'Geladen vanuit geschiedenis';

  @override
  String get historyLoadReplacementWarning =>
      'Sommige items waren niet beschikbaar en zijn vervangen';

  @override
  String get numberExampleHint => 'bijv. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Fout bij laden van materialen: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Fout bij laden van printers: $error';
  }

  @override
  String get retryButton => 'Opnieuw proberen';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Hulp nodig?';

  @override
  String get helpSupportSupportTitle => 'Ondersteuning';

  @override
  String get helpSupportSupportIntro =>
      'Gebruik deze gegevens wanneer je contact opneemt met de ondersteuning.';

  @override
  String get helpSupportWebsiteLabel => 'Website';

  @override
  String get helpSupportEmailLabel => 'E-mail';

  @override
  String get helpSupportSupportIdLabel => 'Ondersteunings-ID';

  @override
  String get helpSupportCopySupportIdTooltip => 'Ondersteunings-ID kopiëren';

  @override
  String get helpSupportRoadmapLabel => 'Roadmap';

  @override
  String get helpSupportRoadmapValue => 'Bekijk wat eraan komt';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'App-versie $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Contact ondersteuning';

  @override
  String get helpSupportContactEmailSubject =>
      '3D-printkostenrekenmachine Ondersteuning';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'Ondersteunings-ID: $supportId\nApp-versie: $version\n\nBeschrijf het probleem hier.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'Ondersteunings-ID: (niet beschikbaar)\nApp-versie: $version\n\nBeschrijf het probleem hier.';
  }

  @override
  String get helpSupportFaqTitle => 'Veelgestelde vragen';

  @override
  String get helpSupportFaqWeightQuestion => 'Welk gewicht moet ik invoeren?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Voer het totale spoelgewicht in, niet het overgebleven filament. De app gebruikt het volledige rolgewicht om de kosten per gram te berekenen.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      'Waarom is elektriciteit belangrijk?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Lange prints en printers met hoog vermogen kunnen echte kosten toevoegen. Elektriciteit overslaan leidt meestal tot te lage prijzen.';

  @override
  String get helpSupportFaqRiskQuestion =>
      'Hoe wordt het risico op mislukking berekend?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'Risico wordt alleen toegepast op basisprintkosten zoals filament en elektriciteit. Het schat het verwachte verlies van mislukte prints in.';

  @override
  String get helpSupportFaqLabourQuestion => 'Wat is arbeid / verwerkingstijd?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Het dekt voorbereiding, opruimen, nabewerking en monitoring. Laat het aan voor diensten waar je tijd belangrijk is.';

  @override
  String get helpSupportFaqMarkupQuestion => 'Wat is opslag?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'Opslag is het percentage dat bovenop de totale kosten wordt toegevoegd om je verkoopprijs te bereiken. Het dekt marge, overhead en winst.';

  @override
  String get helpSupportFaqSetupQuestion => 'Wat is een opstartkosten?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Opstartkosten zijn vaste kosten per opdracht voor kalibratie, machine voorbereiding en administratie. Het helpt kleine prints overhead te dekken.';

  @override
  String get helpSupportLinksTitle => 'Links';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Privacybeleid';

  @override
  String get helpSupportTermsOfUseLabel => 'Gebruiksvoorwaarden';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'Over';

  @override
  String get helpSupportAboutIntro =>
      '3D-printkostenrekenmachine is gebouwd voor local-first prijzen. Het helpt makers en kleine printbedrijven om werk te offeren met minder verrassingen.';

  @override
  String get helpSupportTrustNoAccounts => 'Geen accounts';

  @override
  String get helpSupportTrustNoCloudSync => 'Geen cloud-synchronisatie';

  @override
  String get helpSupportTrustNoTracking => 'Geen tracking';

  @override
  String get helpSupportTrustLocalData => 'Lokale gegevens';

  @override
  String get helpSupportAboutCalculator =>
      'De rekenmachine combineert filamentkosten, elektriciteit, risico op mislukking, arbeid en optionele prijstools zoals opslag en opstartkosten.';

  @override
  String get helpSupportAboutOutcome =>
      'Dat houdt offertes gebonden aan echte kosten, niet alleen materiaaluitgaven.';

  @override
  String get supportEmailPrefix => 'Bij problemen kun je mij mailen op ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Voeg je support-ID toe: ';

  @override
  String get supportEmailSubject =>
      'Ondersteuning voor 3D Print Cost Calculator';

  @override
  String get clickToCopy => '(klik om te kopiëren)';

  @override
  String get materialWeightExplanation =>
      'Materiaalgewicht is het totale gewicht van het bronmateriaal, dus de volledige rol filament. De kosten zijn de kosten van de volledige eenheid.';

  @override
  String get supportIdCopied => 'Support-ID gekopieerd';

  @override
  String get exportSuccess => 'Export geslaagd';

  @override
  String get exportError => 'Export mislukt';

  @override
  String get exportButton => 'Exporteren';

  @override
  String get privacyPolicyLink => 'Privacybeleid';

  @override
  String get websiteLink => 'Webpagina';

  @override
  String get termsOfUseLink => 'Gebruiksvoorwaarden';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Sluiten';

  @override
  String get cancelFeedbackPromptTitle =>
      'Het lijkt erop dat je verlenging hebt uitgezet. Wil je zeggen waarom?';

  @override
  String get feedbackSubmitButton => 'Feedback versturen';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Te duur';

  @override
  String get cancelFeedbackReasonMissingFeatures => 'Functies ontbreken';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'Niet genoeg waarde';

  @override
  String get cancelFeedbackReasonConfusingToUse => 'Verwarrend in gebruik';

  @override
  String get cancelFeedbackReasonJustTesting =>
      'Ik was de app alleen aan het testen';

  @override
  String get cancelFeedbackReasonOther => 'Anders';

  @override
  String get testDataToolsTitle => 'Testdatatools';

  @override
  String get testDataToolsBody =>
      'Deze acties zijn alleen voor lokale tests. Seeden vervangt de huidige lokale setup door demogegevens. Wissen verwijdert permanent alle lokale appgegevens op dit apparaat.';

  @override
  String get seedTestDataButton => 'Testgegevens seeden';

  @override
  String get purgeLocalDataButton => 'Lokale gegevens wissen';

  @override
  String get enablePremiumButton => 'Premium inschakelen';

  @override
  String get forceUpdateAvailableButton => 'Update beschikbaar forceren';

  @override
  String get forceNoUpdateButton => 'Geen update forceren';

  @override
  String get clearUpdateCooldownButton => 'Update-afkoeling wissen';

  @override
  String get previewCancelFeedbackButton => 'Voorvertoning annuleringsfeedback';

  @override
  String get enableBatchCostingButton => 'Batchkostenberekening inschakelen';

  @override
  String get batchCostingSummarySaveButton => 'Offerte opslaan';

  @override
  String get batchCostingSummarySaveSuccessTitle => 'Offerte opgeslagen';

  @override
  String get batchCostingSummarySaveSuccessBody =>
      'Opgeslagen in geschiedenis.';

  @override
  String get batchCostingSummaryViewHistoryButton => 'Geschiedenis bekijken';

  @override
  String get batchCostingSummarySaveErrorMessage => 'Kon offerte niet opslaan';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'Batch-offerte';

  @override
  String get batchCostingSummaryQuoteNameDialogTitle =>
      'Geef uw offerte een naam';

  @override
  String get batchCostingSummaryQuoteNameHint => 'Offertenaam';

  @override
  String get batchHistoryItemsTitle => 'Batchitems';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalQuantity,
      locale: localeName,
      other: 'kopieën',
      one: 'kopie',
    );
    return '$itemCount $_temp0 • $totalQuantity $_temp1';
  }

  @override
  String batchHistoryItemRow(Object name, Object quantity) {
    return '$name × $quantity';
  }

  @override
  String get showWhatsNewButton => 'Show What\'s New';

  @override
  String get enablePremiumTitle => 'Premium inschakelen';

  @override
  String get enablePremiumBody =>
      'Voer de bevestigingscode in om lokale premiumtests in te schakelen';

  @override
  String get invalidConfirmationCodeMessage => 'Ongeldige bevestigingscode';

  @override
  String get seedTestDataConfirmTitle => 'Testgegevens seeden?';

  @override
  String get seedTestDataConfirmBody =>
      'Dit vervangt de huidige lokale setup door deterministische demogegevens.';

  @override
  String get purgeLocalDataConfirmTitle => 'Lokale gegevens wissen?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Dit verwijdert permanent alle lokale appgegevens op dit apparaat.';

  @override
  String get testDataSeededMessage => 'Testgegevens geseed';

  @override
  String get testDataPurgedMessage => 'Lokale gegevens gewist';

  @override
  String get testDataActionFailedMessage => 'Actie voor testgegevens mislukt';

  @override
  String get updatePromptTitle => 'Update beschikbaar';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'Versie $storeVersion is beschikbaar. U hebt $currentVersion geïnstalleerd.';
  }

  @override
  String get updatePromptBodyUnknown =>
      'Er is een nieuwere versie beschikbaar.';

  @override
  String get updatePromptOpenStoreButton => 'Store openen';

  @override
  String get mailClientError => 'Kon e-mailclient niet openen';

  @override
  String get offeringsError => 'Fout: ';

  @override
  String get currentOfferings => 'Huidige aanbiedingen';

  @override
  String get purchaseError =>
      'Er is een fout opgetreden bij het verwerken van je aankoop. Probeer het later opnieuw.';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get printersHeader => '3D-printers';

  @override
  String get materialsHeader => 'Materialen';

  @override
  String get filamentCostLabel => 'Filamentkosten';

  @override
  String get labourCostLabel => 'Arbeidskosten';

  @override
  String get additionalCostLabel => 'Extra kosten';

  @override
  String get additionalCostNoteLabel => 'Opmerking extra kosten';

  @override
  String get additionalCostNoteDialogTitle => 'Opmerking extra kosten';

  @override
  String get riskCostLabel => 'Risico';

  @override
  String get totalCostLabel => 'Totaal';

  @override
  String get costTotalLabel => 'Kosten';

  @override
  String get markupLabel => 'Opslag';

  @override
  String get setupFeeLabel => 'Instelkosten';

  @override
  String get roundingAdjustmentLabel => 'Afrondingscorrectie';

  @override
  String get finalPriceLabel => 'Eindprijs';

  @override
  String get jobPricingOverridesLabel => 'Taakinstellingen';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'overschrijvingen toegepast',
      one: 'overschrijving toegepast',
    );
    return '$count $_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => 'Opslag %';

  @override
  String get pricingSetupFeeLabel => 'Instelkosten';

  @override
  String get pricingRoundingLabel => 'Afronding';

  @override
  String get pricingRoundingNoneLabel => 'Geen';

  @override
  String get pricingRoundingWholeDollarLabel => 'Hele eenheid';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Eindigt op .99';

  @override
  String get currencySymbolLabel => 'Valutasymbool';

  @override
  String get currencyPositionLabel => 'Positie van het symbool';

  @override
  String get currencyPositionBeforeLabel => 'Voor';

  @override
  String get currencyPositionAfterLabel => 'Na';

  @override
  String get currencySpacingLabel => 'Spatie met symbool';

  @override
  String get currencyPreviewLabel => 'Voorbeeld';

  @override
  String materialCostPerKilogramLabel(Object cost) {
    return '$cost/kg';
  }

  @override
  String historyTimeCompactLabel(Object hours, Object minutes) {
    return '$hours u $minutes min';
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
  String get workCostsLabel => 'Arbeidskosten';

  @override
  String get enterNumber => 'Voer een getal in';

  @override
  String get invalidNumber => 'Ongeldig getal';

  @override
  String get validationRequired => 'Verplicht';

  @override
  String get validationEnterValidNumber => 'Voer een geldig getal in';

  @override
  String get validationMustBeGreaterThanZero => 'Moet groter zijn dan 0';

  @override
  String get validationMustBeZeroOrMore => 'Moet 0 of hoger zijn';

  @override
  String get lockedValuePlaceholder => 'Alleen Premium';

  @override
  String get hideProPromotionsTitle => 'Pro-promoties verbergen';

  @override
  String get hideProPromotionsSubtitle =>
      'Upgrade-banners en prompts verbergen';

  @override
  String get printerLimitReachedMessage =>
      'Je kunt op Free maximaal 2 printers opslaan. Upgrade naar Premium voor onbeperkte printers.';

  @override
  String get materialLimitReachedMessage =>
      'Je kunt op Free maximaal 5 materialen opslaan. Upgrade naar Premium voor onbeperkte materialen.';

  @override
  String get batchItemLimitReachedMessage =>
      'Je kunt op Free maximaal 3 batchitems toevoegen. Upgrade naar Premium voor onbeperkte batchitems.';

  @override
  String get historySearchHint => 'Zoeken op naam of printer';

  @override
  String get historyExportMenuTitle => 'Prints exporteren';

  @override
  String get historyExportRangeAll => 'Alles';

  @override
  String get historyExportRangeLast7Days => 'Laatste 7 dagen';

  @override
  String get historyExportRangeLast30Days => 'Laatste 30 dagen';

  @override
  String get historyEmptyTitle => 'Nog geen opgeslagen prints';

  @override
  String get historyEmptyDescription =>
      'Gebruik eerdere prints opnieuw in de calculator';

  @override
  String get historyUpsellTitle => 'Hergebruik eerdere prints meteen';

  @override
  String get historyUpsellDescription =>
      'Je kunt op Free maximaal 7 opgeslagen prints bewaren. Upgrade naar Premium voor onbeperkte geschiedenis en exports.';

  @override
  String get historyNoMoreRecords => 'Geen verdere records';

  @override
  String get historyOverflowHint => 'Meer acties in ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Geschiedenis laden mislukt: $error';
  }

  @override
  String get historyCsvHeader =>
      'Datum,Printer,Materiaal,Materialen,Gewicht (g),Tijd,Elektriciteit,Filament,Arbeid,Risico,Totaal,Opslag %,Opslagbedrag,Instelkosten,Afrondingsmodus,Tussenbedrag voor afronding,Afrondingscorrectie,Eindprijs';

  @override
  String get historyExportShareText => 'Export van 3D-printkostenoverzicht';

  @override
  String get batchQuoteExportShareText => 'Export van 3D-printbatchofferte';

  @override
  String get mixedHistoryExportShareText =>
      'Export van 3D-printkostenoverzicht';

  @override
  String get historyTeaserTitle => 'Bewaar elke printschatting op één plek';

  @override
  String get historyTeaserDescription =>
      'Free-gebruikers kunnen maximaal 7 opgeslagen prints bewaren. Upgrade naar Premium voor onbeperkte geschiedenis en exports.';

  @override
  String get historyTeaserCta =>
      'Upgrade naar Premium voor onbeperkte geschiedenis';

  @override
  String get historyExportPreviewEntry => 'Voorbeeld van CSV-export';

  @override
  String get historyExportPreviewTitle => 'CSV-voorbeeld';

  @override
  String get historyExportPreviewDescription =>
      'Bulk-export van geschiedenis is een Premium-functie. Downloaden en delen worden ontgrendeld met Premium.';

  @override
  String get historyExportPreviewSampleLabel => '[Voorbeeld]';

  @override
  String get historyExportPreviewAction => 'Downloaden / Delen met Premium';

  @override
  String get addMaterialButton => 'Materiaal toevoegen';

  @override
  String get useSingleTotalWeightAction => 'Gebruik enkel totaalgewicht';

  @override
  String get addAtLeastOneMaterial => 'Voeg minimaal één materiaal toe.';

  @override
  String get searchMaterialsHint => 'Zoek naam of merk';

  @override
  String get materialBreakdownLabel => 'Materiaaluitsplitsing';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'materialen',
      one: 'materiaal',
    );
    return '$count $_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Totaal materiaalgewicht: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Versie $version';
  }

  @override
  String get materialFallback => 'Materiaal';

  @override
  String get durationPickerLabel => 'Afdruktijd (uu:mm)';

  @override
  String get importGcodeButton => 'G-code importeren (Auto-invullen)';

  @override
  String get importGcodePageTitle => 'G-code importeren (Beta)';

  @override
  String get importGcodeIntro =>
      'Kies een lokaal .gcode-bestand. Ondersteunde slicers: PrusaSlicer, OrcaSlicer, Bambu Studio en Cura.';

  @override
  String get importGcodeSelectFileButton => 'G-code bestand kiezen';

  @override
  String get importGcodePickAnotherButton => 'Ander bestand kiezen';

  @override
  String get importGcodeSelectedFileLabel => 'Geselecteerd bestand';

  @override
  String get gcodeImportFeedbackTitle => 'G-code Import Beta Feedback';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Beta-functie';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Vertel ons wat geholpen heeft, wat is gebroken of wat er nog verkeerd uitziet.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Welke slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Voorbeeldresultaat';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Metadataresultaat';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'Wat werkte, wat brak af, of wat ziet er verkeerd uit?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Geïmporteerd G-code-bestand bijvoegen';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'Geen geïmporteerd G-code bestand beschikbaar.';

  @override
  String get gcodeImportFeedbackSendCta => 'Feedback verzenden';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback verzonden';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Voorbeeld geladen';

  @override
  String get gcodeFeedbackPreviewMissing => 'Voorbeeld ontbreekt';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Voorbeeld onjuist';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Niet zeker';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Lijkt correct';

  @override
  String get gcodeFeedbackMetadataMissing => 'Gegevens ontbreken';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Gegevens onjuist';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Niet zeker';

  @override
  String get importGcodeSummaryTitle => 'Importoverzicht';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Ondersteunde slicers: PrusaSlicer, OrcaSlicer, Bambu Studio en Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Geïmporteerde waarden vullen alleen tijd en totaal materiaalgewicht in. Printer, materiaal en uiteindelijke kosten komen uit je rekenmachine-instellingen.';

  @override
  String get importGcodeUseValuesButton => 'Deze waarden gebruiken';

  @override
  String get importGcodeQuantityLabel => 'Aantal';

  @override
  String get importGcodeCreateBatchButton => 'Batch maken';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'Voor batchaanmaak zijn zowel gedetecteerde duur als filamentgewicht nodig.';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Geschatte duur';

  @override
  String get importGcodeFilamentWeightLabel => 'Filamentgewicht';

  @override
  String get importGcodeFilamentLengthLabel => 'Filamentlengte';

  @override
  String get importGcodeLayerHeightLabel => 'Laaghoogte';

  @override
  String get importGcodePreviewLabel => 'Voorbeeld';

  @override
  String get importGcodePreviewAvailable => 'Beschikbaar';

  @override
  String get importGcodePreviewView => 'Bekijken';

  @override
  String get importGcodePreviewUnavailable => 'Geen voorbeeld';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Voorbeeld metadata gevonden maar afbeelding kon niet worden weergegeven.';

  @override
  String get importGcodePreviewCuraNote =>
      'Cura-voorbeelden hebben mogelijk een post-processing script nodig om thumbnails in te sluiten.';

  @override
  String get importGcodeWarningsTitle => 'Waarschuwingen';

  @override
  String get importGcodeUnsupportedTypeError =>
      'Dit bestand lijkt geen ondersteund G-code-bestand te zijn.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Dit bestand lijkt geen ondersteund G-code-bestand te zijn.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'Dit bestand is te groot om te importeren. Kies een bestand kleiner dan $maxSizeMb MB.';
  }

  @override
  String get importGcodeReadError =>
      'Het geselecteerde bestand kon niet worden gelezen.';

  @override
  String get importGcodeUnknownSlicerValue => 'Onbekend';

  @override
  String get importGcodeMissingValue => 'Niet gevonden';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer niet geïdentificeerd. Controleer waarden voor toepassen.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Printtijd kon niet worden gedetecteerd.';

  @override
  String get importGcodeWarningMissingFilament => 'Filamentgebruik onvolledig.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Filamentgewicht ontbreekt.';

  @override
  String get importGcodeWarningPartialMetadata => 'Sommige metadata ontbreken.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Meerdere materiaal totalen gevonden. Controleren voor toepassen.';

  @override
  String get importGcodeAppliedMessage =>
      'Geïmporteerde waarden toegepast op rekenmachine';

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
  String get slicerOther => 'Overig';

  @override
  String get slicerUnknown => 'Onbekend';

  @override
  String get materialsAppBarTitle => 'Materialen';

  @override
  String get materialsNavLabel => 'Materialen';

  @override
  String get brandLabel => 'Merk';

  @override
  String get materialTypeLabel => 'Materiaaltype';

  @override
  String get colorHexLabel => 'Kleur hex (optioneel)';

  @override
  String get notesLabel => 'Notities';

  @override
  String get materialsEmpty =>
      'Nog geen materialen. Tik op + om er een toe te voegen.';

  @override
  String get materialsFilterAll => 'Alles';

  @override
  String get materialsFilterInStock => 'Op voorraad';

  @override
  String get materialsFilterLowStock => 'Lage voorraad';

  @override
  String get materialsFilterOutOfStock => 'Uitverkocht';

  @override
  String get csvImportTitle => 'Materialen importeren';

  @override
  String get csvTemplateButton => 'Sjabloon';

  @override
  String get csvTemplateShareText => 'Materialen CSV-sjabloon';

  @override
  String get csvTemplateError => 'Kon het sjabloon niet delen.';

  @override
  String get csvImportIntro => 'Importeer materialen uit een CSV-bestand.';

  @override
  String get csvSelectFileButton => 'Kies CSV-bestand';

  @override
  String get csvImportButton => 'Geldige rijen importeren';

  @override
  String get csvReadError =>
      'Het geselecteerde bestand kon niet worden gelezen.';

  @override
  String get csvFileTypeError => 'Kies een .csv-bestand';

  @override
  String get csvNameRequiredError => 'Naam is verplicht';

  @override
  String get csvColorRequiredError => 'Kleur is verplicht';

  @override
  String get csvSpoolWeightRequiredError => 'Spoelgewicht is verplicht';

  @override
  String get csvSpoolWeightPositiveError => 'Spoelgewicht moet > 0 zijn';

  @override
  String get csvCostRequiredError => 'Kosten zijn verplicht';

  @override
  String get csvCostPositiveError => 'Kosten moeten > 0 zijn';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materialen geïmporteerd',
      one: '1 materiaal geïmporteerd',
    );
    return '$_temp0';
  }

  @override
  String get csvNoValidRowsError => 'Geen geldige rijen om te importeren.';

  @override
  String get csvImportQuotaExceededError =>
      'Deze import overschrijdt je materiaallimiet.';

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total rijen: $valid geldig, $invalid met fouten';
  }

  @override
  String get csvEmptyNamePlaceholder => '(leeg)';

  @override
  String get editButton => 'Bewerken';

  @override
  String get duplicateButton => 'Dupliceren';

  @override
  String get duplicateMaterialSuccessMessage => 'Materiaal gedupliceerd';

  @override
  String get duplicateMaterialErrorMessage =>
      'Fout bij dupliceren van materiaal';

  @override
  String get materialsSwipeHint =>
      'Veeg een materiaal om te bewerken, dupliceren of verwijderen.';

  @override
  String get stockBadgeOut => 'Uitverkocht';

  @override
  String get stockBadgeLow => 'Lage voorraad';

  @override
  String get stockBadgeInStock => 'Op voorraad';

  @override
  String get stockBadgeNoTracking => 'Niet bijgehouden';

  @override
  String get batchCostingReviewAppBarTitle => 'Batch-artikelbeoordeling';

  @override
  String get batchCostingReviewSubtitle =>
      'Beoordeel batch-artikelen vóór printertoewijzing.';

  @override
  String get batchCostingReviewAddManualItemButton =>
      'Handmatig item toevoegen';

  @override
  String get batchCostingReviewEmptyTitle => 'Nog geen batch-artikelen';

  @override
  String get batchCostingReviewEmptyBody =>
      'Voeg handmatige prints toe om verder te gaan.';

  @override
  String get batchCostingReviewImportGcodeButton =>
      'G-codebestanden importeren';

  @override
  String get batchCostingReviewImportGcodeButtonPremium =>
      'G-codebestanden importeren (Premium)';

  @override
  String get batchGcodeImportTitle => 'Batch G-code importeren';

  @override
  String get batchGcodeImportBody =>
      'Kies een of meer G-codebestanden. Elk bestand wordt apart geparseerd.';

  @override
  String get batchGcodeImportPickButton => 'Bestanden kiezen';

  @override
  String get batchGcodeImportSuccessLabel => 'Succesvol geïmporteerd';

  @override
  String get batchGcodeImportFailureLabel => 'Import mislukt';

  @override
  String get batchGcodeImportParseFailure =>
      'Dit bestand kon niet worden geïmporteerd.';

  @override
  String get batchGcodeImportContinueButton => 'Verder naar batchcontrole';

  @override
  String get batchGcodeImportRetryButton => 'Opnieuw kiezen';

  @override
  String get batchGcodeImportImportingLabel => 'Importeren…';

  @override
  String get batchGcodeImportPendingLabel => 'In afwachting';

  @override
  String get batchGcodeImportNeedsDetailsLabel => 'Details nodig';

  @override
  String get batchGcodeImportReadyLabel => 'Gereed';

  @override
  String get batchGcodeImportNeedsWeight => 'Gewicht vereist';

  @override
  String get batchGcodeImportNeedsDuration => 'Duur vereist';

  @override
  String get batchGcodeImportApply => 'Toepassen';

  @override
  String get batchGcodeImportAddButton => 'Toevoegen aan batchcontrole';

  @override
  String get batchGcodeImportDetailsButton => 'Details';

  @override
  String get batchGcodeImportDuplicateMessage =>
      'Sommige bestanden zijn al toegevoegd.';

  @override
  String get batchGcodeImportQuantityHint =>
      'Hoeveelheden kunnen in de volgende stap worden aangepast.';

  @override
  String get batchCostingReviewContinueButton =>
      'Doorgaan naar printertoewijzing';

  @override
  String get batchCostingReviewQuantityLabel => 'Aantal';

  @override
  String get batchCostingReviewRemoveButton => 'Verwijderen';

  @override
  String get batchCostingReviewSourceLabel => 'Bron';

  @override
  String get batchCostingReviewSourceManual => 'Handmatig';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => 'Onbekend';

  @override
  String get batchCostingReviewWeightLabel => 'Gewicht';

  @override
  String get batchCostingReviewDurationLabel => 'Duur';

  @override
  String get batchCostingReviewWeightRequired => 'Gewicht vereist';

  @override
  String get batchCostingReviewDurationRequired => 'Duur vereist';

  @override
  String get batchCostingReviewMissingFieldsError => 'Vul verplichte velden in';

  @override
  String get batchCostingItemEditorAddTitle => 'Handmatig item toevoegen';

  @override
  String get batchCostingItemEditorEditTitle => 'Batch-item bewerken';

  @override
  String get batchCostingItemNameLabel => 'Item-/modelnaam';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle => 'Printertoewijzing';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Wijs printers toe vóór materiaal.';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'Hele batch';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => 'Per item';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'Kies één printer voor alle items.';

  @override
  String get batchCostingPrinterAssignmentPerItemHint =>
      'Kies een printer voor dit item.';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'Kopieën splitsen';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return 'Kopieën splitsen voor $itemName';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return 'Totaal moet gelijk zijn aan $total';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      'Toewijzingen zijn gereset omdat de hoeveelheid is gewijzigd.';

  @override
  String get batchCostingAssignmentCopiesLabel => 'Kopieën';

  @override
  String get batchCostingAllocationPickerSearchLabel => 'Zoek opties';

  @override
  String get batchCostingAllocationPickerAvailableLabel => 'Beschikbaar';

  @override
  String get batchCostingAllocationPickerSelectedLabel => 'Geselecteerd';

  @override
  String get batchCostingAllocationPickerAddButton => 'Toevoegen';

  @override
  String get batchCostingAllocationPickerNoResultsLabel => 'Geen resultaten.';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      'Kies een printer om door te gaan.';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => 'Vorige';

  @override
  String get batchCostingPrinterAssignmentNextButton => 'Volgende';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'Er zijn nog geen printers beschikbaar.';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle => 'Materiaaltoewijzing';

  @override
  String get batchCostingMaterialAssignmentSubtitle =>
      'Wijs materialen of spoelen toe vóór de prijs.';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel =>
      'Materiaal of spoel';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'Hele batch';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'Per item';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'Kies één materiaal voor alle items.';

  @override
  String get batchCostingMaterialAssignmentPerItemHint =>
      'Kies een materiaal voor dit item.';

  @override
  String get batchCostingMaterialAssignmentRequiredError =>
      'Kies een materiaal om door te gaan.';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => 'Vorige';

  @override
  String get batchCostingMaterialAssignmentNextButton => 'Volgende';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      'Voeg minstens één materiaal of spoel toe om door te gaan.';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return 'Benodigd $required overschrijdt de geselecteerde voorraad $available.';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => 'Prijsbereik';

  @override
  String get batchCostingPricingScopeSubtitle =>
      'Stel in waar elke prijswaarde geldt.';

  @override
  String get batchCostingPricingScopeItemMode => 'Item';

  @override
  String get batchCostingPricingScopeBatchMode => 'Batch';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => 'Item (per kopie)';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'Batch (eenmalig)';

  @override
  String get batchCostingPricingScopeScopeLabel => 'Bereik';

  @override
  String get batchCostingSummaryAppBarTitle => 'Batchoverzicht';

  @override
  String get batchCostingSummarySubtitle =>
      'Controleer de batch voordat u een offerte genereert.';

  @override
  String get batchCostingSummaryOverviewTitle => 'Overzicht';

  @override
  String get batchCostingSummaryItemCountLabel => 'Items';

  @override
  String get batchCostingSummaryTotalQuantityLabel => 'Totale hoeveelheid';

  @override
  String get batchCostingSummaryTotalWeightLabel => 'Totaal gewicht';

  @override
  String get batchCostingSummaryTotalDurationLabel => 'Totale printtijd';

  @override
  String get batchCostingSummaryItemWeightLabel => 'Gewicht';

  @override
  String get batchCostingSummaryItemDurationLabel => 'Printtijd';

  @override
  String get batchCostingSummaryItemBaseCostLabel => 'Basiskosten';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => 'Aanpassingen';

  @override
  String get batchCostingSummaryItemTotalLabel => 'Totaal item';

  @override
  String get batchCostingSummaryFinalTotalLabel => 'Eindtotaal';

  @override
  String get batchCostingSummaryBackButton => 'Terug naar prijsbereik';

  @override
  String get batchCostingSummaryReturnToCalculatorButton =>
      'Terug naar calculator';

  @override
  String get batchCostingSummaryStartNewBatchButton => 'Nieuwe batch starten';

  @override
  String get batchCostingSummaryEmptyTitle => 'Nog geen batchoverzicht';

  @override
  String get batchCostingSummaryEmptyBody =>
      'Voeg items toe en stel het prijsbereik in voordat u het overzicht bekijkt.';

  @override
  String get batchCostingSummaryPricingTitle => 'Prijzen';

  @override
  String get batchCostingSummaryItemsTitle => 'Items';

  @override
  String get batchCostingNewBatchDialogTitle => 'Nieuwe batch starten';

  @override
  String get batchCostingNewBatchDialogBody =>
      'Dit zal alle huidige batchvoortgang wissen. Een nieuwe batch starten?';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnit elk → $lineTotal totaal';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'Printer';

  @override
  String get batchCostingEntryButton => 'Batchofferte starten';
}
