// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static String m0(count) =>
      "${Intl.plural(count, one: '# materiale', other: '# materiali')}";

  static String m1(grams) => "Peso totale materiale: ${grams}g";

  static String m2(version) => "Versione ${version}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Aggiungi almeno un materiale.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage(
      "Aggiungi materiale",
    ),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Dimensione piano *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Calcolatrice per stampa 3D",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Calcolatore"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Annulla"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage("(tocca per copiare)"),
    "closeButton": MessageLookupByLibrary.simpleMessage("Chiudi"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Colore *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Costo *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage("Offerte attuali"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Elimina"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler eliminare questo elemento?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Elimina"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage(
      "Costo dell\'elettricità",
    ),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Costo elettricità",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage("Inserisci un numero"),
    "exportButton": MessageLookupByLibrary.simpleMessage("Esporta"),
    "exportError": MessageLookupByLibrary.simpleMessage(
      "Esportazione non riuscita",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Esportazione riuscita",
    ),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Rischio di guasto (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("Filamento"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Cronologia"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("Cronologia"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Cerca per nome o stampante",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage("Tempo di stampa (ore)"),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Numero non valido"),
    "kwh": MessageLookupByLibrary.simpleMessage("kW/ora"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("Lavoro"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo lavoro/Materiali: ",
    ),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("Tariffa oraria"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage(
      "Tempo di elaborazione",
    ),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "Impossibile aprire il client di posta",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Dettaglio materiali",
    ),
    "materialFallback": MessageLookupByLibrary.simpleMessage("Materiale"),
    "materialNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nome materiale *",
    ),
    "materialNone": MessageLookupByLibrary.simpleMessage("Nessuno"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "Il peso del materiale è il peso totale del materiale di origine, quindi dell\'intero rotolo di filamento. Il costo è quello dell\'intera unità.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Materiali"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Minuti"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage(
      "Hai bisogno di aiuto?",
    ),
    "offeringsError": MessageLookupByLibrary.simpleMessage("Errore: "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Solo utenti Premium:",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage("Nome stampa"),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso della stampa",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Nome *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("Stampanti"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage(
      "Informativa sulla privacy",
    ),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "Si è verificato un errore durante l\'elaborazione dell\'acquisto. Riprova più tardi.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Ripristina acquisti",
    ),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo totale per l\'elettricità: ",
    ),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo totale per il filamento: ",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("Costo totale: "),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("Rischio"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo del rischio: ",
    ),
    "saveButton": MessageLookupByLibrary.simpleMessage("Salva"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage("Salva stampa"),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Cerca materiali",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Personalizzato (non salvato)",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Seleziona stampante",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage(
      "Costo bobina/resina",
    ),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso bobina/resina",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Calcolare"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "Per qualsiasi problema, scrivimi a ",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "ID di supporto copiato",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Includi il tuo ID di supporto: ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage(
      "Termini di utilizzo",
    ),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Totale"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Usa peso totale singolo",
    ),
    "versionLabel": m2,
    "watt": MessageLookupByLibrary.simpleMessage("Watt"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Watt (stampante 3D)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Potenza *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Materiali/Usura + strappo",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Peso *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage("Costi del lavoro"),
  };
}
