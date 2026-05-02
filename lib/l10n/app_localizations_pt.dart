// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get calculatorAppBarTitle => 'Calculadora de impressão 3D';

  @override
  String get historyAppBarTitle => 'Histórico';

  @override
  String get settingsAppBarTitle => 'Configurações';

  @override
  String get calculatorNavLabel => 'Calculadora';

  @override
  String get historyNavLabel => 'Histórico';

  @override
  String get settingsNavLabel => 'Configurações';

  @override
  String get newAnnouncementBadgeLabel => 'Novo';

  @override
  String get generalHeader => 'Geral';

  @override
  String get wattLabel => 'Watt (impressora 3D)';

  @override
  String get printWeightLabel => 'Peso da impressão';

  @override
  String get hoursLabel => 'Tempo de impressão (horas)';

  @override
  String get durationHoursLabel => 'Horas';

  @override
  String get wearAndTearLabel => 'Materiais/desgaste + rasgo';

  @override
  String get labourRateLabel => 'Taxa horária';

  @override
  String get labourTimeLabel => 'Tempo de processamento';

  @override
  String get failureRiskLabel => 'Risco de falha (%)';

  @override
  String get minutesLabel => 'Minutos';

  @override
  String get durationMinutesLabel => 'Minutos';

  @override
  String get printingTimeDialogTitle => 'Tempo de impressão';

  @override
  String get workTimeDialogTitle => 'Tempo de trabalho';

  @override
  String get spoolWeightLabel => 'Peso do carretel/resina';

  @override
  String get spoolCostLabel => 'Custo do carretel/resina';

  @override
  String get electricityCostLabel => 'Custo de eletricidade';

  @override
  String get electricityCostSettingsLabel => 'Custo de eletricidade';

  @override
  String get submitButton => 'Calcular';

  @override
  String get resultElectricityPrefix => 'Custo total de eletricidade: ';

  @override
  String get resultFilamentPrefix => 'Custo total do filamento: ';

  @override
  String get resultTotalPrefix => 'Custo total: ';

  @override
  String get riskTotalPrefix => 'Custo do risco: ';

  @override
  String get premiumHeader => 'Apenas usuários premium:';

  @override
  String get labourCostPrefix => 'Mão de obra/Materiais: ';

  @override
  String get selectPrinterHint => 'Selecionar impressora';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Salvar impressão';

  @override
  String get printNameHint => 'Nome da impressão';

  @override
  String get printerNameLabel => 'Nome *';

  @override
  String get bedSizeLabel => 'Tamanho da mesa *';

  @override
  String get wattageLabel => 'Potência *';

  @override
  String get materialNameLabel => 'Nome do material *';

  @override
  String get colorLabel => 'Cor *';

  @override
  String get weightLabel => 'Peso *';

  @override
  String get costLabel => 'Custo *';

  @override
  String get saveButton => 'Salvar';

  @override
  String get deleteDialogTitle => 'Excluir';

  @override
  String get deleteDialogContent =>
      'Tem certeza de que deseja excluir este item?';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get resetButtonLabel => 'Redefinir';

  @override
  String get resetCalculationTitle => 'Redefinir cálculo?';

  @override
  String get resetCalculationBody =>
      'Isso descartará os valores atuais da calculadora e recarregará os padrões atuais.';

  @override
  String get deleteButton => 'Excluir';

  @override
  String get selectMaterialHint => 'Personalizado (não salvo)';

  @override
  String get materialNone => 'Nenhum';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => 'Restante:';

  @override
  String get trackRemainingFilamentLabel => 'Monitorar filamento restante';

  @override
  String get remainingFilamentLabel => 'Filamento restante';

  @override
  String get savePrintErrorMessage => 'Erro ao salvar a impressão';

  @override
  String get deleteRecordErrorMessage => 'Erro ao remover o registo';

  @override
  String get savePrintSuccessMessage => 'Impressão salva';

  @override
  String get deleteMaterialSuccessMessage => 'Material removido';

  @override
  String get historyLoadAction => 'Editar na calculadora';

  @override
  String get historyLoadSuccessMessage => 'Carregado do histórico';

  @override
  String get historyLoadReplacementWarning =>
      'Alguns itens não estavam disponíveis e foram substituídos';

  @override
  String get numberExampleHint => 'ex.: 123';

  @override
  String materialsLoadError(Object error) {
    return 'Erro ao carregar materiais: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Erro ao carregar impressoras: $error';
  }

  @override
  String get retryButton => 'Tentar novamente';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Precisa de ajuda?';

  @override
  String get helpSupportSupportTitle => 'Suporte';

  @override
  String get helpSupportSupportIntro =>
      'Use esses detalhes ao entrar em contato com o suporte.';

  @override
  String get helpSupportWebsiteLabel => 'Site';

  @override
  String get helpSupportEmailLabel => 'E-mail';

  @override
  String get helpSupportSupportIdLabel => 'ID de suporte';

  @override
  String get helpSupportCopySupportIdTooltip => 'Copiar ID de suporte';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'Versão do app $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Contatar suporte';

  @override
  String get helpSupportContactEmailSubject =>
      'Suporte Calculadora de Custo de Impressão 3D';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'ID de suporte: $supportId\nVersão do app: $version\n\nDescreva o problema aqui.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'ID de suporte: (não disponível)\nVersão do app: $version\n\nDescreva o problema aqui.';
  }

  @override
  String get helpSupportFaqTitle => 'Perguntas frequentes';

  @override
  String get helpSupportFaqWeightQuestion => 'Que peso devo inserir?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Insira o peso total do carretel, não o filamento restante. O app usa o peso do rolo completo para calcular o custo por grama.';

  @override
  String get helpSupportFaqElectricityQuestion =>
      'Por que a eletricidade é importante?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Impressões longas e impressoras de alta potência podem adicionar custo real. Pular a eletricidade geralmente subestima o preço do trabalho.';

  @override
  String get helpSupportFaqRiskQuestion => 'Como o risco de falha é calculado?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'O risco é aplicado apenas aos custos básicos de impressão como filamento e eletricidade. Ele estima a perda esperada de impressões falhadas.';

  @override
  String get helpSupportFaqLabourQuestion =>
      'O que é tempo de mão de obra / processamento?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Cobre preparação, limpeza, pós-processamento e monitoramento. Mantenha ligado para serviços onde seu tempo importa.';

  @override
  String get helpSupportFaqMarkupQuestion => 'O que é margem de lucro?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'A margem de lucro é a porcentagem adicionada em cima do custo total para atingir seu preço de venda. Ela cobre margem, despesas gerais e lucro.';

  @override
  String get helpSupportFaqSetupQuestion => 'O que é uma taxa de configuração?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Uma taxa de configuração é um custo fixo por trabalho para calibração, preparação da máquina e administração. Ajuda impressões pequenas a cobrir despesas gerais.';

  @override
  String get helpSupportLinksTitle => 'Links';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Política de privacidade';

  @override
  String get helpSupportTermsOfUseLabel => 'Termos de uso';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'Sobre';

  @override
  String get helpSupportAboutIntro =>
      'A Calculadora de Custo de Impressão 3D é construída para preços local-first. Ajuda criadores e pequenos negócios de impressão a cotar trabalhos com menos surpresas.';

  @override
  String get helpSupportTrustNoAccounts => 'Sem contas';

  @override
  String get helpSupportTrustNoCloudSync => 'Sem sincronização na nuvem';

  @override
  String get helpSupportTrustNoTracking => 'Sem rastreamento';

  @override
  String get helpSupportTrustLocalData => 'Dados locais';

  @override
  String get helpSupportAboutCalculator =>
      'A calculadora combina custo de filamento, eletricidade, risco de falha, mão de obra e ferramentas de preços opcionais como margem de lucro e taxas de configuração.';

  @override
  String get helpSupportAboutOutcome =>
      'Isso mantém orçamentos vinculados ao custo real, não apenas ao gasto com material.';

  @override
  String get supportEmailPrefix =>
      'Em caso de problemas, envie um e-mail para ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Inclua seu ID de suporte: ';

  @override
  String get supportEmailSubject => 'Suporte do 3D Print Cost Calculator';

  @override
  String get clickToCopy => '(toque para copiar)';

  @override
  String get materialWeightExplanation =>
      'O peso do material é o peso total do material de origem, ou seja, todo o rolo de filamento. O custo é o custo da unidade inteira.';

  @override
  String get supportIdCopied => 'ID de suporte copiado';

  @override
  String get exportSuccess => 'Exportação bem-sucedida';

  @override
  String get exportError => 'Falha na exportação';

  @override
  String get exportButton => 'Exportar';

  @override
  String get privacyPolicyLink => 'Política de Privacidade';

  @override
  String get websiteLink => 'Site';

  @override
  String get termsOfUseLink => 'Termos de Uso';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Fechar';

  @override
  String get testDataToolsTitle => 'Ferramentas de dados de teste';

  @override
  String get testDataToolsBody =>
      'Estas ações são apenas para testes locais. A semente substitui a configuração local atual por dados de demonstração. A limpeza remove permanentemente os dados locais do app neste dispositivo.';

  @override
  String get seedTestDataButton => 'Semear dados de teste';

  @override
  String get purgeLocalDataButton => 'Limpar dados locais';

  @override
  String get enablePremiumButton => 'Ativar premium';

  @override
  String get enablePremiumTitle => 'Ativar premium';

  @override
  String get enablePremiumBody =>
      'Insira o código de confirmação para ativar os testes locais de premium';

  @override
  String get invalidConfirmationCodeMessage => 'Código de confirmação inválido';

  @override
  String get seedTestDataConfirmTitle => 'Semear dados de teste?';

  @override
  String get seedTestDataConfirmBody =>
      'Isso substituirá a configuração local atual por dados de demonstração determinísticos.';

  @override
  String get purgeLocalDataConfirmTitle => 'Limpar dados locais?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Isso removerá permanentemente todos os dados locais do app neste dispositivo.';

  @override
  String get testDataSeededMessage => 'Dados de teste semeados';

  @override
  String get testDataPurgedMessage => 'Dados locais limpos';

  @override
  String get testDataActionFailedMessage => 'Ação de dados de teste falhou';

  @override
  String get mailClientError => 'Não foi possível abrir o cliente de e-mail';

  @override
  String get offeringsError => 'Erro: ';

  @override
  String get currentOfferings => 'Ofertas atuais';

  @override
  String get purchaseError =>
      'Houve um erro ao processar sua compra. Tente novamente mais tarde.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get printersHeader => 'Impressoras';

  @override
  String get materialsHeader => 'Materiais';

  @override
  String get filamentCostLabel => 'Filamento';

  @override
  String get labourCostLabel => 'Mão de obra';

  @override
  String get additionalCostLabel => 'Custo adicional';

  @override
  String get additionalCostNoteLabel => 'Nota de custo adicional';

  @override
  String get additionalCostNoteDialogTitle => 'Nota de custo adicional';

  @override
  String get riskCostLabel => 'Risco';

  @override
  String get totalCostLabel => 'Custo total';

  @override
  String get costTotalLabel => 'Custo total';

  @override
  String get markupLabel => 'Margem';

  @override
  String get setupFeeLabel => 'Taxa de configuração';

  @override
  String get roundingAdjustmentLabel => 'Ajuste de arredondamento';

  @override
  String get finalPriceLabel => 'Preço final';

  @override
  String get jobPricingOverridesLabel => 'Configurações do trabalho';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# substituições aplicadas',
      one: '# substituição aplicada',
    );
    return '$_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => '% de margem';

  @override
  String get pricingSetupFeeLabel => 'Taxa de configuração';

  @override
  String get pricingRoundingLabel => 'Arredondamento';

  @override
  String get pricingRoundingNoneLabel => 'Nenhum';

  @override
  String get pricingRoundingWholeDollarLabel => 'Valor inteiro';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Termina em .99';

  @override
  String get workCostsLabel => 'Custos de mão de obra';

  @override
  String get enterNumber => 'Digite um número';

  @override
  String get invalidNumber => 'Número inválido';

  @override
  String get validationRequired => 'Obrigatório';

  @override
  String get validationEnterValidNumber => 'Insira um número válido';

  @override
  String get validationMustBeGreaterThanZero => 'Deve ser maior que 0';

  @override
  String get validationMustBeZeroOrMore => 'Deve ser 0 ou mais';

  @override
  String get lockedValuePlaceholder => 'Bloqueado';

  @override
  String get hideProPromotionsTitle => 'Ocultar promoções Pro';

  @override
  String get hideProPromotionsSubtitle =>
      'Ocultar banners e prompts de atualização';

  @override
  String get historySearchHint => 'Pesquisar por nome ou impressora';

  @override
  String get historyExportMenuTitle => 'Exportar impressões';

  @override
  String get historyExportRangeAll => 'Tudo';

  @override
  String get historyExportRangeLast7Days => 'Últimos 7 dias';

  @override
  String get historyExportRangeLast30Days => 'Últimos 30 dias';

  @override
  String get historyEmptyTitle => 'Ainda não há impressões salvas';

  @override
  String get historyEmptyDescription =>
      'Reutilize impressões anteriores na calculadora';

  @override
  String get historyUpsellTitle =>
      'Reutilize impressões anteriores instantaneamente';

  @override
  String get historyUpsellDescription =>
      'Desbloqueie edições avançadas e exportações';

  @override
  String get historyNoMoreRecords => 'Não há mais registros';

  @override
  String get historyOverflowHint => 'Mais ações em ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Falha ao carregar o histórico: $error';
  }

  @override
  String get historyCsvHeader =>
      'Data,Impressora,Material,Materiais,Peso (g),Tempo,Eletricidade,Filamento,Mão de obra,Risco,Total,% de margem,Valor da margem,Taxa de configuração,Modo de arredondamento,Subtotal antes do arredondamento,Ajuste de arredondamento,Preço final';

  @override
  String get historyExportShareText =>
      'Exportação do histórico de custos de impressão 3D';

  @override
  String get historyTeaserTitle =>
      'Guarde cada estimativa de impressão em um só lugar';

  @override
  String get historyTeaserDescription =>
      'Veja como o histórico funciona antes de fazer upgrade. Salve estimativas concluídas e exporte-as a qualquer momento com o Pro.';

  @override
  String get historyTeaserCta => 'Salvar e exportar histórico com Pro';

  @override
  String get historyExportPreviewEntry => 'Prévia da exportação CSV';

  @override
  String get historyExportPreviewTitle => 'Prévia CSV';

  @override
  String get historyExportPreviewDescription =>
      'Veja como sua exportação ficará. Download e compartilhamento são desbloqueados com o Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Amostra]';

  @override
  String get historyExportPreviewAction => 'Baixar / Compartilhar com Pro';

  @override
  String get addMaterialButton => 'Adicionar';

  @override
  String get useSingleTotalWeightAction => 'Usar peso total único';

  @override
  String get addAtLeastOneMaterial => 'Adicione pelo menos um material.';

  @override
  String get searchMaterialsHint => 'Pesquisar nome ou marca';

  @override
  String get materialBreakdownLabel => 'Detalhamento de materiais';

  @override
  String materialsCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# materiais',
      one: '# material',
    );
    return '$_temp0';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Peso total do material: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Versão $version';
  }

  @override
  String get materialFallback => 'Material padrão';

  @override
  String get durationPickerLabel => 'Printing time (hh:mm)';

  @override
  String get importGcodeButton => 'Importar G-code (Preenchimento auto)';

  @override
  String get importGcodePageTitle => 'Importar G-code (Beta)';

  @override
  String get importGcodeIntro =>
      'Escolha um arquivo .gcode local. Slicers suportados: PrusaSlicer, OrcaSlicer, Bambu Studio e Cura.';

  @override
  String get importGcodeSelectFileButton => 'Selecionar arquivo G-code';

  @override
  String get importGcodePickAnotherButton => 'Selecionar outro arquivo';

  @override
  String get importGcodeSelectedFileLabel => 'Arquivo selecionado';

  @override
  String get gcodeImportFeedbackTitle => 'Feedback Importação G-code Beta';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Funcionalidade beta';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Diga-nos o que funcionou, o que falhou ou o que ainda parece errado.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Qual slicer?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Resultado da pré-visualização';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Resultado de metadados';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'O que funcionou, o que falhou ou o que parece errado?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Anexar arquivo G-code importado';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'Nenhum arquivo G-code importado disponível.';

  @override
  String get gcodeImportFeedbackSendCta => 'Enviar feedback';

  @override
  String get gcodeImportFeedbackSentMessage => 'Feedback enviado';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Pré-visualização carregada';

  @override
  String get gcodeFeedbackPreviewMissing => 'Pré-visualização faltando';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Pré-visualização incorreta';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Não tenho certeza';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Parece correto';

  @override
  String get gcodeFeedbackMetadataMissing => 'Dados faltando';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Dados incorretos';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Não tenho certeza';

  @override
  String get importGcodeSummaryTitle => 'Resumo da importação';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Slicers suportados: PrusaSlicer, OrcaSlicer, Bambu Studio e Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Valores importados preenchem apenas tempo e peso total do material. Impressora, material e custo final vêm das suas configurações.';

  @override
  String get importGcodeUseValuesButton => 'Usar estes valores';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Duração estimada';

  @override
  String get importGcodeFilamentWeightLabel => 'Peso do filamento';

  @override
  String get importGcodeFilamentLengthLabel => 'Comprimento do filamento';

  @override
  String get importGcodeLayerHeightLabel => 'Altura da camada';

  @override
  String get importGcodePreviewLabel => 'Pré-visualização';

  @override
  String get importGcodePreviewAvailable => 'Disponível';

  @override
  String get importGcodePreviewView => 'Ver';

  @override
  String get importGcodePreviewUnavailable => 'Não disponível';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Metadados da pré-visualização encontrados mas a imagem não pôde ser exibida.';

  @override
  String get importGcodePreviewCuraNote =>
      'Pré-visualizações Cura podem requerer script pós-processamento para incorporar thumbnails.';

  @override
  String get importGcodeWarningsTitle => 'Avisos';

  @override
  String get importGcodeUnsupportedTypeError => 'Escolha um arquivo .gcode.';

  @override
  String get importGcodeUnsupportedFileError =>
      'Este arquivo não continha metadados G-code suportados.';

  @override
  String get importGcodeReadError => 'O arquivo selecionado não pôde ser lido.';

  @override
  String get importGcodeUnknownSlicerValue => 'Desconhecido';

  @override
  String get importGcodeMissingValue => 'Não encontrado';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer não identificado. Revise os valores antes de aplicar.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Tempo de impressão não pôde ser detectado.';

  @override
  String get importGcodeWarningMissingFilament =>
      'Uso do filamento incompleto.';

  @override
  String get importGcodeWarningMissingFilamentWeight =>
      'Peso do filamento faltando.';

  @override
  String get importGcodeWarningPartialMetadata => 'Alguns metadados faltando.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Múltiplos totais de material encontrados. Revise antes de aplicar.';

  @override
  String get importGcodeAppliedMessage =>
      'Valores importados aplicados à calculadora';

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
  String get slicerUnknown => 'Desconhecido';

  @override
  String get materialsAppBarTitle => 'Materiais';

  @override
  String get materialsNavLabel => 'Materiais';

  @override
  String get brandLabel => 'Marca';

  @override
  String get materialTypeLabel => 'Tipo de material';

  @override
  String get colorHexLabel => 'Cor hex (opcional)';

  @override
  String get notesLabel => 'Notas';

  @override
  String get materialsEmpty =>
      'Nenhum material ainda. Toque em + para adicionar.';

  @override
  String get materialsFilterAll => 'Todos';

  @override
  String get materialsFilterInStock => 'Em estoque';

  @override
  String get materialsFilterLowStock => 'Estoque baixo';

  @override
  String get materialsFilterOutOfStock => 'Fora de estoque';

  @override
  String get csvImportTitle => 'Importar materiais';

  @override
  String get csvTemplateButton => 'Modelo';

  @override
  String get csvTemplateShareText => 'Modelo CSV de materiais';

  @override
  String get csvTemplateError => 'Não foi possível compartilhar o modelo.';

  @override
  String get csvImportIntro => 'Importe materiais de um arquivo CSV.';

  @override
  String get csvSelectFileButton => 'Escolher arquivo CSV';

  @override
  String get csvImportButton => 'Importar linhas válidas';

  @override
  String get csvReadError => 'Não foi possível ler o arquivo selecionado.';

  @override
  String get csvFileTypeError => 'Selecione um arquivo .csv';

  @override
  String get csvNameRequiredError => 'Nome é obrigatório';

  @override
  String get csvColorRequiredError => 'Cor é obrigatória';

  @override
  String get csvSpoolWeightRequiredError => 'Peso do carretel é obrigatório';

  @override
  String get csvSpoolWeightPositiveError => 'Peso do carretel deve ser > 0';

  @override
  String get csvCostRequiredError => 'Custo é obrigatório';

  @override
  String get csvCostPositiveError => 'Custo deve ser > 0';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materiais importados',
      one: '1 material importado',
    );
    return '$_temp0';
  }

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total linhas: $valid válidas, $invalid com erros';
  }

  @override
  String get csvEmptyNamePlaceholder => '(vazio)';

  @override
  String get stockBadgeOut => 'Sem estoque';

  @override
  String get stockBadgeLow => 'Estoque baixo';

  @override
  String get stockBadgeInStock => 'Em estoque';

  @override
  String get stockBadgeNoTracking => 'Sem rastreio';
}
