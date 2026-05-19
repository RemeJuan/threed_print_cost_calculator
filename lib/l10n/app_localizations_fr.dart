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
  String get newAnnouncementBadgeLabel => 'Nouveau';

  @override
  String get whatsNewSeeRecentUpdates => 'Voir les nouveautés récentes';

  @override
  String get generalHeader => 'Général';

  @override
  String get wattLabel => 'Watts (Imprimante 3D)';

  @override
  String get printWeightLabel => 'Poids de l\'impression';

  @override
  String get hoursLabel => 'Temps d\'impression (heures)';

  @override
  String get durationHoursLabel => 'Heures';

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
  String get durationMinutesLabel => 'Min.';

  @override
  String get printingTimeDialogTitle => 'Temps d\'impression';

  @override
  String get workTimeDialogTitle => 'Temps de travail';

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
  String get resetButtonLabel => 'Réinitialiser';

  @override
  String get resetCalculationTitle => 'Réinitialiser le calcul ?';

  @override
  String get resetCalculationBody =>
      'Cela supprimera les valeurs actuelles du calculateur et rechargera les valeurs par défaut actuelles.';

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
  String get deleteRecordErrorMessage =>
      'Erreur lors de la suppression de l\'enregistrement';

  @override
  String get savePrintSuccessMessage => 'Impression enregistrée';

  @override
  String get deleteMaterialSuccessMessage => 'Matériau supprimé';

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
  String get helpSupportSupportTitle => 'Support';

  @override
  String get helpSupportSupportIntro =>
      'Utilisez ces détails lorsque vous contactez le support.';

  @override
  String get helpSupportWebsiteLabel => 'Site web';

  @override
  String get helpSupportEmailLabel => 'E-mail';

  @override
  String get helpSupportSupportIdLabel => 'ID de support';

  @override
  String get helpSupportCopySupportIdTooltip => 'Copier l\'ID de support';

  @override
  String get helpSupportRoadmapLabel => 'Feuille de route';

  @override
  String get helpSupportRoadmapValue => 'Voir ce qui arrive';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'Version de l\'app $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Contacter le support';

  @override
  String get helpSupportContactEmailSubject =>
      'Support Calculateur de Coût d\'Impression 3D';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'ID de support : $supportId\nVersion de l\'app : $version\n\nDécrivez le problème ici.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'ID de support : (non disponible)\nVersion de l\'app : $version\n\nDécrivez le problème ici.';
  }

  @override
  String get helpSupportFaqTitle => 'FAQ';

  @override
  String get helpSupportFaqWeightQuestion => 'Quel poids dois-je entrer ?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Entrez le poids total de la bobine, pas le filament restant. L\'application utilise le poids du rouleau complet pour calculer le coût par gramme.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      'Pourquoi l\'électricité est-elle importante ?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Les longues impressions et les imprimantes à forte puissance peuvent ajouter un coût réel. Ignorer l\'électricité sous-estime généralement le prix du travail.';

  @override
  String get helpSupportFaqRiskQuestion =>
      'Comment le risque d\'échec est-il calculé ?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'Le risque est appliqué uniquement aux coûts d\'impression de base comme le filament et l\'électricité. Il estime la perte attendue des impressions échouées.';

  @override
  String get helpSupportFaqLabourQuestion =>
      'Qu\'est-ce que le temps de main-d\'œuvre / traitement ?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Il couvre la préparation, le nettoyage, le post-traitement et la surveillance. Gardez-le activé pour les services où votre temps compte.';

  @override
  String get helpSupportFaqMarkupQuestion => 'Qu\'est-ce que la majoration ?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'La majoration est le pourcentage ajouté au coût total pour atteindre votre prix de vente. Elle couvre la marge, les frais généraux et le profit.';

  @override
  String get helpSupportFaqSetupQuestion =>
      'Qu\'est-ce qu\'un frais de configuration ?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Un frais de configuration est un coût fixe par travail pour l\'étalonnage, la préparation de la machine et l\'administration. Il aide les petites impressions à couvrir les frais généraux.';

  @override
  String get helpSupportLinksTitle => 'Liens';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Politique de confidentialité';

  @override
  String get helpSupportTermsOfUseLabel => 'Conditions d\'utilisation';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'À propos';

  @override
  String get helpSupportAboutIntro =>
      'Le Calculateur de Coût d\'Impression 3D est conçu pour une tarification locale d\'abord. Il aide les créateurs et les petites entreprises d\'impression à établir des devis avec moins de surprises.';

  @override
  String get helpSupportTrustNoAccounts => 'Pas de comptes';

  @override
  String get helpSupportTrustNoCloudSync => 'Pas de synchronisation cloud';

  @override
  String get helpSupportTrustNoTracking => 'Pas de suivi';

  @override
  String get helpSupportTrustLocalData => 'Données locales';

  @override
  String get helpSupportAboutCalculator =>
      'Le calculateur combine le coût du filament, l\'électricité, le risque d\'échec, la main-d\'œuvre et des outils de tarification optionnels comme la majoration et les frais de configuration.';

  @override
  String get helpSupportAboutOutcome =>
      'Cela maintient les devis liés au coût réel, pas seulement aux dépenses matérielles.';

  @override
  String get supportEmailPrefix =>
      'En cas de problème, envoyez-moi un e-mail à ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Veuillez inclure votre ID de support : ';

  @override
  String get supportEmailSubject => 'Assistance pour 3D Print Cost Calculator';

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
  String get websiteLink => 'Site web';

  @override
  String get termsOfUseLink => 'Conditions d\'utilisation';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Fermer';

  @override
  String get cancelFeedbackPromptTitle =>
      'On dirait que vous avez désactivé le renouvellement. Pouvez-vous nous dire pourquoi ?';

  @override
  String get feedbackSubmitButton => 'Envoyer un retour';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Trop cher';

  @override
  String get cancelFeedbackReasonMissingFeatures =>
      'Fonctionnalités manquantes';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'Pas assez de valeur';

  @override
  String get cancelFeedbackReasonConfusingToUse => 'Difficile à utiliser';

  @override
  String get cancelFeedbackReasonJustTesting => 'Je testais juste l’app';

  @override
  String get cancelFeedbackReasonOther => 'Autre';

  @override
  String get testDataToolsTitle => 'Outils de données de test';

  @override
  String get testDataToolsBody =>
      'Ces actions sont réservées aux tests locaux. Le remplissage remplace la configuration locale actuelle par des données de démonstration. Le nettoyage supprime définitivement les données locales de l\'appareil.';

  @override
  String get seedTestDataButton => 'Remplir les données de test';

  @override
  String get purgeLocalDataButton => 'Effacer les données locales';

  @override
  String get enablePremiumButton => 'Activer le premium';

  @override
  String get forceUpdateAvailableButton => 'Forcer la mise à jour disponible';

  @override
  String get forceNoUpdateButton => 'Forcer aucune mise à jour';

  @override
  String get clearUpdateCooldownButton => 'Effacer le délai de mise à jour';

  @override
  String get previewCancelFeedbackButton =>
      'Aperçu des commentaires d\'annulation';

  @override
  String get enableBatchCostingButton => 'Activer le calcul par lots';

  @override
  String get batchCostingSummarySaveButton => 'Enregistrer le devis';

  @override
  String get batchCostingSummarySaveSuccessTitle => 'Devis enregistré';

  @override
  String get batchCostingSummarySaveSuccessBody =>
      'Enregistré dans l\'historique.';

  @override
  String get batchCostingSummaryViewHistoryButton => 'Voir l\'historique';

  @override
  String get batchCostingSummarySaveErrorMessage =>
      'Impossible d\'enregistrer le devis';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'Devis par lots';

  @override
  String get batchHistoryItemsTitle => 'Articles du lot';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'articles',
      one: 'article',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalQuantity,
      locale: localeName,
      other: 'copies',
      one: 'copie',
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
  String get enablePremiumTitle => 'Activer le premium';

  @override
  String get enablePremiumBody =>
      'Saisissez le code de confirmation pour activer les tests premium locaux';

  @override
  String get invalidConfirmationCodeMessage => 'Code de confirmation invalide';

  @override
  String get seedTestDataConfirmTitle => 'Remplir les données de test ?';

  @override
  String get seedTestDataConfirmBody =>
      'Cela remplacera la configuration locale actuelle par des données de démonstration déterministes.';

  @override
  String get purgeLocalDataConfirmTitle => 'Effacer les données locales ?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Cela supprimera définitivement toutes les données locales de l\'application sur cet appareil.';

  @override
  String get testDataSeededMessage => 'Données de test remplies';

  @override
  String get testDataPurgedMessage => 'Données locales effacées';

  @override
  String get testDataActionFailedMessage =>
      'L\'action de données de test a échoué';

  @override
  String get updatePromptTitle => 'Mise à jour disponible';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'La version $storeVersion est disponible. Vous avez $currentVersion installé.';
  }

  @override
  String get updatePromptBodyUnknown =>
      'Une version plus récente est disponible.';

  @override
  String get updatePromptOpenStoreButton => 'Ouvrir le store';

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
  String get additionalCostLabel => 'Coût supplémentaire';

  @override
  String get additionalCostNoteLabel => 'Note de coût supplémentaire';

  @override
  String get additionalCostNoteDialogTitle => 'Note de coût supplémentaire';

  @override
  String get riskCostLabel => 'Risque';

  @override
  String get totalCostLabel => 'Coût total';

  @override
  String get costTotalLabel => 'Coût';

  @override
  String get markupLabel => 'Marge';

  @override
  String get setupFeeLabel => 'Frais d\'installation';

  @override
  String get roundingAdjustmentLabel => 'Ajustement d\'arrondi';

  @override
  String get finalPriceLabel => 'Prix final';

  @override
  String get jobPricingOverridesLabel => 'Paramètres du travail';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'surcharges appliquées',
      one: 'surcharge appliquée',
    );
    return '$count $_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => '% de marge';

  @override
  String get pricingSetupFeeLabel => 'Frais d\'installation';

  @override
  String get pricingRoundingLabel => 'Arrondi';

  @override
  String get pricingRoundingNoneLabel => 'Aucun';

  @override
  String get pricingRoundingWholeDollarLabel => 'Unité entière';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Se termine par .99';

  @override
  String get currencySymbolLabel => 'Symbole monétaire';

  @override
  String get currencyPositionLabel => 'Position du symbole';

  @override
  String get currencyPositionBeforeLabel => 'Avant';

  @override
  String get currencyPositionAfterLabel => 'Après';

  @override
  String get currencySpacingLabel => 'Espace avec symbole';

  @override
  String get currencyPreviewLabel => 'Aperçu';

  @override
  String materialCostPerKilogramLabel(Object cost) {
    return '$cost/kg';
  }

  @override
  String historyTimeCompactLabel(Object hours, Object minutes) {
    return '$hours h $minutes min';
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
      'Date,Imprimante,Matériau,Matériaux,Poids (g),Temps,Électricité,Filament,Main-d\'œuvre,Risque,Total,%,Montant de marge,Frais d\'installation,Mode d\'arrondi,Sous-total avant arrondi,Ajustement d\'arrondi,Prix final';

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
  String get searchMaterialsHint => 'Chercher nom ou marque';

  @override
  String get materialBreakdownLabel => 'Répartition des matériaux';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'matériaux',
      one: 'matériau',
    );
    return '$count $_temp0';
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

  @override
  String get durationPickerLabel => 'Printing time (hh:mm)';

  @override
  String get importGcodeButton => 'Importer G-code (Remplissage auto)';

  @override
  String get importGcodePageTitle => 'Importer G-code (Bêta)';

  @override
  String get importGcodeIntro =>
      'Sélectionnez un fichier .gcode local. Slicers pris en charge: PrusaSlicer, OrcaSlicer, Bambu Studio et Cura.';

  @override
  String get importGcodeSelectFileButton => 'Sélectionner fichier G-code';

  @override
  String get importGcodePickAnotherButton => 'Sélectionner un autre fichier';

  @override
  String get importGcodeSelectedFileLabel => 'Fichier sélectionné';

  @override
  String get gcodeImportFeedbackTitle => 'Feedback importation G-code Bêta';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Fonctionnalité bêta';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Dites-nous ce qui a fonctionné, ce qui a échoué ou ce qui semble incorrect.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Quel slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Résultat aperçu';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Résultat métadonnées';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'Qu\'est-ce qui a fonctionné, échoué ou semble incorrect?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Joindre le fichier G-code importé';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'Aucun fichier G-code importé disponible.';

  @override
  String get gcodeImportFeedbackSendCta => 'Envoyer le feedback';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback envoyé';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Aperçu chargé';

  @override
  String get gcodeFeedbackPreviewMissing => 'Aperçu manquant';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Aperçu incorrect';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Pas sûr';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Semble correct';

  @override
  String get gcodeFeedbackMetadataMissing => 'Données manquantes';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Données incorrectes';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Pas sûr';

  @override
  String get importGcodeSummaryTitle => 'Résumé de l\'import';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Slicers pris en charge: PrusaSlicer, OrcaSlicer, Bambu Studio et Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Les valeurs importées préremplissent seulement le temps et le poids total du matériau. L\'imprimante, le matériau et le coût final proviennent de vos paramètres.';

  @override
  String get importGcodeUseValuesButton => 'Utiliser ces valeurs';

  @override
  String get importGcodeQuantityLabel => 'Quantité';

  @override
  String get importGcodeCreateBatchButton => 'Créer un lot';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'La création du lot nécessite une durée et un poids de filament détectés.';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Durée estimée';

  @override
  String get importGcodeFilamentWeightLabel => 'Poids du filament';

  @override
  String get importGcodeFilamentLengthLabel => 'Longueur du filament';

  @override
  String get importGcodeLayerHeightLabel => 'Hauteur de couche';

  @override
  String get importGcodePreviewLabel => 'Aperçu';

  @override
  String get importGcodePreviewAvailable => 'Disponible';

  @override
  String get importGcodePreviewView => 'Voir';

  @override
  String get importGcodePreviewUnavailable => 'Aucun aperçu';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Métadonnées d\'aperçu trouvées mais l\'image n\'a pas pu être affichée.';

  @override
  String get importGcodePreviewCuraNote =>
      'Les aperçus Cura peuvent nécessiter un script post-traitement pour intégrer les miniatures.';

  @override
  String get importGcodeWarningsTitle => 'Avertissements';

  @override
  String get importGcodeUnsupportedTypeError =>
      'Ce fichier ne ressemble pas à un fichier G-code pris en charge.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Ce fichier ne ressemble pas à un fichier G-code pris en charge.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'Ce fichier est trop volumineux pour être importé. Choisissez un fichier inférieur à $maxSizeMb MB.';
  }

  @override
  String get importGcodeReadError =>
      'Le fichier sélectionné n\'a pas pu être lu.';

  @override
  String get importGcodeUnknownSlicerValue => 'Inconnu';

  @override
  String get importGcodeMissingValue => 'Non trouvé';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer non identifié. Vérifiez les valeurs avant d\'appliquer.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Le temps d\'impression n\'a pas pu être détecté.';

  @override
  String get importGcodeWarningMissingFilament =>
      'Utilisation du filament incomplète.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Poids du filament manquant.';

  @override
  String get importGcodeWarningPartialMetadata =>
      'Certaines métadonnées manquent.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Plusieurs totaux de matériau trouvés. Vérifiez avant d\'appliquer.';

  @override
  String get importGcodeAppliedMessage =>
      'Valeurs importées appliquées à la calculatrice';

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
  String get slicerUnknown => 'Inconnu';

  @override
  String get materialsAppBarTitle => 'Matériaux';

  @override
  String get materialsNavLabel => 'Matériaux';

  @override
  String get brandLabel => 'Marque';

  @override
  String get materialTypeLabel => 'Type de matériau';

  @override
  String get colorHexLabel => 'Code hex (optionnel)';

  @override
  String get notesLabel => 'Notes';

  @override
  String get materialsEmpty =>
      'Aucun matériau pour l\'instant. Appuyez sur + pour en ajouter.';

  @override
  String get materialsFilterAll => 'Tout';

  @override
  String get materialsFilterInStock => 'En stock';

  @override
  String get materialsFilterLowStock => 'Stock bas';

  @override
  String get materialsFilterOutOfStock => 'Rupture de stock';

  @override
  String get csvImportTitle => 'Importer des matériaux';

  @override
  String get csvTemplateButton => 'Modèle';

  @override
  String get csvTemplateShareText => 'Matériaux - Modèle CSV';

  @override
  String get csvTemplateError => 'Impossible de partager le modèle.';

  @override
  String get csvImportIntro => 'Importez des matériaux depuis un fichier CSV.';

  @override
  String get csvSelectFileButton => 'Choisir un fichier CSV';

  @override
  String get csvImportButton => 'Importer les lignes valides';

  @override
  String get csvReadError => 'Le fichier sélectionné n\'a pas pu être lu.';

  @override
  String get csvFileTypeError => 'Sélectionnez un fichier .csv';

  @override
  String get csvNameRequiredError => 'Le nom est obligatoire';

  @override
  String get csvColorRequiredError => 'La couleur est obligatoire';

  @override
  String get csvSpoolWeightRequiredError =>
      'Le poids de la bobine est obligatoire';

  @override
  String get csvSpoolWeightPositiveError =>
      'Le poids de la bobine doit être > 0';

  @override
  String get csvCostRequiredError => 'Le coût est obligatoire';

  @override
  String get csvCostPositiveError => 'Le coût doit être > 0';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matériaux importés',
      one: '1 matériau importé',
    );
    return '$_temp0';
  }

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total lignes: $valid valides, $invalid avec erreurs';
  }

  @override
  String get csvEmptyNamePlaceholder => '(vide)';

  @override
  String get editButton => 'Modifier';

  @override
  String get duplicateButton => 'Dupliquer';

  @override
  String get duplicateMaterialSuccessMessage => 'Matériau dupliqué';

  @override
  String get duplicateMaterialErrorMessage =>
      'Erreur lors de la duplication du matériau';

  @override
  String get materialsSwipeHint =>
      'Balayer un matériau pour modifier, dupliquer ou supprimer.';

  @override
  String get stockBadgeOut => 'Rupture';

  @override
  String get stockBadgeLow => 'Stock faible';

  @override
  String get stockBadgeInStock => 'En stock';

  @override
  String get stockBadgeNoTracking => 'Non suivi';

  @override
  String get batchCostingReviewAppBarTitle => 'Vérification des lots';

  @override
  String get batchCostingReviewSubtitle =>
      'Vérifiez les articles du lot avant l\'attribution de l\'imprimante.';

  @override
  String get batchCostingReviewAddManualItemButton =>
      'Ajouter un article manuel';

  @override
  String get batchCostingReviewEmptyTitle =>
      'Aucun article de lot pour l\'instant';

  @override
  String get batchCostingReviewEmptyBody =>
      'Ajoutez des impressions importées ou manuelles pour continuer.';

  @override
  String get batchCostingReviewImportGcodeButton =>
      'Importer des fichiers G-code';

  @override
  String get batchGcodeImportTitle => 'Importer un lot de G-code';

  @override
  String get batchGcodeImportBody =>
      'Choisissez un ou plusieurs fichiers G-code. Chaque fichier est analysé séparément.';

  @override
  String get batchGcodeImportPickButton => 'Choisir des fichiers';

  @override
  String get batchGcodeImportSuccessLabel => 'Importé avec succès';

  @override
  String get batchGcodeImportFailureLabel => 'Échec de l\'import';

  @override
  String get batchGcodeImportParseFailure =>
      'Ce fichier n\'a pas pu être importé.';

  @override
  String get batchGcodeImportContinueButton => 'Continuer vers la revue du lot';

  @override
  String get batchGcodeImportRetryButton => 'Choisir à nouveau';

  @override
  String get batchCostingReviewContinueButton =>
      'Continuer vers l\'attribution de l\'imprimante';

  @override
  String get batchCostingReviewQuantityLabel => 'Quantité';

  @override
  String get batchCostingReviewRemoveButton => 'Supprimer';

  @override
  String get batchCostingReviewSourceLabel => 'Source';

  @override
  String get batchCostingReviewSourceManual => 'Manuel';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => 'Inconnu';

  @override
  String get batchCostingReviewWeightLabel => 'Poids';

  @override
  String get batchCostingReviewDurationLabel => 'Durée';

  @override
  String get batchCostingItemEditorAddTitle => 'Ajouter un article manuel';

  @override
  String get batchCostingItemEditorEditTitle => 'Modifier l\'article du lot';

  @override
  String get batchCostingItemNameLabel => 'Nom de l\'article / du modèle';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle =>
      'Attribution de l\'imprimante';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Attribuez les imprimantes avant les matériaux.';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'Tout le lot';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => 'Par élément';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'Choisissez une imprimante pour tous les éléments.';

  @override
  String get batchCostingPrinterAssignmentPerItemHint =>
      'Choisissez une imprimante pour cet élément.';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'Répartir les copies';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return 'Répartir les copies pour $itemName';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return 'Le total doit être égal à $total';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      'Les affectations ont été réinitialisées car la quantité a changé.';

  @override
  String get batchCostingAssignmentCopiesLabel => 'Copies';

  @override
  String get batchCostingAllocationPickerSearchLabel =>
      'Rechercher des options';

  @override
  String get batchCostingAllocationPickerAvailableLabel => 'Disponible';

  @override
  String get batchCostingAllocationPickerSelectedLabel => 'Sélectionné';

  @override
  String get batchCostingAllocationPickerAddButton => 'Ajouter';

  @override
  String get batchCostingAllocationPickerNoResultsLabel => 'Aucun résultat.';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      'Choisissez une imprimante pour continuer.';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => 'Précédent';

  @override
  String get batchCostingPrinterAssignmentNextButton => 'Suivant';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'Aucune imprimante n\'est encore disponible.';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle =>
      'Attribution du matériau';

  @override
  String get batchCostingMaterialAssignmentSubtitle =>
      'Attribuez les matériaux ou bobines avant le prix.';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel =>
      'Matériau ou bobine';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'Lot entier';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'Par élément';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'Choisissez un matériau pour tous les éléments.';

  @override
  String get batchCostingMaterialAssignmentPerItemHint =>
      'Choisissez un matériau pour cet élément.';

  @override
  String get batchCostingMaterialAssignmentRequiredError =>
      'Choisissez un matériau pour continuer.';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => 'Précédent';

  @override
  String get batchCostingMaterialAssignmentNextButton => 'Suivant';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      'Ajoutez au moins un matériau ou une bobine pour continuer.';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return 'Le requis $required dépasse le stock sélectionné $available.';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => 'Portée du prix';

  @override
  String get batchCostingPricingScopeSubtitle =>
      'Définissez où chaque valeur de prix s\'applique.';

  @override
  String get batchCostingPricingScopeItemMode => 'Article';

  @override
  String get batchCostingPricingScopeBatchMode => 'Lot';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => 'Article (par copie)';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'Lot (une fois)';

  @override
  String get batchCostingPricingScopeScopeLabel => 'Portée';

  @override
  String get batchCostingSummaryAppBarTitle => 'Résumé du lot';

  @override
  String get batchCostingSummarySubtitle =>
      'Vérifiez le lot avant de générer un devis.';

  @override
  String get batchCostingSummaryOverviewTitle => 'Aperçu';

  @override
  String get batchCostingSummaryItemCountLabel => 'Articles';

  @override
  String get batchCostingSummaryTotalQuantityLabel => 'Quantité totale';

  @override
  String get batchCostingSummaryTotalWeightLabel => 'Poids total';

  @override
  String get batchCostingSummaryTotalDurationLabel =>
      'Temps total d\'impression';

  @override
  String get batchCostingSummaryItemWeightLabel => 'Poids';

  @override
  String get batchCostingSummaryItemDurationLabel => 'Temps d\'impression';

  @override
  String get batchCostingSummaryItemBaseCostLabel => 'Coût de base';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => 'Ajustements';

  @override
  String get batchCostingSummaryItemTotalLabel => 'Total de l\'article';

  @override
  String get batchCostingSummaryFinalTotalLabel => 'Total final';

  @override
  String get batchCostingSummaryBackButton => 'Retour à la portée de prix';

  @override
  String get batchCostingSummaryReturnToCalculatorButton =>
      'Retour au calculateur';

  @override
  String get batchCostingSummaryStartNewBatchButton => 'Nouveau lot';

  @override
  String get batchCostingSummaryEmptyTitle => 'Aucun résumé de lot';

  @override
  String get batchCostingSummaryEmptyBody =>
      'Ajoutez des articles et définissez la portée avant de consulter le résumé.';

  @override
  String get batchCostingSummaryPricingTitle => 'Tarification';

  @override
  String get batchCostingSummaryItemsTitle => 'Articles';

  @override
  String get batchCostingNewBatchDialogTitle => 'Nouveau lot';

  @override
  String get batchCostingNewBatchDialogBody =>
      'Cela supprimera toute la progression actuelle du lot. Démarrer un nouveau lot ?';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnit chacun → $lineTotal total';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'Imprimante';
}
