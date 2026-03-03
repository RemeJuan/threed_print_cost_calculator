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

  static String m0(count) =>
      "${Intl.plural(count, one: '# material', other: '# materiales')}";

  static String m1(grams) => "Peso total del material: ${grams}g";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Añade al menos un material.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage(
      "Añadir material",
    ),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Tamaño de cama *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Calculadora de impresión 3D",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Calculadora"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage(
      "(haz clic para copiar)",
    ),
    "closeButton": MessageLookupByLibrary.simpleMessage("Cerrar"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Color del material *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Costo *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage(
      "Ofertas actuales",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "¿Seguro que deseas eliminar este elemento?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage(
      "Costo de electricidad",
    ),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Costo de electricidad",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage("Ingresa un número"),
    "exportButton": MessageLookupByLibrary.simpleMessage("Exportar"),
    "exportError": MessageLookupByLibrary.simpleMessage("Error de exportación"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exportación exitosa",
    ),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Riesgo de falla (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("Filamento"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Historial"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("Historial"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Buscar por nombre o impresora",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage(
      "Tiempo de impresión (horas)",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Número inválido"),
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
      "No se pudo abrir el cliente de correo",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Desglose de materiales",
    ),
    "materialFallback": MessageLookupByLibrary.simpleMessage(
      "Material genérico",
    ),
    "materialNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nombre del material *",
    ),
    "materialNone": MessageLookupByLibrary.simpleMessage("Ninguno"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "El peso del material es el peso total del material de origen, es decir, todo el rollo de filamento. El costo es el costo de la unidad completa.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Materiales"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Minutos"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage("¿Necesitas ayuda?"),
    "offeringsError": MessageLookupByLibrary.simpleMessage(
      "Error de ofertas: ",
    ),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Sólo usuarios premium:",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage(
      "Nombre de impresión",
    ),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso de la impresión",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Nombre *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("Impresoras"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "Hubo un error al procesar tu compra. Inténtalo de nuevo más tarde.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Restaurar compras",
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
    "saveButton": MessageLookupByLibrary.simpleMessage("Guardar"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage(
      "Guardar impresión",
    ),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Buscar materiales",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Personalizado (no guardado)",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Seleccionar impresora",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage("Ajustes"),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Configuración"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage(
      "Costo del carrete/resina",
    ),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso del carrete/resina",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Calcular"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "Si tienes algún problema, escríbeme a ",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "ID de soporte copiado",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Incluye tu ID de soporte: ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage("Términos de uso"),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Costo total"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Usar peso total único",
    ),
    "watt": MessageLookupByLibrary.simpleMessage("Vatio"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Vatio (impresora 3D)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Potencia *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Materiales/Desgaste + desgaste",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Peso *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage("Costos de Trabajo"),
  };
}
