// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get calculatorAppBarTitle => 'Calculadora de impresión 3D';

  @override
  String get historyAppBarTitle => 'Historial';

  @override
  String get settingsAppBarTitle => 'Ajustes';

  @override
  String get calculatorNavLabel => 'Calculadora';

  @override
  String get historyNavLabel => 'Historial';

  @override
  String get settingsNavLabel => 'Configuración';

  @override
  String get newAnnouncementBadgeLabel => 'Nuevo';

  @override
  String get generalHeader => 'General';

  @override
  String get wattLabel => 'Vatio (impresora 3D)';

  @override
  String get printWeightLabel => 'Peso de la impresión';

  @override
  String get hoursLabel => 'Tiempo de impresión (horas)';

  @override
  String get durationHoursLabel => 'Horas';

  @override
  String get wearAndTearLabel => 'Materiales/Desgaste';

  @override
  String get labourRateLabel => 'Tarifa por hora';

  @override
  String get labourTimeLabel => 'Tiempo de procesamiento';

  @override
  String get failureRiskLabel => 'Riesgo de falla (%)';

  @override
  String get minutesLabel => 'Minutos';

  @override
  String get durationMinutesLabel => 'Minutos';

  @override
  String get printingTimeDialogTitle => 'Tiempo de impresión';

  @override
  String get workTimeDialogTitle => 'Tiempo de trabajo';

  @override
  String get spoolWeightLabel => 'Peso del carrete/resina';

  @override
  String get spoolCostLabel => 'Costo del carrete/resina';

  @override
  String get electricityCostLabel => 'Costo de electricidad';

  @override
  String get electricityCostSettingsLabel => 'Costo de electricidad';

  @override
  String get submitButton => 'Calcular';

  @override
  String get resultElectricityPrefix => 'Costo total de Electricidad: ';

  @override
  String get resultFilamentPrefix => 'Costo total del filamento: ';

  @override
  String get resultTotalPrefix => 'Coste total: ';

  @override
  String get riskTotalPrefix => 'Costo del riesgo: ';

  @override
  String get premiumHeader => 'Sólo usuarios premium:';

  @override
  String get labourCostPrefix => 'Costo laboral/Materiales: ';

  @override
  String get selectPrinterHint => 'Seleccionar impresora';

  @override
  String get watt => 'Vatio';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Guardar impresión';

  @override
  String get printNameHint => 'Nombre de impresión';

  @override
  String get printerNameLabel => 'Nombre *';

  @override
  String get bedSizeLabel => 'Tamaño de cama *';

  @override
  String get wattageLabel => 'Potencia *';

  @override
  String get materialNameLabel => 'Nombre del material *';

  @override
  String get colorLabel => 'Color del material *';

  @override
  String get weightLabel => 'Peso *';

  @override
  String get costLabel => 'Costo *';

  @override
  String get saveButton => 'Guardar';

  @override
  String get deleteDialogTitle => 'Eliminar';

  @override
  String get deleteDialogContent =>
      '¿Seguro que deseas eliminar este elemento?';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get resetButtonLabel => 'Restablecer';

  @override
  String get resetCalculationTitle => '¿Restablecer cálculo?';

  @override
  String get resetCalculationBody =>
      'Esto descartará los valores actuales de la calculadora y volverá a cargar los valores predeterminados actuales.';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get selectMaterialHint => 'Personalizado (no guardado)';

  @override
  String get materialNone => 'Ninguno';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => 'Restante:';

  @override
  String get trackRemainingFilamentLabel =>
      'Hacer seguimiento del filamento restante';

  @override
  String get remainingFilamentLabel => 'Filamento restante';

  @override
  String get savePrintErrorMessage => 'Error al guardar la impresión';

  @override
  String get deleteRecordErrorMessage => 'Error al eliminar el registro';

  @override
  String get savePrintSuccessMessage => 'Impresión guardada';

  @override
  String get historyLoadAction => 'Editar en la calculadora';

  @override
  String get historyLoadSuccessMessage => 'Cargado desde el historial';

  @override
  String get historyLoadReplacementWarning =>
      'Algunos elementos no estaban disponibles y se sustituyeron';

  @override
  String get numberExampleHint => 'p. ej. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Error al cargar los materiales: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Error al cargar las impresoras: $error';
  }

  @override
  String get retryButton => 'Reintentar';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => '¿Necesitas ayuda?';

  @override
  String get supportEmailPrefix => 'Si tienes algún problema, escríbeme a ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Incluye tu ID de soporte: ';

  @override
  String get clickToCopy => '(haz clic para copiar)';

  @override
  String get materialWeightExplanation =>
      'El peso del material es el peso total del material de origen, es decir, todo el rollo de filamento. El costo es el costo de la unidad completa.';

  @override
  String get supportIdCopied => 'ID de soporte copiado';

  @override
  String get exportSuccess => 'Exportación exitosa';

  @override
  String get exportError => 'Error de exportación';

  @override
  String get exportButton => 'Exportar';

  @override
  String get privacyPolicyLink => 'Política de privacidad';

  @override
  String get termsOfUseLink => 'Términos de uso';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get testDataToolsTitle => 'Herramientas de datos de prueba';

  @override
  String get testDataToolsBody =>
      'Estas acciones son solo para pruebas locales. Cargar datos reemplaza la configuración local actual con datos de demostración. Borrar elimina permanentemente los datos locales de la app en este dispositivo.';

  @override
  String get seedTestDataButton => 'Cargar datos de prueba';

  @override
  String get purgeLocalDataButton => 'Borrar datos locales';

  @override
  String get enablePremiumButton => 'Activar premium';

  @override
  String get enablePremiumTitle => 'Activar premium';

  @override
  String get enablePremiumBody =>
      'Introduce el código de confirmación para activar las pruebas locales de premium';

  @override
  String get invalidConfirmationCodeMessage =>
      'Código de confirmación inválido';

  @override
  String get seedTestDataConfirmTitle => '¿Cargar datos de prueba?';

  @override
  String get seedTestDataConfirmBody =>
      'Esto reemplazará la configuración local actual con datos de demostración deterministas.';

  @override
  String get purgeLocalDataConfirmTitle => '¿Borrar datos locales?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Esto eliminará permanentemente todos los datos locales de la app en este dispositivo.';

  @override
  String get testDataSeededMessage => 'Datos de prueba cargados';

  @override
  String get testDataPurgedMessage => 'Datos locales borrados';

  @override
  String get testDataActionFailedMessage =>
      'La acción de datos de prueba falló';

  @override
  String get mailClientError => 'No se pudo abrir el cliente de correo';

  @override
  String get offeringsError => 'Error de ofertas: ';

  @override
  String get currentOfferings => 'Ofertas actuales';

  @override
  String get purchaseError =>
      'Hubo un error al procesar tu compra. Inténtalo de nuevo más tarde.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get printersHeader => 'Impresoras';

  @override
  String get materialsHeader => 'Materiales';

  @override
  String get filamentCostLabel => 'Filamento';

  @override
  String get labourCostLabel => 'Costo laboral';

  @override
  String get additionalCostLabel => 'Costo adicional';

  @override
  String get additionalCostNoteLabel => 'Nota de costo adicional';

  @override
  String get additionalCostNoteDialogTitle => 'Nota de costo adicional';

  @override
  String get riskCostLabel => 'Riesgo';

  @override
  String get totalCostLabel => 'Costo total';

  @override
  String get costTotalLabel => 'Costo total';

  @override
  String get markupLabel => 'Margen';

  @override
  String get setupFeeLabel => 'Tarifa de configuración';

  @override
  String get roundingAdjustmentLabel => 'Ajuste por redondeo';

  @override
  String get finalPriceLabel => 'Precio final';

  @override
  String get jobPricingOverridesLabel => 'Configuración del trabajo';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# sobrescrituras aplicadas',
      one: '# sobrescritura aplicada',
    );
    return '$_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => '% de margen';

  @override
  String get pricingSetupFeeLabel => 'Tarifa de configuración';

  @override
  String get pricingRoundingLabel => 'Redondeo';

  @override
  String get pricingRoundingNoneLabel => 'Ninguno';

  @override
  String get pricingRoundingWholeDollarLabel => 'Dólar entero';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Termina en .99';

  @override
  String get workCostsLabel => 'Costos de Trabajo';

  @override
  String get enterNumber => 'Ingresa un número';

  @override
  String get invalidNumber => 'Número inválido';

  @override
  String get validationRequired => 'Obligatorio';

  @override
  String get validationEnterValidNumber => 'Introduce un número válido';

  @override
  String get validationMustBeGreaterThanZero => 'Debe ser mayor que 0';

  @override
  String get validationMustBeZeroOrMore => 'Debe ser 0 o más';

  @override
  String get lockedValuePlaceholder => 'Bloqueado';

  @override
  String get hideProPromotionsTitle => 'Ocultar promociones Pro';

  @override
  String get hideProPromotionsSubtitle =>
      'Ocultar banners y avisos de actualización';

  @override
  String get historySearchHint => 'Buscar por nombre o impresora';

  @override
  String get historyExportMenuTitle => 'Exportar impresiones';

  @override
  String get historyExportRangeAll => 'Todas';

  @override
  String get historyExportRangeLast7Days => 'Últimos 7 días';

  @override
  String get historyExportRangeLast30Days => 'Últimos 30 días';

  @override
  String get historyEmptyTitle => 'Aún no hay impresiones guardadas';

  @override
  String get historyEmptyDescription =>
      'Reutiliza impresiones anteriores en la calculadora';

  @override
  String get historyUpsellTitle =>
      'Reutiliza impresiones anteriores al instante';

  @override
  String get historyUpsellDescription =>
      'Desbloquea ediciones avanzadas y exportaciones';

  @override
  String get historyNoMoreRecords => 'No hay más registros';

  @override
  String get historyOverflowHint => 'Más acciones en ⋯';

  @override
  String historyLoadError(Object error) {
    return 'No se pudo cargar el historial: $error';
  }

  @override
  String get historyCsvHeader =>
      'Fecha,Impresora,Material,Materiales,Peso (g),Tiempo,Electricidad,Filamento,Mano de obra,Riesgo,Total,% de margen,Monto del margen,Tarifa de configuración,Modo de redondeo,Subtotal antes de redondeo,Ajuste por redondeo,Precio final';

  @override
  String get historyExportShareText =>
      'Exportación del historial de costes de impresión 3D';

  @override
  String get historyTeaserTitle =>
      'Guarda cada estimación de impresión en un solo lugar';

  @override
  String get historyTeaserDescription =>
      'Descubre cómo funciona el historial antes de actualizar. Guarda las estimaciones completadas y expórtalas cuando quieras con Pro.';

  @override
  String get historyTeaserCta => 'Guardar y exportar historial con Pro';

  @override
  String get historyExportPreviewEntry => 'Vista previa de exportación CSV';

  @override
  String get historyExportPreviewTitle => 'Vista previa CSV';

  @override
  String get historyExportPreviewDescription =>
      'Mira cómo quedará tu exportación. La descarga y el compartir se desbloquean con Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Muestra]';

  @override
  String get historyExportPreviewAction => 'Descargar / Compartir con Pro';

  @override
  String get addMaterialButton => 'Añadir material';

  @override
  String get useSingleTotalWeightAction => 'Usar peso total único';

  @override
  String get addAtLeastOneMaterial => 'Añade al menos un material.';

  @override
  String get searchMaterialsHint => 'Buscar materiales';

  @override
  String get materialBreakdownLabel => 'Desglose de materiales';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# materiales',
      one: '# material',
    );
    return '$_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Peso total del material: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Versión $version';
  }

  @override
  String get materialFallback => 'Material genérico';

  @override
  String get durationPickerLabel => 'Tiempo de impresión (hh:mm)';

  @override
  String get importGcodeButton => 'Importar G-code (Relleno auto)';

  @override
  String get importGcodePageTitle => 'Importar G-code (Beta)';

  @override
  String get importGcodeIntro =>
      'Selecciona un archivo .gcode local. Slicers compatibles: PrusaSlicer, OrcaSlicer, Bambu Studio y Cura.';

  @override
  String get importGcodeSelectFileButton => 'Seleccionar archivo G-code';

  @override
  String get importGcodePickAnotherButton => 'Seleccionar otro archivo';

  @override
  String get importGcodeSelectedFileLabel => 'Archivo seleccionado';

  @override
  String get gcodeImportFeedbackTitle => 'Feedback importación G-code Beta';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Función beta';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Cuéntanos qué funcionó, qué falló o qué sigue viendo mal.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => '¿Qué slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Resultado de vista previa';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Resultado de metadatos';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      '¿Qué funcionó, qué falló o qué parece incorrecto?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Adjuntar archivo G-code importado';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'No hay archivo G-code disponible para adjuntar.';

  @override
  String get gcodeImportFeedbackSendCta => 'Enviar feedback';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback enviado';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Vista previa cargada';

  @override
  String get gcodeFeedbackPreviewMissing => 'Vista previa faltante';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Vista previa incorrecta';

  @override
  String get gcodeFeedbackPreviewNotSure => 'No estoy seguro';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Parece correcto';

  @override
  String get gcodeFeedbackMetadataMissing => 'Datos faltantes';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Datos incorrectos';

  @override
  String get gcodeFeedbackMetadataNotSure => 'No estoy seguro';

  @override
  String get importGcodeSummaryTitle => 'Resumen de importación';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Slicers compatibles: PrusaSlicer, OrcaSlicer, Bambu Studio y Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Los valores importados solo prellenan tiempo y peso total del material. La impresora, material y costo final vienen de tu configuración.';

  @override
  String get importGcodeUseValuesButton => 'Usar estos valores';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Duración estimada';

  @override
  String get importGcodeFilamentWeightLabel => 'Peso del filamento';

  @override
  String get importGcodeFilamentLengthLabel => 'Longitud del filamento';

  @override
  String get importGcodeLayerHeightLabel => 'Altura de capa';

  @override
  String get importGcodePreviewLabel => 'Vista previa';

  @override
  String get importGcodePreviewAvailable => 'Disponible';

  @override
  String get importGcodePreviewView => 'Ver';

  @override
  String get importGcodePreviewUnavailable => 'No disponible';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Metadatos de vista previa encontrados pero la imagen no pudo mostrarse.';

  @override
  String get importGcodePreviewCuraNote =>
      'Las vistas previas de Cura pueden requerir un script post-procesamiento para embeber miniaturas.';

  @override
  String get importGcodeWarningsTitle => 'Advertencias';

  @override
  String get importGcodeUnsupportedTypeError =>
      'Por favor selecciona un archivo .gcode.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Este archivo no contenía metadatos G-code compatibles.';

  @override
  String get importGcodeReadError =>
      'El archivo seleccionado no pudo ser leído.';

  @override
  String get importGcodeUnknownSlicerValue => 'Desconocido';

  @override
  String get importGcodeMissingValue => 'No encontrado';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer no identificado. Revisa los valores antes de aplicar.';

  @override
  String get importGcodeWarningMissingDuration =>
      'El tiempo de impresión no pudo ser detectado.';

  @override
  String get importGcodeWarningMissingFilament =>
      'Uso de filamento incompleto.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Peso del filamento faltante.';

  @override
  String get importGcodeWarningPartialMetadata => 'Algunos metadatos faltan.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Se encontraron múltiples totales de material. Revisa antes de aplicar.';

  @override
  String get importGcodeAppliedMessage =>
      'Valores importados aplicados a la calculadora';

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
  String get slicerOther => 'Otro';

  @override
  String get slicerUnknown => 'Desconocido';
}
