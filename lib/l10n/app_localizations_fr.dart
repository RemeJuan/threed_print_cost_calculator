// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get calculatorAppBarTitle => 'Calculateur d\'impression 3D';

  @override
  String get historyAppBarTitle => 'Historique';

  @override
  String get settingsAppBarTitle => 'Paramètres';

  @override
  String get calculatorNavLabel => 'Calculatrice';

  @override
  String get historyNavLabel => 'Historique';

  @override
  String get settingsNavLabel => 'Paramètres';

  @override
  String get generalHeader => 'Général';

  @override
  String get wattLabel => 'Watts (Imprimante 3D)';

  @override
  String get printWeightLabel => 'Poids de l\'impression';

  @override
  String get hoursLabel => 'Temps d\'impression (heures)';

  @override
  String get wearAndTearLabel => 'Matières/Usures + déchirures';

  @override
  String get labourRateLabel => 'Taux horaire';

  @override
  String get labourTimeLabel => 'Temps de traitement';

  @override
  String get failureRiskLabel => 'Risque d\'échec (%)';

  @override
  String get minutesLabel => 'Min.';

  @override
  String get spoolWeightLabel => 'Poids de la bobine/résine';

  @override
  String get spoolCostLabel => 'Coût de la bobine/résine';

  @override
  String get electricityCostLabel => 'Coût de l\'électricité';

  @override
  String get electricityCostSettingsLabel => 'Coût de l\'électricité';

  @override
  String get submitButton => 'Calculer';

  @override
  String get resultElectricityPrefix => 'Coût total de l\'électricité : ';

  @override
  String get resultFilamentPrefix => 'Coût total du filament : ';

  @override
  String get resultTotalPrefix => 'Coût total: ';

  @override
  String get riskTotalPrefix => 'Coût du risque : ';

  @override
  String get premiumHeader => 'Utilisateurs Premium uniquement :';

  @override
  String get labourCostPrefix => 'Main-d\'œuvre/Matières: ';

  @override
  String get selectPrinterHint => 'Sélectionner l\'imprimante';

  @override
  String get watt => 'W';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Enregistrer l\'impression';

  @override
  String get printNameHint => 'Nom de l\'impression';

  @override
  String get printerNameLabel => 'Nom *';

  @override
  String get bedSizeLabel => 'Taille du plateau *';

  @override
  String get wattageLabel => 'Puissance *';

  @override
  String get materialNameLabel => 'Nom du matériau *';

  @override
  String get colorLabel => 'Couleur *';

  @override
  String get weightLabel => 'Poids *';

  @override
  String get costLabel => 'Coût *';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get deleteDialogTitle => 'Supprimer';

  @override
  String get deleteDialogContent =>
      'Voulez-vous vraiment supprimer cet élément ?';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get selectMaterialHint => 'Personnalisé (non enregistré)';

  @override
  String get materialNone => 'Aucun';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => 'Restant :';

  @override
  String get trackRemainingFilamentLabel => 'Suivre le filament restant';

  @override
  String get remainingFilamentLabel => 'Filament restant';

  @override
  String get savePrintErrorMessage =>
      'Erreur lors de l\'enregistrement de l\'impression';

  @override
  String get savePrintSuccessMessage => 'Impression enregistrée';

  @override
  String get historyLoadAction => 'Modifier dans la calculatrice';

  @override
  String get historyLoadSuccessMessage => 'Chargé depuis l\'historique';

  @override
  String get historyLoadReplacementWarning =>
      'Certains éléments étaient indisponibles et ont été remplacés';

  @override
  String get numberExampleHint => 'ex. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Échec du chargement des matériaux : $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Échec du chargement des imprimantes : $error';
  }

  @override
  String get retryButton => 'Réessayer';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Besoin d\'aide ?';

  @override
  String get supportEmailPrefix =>
      'En cas de problème, envoyez-moi un e-mail à ';

  @override
  String get supportEmail => 'google@remej.dev';

  @override
  String get supportIdLabel => 'Veuillez inclure votre ID de support : ';

  @override
  String get clickToCopy => '(cliquer pour copier)';

  @override
  String get materialWeightExplanation =>
      'Le poids du matériau est le poids total du matériau source, c\'est-à-dire toute la bobine de filament. Le coût est celui de l\'unité complète.';

  @override
  String get supportIdCopied => 'ID de support copié';

  @override
  String get exportSuccess => 'Exportation réussie';

  @override
  String get exportError => 'Échec de l\'exportation';

  @override
  String get exportButton => 'Exporter';

  @override
  String get privacyPolicyLink => 'Politique de confidentialité';

  @override
  String get termsOfUseLink => 'Conditions d\'utilisation';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Fermer';

  @override
  String get mailClientError => 'Impossible d\'ouvrir le client mail';

  @override
  String get offeringsError => 'Erreur : ';

  @override
  String get currentOfferings => 'Offres actuelles';

  @override
  String get purchaseError =>
      'Une erreur est survenue lors du traitement de votre achat. Veuillez réessayer plus tard.';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get printersHeader => 'Imprimantes';

  @override
  String get materialsHeader => 'Matériaux';

  @override
  String get filamentCostLabel => 'Coût du filament';

  @override
  String get labourCostLabel => 'Main-d\'œuvre';

  @override
  String get riskCostLabel => 'Risque';

  @override
  String get totalCostLabel => 'Coût total';

  @override
  String get workCostsLabel => 'Coûts de main-d\'œuvre';

  @override
  String get enterNumber => 'Veuillez saisir un nombre';

  @override
  String get invalidNumber => 'Nombre invalide';

  @override
  String get validationRequired => 'Obligatoire';

  @override
  String get validationEnterValidNumber => 'Saisissez un nombre valide';

  @override
  String get validationMustBeGreaterThanZero => 'Doit être supérieur à 0';

  @override
  String get validationMustBeZeroOrMore => 'Doit être supérieur ou égal à 0';

  @override
  String get lockedValuePlaceholder => 'Verrouillé';

  @override
  String get hideProPromotionsTitle => 'Masquer les promotions Pro';

  @override
  String get hideProPromotionsSubtitle =>
      'Masquer les bannières et les invites de mise à niveau';

  @override
  String get historySearchHint => 'Rechercher par nom ou imprimante';

  @override
  String get historyExportMenuTitle => 'Exporter les impressions';

  @override
  String get historyExportRangeAll => 'Toutes';

  @override
  String get historyExportRangeLast7Days => '7 derniers jours';

  @override
  String get historyExportRangeLast30Days => '30 derniers jours';

  @override
  String get historyEmptyTitle =>
      'Aucune impression enregistrée pour l\'instant';

  @override
  String get historyEmptyDescription =>
      'Réutilisez d\'anciennes impressions dans la calculatrice';

  @override
  String get historyUpsellTitle =>
      'Réutilisez instantanément d\'anciennes impressions';

  @override
  String get historyUpsellDescription =>
      'Débloquez les modifications avancées et les exportations';

  @override
  String get historyNoMoreRecords => 'Aucun autre enregistrement';

  @override
  String get historyOverflowHint => 'Plus d\'actions dans ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Impossible de charger l\'historique : $error';
  }

  @override
  String get historyCsvHeader =>
      'Date,Imprimante,Matériau,Matériaux,Poids (g),Temps,Électricité,Filament,Main-d\'œuvre,Risque,Total';

  @override
  String get historyExportShareText =>
      'Export de l\'historique des coûts d\'impression 3D';

  @override
  String get historyTeaserTitle =>
      'Conservez chaque estimation d\'impression au même endroit';

  @override
  String get historyTeaserDescription =>
      'Découvrez le fonctionnement de l\'historique avant de passer à Pro. Enregistrez vos estimations terminées et exportez-les à tout moment avec Pro.';

  @override
  String get historyTeaserCta =>
      'Enregistrer et exporter l\'historique avec Pro';

  @override
  String get historyExportPreviewEntry => 'Aperçu de l\'export CSV';

  @override
  String get historyExportPreviewTitle => 'Aperçu CSV';

  @override
  String get historyExportPreviewDescription =>
      'Voyez à quoi ressemblera votre export. Le téléchargement et le partage sont débloqués avec Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Exemple]';

  @override
  String get historyExportPreviewAction => 'Télécharger / Partager avec Pro';

  @override
  String get addMaterialButton => 'Ajouter un matériau';

  @override
  String get useSingleTotalWeightAction => 'Utiliser le poids total unique';

  @override
  String get addAtLeastOneMaterial => 'Ajoutez au moins un matériau.';

  @override
  String get searchMaterialsHint => 'Rechercher des matériaux';

  @override
  String get materialBreakdownLabel => 'Répartition des matériaux';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# matériaux',
      one: '# matériau',
    );
    return '$_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Poids total du matériau : ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get materialFallback => 'Matériau';
}
