// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'nl';

  static String m0(count) =>
      "${Intl.plural(count, one: '# materiaal', other: '# materialen')}";

  static String m1(grams) => "Totaal materiaalgewicht: ${grams}g";

  static String m2(version) => "Versie ${version}";

  static String m3(error) => "Fout bij laden van materialen: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Voeg minimaal één materiaal toe.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage(
      "Materiaal toevoegen",
    ),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Bedgrootte *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "3D-printcalculator",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Rekenmachine"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage(
      "(klik om te kopiëren)",
    ),
    "closeButton": MessageLookupByLibrary.simpleMessage("Sluiten"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Kleur *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Kosten *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage(
      "Huidige aanbiedingen",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "Weet je zeker dat je dit item wilt verwijderen?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage(
      "Elektriciteitskosten",
    ),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Elektriciteitskosten",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage("Voer een getal in"),
    "exportButton": MessageLookupByLibrary.simpleMessage("Exporteren"),
    "exportError": MessageLookupByLibrary.simpleMessage("Export mislukt"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export geslaagd"),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Risico op falen (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("Filamentkosten"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Geschiedenis"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("Geschiedenis"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Zoeken op naam of printer",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage("Afdruktijd (uren)"),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Ongeldig getal"),
    "kwh": MessageLookupByLibrary.simpleMessage("kW/uur"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("Arbeidskosten"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage(
      "Arbeid/Materialen:",
    ),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("Uurtarief"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage("Verwerkingstijd"),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "Kon e-mailclient niet openen",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Materiaaluitsplitsing",
    ),
    "materialFallback": MessageLookupByLibrary.simpleMessage("Materiaal"),
    "materialsLoadError": m3,
    "materialNameLabel": MessageLookupByLibrary.simpleMessage(
      "Materiaalnaam *",
    ),
    "materialNone": MessageLookupByLibrary.simpleMessage("Geen"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "Materiaalgewicht is het totale gewicht van het bronmateriaal, dus de volledige rol filament. De kosten zijn de kosten van de volledige eenheid.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Materialen"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Notulen"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage("Hulp nodig?"),
    "numberExampleHint": MessageLookupByLibrary.simpleMessage("bijv. 123"),
    "offeringsError": MessageLookupByLibrary.simpleMessage("Fout: "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Alleen voor Premium-gebruikers:",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage("Printnaam"),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Gewicht van de afdruk",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Naam *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("3D-printers"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage("Privacybeleid"),
    "remainingFilamentLabel": MessageLookupByLibrary.simpleMessage(
      "Resterend filament",
    ),
    "remainingLabel": MessageLookupByLibrary.simpleMessage("Resterend:"),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "Er is een fout opgetreden bij het verwerken van je aankoop. Probeer het later opnieuw.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Aankopen herstellen",
    ),
    "retryButton": MessageLookupByLibrary.simpleMessage("Opnieuw proberen"),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage(
      "Totale kosten voor elektriciteit:",
    ),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "Totale kosten voor filament:",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("Totale kosten:"),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("Risico"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage("Risicokosten:"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Opslaan"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage("Print opslaan"),
    "savePrintErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Fout bij opslaan van print",
    ),
    "savePrintSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Print opgeslagen",
    ),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Materialen zoeken",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Aangepast (niet opgeslagen)",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Selecteer printer",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage("Instellingen"),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Instellingen"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage("Spoel/hars kosten"),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Spoel/harsgewicht",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Berekenen"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "Bij problemen kun je mij mailen op ",
    ),
    "trackRemainingFilamentLabel": MessageLookupByLibrary.simpleMessage(
      "Resterend filament bijhouden",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "Support-ID gekopieerd",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Voeg je support-ID toe: ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage(
      "Gebruiksvoorwaarden",
    ),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Totaal"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Gebruik enkel totaalgewicht",
    ),
    "versionLabel": m2,
    "watt": MessageLookupByLibrary.simpleMessage("Watt"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Watt (3D-printer)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Vermogen *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Materialen/Slijtage",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Gewicht *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage("Arbeidskosten"),
  };
}
