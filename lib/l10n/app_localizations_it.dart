// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get calculatorAppBarTitle => 'Calcolatrice per stampa 3D';

  @override
  String get historyAppBarTitle => 'Cronologia';

  @override
  String get settingsAppBarTitle => 'Impostazioni';

  @override
  String get calculatorNavLabel => 'Calcolatore';

  @override
  String get historyNavLabel => 'Cronologia';

  @override
  String get settingsNavLabel => 'Impostazioni';

  @override
  String get newAnnouncementBadgeLabel => 'Nuovo';

  @override
  String get whatsNewSeeRecentUpdates => 'Vedi gli aggiornamenti recenti';

  @override
  String get generalHeader => 'Generale';

  @override
  String get wattLabel => 'Watt (stampante 3D)';

  @override
  String get printWeightLabel => 'Peso della stampa';

  @override
  String get hoursLabel => 'Tempo di stampa (ore)';

  @override
  String get durationHoursLabel => 'Ore';

  @override
  String get wearAndTearLabel => 'Materiali/Usura + strappo';

  @override
  String get labourRateLabel => 'Tariffa oraria';

  @override
  String get labourTimeLabel => 'Tempo di elaborazione';

  @override
  String get failureRiskLabel => 'Rischio di guasto (%)';

  @override
  String get minutesLabel => 'Minuti';

  @override
  String get durationMinutesLabel => 'Minuti';

  @override
  String get printingTimeDialogTitle => 'Tempo di stampa';

  @override
  String get workTimeDialogTitle => 'Tempo di lavoro';

  @override
  String get spoolWeightLabel => 'Peso bobina/resina';

  @override
  String get spoolCostLabel => 'Costo bobina/resina';

  @override
  String get electricityCostLabel => 'Costo dell\'elettricità';

  @override
  String get electricityCostSettingsLabel => 'Costo elettricità';

  @override
  String get submitButton => 'Calcolare';

  @override
  String get resultElectricityPrefix => 'Costo totale per l\'elettricità: ';

  @override
  String get resultFilamentPrefix => 'Costo totale per il filamento: ';

  @override
  String get resultTotalPrefix => 'Costo totale: ';

  @override
  String get riskTotalPrefix => 'Costo del rischio: ';

  @override
  String get premiumHeader => 'Solo utenti Premium:';

  @override
  String get labourCostPrefix => 'Costo lavoro/Materiali: ';

  @override
  String get selectPrinterHint => 'Seleziona stampante';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Salva stampa';

  @override
  String get printNameHint => 'Nome stampa';

  @override
  String get printerNameLabel => 'Nome *';

  @override
  String get bedSizeLabel => 'Dimensione piano *';

  @override
  String get wattageLabel => 'Potenza *';

  @override
  String get materialNameLabel => 'Nome materiale *';

  @override
  String get colorLabel => 'Colore *';

  @override
  String get weightLabel => 'Peso *';

  @override
  String get costLabel => 'Costo *';

  @override
  String get saveButton => 'Salva';

  @override
  String get deleteDialogTitle => 'Elimina';

  @override
  String get deleteDialogContent =>
      'Sei sicuro di voler eliminare questo elemento?';

  @override
  String get cancelButton => 'Annulla';

  @override
  String get resetButtonLabel => 'Reimposta';

  @override
  String get resetCalculationTitle => 'Reimpostare il calcolo?';

  @override
  String get resetCalculationBody =>
      'Questa azione eliminerà i valori correnti del calcolatore e ricaricherà i valori predefiniti correnti.';

  @override
  String get deleteButton => 'Elimina';

  @override
  String get selectMaterialHint => 'Personalizzato (non salvato)';

  @override
  String get materialNone => 'Nessuno';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => 'Rimanente:';

  @override
  String get trackRemainingFilamentLabel =>
      'Tieni traccia del filamento rimanente';

  @override
  String get remainingFilamentLabel => 'Filamento rimanente';

  @override
  String get savePrintErrorMessage =>
      'Errore durante il salvataggio della stampa';

  @override
  String get deleteRecordErrorMessage =>
      'Errore durante la rimozione del record';

  @override
  String get savePrintSuccessMessage => 'Stampa salvata';

  @override
  String get deleteMaterialSuccessMessage => 'Materiale eliminato';

  @override
  String get historyLoadAction => 'Modifica nel calcolatore';

  @override
  String get historyLoadSuccessMessage => 'Caricato dalla cronologia';

  @override
  String get historyLoadReplacementWarning =>
      'Alcuni elementi non erano disponibili e sono stati sostituiti';

  @override
  String get numberExampleHint => 'es. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Errore durante il caricamento dei materiali: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Errore durante il caricamento delle stampanti: $error';
  }

  @override
  String get retryButton => 'Riprova';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Hai bisogno di aiuto?';

  @override
  String get helpSupportSupportTitle => 'Supporto';

  @override
  String get helpSupportSupportIntro =>
      'Usa questi dettagli quando contatti il supporto.';

  @override
  String get helpSupportWebsiteLabel => 'Sito web';

  @override
  String get helpSupportEmailLabel => 'E-mail';

  @override
  String get helpSupportSupportIdLabel => 'ID supporto';

  @override
  String get helpSupportCopySupportIdTooltip => 'Copia ID supporto';

  @override
  String get helpSupportRoadmapLabel => 'Roadmap';

  @override
  String get helpSupportRoadmapValue => 'Scopri cosa sta arrivando';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'Versione app $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Contatta supporto';

  @override
  String get helpSupportContactEmailSubject =>
      'Supporto Calcolatore Costi Stampa 3D';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'ID supporto: $supportId\nVersione app: $version\n\nDescrivi il problema qui.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'ID supporto: (non disponibile)\nVersione app: $version\n\nDescrivi il problema qui.';
  }

  @override
  String get helpSupportFaqTitle => 'FAQ';

  @override
  String get helpSupportFaqWeightQuestion => 'Che peso devo inserire?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Inserisci il peso totale della bobina, non il filamento rimasto. L\'app usa il peso del rotolo completo per calcolare il costo per grammo.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      'Perché l\'elettricità è importante?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Stampe lunghe e stampanti ad alto wattaggio possono aggiungere costi reali. Saltare l\'elettricità di solito sottostima il prezzo del lavoro.';

  @override
  String get helpSupportFaqRiskQuestion =>
      'Come viene calcolato il rischio di guasto?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'Il rischio è applicato solo ai costi di stampa base come filamento ed elettricità. Stima la perdita prevista da stampe fallite.';

  @override
  String get helpSupportFaqLabourQuestion =>
      'Cos\'è il tempo di lavoro / elaborazione?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Copre preparazione, pulizia, post-elaborazione e monitoraggio. Tienilo attivo per servizi dove il tuo tempo conta.';

  @override
  String get helpSupportFaqMarkupQuestion => 'Cos\'è il ricarico?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'Il ricarico è la percentuale aggiunta sopra il costo totale per raggiungere il tuo prezzo di vendita. Copre margine, spese generali e profitto.';

  @override
  String get helpSupportFaqSetupQuestion =>
      'Cos\'è una tariffa di configurazione?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Una tariffa di configurazione è un costo fisso per lavoro per calibrazione, preparazione macchina e amministrazione. Aiuta le stampe piccole a coprire le spese generali.';

  @override
  String get helpSupportLinksTitle => 'Link';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Informativa sulla privacy';

  @override
  String get helpSupportTermsOfUseLabel => 'Termini di utilizzo';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'Informazioni';

  @override
  String get helpSupportAboutIntro =>
      'Il Calcolatore Costi Stampa 3D è costruito per prezzi local-first. Aiuta i creatori e le piccole imprese di stampa a quotare lavori con meno sorprese.';

  @override
  String get helpSupportTrustNoAccounts => 'Nessun account';

  @override
  String get helpSupportTrustNoCloudSync => 'Nessuna sincronizzazione cloud';

  @override
  String get helpSupportTrustNoTracking => 'Nessun tracciamento';

  @override
  String get helpSupportTrustLocalData => 'Dati locali';

  @override
  String get helpSupportAboutCalculator =>
      'Il calcolatore combina costo filamento, elettricità, rischio guasto, lavoro e strumenti di prezzi opzionali come ricarico e tariffe di configurazione.';

  @override
  String get helpSupportAboutOutcome =>
      'Questo mantiene le quotazioni legate al costo reale, non solo alla spesa materiale.';

  @override
  String get supportEmailPrefix => 'Per qualsiasi problema, scrivimi a ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Includi il tuo ID di supporto: ';

  @override
  String get supportEmailSubject => 'Supporto 3D Print Cost Calculator';

  @override
  String get clickToCopy => '(tocca per copiare)';

  @override
  String get materialWeightExplanation =>
      'Il peso del materiale è il peso totale del materiale di origine, quindi dell\'intero rotolo di filamento. Il costo è quello dell\'intera unità.';

  @override
  String get supportIdCopied => 'ID di supporto copiato';

  @override
  String get exportSuccess => 'Esportazione riuscita';

  @override
  String get exportError => 'Esportazione non riuscita';

  @override
  String get exportButton => 'Esporta';

  @override
  String get privacyPolicyLink => 'Informativa sulla privacy';

  @override
  String get websiteLink => 'Sito web';

  @override
  String get termsOfUseLink => 'Termini di utilizzo';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Chiudi';

  @override
  String get cancelFeedbackPromptTitle =>
      'Sembra che tu abbia disattivato il rinnovo. Ti va di dirci perché?';

  @override
  String get feedbackSubmitButton => 'Invia feedback';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Troppo costoso';

  @override
  String get cancelFeedbackReasonMissingFeatures => 'Funzioni mancanti';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'Valore non sufficiente';

  @override
  String get cancelFeedbackReasonConfusingToUse => 'Confuso da usare';

  @override
  String get cancelFeedbackReasonJustTesting => 'Stavo solo provando l’app';

  @override
  String get cancelFeedbackReasonOther => 'Altro';

  @override
  String get testDataToolsTitle => 'Strumenti dati di test';

  @override
  String get testDataToolsBody =>
      'Queste azioni sono solo per i test locali. Il popolamento sostituisce l\'attuale configurazione locale con dati demo. La pulizia rimuove in modo permanente i dati locali dell\'app su questo dispositivo.';

  @override
  String get seedTestDataButton => 'Popola dati di test';

  @override
  String get purgeLocalDataButton => 'Elimina dati locali';

  @override
  String get enablePremiumButton => 'Attiva premium';

  @override
  String get forceUpdateAvailableButton => 'Forza aggiornamento disponibile';

  @override
  String get forceNoUpdateButton => 'Forza nessun aggiornamento';

  @override
  String get clearUpdateCooldownButton => 'Cancella attesa aggiornamento';

  @override
  String get previewCancelFeedbackButton => 'Anteprima feedback annullamento';

  @override
  String get enableBatchCostingButton => 'Enable batch costing';

  @override
  String get showWhatsNewButton => 'Show What\'s New';

  @override
  String get enablePremiumTitle => 'Attiva premium';

  @override
  String get enablePremiumBody =>
      'Inserisci il codice di conferma per attivare i test premium locali';

  @override
  String get invalidConfirmationCodeMessage => 'Codice di conferma non valido';

  @override
  String get seedTestDataConfirmTitle => 'Popolare i dati di test?';

  @override
  String get seedTestDataConfirmBody =>
      'Questo sostituirà l\'attuale configurazione locale con dati demo deterministici.';

  @override
  String get purgeLocalDataConfirmTitle => 'Eliminare i dati locali?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Questo rimuoverà in modo permanente tutti i dati locali dell\'app su questo dispositivo.';

  @override
  String get testDataSeededMessage => 'Dati di test popolati';

  @override
  String get testDataPurgedMessage => 'Dati locali eliminati';

  @override
  String get testDataActionFailedMessage =>
      'Operazione sui dati di test non riuscita';

  @override
  String get updatePromptTitle => 'Aggiornamento disponibile';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'La versione $storeVersion è disponibile. Hai installato $currentVersion.';
  }

  @override
  String get updatePromptBodyUnknown =>
      'È disponibile una versione più recente.';

  @override
  String get updatePromptOpenStoreButton => 'Apri store';

  @override
  String get mailClientError => 'Impossibile aprire il client di posta';

  @override
  String get offeringsError => 'Errore: ';

  @override
  String get currentOfferings => 'Offerte attuali';

  @override
  String get purchaseError =>
      'Si è verificato un errore durante l\'elaborazione dell\'acquisto. Riprova più tardi.';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get printersHeader => 'Stampanti';

  @override
  String get materialsHeader => 'Materiali';

  @override
  String get filamentCostLabel => 'Filamento';

  @override
  String get labourCostLabel => 'Lavoro';

  @override
  String get additionalCostLabel => 'Costo aggiuntivo';

  @override
  String get additionalCostNoteLabel => 'Nota costo aggiuntivo';

  @override
  String get additionalCostNoteDialogTitle => 'Nota costo aggiuntivo';

  @override
  String get riskCostLabel => 'Rischio';

  @override
  String get totalCostLabel => 'Totale';

  @override
  String get costTotalLabel => 'Costo totale';

  @override
  String get markupLabel => 'Ricarico';

  @override
  String get setupFeeLabel => 'Costo di configurazione';

  @override
  String get roundingAdjustmentLabel => 'Aggiustamento arrotondamento';

  @override
  String get finalPriceLabel => 'Prezzo finale';

  @override
  String get jobPricingOverridesLabel => 'Impostazioni lavoro';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# override applicati',
      one: '# override applicato',
    );
    return '$_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => '% ricarico';

  @override
  String get pricingSetupFeeLabel => 'Costo di configurazione';

  @override
  String get pricingRoundingLabel => 'Arrotondamento';

  @override
  String get pricingRoundingNoneLabel => 'Nessuno';

  @override
  String get pricingRoundingWholeDollarLabel => 'Unità intera';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Termina con .99';

  @override
  String get currencySymbolLabel => 'Simbolo valuta';

  @override
  String get currencyPositionLabel => 'Posizione del simbolo';

  @override
  String get currencyPositionBeforeLabel => 'Prima';

  @override
  String get currencyPositionAfterLabel => 'Dopo';

  @override
  String get currencySpacingLabel => 'Spazio con simbolo';

  @override
  String get currencyPreviewLabel => 'Anteprima';

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
  String get workCostsLabel => 'Costi del lavoro';

  @override
  String get enterNumber => 'Inserisci un numero';

  @override
  String get invalidNumber => 'Numero non valido';

  @override
  String get validationRequired => 'Obbligatorio';

  @override
  String get validationEnterValidNumber => 'Inserisci un numero valido';

  @override
  String get validationMustBeGreaterThanZero => 'Deve essere maggiore di 0';

  @override
  String get validationMustBeZeroOrMore => 'Deve essere 0 o maggiore';

  @override
  String get lockedValuePlaceholder => 'Bloccato';

  @override
  String get hideProPromotionsTitle => 'Nascondi promozioni Pro';

  @override
  String get hideProPromotionsSubtitle =>
      'Nascondi banner e richieste di aggiornamento';

  @override
  String get historySearchHint => 'Cerca per nome o stampante';

  @override
  String get historyExportMenuTitle => 'Esporta stampe';

  @override
  String get historyExportRangeAll => 'Tutto';

  @override
  String get historyExportRangeLast7Days => 'Ultimi 7 giorni';

  @override
  String get historyExportRangeLast30Days => 'Ultimi 30 giorni';

  @override
  String get historyEmptyTitle => 'Nessuna stampa salvata';

  @override
  String get historyEmptyDescription =>
      'Riutilizza le stampe passate nel calcolatore';

  @override
  String get historyUpsellTitle => 'Riutilizza subito le stampe passate';

  @override
  String get historyUpsellDescription =>
      'Sblocca modifiche avanzate ed esportazioni';

  @override
  String get historyNoMoreRecords => 'Nessun altro record';

  @override
  String get historyOverflowHint => 'Altre azioni in ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Impossibile caricare la cronologia: $error';
  }

  @override
  String get historyCsvHeader =>
      'Data,Stampante,Materiale,Materiali,Peso (g),Tempo,Energia,Filamento,Manodopera,Rischio,Totale,% ricarico,Importo ricarico,Costo di configurazione,Modalità di arrotondamento,Subtotale prima dell\'arrotondamento,Aggiustamento arrotondamento,Prezzo finale';

  @override
  String get historyExportShareText =>
      'Esportazione della cronologia dei costi di stampa 3D';

  @override
  String get historyTeaserTitle =>
      'Conserva ogni preventivo di stampa in un unico posto';

  @override
  String get historyTeaserDescription =>
      'Scopri come funziona la cronologia prima di passare a Pro. Salva i preventivi completati ed esportali in qualsiasi momento con Pro.';

  @override
  String get historyTeaserCta => 'Salva ed esporta la cronologia con Pro';

  @override
  String get historyExportPreviewEntry => 'Anteprima esportazione CSV';

  @override
  String get historyExportPreviewTitle => 'Anteprima CSV';

  @override
  String get historyExportPreviewDescription =>
      'Vedi come apparirà la tua esportazione. Download e condivisione sono sbloccati con Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Esempio]';

  @override
  String get historyExportPreviewAction => 'Scarica / Condividi con Pro';

  @override
  String get addMaterialButton => 'Aggiungi materiale';

  @override
  String get useSingleTotalWeightAction => 'Usa peso totale singolo';

  @override
  String get addAtLeastOneMaterial => 'Aggiungi almeno un materiale.';

  @override
  String get searchMaterialsHint => 'Cerca nome o marca';

  @override
  String get materialBreakdownLabel => 'Dettaglio materiali';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# materiali',
      one: '# materiale',
    );
    return '$_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Peso totale materiale: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Versione $version';
  }

  @override
  String get materialFallback => 'Materiale';

  @override
  String get durationPickerLabel => 'Tempo di stampa (hh:mm)';

  @override
  String get importGcodeButton => 'Importa G-code (Compilazione auto)';

  @override
  String get importGcodePageTitle => 'Importa G-code (Beta)';

  @override
  String get importGcodeIntro =>
      'Scegli un file .gcode locale. Slicer supportati: PrusaSlicer, OrcaSlicer, Bambu Studio e Cura.';

  @override
  String get importGcodeSelectFileButton => 'Scegli file G-code';

  @override
  String get importGcodePickAnotherButton => 'Scegli un altro file';

  @override
  String get importGcodeSelectedFileLabel => 'File selezionato';

  @override
  String get gcodeImportFeedbackTitle => 'Feedback Importazione G-code Beta';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Funzionalità beta';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Raccontaci cosa ha funzionato, cosa è fallita o cosa sembra ancora sbagliato.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Quale slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Risultato anteprima';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Risultato metadati';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'Cosa ha funzionato, cosa è fallita o cosa sembra sbagliato?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Allega file G-code importato';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'Nessun file G-code importato disponibile.';

  @override
  String get gcodeImportFeedbackSendCta => 'Invia feedback';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback inviato';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Anteprima caricata';

  @override
  String get gcodeFeedbackPreviewMissing => 'Anteprima mancante';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Anteprima errata';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Non sicuro';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Sembra corretto';

  @override
  String get gcodeFeedbackMetadataMissing => 'Dati mancanti';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Dati errati';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Non sicuro';

  @override
  String get importGcodeSummaryTitle => 'Riepilogo importazione';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Slicer supportati: PrusaSlicer, OrcaSlicer, Bambu Studio e Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'I valori importati precompilano solo tempo e peso totale del materiale. Stampante, materiale e costo finale provengono dalle impostazioni del calcolatore.';

  @override
  String get importGcodeUseValuesButton => 'Usa questi valori';

  @override
  String get importGcodeQuantityLabel => 'Quantità';

  @override
  String get importGcodeCreateBatchButton => 'Crea batch';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'La creazione del batch richiede durata e peso del filamento rilevati.';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Durata stimata';

  @override
  String get importGcodeFilamentWeightLabel => 'Peso filamento';

  @override
  String get importGcodeFilamentLengthLabel => 'Lunghezza filamento';

  @override
  String get importGcodeLayerHeightLabel => 'Altezza layer';

  @override
  String get importGcodePreviewLabel => 'Anteprima';

  @override
  String get importGcodePreviewAvailable => 'Disponibile';

  @override
  String get importGcodePreviewView => 'Visualizza';

  @override
  String get importGcodePreviewUnavailable => 'Nessuna anteprima';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Metadati anteprima trovati ma l\'immagine non poteva essere visualizzata.';

  @override
  String get importGcodePreviewCuraNote =>
      'Le anteprime Cura potrebbero richiedere uno script post-elaborazione per incorporare le miniature.';

  @override
  String get importGcodeWarningsTitle => 'Avvisi';

  @override
  String get importGcodeUnsupportedTypeError =>
      'Questo file non sembra un file G-code supportato.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Questo file non sembra un file G-code supportato.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'Questo file è troppo grande da importare. Scegli un file più piccolo di $maxSizeMb MB.';
  }

  @override
  String get importGcodeReadError =>
      'Il file selezionato non poteva essere letto.';

  @override
  String get importGcodeUnknownSlicerValue => 'Sconosciuto';

  @override
  String get importGcodeMissingValue => 'Non trovato';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer non identificato. Rivedi i valori prima di applicare.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Il tempo di stampa non poteva essere rilevato.';

  @override
  String get importGcodeWarningMissingFilament =>
      'Uso del filamento incompleto.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Peso del filamento mancante.';

  @override
  String get importGcodeWarningPartialMetadata => 'Alcuni metadati mancano.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Trovati più totali materiale. Rivedi prima di applicare.';

  @override
  String get importGcodeAppliedMessage =>
      'Valori importati applicati al calcolatore';

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
  String get slicerOther => 'Altro';

  @override
  String get slicerUnknown => 'Sconosciuto';

  @override
  String get materialsAppBarTitle => 'Materiali';

  @override
  String get materialsNavLabel => 'Materiali';

  @override
  String get brandLabel => 'Marca';

  @override
  String get materialTypeLabel => 'Tipo di materiale';

  @override
  String get colorHexLabel => 'Hex colore (opzionale)';

  @override
  String get notesLabel => 'Note';

  @override
  String get materialsEmpty =>
      'Nessun materiale ancora. Tocca + per aggiungerne uno.';

  @override
  String get materialsFilterAll => 'Tutti';

  @override
  String get materialsFilterInStock => 'Disponibile';

  @override
  String get materialsFilterLowStock => 'Scorte basse';

  @override
  String get materialsFilterOutOfStock => 'Esaurito';

  @override
  String get csvImportTitle => 'Importa materiali';

  @override
  String get csvTemplateButton => 'Modello';

  @override
  String get csvTemplateShareText => 'Modello CSV materiali';

  @override
  String get csvTemplateError => 'Impossibile condividere il modello.';

  @override
  String get csvImportIntro => 'Importa materiali da un file CSV.';

  @override
  String get csvSelectFileButton => 'Scegli file CSV';

  @override
  String get csvImportButton => 'Importa righe valide';

  @override
  String get csvReadError => 'Il file selezionato non può essere letto.';

  @override
  String get csvFileTypeError => 'Seleziona un file .csv';

  @override
  String get csvNameRequiredError => 'Il nome è obbligatorio';

  @override
  String get csvColorRequiredError => 'Il colore è obbligatorio';

  @override
  String get csvSpoolWeightRequiredError =>
      'Il peso della bobina è obbligatorio';

  @override
  String get csvSpoolWeightPositiveError =>
      'Il peso della bobina deve essere > 0';

  @override
  String get csvCostRequiredError => 'Il costo è obbligatorio';

  @override
  String get csvCostPositiveError => 'Il costo deve essere > 0';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiali importati',
      one: '1 materiale importato',
    );
    return '$_temp0';
  }

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total righe: $valid valide, $invalid con errori';
  }

  @override
  String get csvEmptyNamePlaceholder => '(vuoto)';

  @override
  String get editButton => 'Modifica';

  @override
  String get duplicateButton => 'Duplica';

  @override
  String get duplicateMaterialSuccessMessage => 'Materiale duplicato';

  @override
  String get duplicateMaterialErrorMessage =>
      'Errore durante la duplicazione del materiale';

  @override
  String get materialsSwipeHint =>
      'Scorri un materiale per modificare, duplicare o eliminare.';

  @override
  String get stockBadgeOut => 'Esaurito';

  @override
  String get stockBadgeLow => 'Scorta bassa';

  @override
  String get stockBadgeInStock => 'Disponibile';

  @override
  String get stockBadgeNoTracking => 'Non tracciato';

  @override
  String get batchCostingReviewAppBarTitle => 'Revisione articoli batch';

  @override
  String get batchCostingReviewSubtitle =>
      'Rivedi gli articoli batch prima dell\'assegnazione stampante.';

  @override
  String get batchCostingReviewEmptyTitle => 'Nessun articolo batch ancora';

  @override
  String get batchCostingReviewEmptyBody =>
      'Aggiungi stampe importate o manuali per continuare.';

  @override
  String get batchCostingReviewContinueButton =>
      'Continua all\'assegnazione stampante';

  @override
  String get batchCostingReviewQuantityLabel => 'Quantità';

  @override
  String get batchCostingReviewRemoveButton => 'Rimuovi';

  @override
  String get batchCostingReviewSourceLabel => 'Origine';

  @override
  String get batchCostingReviewSourceManual => 'Manuale';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => 'Sconosciuto';

  @override
  String get batchCostingReviewWeightLabel => 'Peso';

  @override
  String get batchCostingReviewDurationLabel => 'Durata';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle =>
      'Assegnazione stampante';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'L\'assegnazione stampante continua nel prossimo passaggio.';
}
