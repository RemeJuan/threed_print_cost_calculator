// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: '# matériau', other: '# matériaux')}";

  static String m1(grams) => "Poids total du matériau : ${grams}g";

  static String m2(version) => "Version ${version}";

  static String m3(error) => "Échec du chargement des matériaux : ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Ajoutez au moins un matériau.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage(
      "Ajouter un matériau",
    ),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Taille du plateau *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Calculateur d\'impression 3D",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Calculatrice"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Annuler"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage(
      "(cliquer pour copier)",
    ),
    "closeButton": MessageLookupByLibrary.simpleMessage("Fermer"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Couleur *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Coût *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage(
      "Offres actuelles",
    ),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "Voulez-vous vraiment supprimer cet élément ?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage(
      "Coût de l\'électricité",
    ),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Coût de l\'électricité",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un nombre",
    ),
    "exportButton": MessageLookupByLibrary.simpleMessage("Exporter"),
    "exportError": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'exportation",
    ),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exportation réussie",
    ),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Risque d\'échec (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage(
      "Coût du filament",
    ),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Historique"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("Historique"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Rechercher par nom ou imprimante",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage(
      "Temps d\'impression (heures)",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Nombre invalide"),
    "kwh": MessageLookupByLibrary.simpleMessage("kWh"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("Main-d\'œuvre"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage(
      "Main-d\'œuvre/Matières: ",
    ),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("Taux horaire"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage(
      "Temps de traitement",
    ),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'ouvrir le client mail",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Répartition des matériaux",
    ),
    "materialFallback": MessageLookupByLibrary.simpleMessage("Matériau"),
    "materialsLoadError": m3,
    "materialNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nom du matériau *",
    ),
    "materialNone": MessageLookupByLibrary.simpleMessage("Aucun"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "Le poids du matériau est le poids total du matériau source, c\'est-à-dire toute la bobine de filament. Le coût est celui de l\'unité complète.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Matériaux"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Min."),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage("Besoin d\'aide ?"),
    "numberExampleHint": MessageLookupByLibrary.simpleMessage("ex. 123"),
    "offeringsError": MessageLookupByLibrary.simpleMessage("Erreur : "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Utilisateurs Premium uniquement :",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage(
      "Nom de l\'impression",
    ),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Poids de l\'impression",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Nom *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("Imprimantes"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage(
      "Politique de confidentialité",
    ),
    "remainingFilamentLabel": MessageLookupByLibrary.simpleMessage(
      "Filament restant",
    ),
    "remainingLabel": MessageLookupByLibrary.simpleMessage("Restant :"),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue lors du traitement de votre achat. Veuillez réessayer plus tard.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Restaurer les achats",
    ),
    "retryButton": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage(
      "Coût total de l\'électricité : ",
    ),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "Coût total du filament : ",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("Coût total: "),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("Risque"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage(
      "Coût du risque : ",
    ),
    "saveButton": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage(
      "Enregistrer l\'impression",
    ),
    "savePrintErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Erreur lors de l\'enregistrement de l\'impression",
    ),
    "savePrintSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Impression enregistrée",
    ),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Rechercher des matériaux",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Personnalisé (non enregistré)",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Sélectionner l\'imprimante",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage(
      "Coût de la bobine/résine",
    ),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Poids de la bobine/résine",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Calculer"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "En cas de problème, envoyez-moi un e-mail à ",
    ),
    "trackRemainingFilamentLabel": MessageLookupByLibrary.simpleMessage(
      "Suivre le filament restant",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "ID de support copié",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Veuillez inclure votre ID de support : ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage(
      "Conditions d\'utilisation",
    ),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Coût total"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Utiliser le poids total unique",
    ),
    "versionLabel": m2,
    "watt": MessageLookupByLibrary.simpleMessage("W"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Watts (Imprimante 3D)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Puissance *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Matières/Usures + déchirures",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Poids *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage(
      "Coûts de main-d\'œuvre",
    ),
  };
}
