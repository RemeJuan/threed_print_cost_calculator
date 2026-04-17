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
  String get generalHeader => 'Generale';

  @override
  String get wattLabel => 'Watt (stampante 3D)';

  @override
  String get printWeightLabel => 'Peso della stampa';

  @override
  String get hoursLabel => 'Tempo di stampa (ore)';

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
  String get savePrintSuccessMessage => 'Stampa salvata';

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
  String get supportEmailPrefix => 'Per qualsiasi problema, scrivimi a ';

  @override
  String get supportEmail => 'google@remej.dev';

  @override
  String get supportIdLabel => 'Includi il tuo ID di supporto: ';

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
  String get termsOfUseLink => 'Termini di utilizzo';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Chiudi';

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
  String get riskCostLabel => 'Rischio';

  @override
  String get totalCostLabel => 'Totale';

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
      'Data,Stampante,Materiale,Materiali,Peso (g),Tempo,Energia,Filamento,Manodopera,Rischio,Totale';

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
  String get searchMaterialsHint => 'Cerca materiali';

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
}
