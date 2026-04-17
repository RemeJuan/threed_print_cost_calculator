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
  String get generalHeader => 'Geral';

  @override
  String get wattLabel => 'Watt (impressora 3D)';

  @override
  String get printWeightLabel => 'Peso da impressão';

  @override
  String get hoursLabel => 'Tempo de impressão (horas)';

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
  String get savePrintSuccessMessage => 'Impressão salva';

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
  String get supportEmailPrefix =>
      'Em caso de problemas, envie um e-mail para ';

  @override
  String get supportEmail => 'google@remej.dev';

  @override
  String get supportIdLabel => 'Inclua seu ID de suporte: ';

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
  String get termsOfUseLink => 'Termos de Uso';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Fechar';

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
  String get riskCostLabel => 'Risco';

  @override
  String get totalCostLabel => 'Custo total';

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
      'Data,Impressora,Material,Materiais,Peso (g),Tempo,Eletricidade,Filamento,Mão de obra,Risco,Total';

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
  String get searchMaterialsHint => 'Pesquisar materiais';

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
}
