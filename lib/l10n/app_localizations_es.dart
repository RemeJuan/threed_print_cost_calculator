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
  String get whatsNewSeeRecentUpdates => 'Ver actualizaciones recientes';

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
  String get resultElectricityRated => 'Electricidad (Nominal)';

  @override
  String get resultElectricityAverage => 'Electricidad (Promedio)';

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
  String get wattageLabel => 'Potencia (Nominal) *';

  @override
  String get averageWattageLabel => 'Potencia (Promedio)';

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
  String get millimetersSuffix => 'mm';

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
  String get deleteMaterialSuccessMessage => 'Material eliminado';

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
  String get helpSupportSupportTitle => 'Soporte';

  @override
  String get helpSupportSupportIntro =>
      'Usa estos detalles al contactar con soporte.';

  @override
  String get helpSupportWebsiteLabel => 'Sitio web';

  @override
  String get helpSupportEmailLabel => 'Correo electrónico';

  @override
  String get helpSupportSupportIdLabel => 'ID de soporte';

  @override
  String get helpSupportCopySupportIdTooltip => 'Copiar ID de soporte';

  @override
  String get helpSupportRoadmapLabel => 'Hoja de ruta';

  @override
  String get helpSupportRoadmapValue => 'Ver lo que viene';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'Versión de la app $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Contactar soporte';

  @override
  String get helpSupportContactEmailSubject =>
      'Soporte Calculadora de Costes de Impresión 3D';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'ID de soporte: $supportId\nVersión de la app: $version\n\nDescribe el problema aquí.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'ID de soporte: (no disponible)\nVersión de la app: $version\n\nDescribe el problema aquí.';
  }

  @override
  String get helpSupportFaqTitle => 'Preguntas frecuentes';

  @override
  String get helpSupportFaqWeightQuestion => '¿Qué peso debo ingresar?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Ingresa el peso total del carrete, no el filamento sobrante. La app usa el peso del rollo completo para calcular el coste por gramo.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      '¿Por qué importa la electricidad?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Las impresiones largas y las impresoras de alto vataje pueden añadir coste real. Omitir la electricidad normalmente subestima el precio del trabajo.';

  @override
  String get helpSupportFaqRiskQuestion =>
      '¿Cómo se calcula el riesgo de fallo?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'El riesgo se aplica solo a los costes de impresión base como filamento y electricidad. Estima la pérdida esperada por impresiones fallidas.';

  @override
  String get helpSupportFaqLabourQuestion =>
      '¿Qué es el tiempo de mano de obra / procesamiento?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Cubre preparación, limpieza, postprocesamiento y monitoreo. Mantenlo activo para servicios donde tu tiempo importa.';

  @override
  String get helpSupportFaqMarkupQuestion => '¿Qué es el margen?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'El margen es el porcentaje añadido sobre el coste total para alcanzar tu precio de venta. Cubre margen, gastos generales y beneficio.';

  @override
  String get helpSupportFaqSetupQuestion =>
      '¿Qué es una tarifa de configuración?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Una tarifa de configuración es un coste fijo por trabajo para calibración, preparación de máquina y administración. Ayuda a que impresiones pequeñas cubran gastos generales.';

  @override
  String get wattageFaqHint =>
      'Consulta las FAQ para ver los detalles de vatios';

  @override
  String get helpSupportFaqWattageQuestion =>
      'Potencia nominal vs. potencia media - ¿cuál es la diferencia?';

  @override
  String get helpSupportFaqWattageAnswer =>
      'La potencia nominal es la máxima que tu impresora puede tomar de la pared (impresa en la placa). La potencia media es su consumo típico durante una impresión, idealmente medido con un medidor enchufable. Usa la potencia media para calcular el coste eléctrico con precisión, o la nominal como límite superior seguro.';

  @override
  String get helpSupportLinksTitle => 'Enlaces';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Política de privacidad';

  @override
  String get helpSupportTermsOfUseLabel => 'Términos de uso';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'Acerca de';

  @override
  String get helpSupportAboutIntro =>
      'La Calculadora de Costes de Impresión 3D está hecha para precios locales primero. Ayuda a creadores y pequeños negocios de impresión a cotizar trabajo con menos sorpresas.';

  @override
  String get helpSupportTrustNoAccounts => 'Sin cuentas';

  @override
  String get helpSupportTrustNoCloudSync => 'Sin sincronización en la nube';

  @override
  String get helpSupportTrustNoTracking => 'Sin seguimiento';

  @override
  String get helpSupportTrustLocalData => 'Datos locales';

  @override
  String get helpSupportAboutCalculator =>
      'La calculadora combina coste de filamento, electricidad, riesgo de fallo, mano de obra y herramientas de precios opcionales como margen y tarifas de configuración.';

  @override
  String get helpSupportAboutOutcome =>
      'Eso mantiene las cotizaciones vinculadas al coste real, no solo al gasto de material.';

  @override
  String get supportEmailPrefix => 'Si tienes algún problema, escríbeme a ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Incluye tu ID de soporte: ';

  @override
  String get supportEmailSubject => 'Soporte de 3D Print Cost Calculator';

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
  String get scheduleAutomaticBackupButton =>
      'Programar copia de seguridad automática';

  @override
  String get automaticBackupDailyLabel => 'Diaria';

  @override
  String get automaticBackupWeeklyLabel => 'Semanal';

  @override
  String get automaticBackupMonthlyLabel => 'Mensual';

  @override
  String get automaticBackupNote =>
      'Las copias de seguridad automáticas se ejecutan en segundo plano cuando tu dispositivo lo permite. El sistema operativo puede retrasar o impedir las copias de seguridad programadas.';

  @override
  String get automaticBackupStatusPending => 'Pendiente';

  @override
  String get automaticBackupStatusSuccess => 'Correcta';

  @override
  String get automaticBackupStatusFailure => 'Fallida';

  @override
  String get automaticBackupScheduleSuccess =>
      'Copia de seguridad automática programada';

  @override
  String get automaticBackupScheduleError =>
      'No se pudo programar la copia de seguridad automática';

  @override
  String automaticBackupStatusLabel(
    Object cadence,
    Object destination,
    Object result,
  ) {
    return 'Copia de seguridad automática: $cadence • $destination • $result';
  }

  @override
  String get privacyPolicyLink => 'Política de privacidad';

  @override
  String get websiteLink => 'Sitio web';

  @override
  String get termsOfUseLink => 'Términos de uso';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get cancelFeedbackPromptTitle =>
      'Parece que cancelaste la renovación. ¿Nos dices por qué?';

  @override
  String get feedbackSubmitButton => 'Enviar comentarios';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Demasiado caro';

  @override
  String get cancelFeedbackReasonMissingFeatures => 'Faltan funciones';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'No aporta suficiente valor';

  @override
  String get cancelFeedbackReasonConfusingToUse => 'Es confusa de usar';

  @override
  String get cancelFeedbackReasonJustTesting => 'Solo estaba probando la app';

  @override
  String get cancelFeedbackReasonOther => 'Otro';

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
  String get forceUpdateAvailableButton => 'Forzar actualización disponible';

  @override
  String get forceNoUpdateButton => 'Forzar sin actualización';

  @override
  String get clearUpdateCooldownButton => 'Borrar pausa de actualización';

  @override
  String get previewCancelFeedbackButton =>
      'Vista previa de comentarios de cancelación';

  @override
  String get enableBatchCostingButton => 'Activar cálculo por lotes';

  @override
  String get batchCostingSummarySaveButton => 'Guardar presupuesto';

  @override
  String get batchCostingSummarySaveSuccessTitle => 'Presupuesto guardado';

  @override
  String get batchCostingSummarySaveSuccessBody => 'Guardado en el historial.';

  @override
  String get batchCostingSummaryViewHistoryButton => 'Ver historial';

  @override
  String get batchCostingSummarySaveErrorMessage =>
      'No se pudo guardar el presupuesto';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'Presupuesto por lotes';

  @override
  String get batchCostingSummaryQuoteNameDialogTitle =>
      'Ponga nombre a su cotización';

  @override
  String get batchCostingSummaryQuoteNameHint => 'Nombre de la cotización';

  @override
  String get batchHistoryItemsTitle => 'Elementos del lote';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'elementos',
      one: 'elemento',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalQuantity,
      locale: localeName,
      other: 'copias',
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
  String get updatePromptTitle => 'Actualización disponible';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'La versión $storeVersion está disponible. Tienes instalada $currentVersion.';
  }

  @override
  String get updatePromptBodyUnknown => 'Hay una versión más nueva disponible.';

  @override
  String get updatePromptOpenStoreButton => 'Abrir tienda';

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
  String get costTotalLabel => 'Costo';

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
      other: 'sobrescrituras aplicadas',
      one: 'sobrescritura aplicada',
    );
    return '$count $_temp0';
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
  String get pricingRoundingWholeDollarLabel => 'Unidad entera';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Termina en .99';

  @override
  String get currencySymbolLabel => 'Símbolo de moneda';

  @override
  String get currencyPositionLabel => 'Posición del símbolo';

  @override
  String get currencyPositionBeforeLabel => 'Antes';

  @override
  String get currencyPositionAfterLabel => 'Después';

  @override
  String get currencySpacingLabel => 'Espacio con símbolo';

  @override
  String get currencyPreviewLabel => 'Vista previa';

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
  String get lockedValuePlaceholder => 'Solo Premium';

  @override
  String get printerLimitReachedMessage =>
      'Puedes guardar hasta 2 impresoras en Free. Actualiza a Premium para impresoras ilimitadas.';

  @override
  String get materialLimitReachedMessage =>
      'Puedes guardar hasta 5 materiales en Free. Actualiza a Premium para materiales ilimitados.';

  @override
  String get batchItemLimitReachedMessage =>
      'Puedes añadir hasta 3 elementos por lote en Free. Actualiza a Premium para elementos de lote ilimitados.';

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
      'Puedes conservar hasta 7 impresiones guardadas en Free. Actualiza a Premium para historial y exportaciones ilimitados.';

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
  String get batchQuoteExportShareText =>
      'Exportación de presupuesto por lotes de impresión 3D';

  @override
  String get mixedHistoryExportShareText =>
      'Exportación del historial de costes de impresión 3D';

  @override
  String get historyTeaserTitle =>
      'Guarda cada estimación de impresión en un solo lugar';

  @override
  String get historyTeaserDescription =>
      'Los usuarios Free pueden conservar hasta 7 impresiones guardadas. Actualiza a Premium para historial y exportaciones ilimitados.';

  @override
  String get historyTeaserCta =>
      'Actualizar a Premium para historial ilimitado';

  @override
  String get historyExportPreviewEntry => 'Vista previa de exportación CSV';

  @override
  String get historyExportPreviewTitle => 'Vista previa CSV';

  @override
  String get historyExportPreviewDescription =>
      'La exportación masiva del historial es una función Premium. Descargar y compartir se desbloquean con Premium.';

  @override
  String get historyExportPreviewSampleLabel => '[Muestra]';

  @override
  String get historyExportPreviewAction => 'Descargar / Compartir con Premium';

  @override
  String get unsavedMaterialOptionLabel => 'Material no guardado';

  @override
  String get unsavedMaterialHeader => 'Material personalizado';

  @override
  String get customMaterialWeightLabel => 'Peso';

  @override
  String get customMaterialCostLabel => 'Costo';

  @override
  String get customMaterialUsedLabel => 'Usado';

  @override
  String get addMaterialButton => 'Añadir material';

  @override
  String get useSingleTotalWeightAction => 'Usar peso total único';

  @override
  String get addAtLeastOneMaterial => 'Añade al menos un material.';

  @override
  String get searchMaterialsHint => 'Buscar nombre o marca';

  @override
  String get materialBreakdownLabel => 'Desglose de materiales';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'materiales',
      one: 'material',
    );
    return '$count $_temp0';
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
  String get importGcodeQuantityLabel => 'Cantidad';

  @override
  String get importGcodeCreateBatchButton => 'Crear lote';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'La creación del lote necesita duración y peso del filamento detectados.';

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
  String get importGcodePreviewUnavailable => 'Sin vista previa';

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
      'Este archivo no parece un archivo G-code compatible.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Este archivo no parece un archivo G-code compatible.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'Este archivo es demasiado grande para importarlo. Elige un archivo de menos de $maxSizeMb MB.';
  }

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

  @override
  String get materialsAppBarTitle => 'Materiales';

  @override
  String get materialsNavLabel => 'Materiales';

  @override
  String get brandLabel => 'Marca';

  @override
  String get materialTypeLabel => 'Tipo de material';

  @override
  String get colorHexLabel => 'Color hex (opcional)';

  @override
  String get notesLabel => 'Notas';

  @override
  String get materialsEmpty => 'Aún no hay materiales. Toca + para añadir uno.';

  @override
  String get materialsFilterAll => 'Todos';

  @override
  String get materialsFilterInStock => 'En stock';

  @override
  String get materialsFilterLowStock => 'Stock bajo';

  @override
  String get materialsFilterOutOfStock => 'Agotado';

  @override
  String get csvImportTitle => 'Importar materiales';

  @override
  String get csvTemplateButton => 'Plantilla';

  @override
  String get csvTemplateShareText => 'Plantilla CSV de materiales';

  @override
  String get csvTemplateError => 'No se pudo compartir la plantilla.';

  @override
  String get csvImportIntro => 'Importa materiales desde un archivo CSV.';

  @override
  String get csvSelectFileButton => 'Elegir archivo CSV';

  @override
  String get csvImportButton => 'Importar filas válidas';

  @override
  String get csvReadError => 'No se pudo leer el archivo seleccionado.';

  @override
  String get csvFileTypeError => 'Selecciona un archivo .csv';

  @override
  String get csvNameRequiredError => 'El nombre es obligatorio';

  @override
  String get csvColorRequiredError => 'El color es obligatorio';

  @override
  String get csvSpoolWeightRequiredError =>
      'El peso del carrete es obligatorio';

  @override
  String get csvSpoolWeightPositiveError => 'El peso del carrete debe ser > 0';

  @override
  String get csvCostRequiredError => 'El costo es obligatorio';

  @override
  String get csvCostPositiveError => 'El costo debe ser > 0';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiales importados',
      one: '1 material importado',
    );
    return '$_temp0';
  }

  @override
  String get csvNoValidRowsError => 'No hay filas válidas para importar.';

  @override
  String get csvImportQuotaExceededError =>
      'Esta importación supera tu límite de materiales.';

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total filas: $valid válidas, $invalid con errores';
  }

  @override
  String get csvEmptyNamePlaceholder => '(vacío)';

  @override
  String get editButton => 'Editar';

  @override
  String get duplicateButton => 'Duplicar';

  @override
  String get duplicateMaterialSuccessMessage => 'Material duplicado';

  @override
  String get duplicateMaterialErrorMessage => 'Error al duplicar el material';

  @override
  String get materialsSwipeHint =>
      'Desliza un material para editar, duplicar o eliminar.';

  @override
  String get stockBadgeOut => 'Agotado';

  @override
  String get stockBadgeLow => 'Stock bajo';

  @override
  String get stockBadgeInStock => 'En stock';

  @override
  String get stockBadgeNoTracking => 'Sin seguimiento';

  @override
  String get batchCostingReviewAppBarTitle => 'Revisión de lotes';

  @override
  String get batchCostingReviewSubtitle =>
      'Revise los artículos del lote antes de asignar impresora.';

  @override
  String get batchCostingReviewAddManualItemButton => 'Añadir artículo manual';

  @override
  String get batchCostingReviewEmptyTitle => 'Aún no hay artículos en lote';

  @override
  String get batchCostingReviewEmptyBody =>
      'Añade impresiones manuales para continuar.';

  @override
  String get batchCostingReviewImportGcodeButton => 'Importar archivos G-code';

  @override
  String get batchCostingReviewImportGcodeButtonPremium =>
      'Importar archivos G-code (Premium)';

  @override
  String get batchGcodeImportTitle => 'Importar G-code en lote';

  @override
  String get batchGcodeImportBody =>
      'Elige uno o más archivos G-code. Cada archivo se analiza por separado.';

  @override
  String get batchGcodeImportPickButton => 'Elegir archivos';

  @override
  String get batchGcodeImportSuccessLabel => 'Importado correctamente';

  @override
  String get batchGcodeImportFailureLabel => 'Error de importación';

  @override
  String get batchGcodeImportParseFailure => 'Este archivo no pudo importarse.';

  @override
  String get batchGcodeImportContinueButton => 'Continuar a revisión de lote';

  @override
  String get batchGcodeImportRetryButton => 'Elegir de nuevo';

  @override
  String get batchGcodeImportImportingLabel => 'Importando…';

  @override
  String get batchGcodeImportPendingLabel => 'Pendiente';

  @override
  String get batchGcodeImportNeedsDetailsLabel => 'Detalles necesarios';

  @override
  String get batchGcodeImportReadyLabel => 'Listo';

  @override
  String get batchGcodeImportNeedsWeight => 'Peso requerido';

  @override
  String get batchGcodeImportNeedsDuration => 'Duración requerida';

  @override
  String get batchGcodeImportApply => 'Aplicar';

  @override
  String get batchGcodeImportAddButton => 'Añadir a la revisión por lote';

  @override
  String get batchGcodeImportDetailsButton => 'Detalles';

  @override
  String get batchGcodeImportDuplicateMessage =>
      'Algunos archivos ya se habían añadido.';

  @override
  String get batchGcodeImportQuantityHint =>
      'Las cantidades se pueden ajustar en el siguiente paso.';

  @override
  String get batchCostingReviewContinueButton =>
      'Continuar a asignación de impresora';

  @override
  String get batchCostingReviewQuantityLabel => 'Cantidad';

  @override
  String get batchCostingReviewRemoveButton => 'Eliminar';

  @override
  String get batchCostingReviewSourceLabel => 'Origen';

  @override
  String get batchCostingReviewSourceManual => 'Manual';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => 'Desconocido';

  @override
  String get batchCostingReviewWeightLabel => 'Peso';

  @override
  String get batchCostingReviewDurationLabel => 'Duración';

  @override
  String get batchCostingReviewWeightRequired => 'Peso requerido';

  @override
  String get batchCostingReviewDurationRequired => 'Duración requerida';

  @override
  String get batchCostingReviewMissingFieldsError =>
      'Complete los campos obligatorios';

  @override
  String get batchCostingItemEditorAddTitle => 'Añadir artículo manual';

  @override
  String get batchCostingItemEditorEditTitle => 'Editar artículo del lote';

  @override
  String get batchCostingItemNameLabel => 'Nombre del artículo/modelo';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle =>
      'Asignación de impresora';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Asigna impresoras antes de pasar a materiales.';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'Todo el lote';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => 'Por elemento';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'Selecciona una impresora para todos los elementos.';

  @override
  String get batchCostingPrinterAssignmentPerItemHint =>
      'Selecciona una impresora para este elemento.';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'Dividir copias';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return 'Dividir copias para $itemName';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return 'El total debe ser igual a $total';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      'Las asignaciones se restablecieron porque la cantidad cambió.';

  @override
  String get batchCostingAssignmentCopiesLabel => 'Copias';

  @override
  String get batchCostingAllocationPickerSearchLabel => 'Buscar opciones';

  @override
  String get batchCostingAllocationPickerAvailableLabel => 'Disponible';

  @override
  String get batchCostingAllocationPickerSelectedLabel => 'Seleccionado';

  @override
  String get batchCostingAllocationPickerAddButton => 'Añadir';

  @override
  String get batchCostingAllocationPickerNoResultsLabel =>
      'No se encontraron resultados.';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      'Selecciona una impresora para continuar.';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => 'Anterior';

  @override
  String get batchCostingPrinterAssignmentNextButton => 'Siguiente';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'Aún no hay impresoras disponibles.';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle =>
      'Asignación de material';

  @override
  String get batchCostingMaterialAssignmentSubtitle =>
      'Asigna materiales o bobinas antes de fijar el precio.';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel => 'Material o bobina';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'Todo el lote';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'Por elemento';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'Elige un material para todos los elementos.';

  @override
  String get batchCostingMaterialAssignmentPerItemHint =>
      'Elige un material para este elemento.';

  @override
  String get batchCostingMaterialAssignmentRequiredError =>
      'Elige un material para continuar.';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => 'Anterior';

  @override
  String get batchCostingMaterialAssignmentNextButton => 'Siguiente';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      'Añade al menos un material o bobina para continuar.';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return 'Lo requerido $required supera el stock seleccionado $available.';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => 'Ámbito de precio';

  @override
  String get batchCostingPricingScopeSubtitle =>
      'Define dónde se aplica cada valor de precio.';

  @override
  String get batchCostingPricingScopeItemMode => 'Artículo';

  @override
  String get batchCostingPricingScopeBatchMode => 'Lote';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => 'Artículo (por copia)';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'Lote (una vez)';

  @override
  String get batchCostingPricingScopeScopeLabel => 'Ámbito';

  @override
  String get batchCostingSummaryAppBarTitle => 'Resumen del lote';

  @override
  String get batchCostingSummarySubtitle =>
      'Revise el lote antes de generar una cotización.';

  @override
  String get batchCostingSummaryOverviewTitle => 'Resumen';

  @override
  String get batchCostingSummaryItemCountLabel => 'Elementos';

  @override
  String get batchCostingSummaryTotalQuantityLabel => 'Cantidad total';

  @override
  String get batchCostingSummaryTotalWeightLabel => 'Peso total';

  @override
  String get batchCostingSummaryTotalDurationLabel =>
      'Tiempo total de impresión';

  @override
  String get batchCostingSummaryItemWeightLabel => 'Peso';

  @override
  String get batchCostingSummaryItemDurationLabel => 'Tiempo de impresión';

  @override
  String get batchCostingSummaryItemBaseCostLabel => 'Coste base';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => 'Ajustes';

  @override
  String get batchCostingSummaryItemTotalLabel => 'Total del elemento';

  @override
  String get batchCostingSummaryFinalTotalLabel => 'Total final';

  @override
  String get batchCostingSummaryBackButton => 'Volver al ámbito de precio';

  @override
  String get batchCostingSummaryReturnToCalculatorButton =>
      'Volver a la calculadora';

  @override
  String get batchCostingSummaryStartNewBatchButton => 'Iniciar nuevo lote';

  @override
  String get batchCostingSummaryEmptyTitle => 'Aún no hay resumen';

  @override
  String get batchCostingSummaryEmptyBody =>
      'Añade elementos y define el ámbito antes de revisar el resumen.';

  @override
  String get batchCostingSummaryPricingTitle => 'Precios';

  @override
  String get batchCostingSummaryItemsTitle => 'Artículos';

  @override
  String get batchCostingNewBatchDialogTitle => 'Iniciar nuevo lote';

  @override
  String get batchCostingNewBatchDialogBody =>
      'Esto descartará todo el progreso actual del lote. ¿Iniciar un nuevo lote?';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnit cada uno → $lineTotal total';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'Impresora';

  @override
  String get batchCostingEntryButton => 'Iniciar presupuesto por lote';

  @override
  String get paywallTitle => 'Desbloquea Premium';

  @override
  String get paywallPitchLine =>
      'Materiales ilimitados, impresoras ilimitadas, exportación por lotes, precios avanzados';

  @override
  String get paywallSubtitle =>
      'Desbloquea todas las funciones con una compra única o una suscripción. Sin cuentas, sin seguimiento, solo tus datos en tu dispositivo.';

  @override
  String get paywallOfferingError =>
      'No se pudieron cargar los paquetes. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get paywallCta => 'Desbloquea Premium';

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallRowPrintersLabel => 'Impresoras';

  @override
  String get paywallRowMaterialsLabel => 'Materiales';

  @override
  String get paywallRowHistoryLabel => 'Guardados del historial';

  @override
  String get paywallRowBatchCostingLabel => 'Cálculo por lotes';

  @override
  String get paywallRowAdvancedPricingLabel => 'Precios avanzados';

  @override
  String get paywallRowExportToolsLabel => 'Herramientas de exportación';

  @override
  String get paywallRowInventoryTrackingLabel => 'Seguimiento de inventario';

  @override
  String get paywallValueUnlimited => 'Ilimitado';

  @override
  String get paywallValueYes => 'Sí';

  @override
  String get paywallValueNo => 'No';

  @override
  String get paywallValueBasic => 'Básico';

  @override
  String get paywallValueFull => 'Completo';

  @override
  String get paywallValueSingleJob => 'Trabajo único';

  @override
  String get paywallValueFullSuite => 'Suite completa';

  @override
  String paywallValueUpToModels(Object limit) {
    return 'Hasta $limit modelos';
  }

  @override
  String get paywallBestValue => 'Mejor valor';

  @override
  String get paywallPlanMonthly => 'Mensual';

  @override
  String get paywallPlanQuarterly => 'Trimestral';

  @override
  String get paywallPlanAnnual => 'Anual';

  @override
  String get paywallPlanLifetime => 'De por vida';

  @override
  String paywallPlanPriceMonthly(Object price) {
    return '$price / mes';
  }

  @override
  String paywallPlanPriceQuarterly(Object price) {
    return '$price / 3 meses';
  }

  @override
  String paywallPlanPriceAnnual(Object price) {
    return '$price / año';
  }

  @override
  String paywallPlanPriceLifetime(Object price) {
    return '$price una vez';
  }

  @override
  String get paywallPlanTrial => 'Prueba gratuita de 7 días';

  @override
  String get paywallPlanCancelAnytime => 'Cancela en cualquier momento';

  @override
  String get paywallPlanOwnForever => 'Disfruta de Premium para siempre';

  @override
  String get paywallTrustLine => 'Primero sin conexión • No se requiere cuenta';

  @override
  String get paywallCtaAnnualTrial => 'Iniciar prueba gratuita de 7 días';

  @override
  String paywallCtaQuarterly(Object price) {
    return 'Actualizar por $price';
  }

  @override
  String paywallCtaLifetime(Object price) {
    return 'Desbloquea Premium por $price';
  }

  @override
  String paywallCtaGeneric(Object price) {
    return 'Actualizar por $price';
  }

  @override
  String paywallValueSaves(Object limit) {
    return '$limit guardados';
  }

  @override
  String get paywallFeatureMaterialsTitle => 'Materiales ilimitados';

  @override
  String get paywallFeatureMaterialsDesc =>
      'Guarda y gestiona bobinas de filamento y materiales ilimitados.';

  @override
  String get paywallFeaturePrintersTitle => 'Impresoras ilimitadas';

  @override
  String get paywallFeaturePrintersDesc =>
      'Crea y gestiona perfiles de impresora ilimitados.';

  @override
  String get paywallFeatureHistoryExportTitle => 'Exportación del historial';

  @override
  String get paywallFeatureHistoryExportDesc =>
      'Exporta entradas individuales del historial a CSV.';

  @override
  String get paywallFeatureBulkHistoryExportTitle =>
      'Exportación masiva del historial';

  @override
  String get paywallFeatureBulkHistoryExportDesc =>
      'Exporta todo el historial de una vez a CSV.';

  @override
  String get paywallFeatureBatchGcodeImportTitle =>
      'Importación de G-code por lotes';

  @override
  String get paywallFeatureBatchGcodeImportDesc =>
      'Importa varios archivos G-code a la vez para el cálculo por lotes.';

  @override
  String get paywallFeatureBatchExportTitle => 'Exportación por lotes';

  @override
  String get paywallFeatureBatchExportDesc =>
      'Exporta presupuestos y resúmenes por lotes.';

  @override
  String get paywallFeatureLabourPricingTitle => 'Precios de mano de obra';

  @override
  String get paywallFeatureLabourPricingDesc =>
      'Añade tarifas horarias de mano de obra a los cálculos de costes.';

  @override
  String get paywallFeatureRiskPricingTitle => 'Precios por riesgo';

  @override
  String get paywallFeatureRiskPricingDesc =>
      'Ten en cuenta el riesgo de fallo en el precio automáticamente.';

  @override
  String get paywallFeatureAdvancedPricingConfigTitle => 'Precios avanzados';

  @override
  String get paywallFeatureAdvancedPricingConfigDesc =>
      'Configura margen, tarifas de preparación y redondeo.';

  @override
  String get paywallFeatureCsvMaterialImportTitle =>
      'Importación de materiales CSV';

  @override
  String get paywallFeatureCsvMaterialImportDesc =>
      'Importa materiales en lote desde archivos CSV.';

  @override
  String get paywallFeatureStockTrackingTitle => 'Seguimiento de stock';

  @override
  String get paywallFeatureStockTrackingDesc =>
      'Haz seguimiento del stock de filamento y recibe alertas de stock bajo.';

  @override
  String get paywallRestoreSuccess => 'Compras restauradas correctamente.';

  @override
  String get paywallRestoreError =>
      'No se pudieron restaurar las compras. Inténtalo de nuevo más tarde.';

  @override
  String get paywallEmptyOfferings =>
      'Actualmente no hay planes de suscripción disponibles. Inténtalo de nuevo más tarde.';

  @override
  String get helpSupportFaqPremiumQuestion => '¿Qué añade Premium?';

  @override
  String get helpSupportFaqPremiumAnswer =>
      'Free incluye todo lo necesario para calcular los costes de impresión, incluyendo electricidad, impresiones multimaterial, importación de G-code y cálculo por lotes.\n\nPremium añade herramientas de precios avanzadas como mano de obra, riesgo de fallo, margen, tarifas de configuración, desgloses detallados de costes, almacenamiento ilimitado de datos y seguimiento del inventario de filamento.';

  @override
  String get helpSupportFaqPremiumUpgradeCta => 'Mejorar a Premium';

  @override
  String get helpSupportFaqPremiumComparisonCta => 'Ver comparativa completa →';

  @override
  String get dataBackupRestoreHeader =>
      'Datos / Copia de seguridad y restauración';

  @override
  String get dataBackupRestoreBody =>
      'Las copias de seguridad incluyen la configuración local de la aplicación, impresoras, materiales y datos guardados. Las compras no están incluidas.';

  @override
  String get dataBackupExportButton => 'Exportar copia de seguridad';

  @override
  String get dataBackupRestoreButton => 'Restaurar copia de seguridad';

  @override
  String get dataBackupRestoreConfirmTitle => '¿Restaurar copia de seguridad?';

  @override
  String get dataBackupRestoreConfirmBody =>
      'Restaurar una copia de seguridad puede reemplazar tus datos locales actuales. ¿Continuar?';

  @override
  String get dataBackupExportSuccess => 'Copia de seguridad exportada';

  @override
  String get dataBackupExportError => 'Error al exportar la copia de seguridad';

  @override
  String get dataBackupRestoreSuccess => 'Copia de seguridad restaurada';

  @override
  String get dataBackupRestoreError =>
      'Error al restaurar la copia de seguridad';

  @override
  String get dataBackupJsonFileTypeLabel => 'JSON';

  @override
  String get settingsPremiumCardTitle => 'Mejorar a Premium';

  @override
  String get settingsPremiumCardBody =>
      'Herramientas avanzadas de precios, uso ilimitado y seguimiento de inventario.';

  @override
  String get settingsPremiumCardCta => 'Mejorar';

  @override
  String get calculatorPremiumFooterBody =>
      'Premium añade herramientas de precios avanzadas.';

  @override
  String get calculatorPremiumFooterCta => 'Más información →';
}
