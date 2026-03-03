// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(count) => "${count} materiales";

  static String m1(grams) => "Peso total del material: ${grams}g";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Añade al menos un material.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage(
      "Añadir material",
    ),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Bed Size *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Calculadora de impresión 3D",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Calculator"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancel"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage("(click to copy)"),
    "closeButton": MessageLookupByLibrary.simpleMessage("Close"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Color *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Cost *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage(
      "Current Offerings",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this item?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Delete"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage(
      "Costo de electricidad",
    ),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Electricity cost",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage(
      "Please enter a number",
    ),
    "exportButton": MessageLookupByLibrary.simpleMessage("Export"),
    "exportError": MessageLookupByLibrary.simpleMessage("Export failed"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Riesgo de falla (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("Filamento"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Historia"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("History"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Buscar por nombre o impresora",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage(
      "Tiempo de impresión (horas)",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Invalid number"),
    "kwh": MessageLookupByLibrary.simpleMessage("kilovatios/h"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("Costo laboral"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo laboral/Materiales: ",
    ),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("Tarifa por hora"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage(
      "Tiempo de procesamiento",
    ),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "Could not open mail client",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Desglose de materiales",
    ),
    "materialNameLabel": MessageLookupByLibrary.simpleMessage("Name *"),
    "materialNone": MessageLookupByLibrary.simpleMessage("None"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "Material weight is the total weight for the source material, so the entire roll of filament. The cost is the cost of the entire unit.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Materials"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Minutos"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage("Need Help?"),
    "offeringsError": MessageLookupByLibrary.simpleMessage("Error: "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Sólo usuarios premium:",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage("Print Name"),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso de la impresión",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Name *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("Printers"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "There was an error processing your purchase. Please try again later.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Restore Purchases",
    ),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo total de Electricidad: ",
    ),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo total del filamento: ",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("Coste total: "),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("Riesgo"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage(
      "Costo del riesgo: ",
    ),
    "saveButton": MessageLookupByLibrary.simpleMessage("Save"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage("Save Print"),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Buscar materiales",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Sin seleccionar",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Seleccionar impresora",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage("Ajustes"),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Settings"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage(
      "Costo del carrete/resina",
    ),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso del carrete/resina",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Calcular"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "For any issues, please mail me at ",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "Support ID Copied",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Please include your Support ID: ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage("Terms of Use"),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Total"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Usar peso total único",
    ),
    "watt": MessageLookupByLibrary.simpleMessage("Vatio"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Vatio (impresora 3D)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Wattage *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Materiales/Desgaste + desgaste",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Weight *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage("Costos de Trabajo"),
  };
}
