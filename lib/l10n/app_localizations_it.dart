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
  String get resultElectricityRated => 'Elettricità (Nominale)';

  @override
  String get resultElectricityAverage => 'Elettricità (Media)';

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
  String get wattageLabel => 'Potenza (Nominale) *';

  @override
  String get averageWattageLabel => 'Potenza (Media)';

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
  String get millimetersSuffix => 'mm';

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
  String get wattageFaqHint => 'See FAQ for wattage details';

  @override
  String get helpSupportFaqWattageQuestion =>
      'Rated vs Average wattage — what\'s the difference?';

  @override
  String get helpSupportFaqWattageAnswer =>
      'Rated wattage is the maximum your printer can draw from the wall (printed on the nameplate). Average wattage is its typical power during a print, ideally measured with a plug-in meter. Use Average for accurate electricity cost, or Rated as a safe upper bound.';

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
  String get enableBatchCostingButton => 'Attiva costing batch';

  @override
  String get batchCostingSummarySaveButton => 'Salva preventivo';

  @override
  String get batchCostingSummarySaveSuccessTitle => 'Preventivo salvato';

  @override
  String get batchCostingSummarySaveSuccessBody => 'Salvato nella cronologia.';

  @override
  String get batchCostingSummaryViewHistoryButton => 'Vedi cronologia';

  @override
  String get batchCostingSummarySaveErrorMessage =>
      'Impossibile salvare il preventivo';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'Preventivo batch';

  @override
  String get batchCostingSummaryQuoteNameDialogTitle =>
      'Dai un nome al tuo preventivo';

  @override
  String get batchCostingSummaryQuoteNameHint => 'Nome preventivo';

  @override
  String get batchHistoryItemsTitle => 'Articoli batch';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'articoli',
      one: 'articolo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalQuantity,
      locale: localeName,
      other: 'copie',
      one: 'copia',
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
  String get costTotalLabel => 'Costo';

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
      other: 'override applicati',
      one: 'override applicato',
    );
    return '$count $_temp0';
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
  String get lockedValuePlaceholder => 'Solo Premium';

  @override
  String get printerLimitReachedMessage =>
      'Puoi salvare fino a 2 stampanti su Free. Passa a Premium per stampanti illimitate.';

  @override
  String get materialLimitReachedMessage =>
      'Puoi salvare fino a 5 materiali su Free. Passa a Premium per materiali illimitati.';

  @override
  String get batchItemLimitReachedMessage =>
      'Puoi aggiungere fino a 3 elementi batch su Free. Passa a Premium per elementi batch illimitati.';

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
      'Puoi conservare fino a 7 stampe salvate su Free. Passa a Premium per cronologia ed esportazioni illimitate.';

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
  String get batchQuoteExportShareText =>
      'Esportazione preventivo batch stampa 3D';

  @override
  String get mixedHistoryExportShareText =>
      'Esportazione della cronologia dei costi di stampa 3D';

  @override
  String get historyTeaserTitle =>
      'Conserva ogni preventivo di stampa in un unico posto';

  @override
  String get historyTeaserDescription =>
      'Gli utenti Free possono conservare fino a 7 stampe salvate. Passa a Premium per cronologia ed esportazioni illimitate.';

  @override
  String get historyTeaserCta => 'Passa a Premium per cronologia illimitata';

  @override
  String get historyExportPreviewEntry => 'Anteprima esportazione CSV';

  @override
  String get historyExportPreviewTitle => 'Anteprima CSV';

  @override
  String get historyExportPreviewDescription =>
      'L\'esportazione in blocco della cronologia è una funzione Premium. Download e condivisione si sbloccano con Premium.';

  @override
  String get historyExportPreviewSampleLabel => '[Esempio]';

  @override
  String get historyExportPreviewAction => 'Scarica / Condividi con Premium';

  @override
  String get unsavedMaterialOptionLabel => 'Materiale non salvato';

  @override
  String get unsavedMaterialHeader => 'Materiale personalizzato';

  @override
  String get customMaterialWeightLabel => 'Peso';

  @override
  String get customMaterialCostLabel => 'Costo';

  @override
  String get customMaterialUsedLabel => 'Usato';

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
      other: 'materiali',
      one: 'materiale',
    );
    return '$count $_temp0';
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
  String get csvNoValidRowsError => 'Nessuna riga valida da importare.';

  @override
  String get csvImportQuotaExceededError =>
      'Questa importazione supera il tuo limite di materiali.';

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
  String get batchCostingReviewAddManualItemButton =>
      'Aggiungi articolo manuale';

  @override
  String get batchCostingReviewEmptyTitle => 'Nessun articolo batch ancora';

  @override
  String get batchCostingReviewEmptyBody =>
      'Aggiungi stampe manuali per continuare.';

  @override
  String get batchCostingReviewImportGcodeButton => 'Importa file G-code';

  @override
  String get batchCostingReviewImportGcodeButtonPremium =>
      'Importa file G-code (Premium)';

  @override
  String get batchGcodeImportTitle => 'Importa G-code batch';

  @override
  String get batchGcodeImportBody =>
      'Scegli uno o più file G-code. Ogni file viene analizzato separatamente.';

  @override
  String get batchGcodeImportPickButton => 'Scegli file';

  @override
  String get batchGcodeImportSuccessLabel => 'Importato con successo';

  @override
  String get batchGcodeImportFailureLabel => 'Importazione fallita';

  @override
  String get batchGcodeImportParseFailure =>
      'Questo file non può essere importato.';

  @override
  String get batchGcodeImportContinueButton => 'Continua alla revisione batch';

  @override
  String get batchGcodeImportRetryButton => 'Scegli di nuovo';

  @override
  String get batchGcodeImportImportingLabel => 'Importazione…';

  @override
  String get batchGcodeImportPendingLabel => 'In attesa';

  @override
  String get batchGcodeImportNeedsDetailsLabel => 'Dettagli necessari';

  @override
  String get batchGcodeImportReadyLabel => 'Pronto';

  @override
  String get batchGcodeImportNeedsWeight => 'Peso richiesto';

  @override
  String get batchGcodeImportNeedsDuration => 'Durata richiesta';

  @override
  String get batchGcodeImportApply => 'Applica';

  @override
  String get batchGcodeImportAddButton => 'Aggiungi alla revisione batch';

  @override
  String get batchGcodeImportDetailsButton => 'Dettagli';

  @override
  String get batchGcodeImportDuplicateMessage =>
      'Alcuni file sono già stati aggiunti.';

  @override
  String get batchGcodeImportQuantityHint =>
      'Le quantità possono essere regolate nel passaggio successivo.';

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
  String get batchCostingReviewWeightRequired => 'Peso richiesto';

  @override
  String get batchCostingReviewDurationRequired => 'Durata richiesta';

  @override
  String get batchCostingReviewMissingFieldsError =>
      'Completa i campi obbligatori';

  @override
  String get batchCostingItemEditorAddTitle => 'Aggiungi articolo manuale';

  @override
  String get batchCostingItemEditorEditTitle => 'Modifica articolo batch';

  @override
  String get batchCostingItemNameLabel => 'Nome articolo / modello';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle =>
      'Assegnazione stampante';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Assegna le stampanti prima dei materiali.';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'Intero batch';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => 'Per elemento';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'Scegli una stampante per tutti gli elementi.';

  @override
  String get batchCostingPrinterAssignmentPerItemHint =>
      'Scegli una stampante per questo elemento.';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'Dividi copie';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return 'Dividi le copie per $itemName';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return 'Il totale deve essere uguale a $total';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      'Le assegnazioni sono state reimpostate perché la quantità è cambiata.';

  @override
  String get batchCostingAssignmentCopiesLabel => 'Copie';

  @override
  String get batchCostingAllocationPickerSearchLabel => 'Cerca opzioni';

  @override
  String get batchCostingAllocationPickerAvailableLabel => 'Disponibile';

  @override
  String get batchCostingAllocationPickerSelectedLabel => 'Selezionato';

  @override
  String get batchCostingAllocationPickerAddButton => 'Aggiungi';

  @override
  String get batchCostingAllocationPickerNoResultsLabel => 'Nessun risultato.';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      'Scegli una stampante per continuare.';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => 'Precedente';

  @override
  String get batchCostingPrinterAssignmentNextButton => 'Successivo';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'Non ci sono ancora stampanti disponibili.';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle =>
      'Assegnazione materiale';

  @override
  String get batchCostingMaterialAssignmentSubtitle =>
      'Assegna materiali o bobine prima del prezzo.';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel =>
      'Materiale o bobina';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'Intero batch';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'Per elemento';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'Scegli un materiale per tutti gli elementi.';

  @override
  String get batchCostingMaterialAssignmentPerItemHint =>
      'Scegli un materiale per questo elemento.';

  @override
  String get batchCostingMaterialAssignmentRequiredError =>
      'Scegli un materiale per continuare.';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => 'Precedente';

  @override
  String get batchCostingMaterialAssignmentNextButton => 'Successivo';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      'Aggiungi almeno un materiale o una bobina per continuare.';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return 'Il richiesto $required supera lo stock selezionato $available.';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => 'Ambito prezzo';

  @override
  String get batchCostingPricingScopeSubtitle =>
      'Imposta dove si applica ogni valore di prezzo.';

  @override
  String get batchCostingPricingScopeItemMode => 'Voce';

  @override
  String get batchCostingPricingScopeBatchMode => 'Batch';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => 'Voce (per copia)';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'Batch (una volta)';

  @override
  String get batchCostingPricingScopeScopeLabel => 'Ambito';

  @override
  String get batchCostingSummaryAppBarTitle => 'Riepilogo batch';

  @override
  String get batchCostingSummarySubtitle =>
      'Rivedi il batch prima di generare un preventivo.';

  @override
  String get batchCostingSummaryOverviewTitle => 'Panoramica';

  @override
  String get batchCostingSummaryItemCountLabel => 'Elementi';

  @override
  String get batchCostingSummaryTotalQuantityLabel => 'Quantità totale';

  @override
  String get batchCostingSummaryTotalWeightLabel => 'Peso totale';

  @override
  String get batchCostingSummaryTotalDurationLabel => 'Tempo di stampa totale';

  @override
  String get batchCostingSummaryItemWeightLabel => 'Peso';

  @override
  String get batchCostingSummaryItemDurationLabel => 'Tempo di stampa';

  @override
  String get batchCostingSummaryItemBaseCostLabel => 'Costo base';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => 'Aggiustamenti';

  @override
  String get batchCostingSummaryItemTotalLabel => 'Totale elemento';

  @override
  String get batchCostingSummaryFinalTotalLabel => 'Totale finale';

  @override
  String get batchCostingSummaryBackButton => 'Torna all\'ambito prezzo';

  @override
  String get batchCostingSummaryReturnToCalculatorButton =>
      'Torna al calcolatore';

  @override
  String get batchCostingSummaryStartNewBatchButton => 'Avvia nuovo batch';

  @override
  String get batchCostingSummaryEmptyTitle => 'Nessun riepilogo batch';

  @override
  String get batchCostingSummaryEmptyBody =>
      'Aggiungi elementi e imposta l\'ambito prezzo prima di rivedere il riepilogo.';

  @override
  String get batchCostingSummaryPricingTitle => 'Prezzi';

  @override
  String get batchCostingSummaryItemsTitle => 'Elementi';

  @override
  String get batchCostingNewBatchDialogTitle => 'Avvia nuovo batch';

  @override
  String get batchCostingNewBatchDialogBody =>
      'Questo eliminerà tutti i progressi correnti del batch. Avviare un nuovo batch?';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnit ciascuno → $lineTotal totale';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'Stampante';

  @override
  String get batchCostingEntryButton => 'Avvia preventivo batch';

  @override
  String get paywallTitle => 'Sblocca Premium';

  @override
  String get paywallPitchLine =>
      'Materiali illimitati, stampanti illimitate, esportazione batch, prezzi avanzati';

  @override
  String get paywallSubtitle =>
      'Sblocca tutte le funzionalità con un acquisto una tantum o un abbonamento. Nessun account, nessun tracciamento, solo i tuoi dati sul tuo dispositivo.';

  @override
  String get paywallOfferingError =>
      'Impossibile caricare i pacchetti. Controlla la connessione e riprova.';

  @override
  String get paywallCta => 'Sblocca Premium';

  @override
  String get paywallRestore => 'Ripristina acquisti';

  @override
  String get paywallRowPrintersLabel => 'Stampanti';

  @override
  String get paywallRowMaterialsLabel => 'Materiali';

  @override
  String get paywallRowHistoryLabel => 'Salvataggi cronologia';

  @override
  String get paywallRowBatchCostingLabel => 'Calcolo batch';

  @override
  String get paywallRowAdvancedPricingLabel => 'Prezzi avanzati';

  @override
  String get paywallRowExportToolsLabel => 'Strumenti di esportazione';

  @override
  String get paywallRowInventoryTrackingLabel => 'Tracciamento inventario';

  @override
  String get paywallValueUnlimited => 'Illimitati';

  @override
  String get paywallValueYes => 'Sì';

  @override
  String get paywallValueNo => 'No';

  @override
  String get paywallValueBasic => 'Base';

  @override
  String get paywallValueFull => 'Completo';

  @override
  String get paywallValueSingleJob => 'Lavoro singolo';

  @override
  String get paywallValueFullSuite => 'Suite completa';

  @override
  String paywallValueUpToModels(Object limit) {
    return 'Fino a $limit modelli';
  }

  @override
  String get paywallBestValue => 'Miglior valore';

  @override
  String get paywallPlanMonthly => 'Mensile';

  @override
  String get paywallPlanQuarterly => 'Trimestrale';

  @override
  String get paywallPlanAnnual => 'Annuale';

  @override
  String get paywallPlanLifetime => 'A vita';

  @override
  String paywallPlanPriceMonthly(Object price) {
    return '$price / mese';
  }

  @override
  String paywallPlanPriceQuarterly(Object price) {
    return '$price / 3 mesi';
  }

  @override
  String paywallPlanPriceAnnual(Object price) {
    return '$price / anno';
  }

  @override
  String paywallPlanPriceLifetime(Object price) {
    return '$price una volta';
  }

  @override
  String get paywallPlanTrial => 'Prova gratuita di 7 giorni';

  @override
  String get paywallPlanCancelAnytime => 'Annulla in qualsiasi momento';

  @override
  String get paywallPlanOwnForever => 'Premium per sempre';

  @override
  String get paywallTrustLine => 'Prima offline • Nessun account richiesto';

  @override
  String get paywallCtaAnnualTrial => 'Inizia la prova gratuita di 7 giorni';

  @override
  String paywallCtaQuarterly(Object price) {
    return 'Aggiorna per $price';
  }

  @override
  String paywallCtaLifetime(Object price) {
    return 'Sblocca Premium per $price';
  }

  @override
  String paywallCtaGeneric(Object price) {
    return 'Aggiorna per $price';
  }

  @override
  String paywallValueSaves(Object limit) {
    return '$limit salvataggi';
  }

  @override
  String get paywallFeatureMaterialsTitle => 'Materiali illimitati';

  @override
  String get paywallFeatureMaterialsDesc =>
      'Salva e gestisci bobine di filamento e materiali illimitati.';

  @override
  String get paywallFeaturePrintersTitle => 'Stampanti illimitate';

  @override
  String get paywallFeaturePrintersDesc =>
      'Crea e gestisci profili stampante illimitati.';

  @override
  String get paywallFeatureHistoryExportTitle => 'Esportazione cronologia';

  @override
  String get paywallFeatureHistoryExportDesc =>
      'Esporta singole voci della cronologia in CSV.';

  @override
  String get paywallFeatureBulkHistoryExportTitle =>
      'Esportazione massiva della cronologia';

  @override
  String get paywallFeatureBulkHistoryExportDesc =>
      'Esporta tutta la cronologia in una volta in CSV.';

  @override
  String get paywallFeatureBatchGcodeImportTitle => 'Importazione batch G-code';

  @override
  String get paywallFeatureBatchGcodeImportDesc =>
      'Importa più file G-code in una volta per il calcolo batch.';

  @override
  String get paywallFeatureBatchExportTitle => 'Esportazione batch';

  @override
  String get paywallFeatureBatchExportDesc =>
      'Esporta preventivi batch e riepiloghi.';

  @override
  String get paywallFeatureLabourPricingTitle => 'Prezzi della manodopera';

  @override
  String get paywallFeatureLabourPricingDesc =>
      'Aggiungi tariffe orarie di manodopera ai calcoli dei costi.';

  @override
  String get paywallFeatureRiskPricingTitle => 'Prezzi del rischio';

  @override
  String get paywallFeatureRiskPricingDesc =>
      'Includi automaticamente il rischio di errore nei prezzi.';

  @override
  String get paywallFeatureAdvancedPricingConfigTitle => 'Prezzi avanzati';

  @override
  String get paywallFeatureAdvancedPricingConfigDesc =>
      'Configura ricarico, costi di configurazione e arrotondamento.';

  @override
  String get paywallFeatureCsvMaterialImportTitle =>
      'Importazione materiali CSV';

  @override
  String get paywallFeatureCsvMaterialImportDesc =>
      'Importa materiali in blocco da file CSV.';

  @override
  String get paywallFeatureStockTrackingTitle => 'Tracciamento scorte';

  @override
  String get paywallFeatureStockTrackingDesc =>
      'Tieni traccia delle scorte di filamento e ricevi avvisi di scorta bassa.';

  @override
  String get paywallRestoreSuccess => 'Acquisti ripristinati con successo.';

  @override
  String get paywallRestoreError =>
      'Impossibile ripristinare gli acquisti. Riprova più tardi.';

  @override
  String get paywallEmptyOfferings =>
      'Al momento non sono disponibili piani di abbonamento. Riprova più tardi.';
}
