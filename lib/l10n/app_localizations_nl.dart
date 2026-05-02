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
  String get generalHeader => 'Algemeen';

  @override
  String get wattLabel => 'Watt (3D-printer)';

  @override
  String get printWeightLabel => 'Gewicht van de afdruk';

  @override
  String get hoursLabel => 'Afdruktijd (uren)';

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
  String get deleteButton => 'Verwijderen';

  @override
  String get selectMaterialHint => 'Aangepast (niet opgeslagen)';

  @override
  String get materialNone => 'Geen';

  @override
  String get gramsSuffix => 'g';

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
      'Long prints and high wattage printers can add real cost. Skipping electricity usually underprices the job.';

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
  String get supportEmailPrefix => 'Bij problemen kun je mij mailen op ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Voeg je support-ID toe: ';

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
  String get termsOfUseLink => 'Gebruiksvoorwaarden';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Sluiten';

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
  String get riskCostLabel => 'Risico';

  @override
  String get totalCostLabel => 'Totaal';

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
  String get lockedValuePlaceholder => 'Vergrendeld';

  @override
  String get hideProPromotionsTitle => 'Pro-promoties verbergen';

  @override
  String get hideProPromotionsSubtitle =>
      'Upgrade-banners en prompts verbergen';

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
      'Ontgrendel geavanceerde bewerkingen en exports';

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
      'Datum,Printer,Materiaal,Materialen,Gewicht (g),Tijd,Elektriciteit,Filament,Arbeid,Risico,Totaal';

  @override
  String get historyExportShareText => 'Export van 3D-printkostenoverzicht';

  @override
  String get historyTeaserTitle => 'Bewaar elke printschatting op één plek';

  @override
  String get historyTeaserDescription =>
      'Bekijk hoe geschiedenis werkt voordat je upgradet. Bewaar voltooide schattingen en exporteer ze altijd met Pro.';

  @override
  String get historyTeaserCta => 'Bewaar en exporteer geschiedenis met Pro';

  @override
  String get historyExportPreviewEntry => 'Voorbeeld van CSV-export';

  @override
  String get historyExportPreviewTitle => 'CSV-voorbeeld';

  @override
  String get historyExportPreviewDescription =>
      'Bekijk hoe je export eruitziet. Downloaden en delen zijn ontgrendeld met Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Voorbeeld]';

  @override
  String get historyExportPreviewAction => 'Downloaden / delen met Pro';

  @override
  String get addMaterialButton => 'Materiaal toevoegen';

  @override
  String get useSingleTotalWeightAction => 'Gebruik enkel totaalgewicht';

  @override
  String get addAtLeastOneMaterial => 'Voeg minimaal één materiaal toe.';

  @override
  String get searchMaterialsHint => 'Materialen zoeken';

  @override
  String get materialBreakdownLabel => 'Materiaaluitsplitsing';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# materialen',
      one: '# materiaal',
    );
    return '$_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Totaal materiaalgewicht: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get materialFallback => 'Materiaal';

  @override
  String get durationPickerLabel => 'Printing time (hh:mm)';

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
  String get importGcodePreviewUnavailable => 'Niet beschikbaar';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Voorbeeld metadata gevonden maar afbeelding kon niet worden weergegeven.';

  @override
  String get importGcodePreviewCuraNote =>
      'Cura-voorbeelden hebben mogelijk een post-processing script nodig om thumbnails in te sluiten.';

  @override
  String get importGcodeWarningsTitle => 'Waarschuwingen';

  @override
  String get importGcodeUnsupportedTypeError => 'Kies een .gcode-bestand.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Dit bestand bevatte geen ondersteunde G-code metadata.';

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
  String get slicerOther => 'Other';

  @override
  String get slicerUnknown => 'Onbekend';
}
