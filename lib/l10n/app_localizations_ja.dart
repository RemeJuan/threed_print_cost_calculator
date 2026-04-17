// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get calculatorAppBarTitle => '3Dプリント計算機';

  @override
  String get historyAppBarTitle => '履歴';

  @override
  String get settingsAppBarTitle => '設定';

  @override
  String get calculatorNavLabel => '計算機';

  @override
  String get historyNavLabel => '履歴';

  @override
  String get settingsNavLabel => '設定';

  @override
  String get generalHeader => '一般';

  @override
  String get wattLabel => 'ワット（3Dプリンター）';

  @override
  String get printWeightLabel => 'プリントの重さ';

  @override
  String get hoursLabel => '印刷時間（時間）';

  @override
  String get wearAndTearLabel => '材質/摩耗';

  @override
  String get labourRateLabel => '時給';

  @override
  String get labourTimeLabel => '処理時間';

  @override
  String get failureRiskLabel => '失敗リスク（％）';

  @override
  String get minutesLabel => '分';

  @override
  String get spoolWeightLabel => 'スプール/樹脂重量';

  @override
  String get spoolCostLabel => 'スプール/樹脂コスト';

  @override
  String get electricityCostLabel => '電気代';

  @override
  String get electricityCostSettingsLabel => '電気料金';

  @override
  String get submitButton => '計算する';

  @override
  String get resultElectricityPrefix => '電気代合計:';

  @override
  String get resultFilamentPrefix => 'フィラメントの合計コスト:';

  @override
  String get resultTotalPrefix => '総費用： ';

  @override
  String get riskTotalPrefix => 'リスクコスト:';

  @override
  String get premiumHeader => 'プレミアムユーザーのみ:';

  @override
  String get labourCostPrefix => '人件費/材料： ';

  @override
  String get selectPrinterHint => 'プリンターを選択';

  @override
  String get watt => 'ワット';

  @override
  String get kwh => 'キロワット時';

  @override
  String get savePrintButton => 'プリントを保存';

  @override
  String get printNameHint => 'プリント名';

  @override
  String get printerNameLabel => '名前 *';

  @override
  String get bedSizeLabel => 'ベッドサイズ *';

  @override
  String get wattageLabel => '消費電力 *';

  @override
  String get materialNameLabel => '材料名 *';

  @override
  String get colorLabel => '色 *';

  @override
  String get weightLabel => '重量 *';

  @override
  String get costLabel => 'コスト *';

  @override
  String get saveButton => '保存';

  @override
  String get deleteDialogTitle => '削除';

  @override
  String get deleteDialogContent => 'この項目を削除してもよろしいですか？';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get deleteButton => '削除';

  @override
  String get selectMaterialHint => 'カスタム（未保存）';

  @override
  String get materialNone => 'なし';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => '残量:';

  @override
  String get trackRemainingFilamentLabel => '残りフィラメントを追跡';

  @override
  String get remainingFilamentLabel => '残りフィラメント';

  @override
  String get savePrintErrorMessage => 'プリントの保存中にエラーが発生しました';

  @override
  String get savePrintSuccessMessage => 'プリントを保存しました';

  @override
  String get historyLoadAction => '計算機で編集';

  @override
  String get historyLoadSuccessMessage => '履歴から読み込みました';

  @override
  String get historyLoadReplacementWarning => '一部の項目は利用できなかったため置き換えられました';

  @override
  String get numberExampleHint => '例: 123';

  @override
  String materialsLoadError(Object error) {
    return '材料の読み込みに失敗しました: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'プリンターの読み込みに失敗しました: $error';
  }

  @override
  String get retryButton => '再試行';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'ヘルプが必要ですか？';

  @override
  String get supportEmailPrefix => '問題がある場合は、次のアドレスまでメールしてください: ';

  @override
  String get supportEmail => 'google@remej.dev';

  @override
  String get supportIdLabel => 'サポートIDを含めてください: ';

  @override
  String get clickToCopy => '（タップしてコピー）';

  @override
  String get materialWeightExplanation =>
      '材料重量は元の材料全体の重量、つまりフィラメントロール全体の重量です。コストはユニット全体の価格です。';

  @override
  String get supportIdCopied => 'サポートIDをコピーしました';

  @override
  String get exportSuccess => 'エクスポートに成功しました';

  @override
  String get exportError => 'エクスポートに失敗しました';

  @override
  String get exportButton => 'エクスポート';

  @override
  String get privacyPolicyLink => 'プライバシーポリシー';

  @override
  String get termsOfUseLink => '利用規約';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => '閉じる';

  @override
  String get testDataToolsTitle => 'テストデータツール';

  @override
  String get testDataToolsBody =>
      'これらの操作はローカルテスト専用です。投入すると現在のローカル設定がデモデータに置き換わります。消去するとこの端末のローカルアプリデータが完全に削除されます。';

  @override
  String get seedTestDataButton => 'テストデータを投入';

  @override
  String get purgeLocalDataButton => 'ローカルデータを消去';

  @override
  String get enablePremiumButton => 'プレミアムを有効化';

  @override
  String get enablePremiumTitle => 'プレミアムを有効化';

  @override
  String get enablePremiumBody => 'ローカルのプレミアムテストを有効にする確認コードを入力してください';

  @override
  String get invalidConfirmationCodeMessage => '確認コードが無効です';

  @override
  String get seedTestDataConfirmTitle => 'テストデータを投入しますか？';

  @override
  String get seedTestDataConfirmBody => '現在のローカル設定が、決定的なデモデータに置き換わります。';

  @override
  String get purgeLocalDataConfirmTitle => 'ローカルデータを消去しますか？';

  @override
  String get purgeLocalDataConfirmBody => 'この端末のローカルアプリデータがすべて完全に削除されます。';

  @override
  String get testDataSeededMessage => 'テストデータを投入しました';

  @override
  String get testDataPurgedMessage => 'ローカルデータを消去しました';

  @override
  String get testDataActionFailedMessage => 'テストデータ操作に失敗しました';

  @override
  String get mailClientError => 'メールクライアントを開けませんでした';

  @override
  String get offeringsError => 'エラー: ';

  @override
  String get currentOfferings => '現在のオファー';

  @override
  String get purchaseError => '購入処理中にエラーが発生しました。後でもう一度お試しください。';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get printersHeader => 'プリンター';

  @override
  String get materialsHeader => '材料';

  @override
  String get filamentCostLabel => 'フィラメント';

  @override
  String get labourCostLabel => '人件費';

  @override
  String get riskCostLabel => 'リスク';

  @override
  String get totalCostLabel => '総費用';

  @override
  String get workCostsLabel => '作業コスト';

  @override
  String get enterNumber => '数値を入力してください';

  @override
  String get invalidNumber => '無効な数値です';

  @override
  String get validationRequired => '必須';

  @override
  String get validationEnterValidNumber => '有効な数値を入力してください';

  @override
  String get validationMustBeGreaterThanZero => '0より大きい値を入力してください';

  @override
  String get validationMustBeZeroOrMore => '0以上の値を入力してください';

  @override
  String get lockedValuePlaceholder => 'ロック中';

  @override
  String get hideProPromotionsTitle => 'Proのプロモーションを非表示';

  @override
  String get hideProPromotionsSubtitle => 'アップグレードのバナーと案内を非表示';

  @override
  String get historySearchHint => '名前やプリンターで検索';

  @override
  String get historyExportMenuTitle => '印刷データを書き出す';

  @override
  String get historyExportRangeAll => 'すべて';

  @override
  String get historyExportRangeLast7Days => '過去7日間';

  @override
  String get historyExportRangeLast30Days => '過去30日間';

  @override
  String get historyEmptyTitle => '保存されたプリントはまだありません';

  @override
  String get historyEmptyDescription => '過去のプリントを計算機で再利用できます';

  @override
  String get historyUpsellTitle => '過去のプリントをすぐに再利用';

  @override
  String get historyUpsellDescription => '高度な編集とエクスポートをアンロック';

  @override
  String get historyNoMoreRecords => 'これ以上の記録はありません';

  @override
  String get historyOverflowHint => 'その他の操作は ⋯ にあります';

  @override
  String historyLoadError(Object error) {
    return '履歴を読み込めませんでした: $error';
  }

  @override
  String get historyCsvHeader =>
      '日付,プリンター,材料,材料一覧,重量 (g),時間,電力,フィラメント,作業,リスク,合計';

  @override
  String get historyExportShareText => '3Dプリント費用履歴の書き出し';

  @override
  String get historyTeaserTitle => 'すべての印刷見積もりを1か所に保存';

  @override
  String get historyTeaserDescription =>
      '履歴の仕組みを確認してからProにアップグレードしましょう。完了した見積もりを保存し、いつでもProで書き出せます。';

  @override
  String get historyTeaserCta => '履歴をProで保存・書き出し';

  @override
  String get historyExportPreviewEntry => 'CSV書き出しのプレビュー';

  @override
  String get historyExportPreviewTitle => 'CSVプレビュー';

  @override
  String get historyExportPreviewDescription =>
      '書き出しがどう見えるか確認できます。ダウンロードと共有はProで有効になります。';

  @override
  String get historyExportPreviewSampleLabel => '[サンプル]';

  @override
  String get historyExportPreviewAction => 'Proでダウンロード / 共有';

  @override
  String get addMaterialButton => '素材を追加';

  @override
  String get useSingleTotalWeightAction => '単一の合計重量を使用';

  @override
  String get addAtLeastOneMaterial => '少なくとも1つの素材を追加してください。';

  @override
  String get searchMaterialsHint => '素材を検索';

  @override
  String get materialBreakdownLabel => '素材内訳';

  @override
  String materialsCountLabel(num count) {
    return '$count 件の素材';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return '素材の合計重量: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'バージョン $version';
  }

  @override
  String get materialFallback => '素材';
}
