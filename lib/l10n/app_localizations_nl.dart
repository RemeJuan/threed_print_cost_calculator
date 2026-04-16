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
  String get supportEmailPrefix => 'Bij problemen kun je mij mailen op ';

  @override
  String get supportEmail => 'google@remej.dev';

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
    return 'Versie $version';
  }

  @override
  String get materialFallback => 'Materiaal';
}
