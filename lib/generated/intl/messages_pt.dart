// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'pt';

  static String m0(count) =>
      "${Intl.plural(count, one: '# material', other: '# materiais')}";

  static String m1(grams) => "Peso total do material: ${grams}g";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "Adicione pelo menos um material.",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage("Adicionar"),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("Tamanho da mesa *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Calculadora de impressão 3D",
    ),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("Calculadora"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage("(toque para copiar)"),
    "closeButton": MessageLookupByLibrary.simpleMessage("Fechar"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("Cor *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("Custo *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage("Ofertas atuais"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("Excluir"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja excluir este item?",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("Excluir"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage(
      "Custo de eletricidade",
    ),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "Custo de eletricidade",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage("Digite um número"),
    "exportButton": MessageLookupByLibrary.simpleMessage("Exportar"),
    "exportError": MessageLookupByLibrary.simpleMessage("Falha na exportação"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage(
      "Exportação bem-sucedida",
    ),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage(
      "Risco de falha (%)",
    ),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("Filamento"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("Histórico"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("Histórico"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage(
      "Pesquisar por nome ou impressora",
    ),
    "hoursLabel": MessageLookupByLibrary.simpleMessage(
      "Tempo de impressão (horas)",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("Número inválido"),
    "kwh": MessageLookupByLibrary.simpleMessage("kWh"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("Mão de obra"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage(
      "Mão de obra/Materiais: ",
    ),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("Taxa horária"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage(
      "Tempo de processamento",
    ),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "Não foi possível abrir o cliente de e-mail",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage(
      "Detalhamento de materiais",
    ),
    "materialFallback": MessageLookupByLibrary.simpleMessage("Material padrão"),
    "materialNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nome do material *",
    ),
    "materialNone": MessageLookupByLibrary.simpleMessage("Nenhum"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "O peso do material é o peso total do material de origem, ou seja, todo o rolo de filamento. O custo é o custo da unidade inteira.",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("Materiais"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("Minutos"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage("Precisa de ajuda?"),
    "offeringsError": MessageLookupByLibrary.simpleMessage("Erro: "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage(
      "Apenas usuários premium:",
    ),
    "printNameHint": MessageLookupByLibrary.simpleMessage("Nome da impressão"),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso da impressão",
    ),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("Nome *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("Impressoras"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage(
      "Política de Privacidade",
    ),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "Houve um erro ao processar sua compra. Tente novamente mais tarde.",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage(
      "Restaurar compras",
    ),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage(
      "Custo total de eletricidade: ",
    ),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "Custo total do filamento: ",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("Custo total: "),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("Risco"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage("Custo do risco: "),
    "saveButton": MessageLookupByLibrary.simpleMessage("Salvar"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage("Salvar impressão"),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage(
      "Pesquisar materiais",
    ),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage(
      "Não selecionado",
    ),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage(
      "Selecionar impressora",
    ),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage(
      "Configurações",
    ),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("Configurações"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage(
      "Custo do carretel/resina",
    ),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage(
      "Peso do carretel/resina",
    ),
    "submitButton": MessageLookupByLibrary.simpleMessage("Calcular"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "Em caso de problemas, envie um e-mail para ",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage(
      "ID de suporte copiado",
    ),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage(
      "Inclua seu ID de suporte: ",
    ),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage("Termos de Uso"),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("Custo total"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "Usar peso total único",
    ),
    "watt": MessageLookupByLibrary.simpleMessage("Watt"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("Watt (impressora 3D)"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("Potência *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage(
      "Materiais/desgaste + rasgo",
    ),
    "weightLabel": MessageLookupByLibrary.simpleMessage("Peso *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage(
      "Custos de mão de obra",
    ),
  };
}
