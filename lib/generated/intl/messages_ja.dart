// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  String get localeName => 'ja';

  static String m0(count) => "${count} 件の材料";

  static String m1(grams) => "素材の合計重量: ${grams}g";

  static String m2(version) => "バージョン ${version}";

  static String m3(error) => "材料の読み込みに失敗しました: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addAtLeastOneMaterial": MessageLookupByLibrary.simpleMessage(
      "少なくとも1つの素材を追加してください。",
    ),
    "addMaterialButton": MessageLookupByLibrary.simpleMessage("素材を追加"),
    "bedSizeLabel": MessageLookupByLibrary.simpleMessage("ベッドサイズ *"),
    "calculatorAppBarTitle": MessageLookupByLibrary.simpleMessage("3Dプリント計算機"),
    "calculatorNavLabel": MessageLookupByLibrary.simpleMessage("計算機"),
    "cancelButton": MessageLookupByLibrary.simpleMessage("キャンセル"),
    "clickToCopy": MessageLookupByLibrary.simpleMessage("（タップしてコピー）"),
    "closeButton": MessageLookupByLibrary.simpleMessage("閉じる"),
    "colorLabel": MessageLookupByLibrary.simpleMessage("色 *"),
    "costLabel": MessageLookupByLibrary.simpleMessage("コスト *"),
    "currentOfferings": MessageLookupByLibrary.simpleMessage("現在のオファー"),
    "deleteButton": MessageLookupByLibrary.simpleMessage("削除"),
    "deleteDialogContent": MessageLookupByLibrary.simpleMessage(
      "この項目を削除してもよろしいですか？",
    ),
    "deleteDialogTitle": MessageLookupByLibrary.simpleMessage("削除"),
    "electricityCostLabel": MessageLookupByLibrary.simpleMessage("電気代"),
    "electricityCostSettingsLabel": MessageLookupByLibrary.simpleMessage(
      "電気料金",
    ),
    "enterNumber": MessageLookupByLibrary.simpleMessage("数値を入力してください"),
    "exportButton": MessageLookupByLibrary.simpleMessage("エクスポート"),
    "exportError": MessageLookupByLibrary.simpleMessage("エクスポートに失敗しました"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("エクスポートに成功しました"),
    "failureRiskLabel": MessageLookupByLibrary.simpleMessage("失敗リスク（％）"),
    "filamentCostLabel": MessageLookupByLibrary.simpleMessage("フィラメント"),
    "gramsSuffix": MessageLookupByLibrary.simpleMessage("g"),
    "historyAppBarTitle": MessageLookupByLibrary.simpleMessage("履歴"),
    "historyNavLabel": MessageLookupByLibrary.simpleMessage("履歴"),
    "historySearchHint": MessageLookupByLibrary.simpleMessage("名前やプリンターで検索"),
    "hoursLabel": MessageLookupByLibrary.simpleMessage("印刷時間（時間）"),
    "invalidNumber": MessageLookupByLibrary.simpleMessage("無効な数値です"),
    "kwh": MessageLookupByLibrary.simpleMessage("キロワット時"),
    "labourCostLabel": MessageLookupByLibrary.simpleMessage("人件費"),
    "labourCostPrefix": MessageLookupByLibrary.simpleMessage("人件費/材料： "),
    "labourRateLabel": MessageLookupByLibrary.simpleMessage("時給"),
    "labourTimeLabel": MessageLookupByLibrary.simpleMessage("処理時間"),
    "mailClientError": MessageLookupByLibrary.simpleMessage(
      "メールクライアントを開けませんでした",
    ),
    "materialBreakdownLabel": MessageLookupByLibrary.simpleMessage("素材内訳"),
    "materialFallback": MessageLookupByLibrary.simpleMessage("材料"),
    "materialsLoadError": m3,
    "materialNameLabel": MessageLookupByLibrary.simpleMessage("材料名 *"),
    "materialNone": MessageLookupByLibrary.simpleMessage("なし"),
    "materialWeightExplanation": MessageLookupByLibrary.simpleMessage(
      "材料重量は元の材料全体の重量、つまりフィラメントロール全体の重量です。コストはユニット全体の価格です。",
    ),
    "materialsCountLabel": m0,
    "materialsHeader": MessageLookupByLibrary.simpleMessage("材料"),
    "minutesLabel": MessageLookupByLibrary.simpleMessage("分"),
    "needHelpTitle": MessageLookupByLibrary.simpleMessage("ヘルプが必要ですか？"),
    "numberExampleHint": MessageLookupByLibrary.simpleMessage("例: 123"),
    "offeringsError": MessageLookupByLibrary.simpleMessage("エラー: "),
    "premiumHeader": MessageLookupByLibrary.simpleMessage("プレミアムユーザーのみ:"),
    "printNameHint": MessageLookupByLibrary.simpleMessage("プリント名"),
    "printWeightLabel": MessageLookupByLibrary.simpleMessage("プリントの重さ"),
    "printerNameLabel": MessageLookupByLibrary.simpleMessage("名前 *"),
    "printersHeader": MessageLookupByLibrary.simpleMessage("プリンター"),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage("プライバシーポリシー"),
    "remainingFilamentLabel": MessageLookupByLibrary.simpleMessage("残りフィラメント"),
    "remainingLabel": MessageLookupByLibrary.simpleMessage("残量:"),
    "purchaseError": MessageLookupByLibrary.simpleMessage(
      "購入処理中にエラーが発生しました。後でもう一度お試しください。",
    ),
    "restorePurchases": MessageLookupByLibrary.simpleMessage("購入を復元"),
    "retryButton": MessageLookupByLibrary.simpleMessage("再試行"),
    "resultElectricityPrefix": MessageLookupByLibrary.simpleMessage("電気代合計:"),
    "resultFilamentPrefix": MessageLookupByLibrary.simpleMessage(
      "フィラメントの合計コスト:",
    ),
    "resultTotalPrefix": MessageLookupByLibrary.simpleMessage("総費用： "),
    "riskCostLabel": MessageLookupByLibrary.simpleMessage("リスク"),
    "riskTotalPrefix": MessageLookupByLibrary.simpleMessage("リスクコスト:"),
    "saveButton": MessageLookupByLibrary.simpleMessage("保存"),
    "savePrintButton": MessageLookupByLibrary.simpleMessage("プリントを保存"),
    "savePrintErrorMessage": MessageLookupByLibrary.simpleMessage(
      "プリントの保存中にエラーが発生しました",
    ),
    "savePrintSuccessMessage": MessageLookupByLibrary.simpleMessage(
      "プリントを保存しました",
    ),
    "searchMaterialsHint": MessageLookupByLibrary.simpleMessage("素材を検索"),
    "selectMaterialHint": MessageLookupByLibrary.simpleMessage("カスタム（未保存）"),
    "selectPrinterHint": MessageLookupByLibrary.simpleMessage("プリンターを選択"),
    "separator": MessageLookupByLibrary.simpleMessage(" | "),
    "settingsAppBarTitle": MessageLookupByLibrary.simpleMessage("設定"),
    "settingsNavLabel": MessageLookupByLibrary.simpleMessage("設定"),
    "spoolCostLabel": MessageLookupByLibrary.simpleMessage("スプール/樹脂コスト"),
    "spoolWeightLabel": MessageLookupByLibrary.simpleMessage("スプール/樹脂重量"),
    "submitButton": MessageLookupByLibrary.simpleMessage("計算する"),
    "supportEmail": MessageLookupByLibrary.simpleMessage("google@remej.dev"),
    "supportEmailPrefix": MessageLookupByLibrary.simpleMessage(
      "問題がある場合は、次のアドレスまでメールしてください: ",
    ),
    "trackRemainingFilamentLabel": MessageLookupByLibrary.simpleMessage(
      "残りフィラメントを追跡",
    ),
    "supportIdCopied": MessageLookupByLibrary.simpleMessage("サポートIDをコピーしました"),
    "supportIdLabel": MessageLookupByLibrary.simpleMessage("サポートIDを含めてください: "),
    "termsOfUseLink": MessageLookupByLibrary.simpleMessage("利用規約"),
    "totalCostLabel": MessageLookupByLibrary.simpleMessage("総費用"),
    "totalMaterialWeightLabel": m1,
    "useSingleTotalWeightAction": MessageLookupByLibrary.simpleMessage(
      "単一の合計重量を使用",
    ),
    "versionLabel": m2,
    "watt": MessageLookupByLibrary.simpleMessage("ワット"),
    "wattLabel": MessageLookupByLibrary.simpleMessage("ワット（3Dプリンター）"),
    "wattageLabel": MessageLookupByLibrary.simpleMessage("消費電力 *"),
    "wattsSuffix": MessageLookupByLibrary.simpleMessage("w"),
    "wearAndTearLabel": MessageLookupByLibrary.simpleMessage("材質/摩耗"),
    "weightLabel": MessageLookupByLibrary.simpleMessage("重量 *"),
    "workCostsLabel": MessageLookupByLibrary.simpleMessage("作業コスト"),
  };
}
