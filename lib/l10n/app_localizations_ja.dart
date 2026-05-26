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
  String get newAnnouncementBadgeLabel => '新規';

  @override
  String get whatsNewSeeRecentUpdates => '最近の更新を見る';

  @override
  String get generalHeader => '一般';

  @override
  String get wattLabel => 'ワット（3Dプリンター）';

  @override
  String get printWeightLabel => 'プリントの重さ';

  @override
  String get hoursLabel => '印刷時間（時間）';

  @override
  String get durationHoursLabel => '時間';

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
  String get durationMinutesLabel => '分';

  @override
  String get printingTimeDialogTitle => '印刷時間';

  @override
  String get workTimeDialogTitle => '作業時間';

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
  String get resetButtonLabel => 'リセット';

  @override
  String get resetCalculationTitle => '計算をリセットしますか？';

  @override
  String get resetCalculationBody => '現在の計算機の値を破棄し、現在のデフォルト値を再読み込みします。';

  @override
  String get deleteButton => '削除';

  @override
  String get selectMaterialHint => 'カスタム（未保存）';

  @override
  String get materialNone => 'なし';

  @override
  String get gramsSuffix => 'g';

  @override
  String get millimetersSuffix => 'mm';

  @override
  String get remainingLabel => '残量:';

  @override
  String get trackRemainingFilamentLabel => '残りフィラメントを追跡';

  @override
  String get remainingFilamentLabel => '残りフィラメント';

  @override
  String get savePrintErrorMessage => 'プリントの保存中にエラーが発生しました';

  @override
  String get deleteRecordErrorMessage => '記録の削除中にエラーが発生しました';

  @override
  String get savePrintSuccessMessage => 'プリントを保存しました';

  @override
  String get deleteMaterialSuccessMessage => '材料を削除しました';

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
  String get helpSupportSupportTitle => 'サポート';

  @override
  String get helpSupportSupportIntro => 'サポートに連絡するときはこれらの詳細を使用してください。';

  @override
  String get helpSupportWebsiteLabel => 'ウェブサイト';

  @override
  String get helpSupportEmailLabel => 'メール';

  @override
  String get helpSupportSupportIdLabel => 'サポートID';

  @override
  String get helpSupportCopySupportIdTooltip => 'サポートIDをコピー';

  @override
  String get helpSupportRoadmapLabel => 'ロードマップ';

  @override
  String get helpSupportRoadmapValue => '今後の予定を見る';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'アプリバージョン $version';
  }

  @override
  String get helpSupportContactSupportButton => 'サポートに連絡';

  @override
  String get helpSupportContactEmailSubject => '3Dプリント費用計算機サポート';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'サポートID: $supportId\nアプリバージョン: $version\n\nここで問題を説明してください。';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'サポートID: (利用できません)\nアプリバージョン: $version\n\nここで問題を説明してください。';
  }

  @override
  String get helpSupportFaqTitle => 'よくある質問';

  @override
  String get helpSupportFaqWeightQuestion => 'どの重量を入力すればよいですか？';

  @override
  String get helpSupportFaqWeightAnswer =>
      '残りのフィラメントではなく、スプールの総重量を入力してください。アプリは完全なロールの重量を使用してグラムあたりのコストを計算します。';

  @override
  String get helpSupportFaqElectricityQuestion => 'なぜ電気が重要ですか？';

  @override
  String get helpSupportFaqElectricityAnswer =>
      '長時間の印刷と高ワット数のプリンターは実際のコストを追加できます。電気をスキップすると通常、仕事の価格が低くなります。';

  @override
  String get helpSupportFaqRiskQuestion => '失敗リスクはどのように計算されますか？';

  @override
  String get helpSupportFaqRiskAnswer =>
      'リスクはフィラメントや電気などの基本印刷コストにのみ適用されます。失敗した印刷からの予想損失を推定します。';

  @override
  String get helpSupportFaqLabourQuestion => '労働/処理時間とは何ですか？';

  @override
  String get helpSupportFaqLabourAnswer =>
      '準備、清掃、後処理、監視をカバーします。あなたの時間が重要なサービスではオンにしておいてください。';

  @override
  String get helpSupportFaqMarkupQuestion => 'マークアップとは何ですか？';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'マークアップは、販売価格に到達するために総コストの上に追加されるパーセンテージです。利益率、諸経費、利益をカバーします。';

  @override
  String get helpSupportFaqSetupQuestion => 'セットアップ料金とは何ですか？';

  @override
  String get helpSupportFaqSetupAnswer =>
      'セットアップ料金は、キャリブレーション、マシン準備、管理のためのジョブごとの固定コストです。小さな印刷が諸経費をカバーするのに役立ちます。';

  @override
  String get helpSupportLinksTitle => 'リンク';

  @override
  String get helpSupportPrivacyPolicyLabel => 'プライバシーポリシー';

  @override
  String get helpSupportTermsOfUseLabel => '利用規約';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'マストドン';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'について';

  @override
  String get helpSupportAboutIntro =>
      '3Dプリント費用計算機はローカルファースト価格設定のために構築されています。メーカーや小規模印刷ビジネスが、より少ない驚きで仕事を見積もるのに役立ちます。';

  @override
  String get helpSupportTrustNoAccounts => 'アカウント不要';

  @override
  String get helpSupportTrustNoCloudSync => 'クラウド同期なし';

  @override
  String get helpSupportTrustNoTracking => '追跡なし';

  @override
  String get helpSupportTrustLocalData => 'ローカルデータ';

  @override
  String get helpSupportAboutCalculator =>
      '計算機は、フィラメントコスト、電気、失敗リスク、労働、およびマークアップやセットアップ料金などのオプションの価格設定ツールを組み合わせます。';

  @override
  String get helpSupportAboutOutcome => 'それは見積もりを真のコストに結び付け、材料費だけではありません。';

  @override
  String get supportEmailPrefix => '問題がある場合は、次のアドレスまでメールしてください: ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'サポートIDを含めてください: ';

  @override
  String get supportEmailSubject => '3D Print Cost Calculator サポート';

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
  String get websiteLink => 'ウェブサイト';

  @override
  String get termsOfUseLink => '利用規約';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => '閉じる';

  @override
  String get cancelFeedbackPromptTitle => '更新をキャンセルしたようです。理由を教えてもらえますか？';

  @override
  String get feedbackSubmitButton => 'フィードバックを送信';

  @override
  String get cancelFeedbackReasonTooExpensive => '高すぎる';

  @override
  String get cancelFeedbackReasonMissingFeatures => '機能が足りない';

  @override
  String get cancelFeedbackReasonNotEnoughValue => '価値が足りない';

  @override
  String get cancelFeedbackReasonConfusingToUse => '使い方がわかりにくい';

  @override
  String get cancelFeedbackReasonJustTesting => 'アプリを試していただけ';

  @override
  String get cancelFeedbackReasonOther => 'その他';

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
  String get forceUpdateAvailableButton => 'アップデートを強制表示';

  @override
  String get forceNoUpdateButton => '更新なしを強制';

  @override
  String get clearUpdateCooldownButton => '更新クールダウンを消去';

  @override
  String get previewCancelFeedbackButton => '取消フィードバックをプレビュー';

  @override
  String get enableBatchCostingButton => 'バッチコスト計算を有効化';

  @override
  String get batchCostingSummarySaveButton => '見積もりを保存';

  @override
  String get batchCostingSummarySaveSuccessTitle => '見積もりを保存しました';

  @override
  String get batchCostingSummarySaveSuccessBody => '履歴に保存されました。';

  @override
  String get batchCostingSummaryViewHistoryButton => '履歴を見る';

  @override
  String get batchCostingSummarySaveErrorMessage => '見積もりを保存できませんでした';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'バッチ見積もり';

  @override
  String get batchCostingSummaryQuoteNameDialogTitle => '見積もりに名前を付ける';

  @override
  String get batchCostingSummaryQuoteNameHint => '見積もり名';

  @override
  String get batchHistoryItemsTitle => 'バッチアイテム';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'アイテム',
    );
    String _temp1 = intl.Intl.pluralLogic(
      totalQuantity,
      locale: localeName,
      other: 'コピー',
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
  String get updatePromptTitle => 'アップデートがあります';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'バージョン $storeVersion が利用できます。現在は $currentVersion がインストールされています。';
  }

  @override
  String get updatePromptBodyUnknown => '新しいバージョンがあります。';

  @override
  String get updatePromptOpenStoreButton => 'ストアを開く';

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
  String get additionalCostLabel => '追加費用';

  @override
  String get additionalCostNoteLabel => '追加費用メモ';

  @override
  String get additionalCostNoteDialogTitle => '追加費用メモ';

  @override
  String get riskCostLabel => 'リスク';

  @override
  String get totalCostLabel => '総費用';

  @override
  String get costTotalLabel => 'コスト';

  @override
  String get markupLabel => '上乗せ';

  @override
  String get setupFeeLabel => '設定料';

  @override
  String get roundingAdjustmentLabel => '端数調整';

  @override
  String get finalPriceLabel => '最終価格';

  @override
  String get jobPricingOverridesLabel => 'ジョブ設定';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '件の上書き適用',
      one: '件の上書き適用',
    );
    return '$count $_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => '上乗せ率 %';

  @override
  String get pricingSetupFeeLabel => '設定料';

  @override
  String get pricingRoundingLabel => '端数処理';

  @override
  String get pricingRoundingNoneLabel => 'なし';

  @override
  String get pricingRoundingWholeDollarLabel => '整数単位';

  @override
  String get pricingRoundingPointNinetyNineLabel => '.99で終わる';

  @override
  String get currencySymbolLabel => '通貨記号';

  @override
  String get currencyPositionLabel => '通貨記号の位置';

  @override
  String get currencyPositionBeforeLabel => '前';

  @override
  String get currencyPositionAfterLabel => '後';

  @override
  String get currencySpacingLabel => '記号との間に空白';

  @override
  String get currencyPreviewLabel => 'プレビュー';

  @override
  String materialCostPerKilogramLabel(Object cost) {
    return '$cost/kg';
  }

  @override
  String historyTimeCompactLabel(Object hours, Object minutes) {
    return '$hours時間 $minutes分';
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
      '日付,プリンター,材料,材料一覧,重量 (g),時間,電力,フィラメント,作業,リスク,合計,上乗せ率 %,上乗せ額,設定料,端数処理,端数処理前小計,端数調整,最終価格';

  @override
  String get historyExportShareText => '3Dプリント費用履歴の書き出し';

  @override
  String get batchQuoteExportShareText => '3Dプリントバッチ見積もりの書き出し';

  @override
  String get mixedHistoryExportShareText => '3Dプリント費用履歴の書き出し';

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
  String get searchMaterialsHint => '名前またはブランドを検索';

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

  @override
  String get durationPickerLabel => '印刷時間（hh:mm）';

  @override
  String get importGcodeButton => 'G-codeをインポート（自動入力）';

  @override
  String get importGcodePageTitle => 'G-codeインポート（ベータ）';

  @override
  String get importGcodeIntro =>
      'ローカルの.gcodeファイルを選択してください。対応スライサー: PrusaSlicer、OrcaSlicer、Bambu Studio、Cura。';

  @override
  String get importGcodeSelectFileButton => 'G-codeファイルを選択';

  @override
  String get importGcodePickAnotherButton => '別のファイルを選択';

  @override
  String get importGcodeSelectedFileLabel => '選択したファイル';

  @override
  String get gcodeImportFeedbackTitle => 'G-codeインポート・ベータフィードバック';

  @override
  String get gcodeImportFeedbackBetaFeature => 'ベータ機能';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      '何が機能したか、何が失敗したか、まだどう見えるかを教えてください。';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'スライサー';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'どのスライサー?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'プレビュー結果';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'メタデータ結果';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      '何が機能したか、何が失敗したか、何がおかしいですか?';

  @override
  String get gcodeImportFeedbackAttachmentLabel => 'インポートしたG-codeファイルを添付';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      '添付できるインポート済みファイルがありません。';

  @override
  String get gcodeImportFeedbackSendCta => 'フィードバックを送信';

  @override
  String get gcodeImportFeedbackSentMessage => 'フィードバックを送信しました';

  @override
  String get gcodeFeedbackPreviewLoaded => 'プレビュー読み込み済み';

  @override
  String get gcodeFeedbackPreviewMissing => 'プレビューなし';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'プレビュー不正確';

  @override
  String get gcodeFeedbackPreviewNotSure => 'わからない';

  @override
  String get gcodeFeedbackMetadataCorrect => '正しく見える';

  @override
  String get gcodeFeedbackMetadataMissing => 'データなし';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'データ不正確';

  @override
  String get gcodeFeedbackMetadataNotSure => 'わからない';

  @override
  String get importGcodeSummaryTitle => 'インポート概要';

  @override
  String get importGcodeSupportedSlicersNote =>
      '対応スライサー: PrusaSlicer、OrcaSlicer、Bambu Studio、Cura。';

  @override
  String get importGcodeCalculatorNote =>
      'インポートした値は時間と材料の合計重量のみ事前入力されます。プリンター、材料、最終コストは計算機設定から取得されます。';

  @override
  String get importGcodeUseValuesButton => 'この値を使用';

  @override
  String get importGcodeQuantityLabel => '数量';

  @override
  String get importGcodeCreateBatchButton => 'バッチを作成';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'バッチ作成には検出された時間とフィラメント重量の両方が必要です。';

  @override
  String get importGcodeSlicerLabel => 'スライサー';

  @override
  String get importGcodeDurationLabel => '予定時間';

  @override
  String get importGcodeFilamentWeightLabel => 'フィラメント重量';

  @override
  String get importGcodeFilamentLengthLabel => 'フィラメント長';

  @override
  String get importGcodeLayerHeightLabel => 'レイヤー高さ';

  @override
  String get importGcodePreviewLabel => 'プレビュー';

  @override
  String get importGcodePreviewAvailable => '利用可能';

  @override
  String get importGcodePreviewView => '表示';

  @override
  String get importGcodePreviewUnavailable => 'プレビューなし';

  @override
  String get importGcodePreviewDecodeFailed =>
      'プレビューメタデータは見つかりましたが、画像を表示できませんでした。';

  @override
  String get importGcodePreviewCuraNote =>
      'Curaプレビューにはサムネイルを埋め込む後処理スクリプトが必要な場合があります。';

  @override
  String get importGcodeWarningsTitle => '警告';

  @override
  String get importGcodeUnsupportedTypeError =>
      'このファイルはサポートされているG-codeファイルではありません。';

  @override
  String get importGcodeUnsupportedFileError =>
      'このファイルはサポートされているG-codeファイルではありません。';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'このファイルは大きすぎてインポートできません。$maxSizeMb MB未満のファイルを選択してください。';
  }

  @override
  String get importGcodeReadError => '選択したファイルを読み込めませんでした。';

  @override
  String get importGcodeUnknownSlicerValue => '不明';

  @override
  String get importGcodeMissingValue => '見つからず';

  @override
  String get importGcodeWarningUnknownSlicer => 'スライサーが特定できません。適用前に値を確認してください。';

  @override
  String get importGcodeWarningMissingDuration => '印刷時間を検出できませんでした。';

  @override
  String get importGcodeWarningMissingFilament => 'フィラメント使用状況が不完全です。';

  @override
  String get importGcodeWarningMissingFilamentWeight => 'フィラメント重量がありません。';

  @override
  String get importGcodeWarningPartialMetadata => '一部のメタデータが欠落しています。';

  @override
  String get importGcodeWarningMixedMaterials =>
      '複数の材料合計が見つかりました。適用前に確認してください。';

  @override
  String get importGcodeAppliedMessage => 'インポートした値を計算機に適用しました';

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
  String get slicerUnknown => '不明';

  @override
  String get materialsAppBarTitle => '材料';

  @override
  String get materialsNavLabel => '材料';

  @override
  String get brandLabel => 'ブランド';

  @override
  String get materialTypeLabel => '素材タイプ';

  @override
  String get colorHexLabel => '色のhex（任意）';

  @override
  String get notesLabel => 'メモ';

  @override
  String get materialsEmpty => '材料がまだありません。+をタップして追加';

  @override
  String get materialsFilterAll => 'すべて';

  @override
  String get materialsFilterInStock => '在庫あり';

  @override
  String get materialsFilterLowStock => '残りわずか';

  @override
  String get materialsFilterOutOfStock => '在庫切れ';

  @override
  String get csvImportTitle => '材料をインポート';

  @override
  String get csvTemplateButton => 'テンプレート';

  @override
  String get csvTemplateShareText => '材料CSVテンプレート';

  @override
  String get csvTemplateError => 'テンプレートを共有できませんでした。';

  @override
  String get csvImportIntro => 'CSVファイルから材料をインポートします。';

  @override
  String get csvSelectFileButton => 'CSVファイルを選択';

  @override
  String get csvImportButton => '有効な行をインポート';

  @override
  String get csvReadError => '選択されたファイルを読み取れませんでした。';

  @override
  String get csvFileTypeError => '.csvファイルを選択してください';

  @override
  String get csvNameRequiredError => '名前は必須です';

  @override
  String get csvColorRequiredError => '色は必須です';

  @override
  String get csvSpoolWeightRequiredError => 'スプール重量は必須です';

  @override
  String get csvSpoolWeightPositiveError => 'スプール重量は0より大きい必要があります';

  @override
  String get csvCostRequiredError => 'コストは必須です';

  @override
  String get csvCostPositiveError => 'コストは0より大きい必要があります';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の材料をインポートしました',
      one: '1件の材料をインポートしました',
    );
    return '$_temp0';
  }

  @override
  String get csvNoValidRowsError => 'インポートする有効な行がありません。';

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total行: $valid件有効, $invalid件エラー';
  }

  @override
  String get csvEmptyNamePlaceholder => '(空白)';

  @override
  String get editButton => '編集';

  @override
  String get duplicateButton => '複製';

  @override
  String get duplicateMaterialSuccessMessage => '材料を複製しました';

  @override
  String get duplicateMaterialErrorMessage => '材料の複製中にエラーが発生しました';

  @override
  String get materialsSwipeHint => '材料をスワイプして編集、複製、削除。';

  @override
  String get stockBadgeOut => '在庫切れ';

  @override
  String get stockBadgeLow => '残りわずか';

  @override
  String get stockBadgeInStock => '在庫あり';

  @override
  String get stockBadgeNoTracking => '追跡なし';

  @override
  String get batchCostingReviewAppBarTitle => 'バッチアイテムレビュー';

  @override
  String get batchCostingReviewSubtitle => 'プリンター割り当て前にバッチアイテムを確認します。';

  @override
  String get batchCostingReviewAddManualItemButton => '手動アイテムを追加';

  @override
  String get batchCostingReviewEmptyTitle => 'まだバッチアイテムがありません';

  @override
  String get batchCostingReviewEmptyBody => 'インポートまたは手動のプリントを追加して続行します。';

  @override
  String get batchCostingReviewImportGcodeButton => 'G-codeファイルをインポート';

  @override
  String get batchGcodeImportTitle => 'バッチG-codeのインポート';

  @override
  String get batchGcodeImportBody => '1つ以上のG-codeファイルを選択します。各ファイルは個別に解析されます。';

  @override
  String get batchGcodeImportPickButton => 'ファイルを選択';

  @override
  String get batchGcodeImportSuccessLabel => '正常にインポートされました';

  @override
  String get batchGcodeImportFailureLabel => 'インポートに失敗しました';

  @override
  String get batchGcodeImportParseFailure => 'このファイルはインポートできませんでした。';

  @override
  String get batchGcodeImportContinueButton => 'バッチレビューへ進む';

  @override
  String get batchGcodeImportRetryButton => 'もう一度選択';

  @override
  String get batchGcodeImportImportingLabel => 'インポート中…';

  @override
  String get batchGcodeImportPendingLabel => '保留中';

  @override
  String get batchGcodeImportNeedsDetailsLabel => '詳細が必要です';

  @override
  String get batchGcodeImportReadyLabel => '準備完了';

  @override
  String get batchGcodeImportNeedsWeight => '重量が必要';

  @override
  String get batchGcodeImportNeedsDuration => '時間が必要';

  @override
  String get batchGcodeImportApply => '適用';

  @override
  String get batchGcodeImportAddButton => 'バッチレビューに追加';

  @override
  String get batchGcodeImportDetailsButton => '詳細';

  @override
  String get batchGcodeImportDuplicateMessage => '一部のファイルはすでに追加されています。';

  @override
  String get batchGcodeImportQuantityHint => '数量は次の手順で調整できます。';

  @override
  String get batchCostingReviewContinueButton => 'プリンター割り当てに進む';

  @override
  String get batchCostingReviewQuantityLabel => '数量';

  @override
  String get batchCostingReviewRemoveButton => '削除';

  @override
  String get batchCostingReviewSourceLabel => 'ソース';

  @override
  String get batchCostingReviewSourceManual => '手動';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => '不明';

  @override
  String get batchCostingReviewWeightLabel => '重量';

  @override
  String get batchCostingReviewDurationLabel => '時間';

  @override
  String get batchCostingReviewWeightRequired => '重量が必要';

  @override
  String get batchCostingReviewDurationRequired => '時間が必要';

  @override
  String get batchCostingReviewMissingFieldsError => '必須項目を入力してください';

  @override
  String get batchCostingItemEditorAddTitle => '手動アイテムを追加';

  @override
  String get batchCostingItemEditorEditTitle => 'バッチアイテムを編集';

  @override
  String get batchCostingItemNameLabel => 'アイテム / モデル名';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle => 'プリンター割り当て';

  @override
  String get batchCostingPrinterAssignmentSubtitle => '材料の前にプリンターを割り当てます。';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'バッチ全体';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => '項目ごと';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'すべての項目に同じプリンターを選択します。';

  @override
  String get batchCostingPrinterAssignmentPerItemHint => 'この項目のプリンターを選択してください。';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'コピーを分割';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return '$itemNameのコピーを分割';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return '合計は$totalと等しくなければなりません';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      '数量が変更されたため、割り当てがリセットされました。';

  @override
  String get batchCostingAssignmentCopiesLabel => '部数';

  @override
  String get batchCostingAllocationPickerSearchLabel => 'オプションを検索';

  @override
  String get batchCostingAllocationPickerAvailableLabel => '利用可能';

  @override
  String get batchCostingAllocationPickerSelectedLabel => '選択済み';

  @override
  String get batchCostingAllocationPickerAddButton => '追加';

  @override
  String get batchCostingAllocationPickerNoResultsLabel => '結果がありません。';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      '続行するプリンターを選択してください。';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => '前へ';

  @override
  String get batchCostingPrinterAssignmentNextButton => '次へ';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'まだ利用できるプリンターがありません。';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle => '材料割り当て';

  @override
  String get batchCostingMaterialAssignmentSubtitle => '価格設定の前に材料やスプールを割り当てます。';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel => '材料またはスプール';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'バッチ全体';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'アイテムごと';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'すべてのアイテムに1つの材料を選びます。';

  @override
  String get batchCostingMaterialAssignmentPerItemHint => 'このアイテムの材料を選びます。';

  @override
  String get batchCostingMaterialAssignmentRequiredError => '続けるには材料を選んでください。';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => '前へ';

  @override
  String get batchCostingMaterialAssignmentNextButton => '次へ';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      '続けるには、少なくとも1つの材料またはスプールを追加してください。';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return '必要量 $required が選択中の在庫 $available を超えています。';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => '価格範囲';

  @override
  String get batchCostingPricingScopeSubtitle => '各価格値の適用先を設定します。';

  @override
  String get batchCostingPricingScopeItemMode => '項目';

  @override
  String get batchCostingPricingScopeBatchMode => 'バッチ';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => '項目（1コピーあたり）';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'バッチ（1回）';

  @override
  String get batchCostingPricingScopeScopeLabel => 'スコープ';

  @override
  String get batchCostingSummaryAppBarTitle => 'バッチ概要';

  @override
  String get batchCostingSummarySubtitle => '見積もりを生成する前にバッチを確認してください。';

  @override
  String get batchCostingSummaryOverviewTitle => '概要';

  @override
  String get batchCostingSummaryItemCountLabel => '項目数';

  @override
  String get batchCostingSummaryTotalQuantityLabel => '合計数量';

  @override
  String get batchCostingSummaryTotalWeightLabel => '合計重量';

  @override
  String get batchCostingSummaryTotalDurationLabel => '合計印刷時間';

  @override
  String get batchCostingSummaryItemWeightLabel => '重量';

  @override
  String get batchCostingSummaryItemDurationLabel => '印刷時間';

  @override
  String get batchCostingSummaryItemBaseCostLabel => '基本料金';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => '調整額';

  @override
  String get batchCostingSummaryItemTotalLabel => '項目合計';

  @override
  String get batchCostingSummaryFinalTotalLabel => '最終合計';

  @override
  String get batchCostingSummaryBackButton => '価格範囲へ戻る';

  @override
  String get batchCostingSummaryReturnToCalculatorButton => '計算機に戻る';

  @override
  String get batchCostingSummaryStartNewBatchButton => '新しいバッチを開始';

  @override
  String get batchCostingSummaryEmptyTitle => 'まだバッチ概要がありません';

  @override
  String get batchCostingSummaryEmptyBody => '概要を確認する前に、項目を追加して価格範囲を設定してください。';

  @override
  String get batchCostingSummaryPricingTitle => '価格設定';

  @override
  String get batchCostingSummaryItemsTitle => 'アイテム';

  @override
  String get batchCostingNewBatchDialogTitle => '新しいバッチを開始';

  @override
  String get batchCostingNewBatchDialogBody =>
      '現在のバッチの進行状況はすべて破棄されます。新しいバッチを開始しますか？';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnitずつ → 合計$lineTotal';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'プリンター';

  @override
  String get batchCostingEntryButton => 'バッチ見積もりを開始';
}
