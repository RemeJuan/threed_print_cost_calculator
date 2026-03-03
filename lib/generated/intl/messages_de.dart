// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(count) =>
      "${Intl.plural(count, one: '# Material', other: '# Materialien')}";

  static String m1(grams) => "Gesamtes Materialgewicht: ${grams}g";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Mindestens ein Material hinzufügen.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage(
      "Material hinzufügen",
    ),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Druckbettgröße *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "3D-Druck-Rechner",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Rechner"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage(
      "(zum Kopieren klicken)",
    ),
    "closeButton": MessageLookupByLibrary.simpleMessage("Schließen"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Farbe *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Kosten *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage(
      "Aktuelle Angebote",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "Möchten Sie dieses Element wirklich löschen?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Löschen"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage("Stromkosten"),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Stromkosten",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie eine Zahl ein",
    ),
    "exportButton": MessageLookupByLibrary.simpleMessage("Exportieren"),
    "exportError": MessageLookupByLibrary.simpleMessage(
      "Export fehlgeschlagen",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export erfolgreich"),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Ausfallrisiko (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("Filamentkosten"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Verlauf"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("Verlauf"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Nach Name oder Drucker suchen",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage("Druckzeit (Stunden)"),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Ungültige Zahl"),
    "kwh": MessageLookupByLibrary.simpleMessage("kW/h"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("Arbeitskosten"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage(
      "Arbeits-/Materialkosten: ",
    ),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("Stundensatz"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage("Bearbeitungszeit"),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Client konnte nicht geöffnet werden",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Materialaufschlüsselung",
    ),
    "materialFallback": MessageLookupByLibrary.simpleMessage("Materialtyp"),
    "materialNameLabel": MessageLookupByLibrary.simpleMessage("Materialname *"),
    "materialNone": MessageLookupByLibrary.simpleMessage("Keine"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "Das Materialgewicht ist das Gesamtgewicht des Ausgangsmaterials, also der gesamten Filamentrolle. Die Kosten sind die Kosten der gesamten Einheit.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Materialien"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Protokoll"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage(
      "Brauchen Sie Hilfe?",
    ),
    "offeringsError": MessageLookupByLibrary.simpleMessage("Fehler: "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Nur Premium-Benutzer:",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage("Name des Drucks"),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Gewicht des Drucks",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Druckername *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("Drucker"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie",
    ),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "Beim Verarbeiten Ihres Kaufs ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Käufe wiederherstellen",
    ),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage(
      "Gesamtkosten für Strom:",
    ),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "Gesamtkosten für Filament:",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("Gesamtkosten: "),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("Risikokosten"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage("Risikokosten:"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Speichern"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage("Druck speichern"),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Materialien suchen",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefiniert (nicht gespeichert)",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Drucker auswählen",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Einstellungen",
    ),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage(
      "Spulen-/Harzkosten",
    ),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Spule/Harzgewicht",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Berechnung"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "Bei Problemen schreiben Sie mir bitte an ",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "Support-ID kopiert",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie Ihre Support-ID an: ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage(
      "Nutzungsbedingungen",
    ),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Gesamtkosten"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Gesamtgewicht verwenden",
    ),
    "watt": MessageLookupByLibrary.simpleMessage("Watt"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Watt (3D-Drucker)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Leistung *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Materialien/Verschleiß",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Gewicht *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage("Arbeitskosten"),
  };
}
