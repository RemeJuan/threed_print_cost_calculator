// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get calculatorAppBarTitle => '3D-Druck-Rechner';

  @override
  String get historyAppBarTitle => 'Verlauf';

  @override
  String get settingsAppBarTitle => 'Einstellungen';

  @override
  String get calculatorNavLabel => 'Rechner';

  @override
  String get historyNavLabel => 'Verlauf';

  @override
  String get settingsNavLabel => 'Einstellungen';

  @override
  String get newAnnouncementBadgeLabel => 'Neu';

  @override
  String get whatsNewSeeRecentUpdates => 'Neueste Updates ansehen';

  @override
  String get generalHeader => 'Allgemein';

  @override
  String get wattLabel => 'Watt (3D-Drucker)';

  @override
  String get printWeightLabel => 'Gewicht des Drucks';

  @override
  String get hoursLabel => 'Druckzeit (Stunden)';

  @override
  String get durationHoursLabel => 'Stunden';

  @override
  String get wearAndTearLabel => 'Materialien/Verschleiß';

  @override
  String get labourRateLabel => 'Stundensatz';

  @override
  String get labourTimeLabel => 'Bearbeitungszeit';

  @override
  String get failureRiskLabel => 'Ausfallrisiko (%)';

  @override
  String get minutesLabel => 'Protokoll';

  @override
  String get durationMinutesLabel => 'Minuten';

  @override
  String get printingTimeDialogTitle => 'Druckzeit';

  @override
  String get workTimeDialogTitle => 'Arbeitszeit';

  @override
  String get spoolWeightLabel => 'Spule/Harzgewicht';

  @override
  String get spoolCostLabel => 'Spulen-/Harzkosten';

  @override
  String get electricityCostLabel => 'Stromkosten';

  @override
  String get electricityCostSettingsLabel => 'Stromkosten';

  @override
  String get submitButton => 'Berechnung';

  @override
  String get resultElectricityPrefix => 'Gesamtkosten für Strom:';

  @override
  String get resultFilamentPrefix => 'Gesamtkosten für Filament:';

  @override
  String get resultTotalPrefix => 'Gesamtkosten: ';

  @override
  String get riskTotalPrefix => 'Risikokosten:';

  @override
  String get premiumHeader => 'Nur Premium-Benutzer:';

  @override
  String get labourCostPrefix => 'Arbeits-/Materialkosten: ';

  @override
  String get selectPrinterHint => 'Drucker auswählen';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Druck speichern';

  @override
  String get printNameHint => 'Name des Drucks';

  @override
  String get printerNameLabel => 'Druckername *';

  @override
  String get bedSizeLabel => 'Druckbettgröße *';

  @override
  String get wattageLabel => 'Leistung *';

  @override
  String get materialNameLabel => 'Materialname *';

  @override
  String get colorLabel => 'Farbe *';

  @override
  String get weightLabel => 'Gewicht *';

  @override
  String get costLabel => 'Kosten *';

  @override
  String get saveButton => 'Speichern';

  @override
  String get deleteDialogTitle => 'Löschen';

  @override
  String get deleteDialogContent =>
      'Möchten Sie dieses Element wirklich löschen?';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get resetButtonLabel => 'Zurücksetzen';

  @override
  String get resetCalculationTitle => 'Berechnung zurücksetzen?';

  @override
  String get resetCalculationBody =>
      'Dadurch werden die aktuellen Rechnerwerte verworfen und die aktuellen Standardwerte neu geladen.';

  @override
  String get deleteButton => 'Löschen';

  @override
  String get selectMaterialHint => 'Benutzerdefiniert (nicht gespeichert)';

  @override
  String get materialNone => 'Keine';

  @override
  String get gramsSuffix => 'g';

  @override
  String get millimetersSuffix => 'mm';

  @override
  String get remainingLabel => 'Verbleibend:';

  @override
  String get trackRemainingFilamentLabel => 'Verbleibendes Filament verfolgen';

  @override
  String get remainingFilamentLabel => 'Verbleibendes Filament';

  @override
  String get savePrintErrorMessage => 'Fehler beim Speichern des Drucks';

  @override
  String get deleteRecordErrorMessage =>
      'Fehler beim Entfernen des Datensatzes';

  @override
  String get savePrintSuccessMessage => 'Druck gespeichert';

  @override
  String get deleteMaterialSuccessMessage => 'Material gelöscht';

  @override
  String get historyLoadAction => 'Im Rechner bearbeiten';

  @override
  String get historyLoadSuccessMessage => 'Aus dem Verlauf geladen';

  @override
  String get historyLoadReplacementWarning =>
      'Einige Elemente waren nicht verfügbar und wurden ersetzt';

  @override
  String get numberExampleHint => 'z. B. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Fehler beim Laden der Materialien: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Fehler beim Laden der Drucker: $error';
  }

  @override
  String get retryButton => 'Erneut versuchen';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Brauchen Sie Hilfe?';

  @override
  String get helpSupportSupportTitle => 'Support';

  @override
  String get helpSupportSupportIntro =>
      'Verwenden Sie diese Details, wenn Sie den Support kontaktieren.';

  @override
  String get helpSupportWebsiteLabel => 'Website';

  @override
  String get helpSupportEmailLabel => 'E-Mail';

  @override
  String get helpSupportSupportIdLabel => 'Support-ID';

  @override
  String get helpSupportCopySupportIdTooltip => 'Support-ID kopieren';

  @override
  String get helpSupportRoadmapLabel => 'Roadmap';

  @override
  String get helpSupportRoadmapValue => 'Ansehen, was als Nächstes kommt';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'App-Version $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Support kontaktieren';

  @override
  String get helpSupportContactEmailSubject => '3D-Druck-Kostenrechner Support';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'Support-ID: $supportId\nApp-Version: $version\n\nBeschreiben Sie hier das Problem.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'Support-ID: (nicht verfügbar)\nApp-Version: $version\n\nBeschreiben Sie hier das Problem.';
  }

  @override
  String get helpSupportFaqTitle => 'Häufig gestellte Fragen';

  @override
  String get helpSupportFaqWeightQuestion =>
      'Welches Gewicht soll ich eingeben?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Geben Sie das Gesamtgewicht der Spule ein, nicht das übriggebliebene Filament. Die App verwendet das volle Rollengewicht zur Berechnung der Kosten pro Gramm.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      'Warum ist Elektrizität wichtig?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Lange Drucke und Drucker mit hoher Wattzahl können echte Kosten verursachen. Elektrizität zu überspringen führt normalerweise zu Unterpreisen.';

  @override
  String get helpSupportFaqRiskQuestion =>
      'Wie wird das Ausfallrisiko berechnet?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'Das Risiko wird nur auf Basisdruck-Kosten wie Filament und Elektrizität angewendet. Es schätzt den erwarteten Verlust durch fehlgeschlagene Drucke.';

  @override
  String get helpSupportFaqLabourQuestion =>
      'Was ist Arbeits-/Bearbeitungszeit?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Es umfasst Vorbereitung, Reinigung, Nachbearbeitung und Überwachung. Lassen Sie es für Dienste eingeschaltet, bei denen Ihre Zeit wichtig ist.';

  @override
  String get helpSupportFaqMarkupQuestion => 'Was ist Aufschlag?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'Aufschlag ist der Prozentsatz, der zu den Gesamtkosten hinzugefügt wird, um Ihren Verkaufspreis zu erreichen. Er deckt Marge, Gemeinkosten und Gewinn ab.';

  @override
  String get helpSupportFaqSetupQuestion => 'Was ist eine Einrichtungsgebühr?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Eine Einrichtungsgebühr ist ein fester Kostenbetrag pro Auftrag für Kalibrierung, Maschinenvorbereitung und Verwaltung. Sie hilft bei kleinen Drucken, Gemeinkosten zu decken.';

  @override
  String get helpSupportLinksTitle => 'Links';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Datenschutzrichtlinie';

  @override
  String get helpSupportTermsOfUseLabel => 'Nutzungsbedingungen';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'Über';

  @override
  String get helpSupportAboutIntro =>
      'Der 3D-Druck-Kostenrechner ist für lokale Preisgestaltung konzipiert. Er hilft Machern und kleinen Druckbetrieben, Arbeiten mit weniger Überraschungen zu kalkulieren.';

  @override
  String get helpSupportTrustNoAccounts => 'Keine Konten';

  @override
  String get helpSupportTrustNoCloudSync => 'Keine Cloud-Synchronisation';

  @override
  String get helpSupportTrustNoTracking => 'Kein Tracking';

  @override
  String get helpSupportTrustLocalData => 'Lokale Daten';

  @override
  String get helpSupportAboutCalculator =>
      'Der Rechner kombiniert Filamentkosten, Elektrizität, Ausfallrisiko, Arbeit und optionale Preisgestaltungstools wie Aufschlag und Einrichtungsgebühren.';

  @override
  String get helpSupportAboutOutcome =>
      'Das hält Angebote an echte Kosten gebunden, nicht nur an Materialausgaben.';

  @override
  String get supportEmailPrefix => 'Bei Problemen schreiben Sie mir bitte an ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Bitte geben Sie Ihre Support-ID an: ';

  @override
  String get supportEmailSubject => 'Support für 3D Print Cost Calculator';

  @override
  String get clickToCopy => '(zum Kopieren klicken)';

  @override
  String get materialWeightExplanation =>
      'Das Materialgewicht ist das Gesamtgewicht des Ausgangsmaterials, also der gesamten Filamentrolle. Die Kosten sind die Kosten der gesamten Einheit.';

  @override
  String get supportIdCopied => 'Support-ID kopiert';

  @override
  String get exportSuccess => 'Export erfolgreich';

  @override
  String get exportError => 'Export fehlgeschlagen';

  @override
  String get exportButton => 'Exportieren';

  @override
  String get privacyPolicyLink => 'Datenschutzrichtlinie';

  @override
  String get websiteLink => 'Webseite';

  @override
  String get termsOfUseLink => 'Nutzungsbedingungen';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Schließen';

  @override
  String get cancelFeedbackPromptTitle =>
      'Du hast die Verlängerung wohl deaktiviert. Magst du uns sagen, warum?';

  @override
  String get feedbackSubmitButton => 'Feedback senden';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Zu teuer';

  @override
  String get cancelFeedbackReasonMissingFeatures => 'Fehlende Funktionen';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'Nicht genug Mehrwert';

  @override
  String get cancelFeedbackReasonConfusingToUse => 'Zu kompliziert';

  @override
  String get cancelFeedbackReasonJustTesting => 'Ich habe die App nur getestet';

  @override
  String get cancelFeedbackReasonOther => 'Sonstiges';

  @override
  String get testDataToolsTitle => 'Testdaten-Tools';

  @override
  String get testDataToolsBody =>
      'Diese Aktionen sind nur für lokale Tests. Das Befüllen ersetzt die aktuelle lokale Einrichtung durch Demo-Daten. Das Löschen entfernt alle lokalen App-Daten dauerhaft von diesem Gerät.';

  @override
  String get seedTestDataButton => 'Testdaten befüllen';

  @override
  String get purgeLocalDataButton => 'Lokale Daten löschen';

  @override
  String get enablePremiumButton => 'Premium aktivieren';

  @override
  String get forceUpdateAvailableButton => 'Update erzwingen';

  @override
  String get forceNoUpdateButton => 'Kein Update erzwingen';

  @override
  String get clearUpdateCooldownButton => 'Update-Wartezeit löschen';

  @override
  String get previewCancelFeedbackButton => 'Rückmeldeansicht zur Verlängerung';

  @override
  String get enableBatchCostingButton => 'Stapelkalkulation aktivieren';

  @override
  String get batchCostingSummarySaveButton => 'Angebot speichern';

  @override
  String get batchCostingSummarySaveSuccessTitle => 'Angebot gespeichert';

  @override
  String get batchCostingSummarySaveSuccessBody => 'Im Verlauf gespeichert.';

  @override
  String get batchCostingSummaryViewHistoryButton => 'Verlauf anzeigen';

  @override
  String get batchCostingSummarySaveErrorMessage =>
      'Angebot konnte nicht gespeichert werden';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'Stapelangebot';

  @override
  String get batchCostingSummaryQuoteNameDialogTitle =>
      'Geben Sie Ihrem Angebot einen Namen';

  @override
  String get batchCostingSummaryQuoteNameHint => 'Angebotsname';

  @override
  String get batchHistoryItemsTitle => 'Stapelpositionen';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'Positionen',
      one: 'Position',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalQuantity,
      locale: localeName,
      other: 'Kopien',
      one: 'Kopie',
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
  String get enablePremiumTitle => 'Premium aktivieren';

  @override
  String get enablePremiumBody =>
      'Bestätigungscode eingeben, um lokale Premium-Tests zu aktivieren';

  @override
  String get invalidConfirmationCodeMessage => 'Ungültiger Bestätigungscode';

  @override
  String get seedTestDataConfirmTitle => 'Testdaten befüllen?';

  @override
  String get seedTestDataConfirmBody =>
      'Dadurch wird die aktuelle lokale Einrichtung durch deterministische Demo-Daten ersetzt.';

  @override
  String get purgeLocalDataConfirmTitle => 'Lokale Daten löschen?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Dadurch werden alle lokalen App-Daten auf diesem Gerät dauerhaft entfernt.';

  @override
  String get testDataSeededMessage => 'Testdaten befüllt';

  @override
  String get testDataPurgedMessage => 'Lokale Daten gelöscht';

  @override
  String get testDataActionFailedMessage => 'Testdatenaktion fehlgeschlagen';

  @override
  String get updatePromptTitle => 'Update verfügbar';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'Version $storeVersion ist verfügbar. Installiert ist $currentVersion.';
  }

  @override
  String get updatePromptBodyUnknown => 'Eine neuere Version ist verfügbar.';

  @override
  String get updatePromptOpenStoreButton => 'Store öffnen';

  @override
  String get mailClientError => 'E-Mail-Client konnte nicht geöffnet werden';

  @override
  String get offeringsError => 'Fehler: ';

  @override
  String get currentOfferings => 'Aktuelle Angebote';

  @override
  String get purchaseError =>
      'Beim Verarbeiten Ihres Kaufs ist ein Fehler aufgetreten. Bitte versuchen Sie es später erneut.';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get printersHeader => 'Drucker';

  @override
  String get materialsHeader => 'Materialien';

  @override
  String get filamentCostLabel => 'Filamentkosten';

  @override
  String get labourCostLabel => 'Arbeitskosten';

  @override
  String get additionalCostLabel => 'Zusatzkosten';

  @override
  String get additionalCostNoteLabel => 'Notiz zu Zusatzkosten';

  @override
  String get additionalCostNoteDialogTitle => 'Notiz zu Zusatzkosten';

  @override
  String get riskCostLabel => 'Risikokosten';

  @override
  String get totalCostLabel => 'Gesamtkosten';

  @override
  String get costTotalLabel => 'Kosten';

  @override
  String get markupLabel => 'Aufschlag';

  @override
  String get setupFeeLabel => 'Einrichtungsgebühr';

  @override
  String get roundingAdjustmentLabel => 'Rundungsanpassung';

  @override
  String get finalPriceLabel => 'Endpreis';

  @override
  String get jobPricingOverridesLabel => 'Auftragseinstellungen';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Überschreibungen aktiv',
      one: 'Überschreibung aktiv',
    );
    return '$count $_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => 'Aufschlag %';

  @override
  String get pricingSetupFeeLabel => 'Einrichtungsgebühr';

  @override
  String get pricingRoundingLabel => 'Rundung';

  @override
  String get pricingRoundingNoneLabel => 'Keine';

  @override
  String get pricingRoundingWholeDollarLabel => 'Ganze Einheit';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Endet auf .99';

  @override
  String get currencySymbolLabel => 'Währungssymbol';

  @override
  String get currencyPositionLabel => 'Position des Währungssymbols';

  @override
  String get currencyPositionBeforeLabel => 'Davor';

  @override
  String get currencyPositionAfterLabel => 'Danach';

  @override
  String get currencySpacingLabel => 'Leerzeichen beim Symbol';

  @override
  String get currencyPreviewLabel => 'Vorschau';

  @override
  String materialCostPerKilogramLabel(Object cost) {
    return '$cost/kg';
  }

  @override
  String historyTimeCompactLabel(Object hours, Object minutes) {
    return '$hours Std. $minutes Min.';
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
  String get workCostsLabel => 'Arbeitskosten';

  @override
  String get enterNumber => 'Bitte geben Sie eine Zahl ein';

  @override
  String get invalidNumber => 'Ungültige Zahl';

  @override
  String get validationRequired => 'Erforderlich';

  @override
  String get validationEnterValidNumber => 'Gültige Zahl eingeben';

  @override
  String get validationMustBeGreaterThanZero => 'Muss größer als 0 sein';

  @override
  String get validationMustBeZeroOrMore => 'Muss 0 oder mehr sein';

  @override
  String get lockedValuePlaceholder => 'Gesperrt';

  @override
  String get hideProPromotionsTitle => 'Pro-Aktionen ausblenden';

  @override
  String get hideProPromotionsSubtitle =>
      'Upgrade-Banner und Hinweise ausblenden';

  @override
  String get historySearchHint => 'Nach Name oder Drucker suchen';

  @override
  String get historyExportMenuTitle => 'Drucke exportieren';

  @override
  String get historyExportRangeAll => 'Alle';

  @override
  String get historyExportRangeLast7Days => 'Letzte 7 Tage';

  @override
  String get historyExportRangeLast30Days => 'Letzte 30 Tage';

  @override
  String get historyEmptyTitle => 'Noch keine gespeicherten Drucke';

  @override
  String get historyEmptyDescription =>
      'Frühere Drucke im Rechner wiederverwenden';

  @override
  String get historyUpsellTitle => 'Frühere Drucke sofort wiederverwenden';

  @override
  String get historyUpsellDescription =>
      'Erweiterte Bearbeitung und Exporte freischalten';

  @override
  String get historyNoMoreRecords => 'Keine weiteren Einträge';

  @override
  String get historyOverflowHint => 'Weitere Aktionen unter ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Verlauf konnte nicht geladen werden: $error';
  }

  @override
  String get historyCsvHeader =>
      'Datum,Drucker,Material,Materialien,Gewicht (g),Zeit,Strom,Filament,Arbeit,Risiko,Gesamt,Aufschlag %,Aufschlagbetrag,Einrichtungsgebühr,Rundungsmodus,Zwischensumme vor Rundung,Rundungsanpassung,Endpreis';

  @override
  String get historyExportShareText => 'Export des 3D-Druck-Kostenverlaufs';

  @override
  String get historyTeaserTitle =>
      'Alle Druckschätzungen an einem Ort speichern';

  @override
  String get historyTeaserDescription =>
      'Sieh dir an, wie der Verlauf funktioniert, bevor du ein Upgrade machst. Speichere abgeschlossene Schätzungen und exportiere sie jederzeit mit Pro.';

  @override
  String get historyTeaserCta => 'Verlauf mit Pro speichern und exportieren';

  @override
  String get historyExportPreviewEntry => 'CSV-Exportvorschau';

  @override
  String get historyExportPreviewTitle => 'CSV-Vorschau';

  @override
  String get historyExportPreviewDescription =>
      'Sieh dir an, wie dein Export aussieht. Download und Teilen sind mit Pro freigeschaltet.';

  @override
  String get historyExportPreviewSampleLabel => '[Beispiel]';

  @override
  String get historyExportPreviewAction => 'Mit Pro herunterladen / teilen';

  @override
  String get addMaterialButton => 'Material hinzufügen';

  @override
  String get useSingleTotalWeightAction => 'Gesamtgewicht verwenden';

  @override
  String get addAtLeastOneMaterial => 'Mindestens ein Material hinzufügen.';

  @override
  String get searchMaterialsHint => 'Name oder Marke suchen';

  @override
  String get materialBreakdownLabel => 'Materialaufschlüsselung';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Materialien',
      one: 'Material',
    );
    return '$count $_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Gesamtes Materialgewicht: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get materialFallback => 'Materialtyp';

  @override
  String get durationPickerLabel => 'Printing time (hh:mm)';

  @override
  String get importGcodeButton => 'G-code importieren (Autoausfüllen)';

  @override
  String get importGcodePageTitle => 'G-code importieren (Beta)';

  @override
  String get importGcodeIntro =>
      'Wählen Sie eine lokale .gcode-Datei. Unterstützte Slicer: PrusaSlicer, OrcaSlicer, Bambu Studio und Cura.';

  @override
  String get importGcodeSelectFileButton => 'G-code-Datei auswählen';

  @override
  String get importGcodePickAnotherButton => 'Andere Datei auswählen';

  @override
  String get importGcodeSelectedFileLabel => 'Ausgewählte Datei';

  @override
  String get gcodeImportFeedbackTitle => 'G-code Import Beta-Feedback';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Beta-Funktion';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Sagen Sie uns, was geholfen hat, was nicht funktioniert hat oder was noch falsch aussieht.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Welcher Slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Vorschau-Ergebnis';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Metadaten-Ergebnis';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'Was hat funktioniert, was nicht funktioniert hat oder was falsch aussieht?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Importierte G-code-Datei anhängen';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'Keine importierte G-code-Datei verfügbar.';

  @override
  String get gcodeImportFeedbackSendCta => 'Feedback senden';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback gesendet';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Vorschau geladen';

  @override
  String get gcodeFeedbackPreviewMissing => 'Vorschau fehlt';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Vorschau falsch';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Nicht sicher';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Sieht korrekt aus';

  @override
  String get gcodeFeedbackMetadataMissing => 'Daten fehlen';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Daten falsch';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Nicht sicher';

  @override
  String get importGcodeSummaryTitle => 'Import-Zusammenfassung';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Unterstützte Slicer: PrusaSlicer, OrcaSlicer, Bambu Studio und Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Importierte Werte füllen nur Zeit und Materialgewicht vor. Drucker, Material und endgültige Kosten stammen aus Ihren Rechnereinstellungen.';

  @override
  String get importGcodeUseValuesButton => 'Diese Werte verwenden';

  @override
  String get importGcodeQuantityLabel => 'Menge';

  @override
  String get importGcodeCreateBatchButton => 'Stapel erstellen';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'Für die Stapelerstellung werden erkannte Dauer und Filamentgewicht benötigt.';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Geschätzte Dauer';

  @override
  String get importGcodeFilamentWeightLabel => 'Filamentgewicht';

  @override
  String get importGcodeFilamentLengthLabel => 'Filamentlänge';

  @override
  String get importGcodeLayerHeightLabel => 'Schichthöhe';

  @override
  String get importGcodePreviewLabel => 'Vorschau';

  @override
  String get importGcodePreviewAvailable => 'Verfügbar';

  @override
  String get importGcodePreviewView => 'Ansehen';

  @override
  String get importGcodePreviewUnavailable => 'Keine Vorschau';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Vorschau-Metadaten gefunden, aber Bild konnte nicht angezeigt werden.';

  @override
  String get importGcodePreviewCuraNote =>
      'Cura-Vorschauen erfordern möglicherweise ein Nachbearbeitungsskript, um Thumbnails in die G-code einzubetten.';

  @override
  String get importGcodeWarningsTitle => 'Warnungen';

  @override
  String get importGcodeUnsupportedTypeError =>
      'Diese Datei sieht nicht wie eine unterstützte G-code-Datei aus.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Diese Datei sieht nicht wie eine unterstützte G-code-Datei aus.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'Diese Datei ist für den Import zu groß. Wähle eine Datei kleiner als $maxSizeMb MB.';
  }

  @override
  String get importGcodeReadError =>
      'Die ausgewählte Datei konnte nicht gelesen werden.';

  @override
  String get importGcodeUnknownSlicerValue => 'Unbekannt';

  @override
  String get importGcodeMissingValue => 'Nicht gefunden';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer nicht identifiziert. Werte vor dem Anwenden überprüfen.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Druckzeit konnte nicht erkannt werden.';

  @override
  String get importGcodeWarningMissingFilament =>
      'Filamentnutzung unvollständig.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Filamentgewicht fehlt.';

  @override
  String get importGcodeWarningPartialMetadata => 'Einige Metadaten fehlen.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Mehrere Materialsummen gefunden. Vor dem Anwenden überprüfen.';

  @override
  String get importGcodeAppliedMessage =>
      'Importierte Werte auf Rechner angewendet';

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
  String get slicerUnknown => 'Unbekannt';

  @override
  String get materialsAppBarTitle => 'Materialien';

  @override
  String get materialsNavLabel => 'Materialien';

  @override
  String get brandLabel => 'Marke';

  @override
  String get materialTypeLabel => 'Materialtyp';

  @override
  String get colorHexLabel => 'Farbe Hex (optional)';

  @override
  String get notesLabel => 'Notizen';

  @override
  String get materialsEmpty =>
      'Noch keine Materialien. Tippe auf +, um eins hinzuzufügen.';

  @override
  String get materialsFilterAll => 'Alle';

  @override
  String get materialsFilterInStock => 'Auf Lager';

  @override
  String get materialsFilterLowStock => 'Niedrig';

  @override
  String get materialsFilterOutOfStock => 'Ausverkauft';

  @override
  String get csvImportTitle => 'Materialien importieren';

  @override
  String get csvTemplateButton => 'Vorlage';

  @override
  String get csvTemplateShareText => 'Material-CSV-Vorlage';

  @override
  String get csvTemplateError => 'Vorlage konnte nicht geteilt werden.';

  @override
  String get csvImportIntro => 'Materialien aus einer CSV-Datei importieren.';

  @override
  String get csvSelectFileButton => 'CSV-Datei auswählen';

  @override
  String get csvImportButton => 'Gültige Zeilen importieren';

  @override
  String get csvReadError =>
      'Die ausgewählte Datei konnte nicht gelesen werden.';

  @override
  String get csvFileTypeError => 'Bitte wählen Sie eine .csv-Datei';

  @override
  String get csvNameRequiredError => 'Name ist erforderlich';

  @override
  String get csvColorRequiredError => 'Farbe ist erforderlich';

  @override
  String get csvSpoolWeightRequiredError => 'Spoolgewicht ist erforderlich';

  @override
  String get csvSpoolWeightPositiveError => 'Spoolgewicht muss > 0 sein';

  @override
  String get csvCostRequiredError => 'Kosten sind erforderlich';

  @override
  String get csvCostPositiveError => 'Kosten müssen > 0 sein';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Materialien importiert',
      one: '1 Material importiert',
    );
    return '$_temp0';
  }

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total Zeilen: $valid gültig, $invalid mit Fehlern';
  }

  @override
  String get csvEmptyNamePlaceholder => '(leer)';

  @override
  String get editButton => 'Bearbeiten';

  @override
  String get duplicateButton => 'Duplizieren';

  @override
  String get duplicateMaterialSuccessMessage => 'Material dupliziert';

  @override
  String get duplicateMaterialErrorMessage =>
      'Fehler beim Duplizieren des Materials';

  @override
  String get materialsSwipeHint =>
      'Wische ein Material zum Bearbeiten, Duplizieren oder Löschen.';

  @override
  String get stockBadgeOut => 'Ausverkauft';

  @override
  String get stockBadgeLow => 'Niedriger Bestand';

  @override
  String get stockBadgeInStock => 'Auf Lager';

  @override
  String get stockBadgeNoTracking => 'Keine Verfolgung';

  @override
  String get batchCostingReviewAppBarTitle => 'Batch-Artikelprüfung';

  @override
  String get batchCostingReviewSubtitle =>
      'Batch-Artikel vor Druckerzuweisung prüfen.';

  @override
  String get batchCostingReviewAddManualItemButton =>
      'Manuellen Artikel hinzufügen';

  @override
  String get batchCostingReviewEmptyTitle => 'Noch keine Batch-Artikel';

  @override
  String get batchCostingReviewEmptyBody =>
      'Importierte oder manuelle Drucke hinzufügen.';

  @override
  String get batchCostingReviewImportGcodeButton =>
      'G-code-Dateien importieren';

  @override
  String get batchGcodeImportTitle => 'Batch-G-code importieren';

  @override
  String get batchGcodeImportBody =>
      'Wähle eine oder mehrere G-code-Dateien. Jede Datei wird einzeln geparst.';

  @override
  String get batchGcodeImportPickButton => 'Dateien auswählen';

  @override
  String get batchGcodeImportSuccessLabel => 'Erfolgreich importiert';

  @override
  String get batchGcodeImportFailureLabel => 'Import fehlgeschlagen';

  @override
  String get batchGcodeImportParseFailure =>
      'Diese Datei konnte nicht importiert werden.';

  @override
  String get batchGcodeImportContinueButton => 'Zur Stapelprüfung fortfahren';

  @override
  String get batchGcodeImportRetryButton => 'Erneut auswählen';

  @override
  String get batchGcodeImportImportingLabel => 'Wird importiert…';

  @override
  String get batchGcodeImportPendingLabel => 'Ausstehend';

  @override
  String get batchGcodeImportNeedsDetailsLabel => 'Details erforderlich';

  @override
  String get batchGcodeImportReadyLabel => 'Bereit';

  @override
  String get batchGcodeImportNeedsWeight => 'Gewicht erforderlich';

  @override
  String get batchGcodeImportNeedsDuration => 'Dauer erforderlich';

  @override
  String get batchGcodeImportApply => 'Übernehmen';

  @override
  String get batchGcodeImportAddButton => 'Zur Stapelprüfung hinzufügen';

  @override
  String get batchGcodeImportDetailsButton => 'Details';

  @override
  String get batchGcodeImportDuplicateMessage =>
      'Einige Dateien wurden bereits hinzugefügt.';

  @override
  String get batchGcodeImportQuantityHint =>
      'Mengen können im nächsten Schritt angepasst werden.';

  @override
  String get batchCostingReviewContinueButton => 'Weiter zur Druckerzuweisung';

  @override
  String get batchCostingReviewQuantityLabel => 'Menge';

  @override
  String get batchCostingReviewRemoveButton => 'Entfernen';

  @override
  String get batchCostingReviewSourceLabel => 'Quelle';

  @override
  String get batchCostingReviewSourceManual => 'Manuell';

  @override
  String get batchCostingReviewSourceGcode => 'G-Code';

  @override
  String get batchCostingReviewSourceUnknown => 'Unbekannt';

  @override
  String get batchCostingReviewWeightLabel => 'Gewicht';

  @override
  String get batchCostingReviewDurationLabel => 'Dauer';

  @override
  String get batchCostingReviewWeightRequired => 'Gewicht erforderlich';

  @override
  String get batchCostingReviewDurationRequired => 'Dauer erforderlich';

  @override
  String get batchCostingReviewMissingFieldsError =>
      'Erforderliche Felder ausfüllen';

  @override
  String get batchCostingItemEditorAddTitle => 'Manuellen Artikel hinzufügen';

  @override
  String get batchCostingItemEditorEditTitle => 'Batch-Artikel bearbeiten';

  @override
  String get batchCostingItemNameLabel => 'Artikel-/Modellname';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle => 'Druckerzuweisung';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Drucker vor Material zuweisen.';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'Gesamter Stapel';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => 'Pro Element';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'Einen Drucker für alle Elemente wählen.';

  @override
  String get batchCostingPrinterAssignmentPerItemHint =>
      'Wähle einen Drucker für dieses Element.';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'Exemplare aufteilen';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return 'Exemplare aufteilen für $itemName';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return 'Gesamtsumme muss $total sein';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      'Zuweisungen wurden zurückgesetzt, da sich die Menge geändert hat.';

  @override
  String get batchCostingAssignmentCopiesLabel => 'Exemplare';

  @override
  String get batchCostingAllocationPickerSearchLabel => 'Optionen suchen';

  @override
  String get batchCostingAllocationPickerAvailableLabel => 'Verfügbar';

  @override
  String get batchCostingAllocationPickerSelectedLabel => 'Ausgewählt';

  @override
  String get batchCostingAllocationPickerAddButton => 'Hinzufügen';

  @override
  String get batchCostingAllocationPickerNoResultsLabel =>
      'Keine Ergebnisse gefunden.';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      'Drucker zum Fortfahren wählen.';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => 'Vorherige';

  @override
  String get batchCostingPrinterAssignmentNextButton => 'Weiter';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'Noch sind keine Drucker verfügbar.';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle => 'Materialzuweisung';

  @override
  String get batchCostingMaterialAssignmentSubtitle =>
      'Material oder Spule vor dem Preis festlegen.';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel =>
      'Material oder Spule';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'Gesamter Stapel';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'Pro Element';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'Ein Material für alle Elemente wählen.';

  @override
  String get batchCostingMaterialAssignmentPerItemHint =>
      'Wähle ein Material für dieses Element.';

  @override
  String get batchCostingMaterialAssignmentRequiredError =>
      'Material zum Fortfahren wählen.';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => 'Vorherige';

  @override
  String get batchCostingMaterialAssignmentNextButton => 'Weiter';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      'Mindestens ein Material oder eine Spule hinzufügen, um fortzufahren.';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return 'Benötigt $required übersteigt den ausgewählten Bestand $available.';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => 'Preisbereich';

  @override
  String get batchCostingPricingScopeSubtitle =>
      'Lege fest, wo jeder Preiswert gilt.';

  @override
  String get batchCostingPricingScopeItemMode => 'Artikel';

  @override
  String get batchCostingPricingScopeBatchMode => 'Stapel';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => 'Artikel (pro Kopie)';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'Stapel (einmal)';

  @override
  String get batchCostingPricingScopeScopeLabel => 'Bereich';

  @override
  String get batchCostingSummaryAppBarTitle => 'Batch-Zusammenfassung';

  @override
  String get batchCostingSummarySubtitle =>
      'Überprüfen Sie den Batch vor der Angebotserstellung.';

  @override
  String get batchCostingSummaryOverviewTitle => 'Übersicht';

  @override
  String get batchCostingSummaryItemCountLabel => 'Elemente';

  @override
  String get batchCostingSummaryTotalQuantityLabel => 'Gesamtmenge';

  @override
  String get batchCostingSummaryTotalWeightLabel => 'Gesamtgewicht';

  @override
  String get batchCostingSummaryTotalDurationLabel => 'Gesamtdruckzeit';

  @override
  String get batchCostingSummaryItemWeightLabel => 'Gewicht';

  @override
  String get batchCostingSummaryItemDurationLabel => 'Druckzeit';

  @override
  String get batchCostingSummaryItemBaseCostLabel => 'Grundkosten';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => 'Anpassungen';

  @override
  String get batchCostingSummaryItemTotalLabel => 'Posten gesamt';

  @override
  String get batchCostingSummaryFinalTotalLabel => 'Endsumme';

  @override
  String get batchCostingSummaryBackButton => 'Zur Preis-Scope zurück';

  @override
  String get batchCostingSummaryReturnToCalculatorButton =>
      'Zurück zum Rechner';

  @override
  String get batchCostingSummaryStartNewBatchButton => 'Neuen Stapel starten';

  @override
  String get batchCostingSummaryEmptyTitle =>
      'Noch keine Batch-Zusammenfassung';

  @override
  String get batchCostingSummaryEmptyBody =>
      'Fügen Sie Elemente hinzu und setzen Sie den Preis-Scope, bevor Sie die Zusammenfassung prüfen.';

  @override
  String get batchCostingSummaryPricingTitle => 'Preisgestaltung';

  @override
  String get batchCostingSummaryItemsTitle => 'Artikel';

  @override
  String get batchCostingNewBatchDialogTitle => 'Neuen Stapel starten';

  @override
  String get batchCostingNewBatchDialogBody =>
      'Dadurch wird der gesamte aktuelle Stapelfortschritt verworfen. Einen neuen Stapel starten?';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnit pro → $lineTotal gesamt';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'Drucker';

  @override
  String get batchCostingEntryButton => 'Stapelkalkulation';
}
