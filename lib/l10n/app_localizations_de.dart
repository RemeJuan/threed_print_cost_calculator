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
  String get deleteButton => 'Löschen';

  @override
  String get selectMaterialHint => 'Benutzerdefiniert (nicht gespeichert)';

  @override
  String get materialNone => 'Keine';

  @override
  String get gramsSuffix => 'g';

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
  String get supportEmailPrefix => 'Bei Problemen schreiben Sie mir bitte an ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Bitte geben Sie Ihre Support-ID an: ';

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
  String get termsOfUseLink => 'Nutzungsbedingungen';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Schließen';

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
  String get riskCostLabel => 'Risikokosten';

  @override
  String get totalCostLabel => 'Gesamtkosten';

  @override
  String get costTotalLabel => 'Kosten gesamt';

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
      other: '# Überschreibungen aktiv',
      one: '# Überschreibung aktiv',
    );
    return '$_temp0';
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
  String get pricingRoundingWholeDollarLabel => 'Ganze Zahl';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Endet auf .99';

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
  String get searchMaterialsHint => 'Materialien suchen';

  @override
  String get materialBreakdownLabel => 'Materialaufschlüsselung';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# Materialien',
      one: '# Material',
    );
    return '$_temp0';
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
  String get importGcodePreviewUnavailable => 'Nicht verfügbar';

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
      'Bitte wählen Sie eine .gcode-Datei.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Diese Datei enthielt keine unterstützten G-code-Metadaten.';

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
}
