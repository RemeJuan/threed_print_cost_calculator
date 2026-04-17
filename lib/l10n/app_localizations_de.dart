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
  String get generalHeader => 'Allgemein';

  @override
  String get wattLabel => 'Watt (3D-Drucker)';

  @override
  String get printWeightLabel => 'Gewicht des Drucks';

  @override
  String get hoursLabel => 'Druckzeit (Stunden)';

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
  String get supportEmail => 'google@remej.dev';

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
      'Datum,Drucker,Material,Materialien,Gewicht (g),Zeit,Strom,Filament,Arbeit,Risiko,Gesamt';

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
}
