// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get calculatorAppBarTitle => 'Kalkulator Cetak 3D';

  @override
  String get historyAppBarTitle => 'Riwayat';

  @override
  String get settingsAppBarTitle => 'Pengaturan';

  @override
  String get calculatorNavLabel => 'Kalkulator';

  @override
  String get historyNavLabel => 'Riwayat';

  @override
  String get settingsNavLabel => 'Pengaturan';

  @override
  String get newAnnouncementBadgeLabel => 'Baru';

  @override
  String get whatsNewSeeRecentUpdates => 'Lihat pembaruan terbaru';

  @override
  String get generalHeader => 'Umum';

  @override
  String get wattLabel => 'Watt (Printer 3D)';

  @override
  String get printWeightLabel => 'Berat cetakan';

  @override
  String get hoursLabel => 'Waktu pencetakan (jam)';

  @override
  String get durationHoursLabel => 'Jam';

  @override
  String get wearAndTearLabel => 'Bahan/Keausan + sobek';

  @override
  String get labourRateLabel => 'Tarif per jam';

  @override
  String get labourTimeLabel => 'Waktu pengerjaan';

  @override
  String get failureRiskLabel => 'Risiko kegagalan (%)';

  @override
  String get minutesLabel => 'Menit';

  @override
  String get durationMinutesLabel => 'Menit';

  @override
  String get printingTimeDialogTitle => 'Waktu pencetakan';

  @override
  String get workTimeDialogTitle => 'Waktu kerja';

  @override
  String get spoolWeightLabel => 'Berat kumparan/Resin';

  @override
  String get spoolCostLabel => 'Biaya Spul/Resin';

  @override
  String get electricityCostLabel => 'Biaya listrik';

  @override
  String get electricityCostSettingsLabel => 'Biaya listrik';

  @override
  String get submitButton => 'Menghitung';

  @override
  String get resultElectricityPrefix => 'Total biaya Listrik: ';

  @override
  String get resultElectricityRated => 'Listrik (Nominal)';

  @override
  String get resultElectricityAverage => 'Listrik (Rata-rata)';

  @override
  String get resultFilamentPrefix => 'Total biaya untuk filamen: ';

  @override
  String get resultTotalPrefix => 'Total biaya: ';

  @override
  String get riskTotalPrefix => 'Biaya risiko: ';

  @override
  String get premiumHeader => 'Khusus pengguna premium:';

  @override
  String get labourCostPrefix => 'Biaya tenaga kerja/Bahan: ';

  @override
  String get selectPrinterHint => 'Pilih printer';

  @override
  String get watt => 'Watt';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'Simpan cetakan';

  @override
  String get printNameHint => 'Nama cetak';

  @override
  String get printerNameLabel => 'Nama *';

  @override
  String get bedSizeLabel => 'Ukuran bed *';

  @override
  String get wattageLabel => 'Daya (Nominal) *';

  @override
  String get averageWattageLabel => 'Daya (Rata-rata)';

  @override
  String get materialNameLabel => 'Nama bahan *';

  @override
  String get colorLabel => 'Warna *';

  @override
  String get weightLabel => 'Berat *';

  @override
  String get costLabel => 'Biaya *';

  @override
  String get saveButton => 'Simpan';

  @override
  String get deleteDialogTitle => 'Hapus';

  @override
  String get deleteDialogContent => 'Yakin ingin menghapus item ini?';

  @override
  String get cancelButton => 'Batal';

  @override
  String get resetButtonLabel => 'Reset';

  @override
  String get resetCalculationTitle => 'Reset perhitungan?';

  @override
  String get resetCalculationBody =>
      'Ini akan membuang nilai kalkulator saat ini dan memuat ulang nilai default saat ini.';

  @override
  String get deleteButton => 'Hapus';

  @override
  String get selectMaterialHint => 'Kustom (belum disimpan)';

  @override
  String get materialNone => 'Tidak ada';

  @override
  String get gramsSuffix => 'g';

  @override
  String get millimetersSuffix => 'mm';

  @override
  String get remainingLabel => 'Sisa:';

  @override
  String get trackRemainingFilamentLabel => 'Lacak sisa filamen';

  @override
  String get remainingFilamentLabel => 'Sisa filamen';

  @override
  String get savePrintErrorMessage => 'Gagal menyimpan hasil cetak';

  @override
  String get deleteRecordErrorMessage => 'Gagal menghapus catatan';

  @override
  String get savePrintSuccessMessage => 'Hasil cetak disimpan';

  @override
  String get deleteMaterialSuccessMessage => 'Material dihapus';

  @override
  String get historyLoadAction => 'Edit di kalkulator';

  @override
  String get historyLoadSuccessMessage => 'Dimuat dari riwayat';

  @override
  String get historyLoadReplacementWarning =>
      'Beberapa item tidak tersedia dan telah diganti';

  @override
  String get numberExampleHint => 'mis. 123';

  @override
  String materialsLoadError(Object error) {
    return 'Gagal memuat material: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'Gagal memuat printer: $error';
  }

  @override
  String get retryButton => 'Coba lagi';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'Butuh bantuan?';

  @override
  String get helpSupportSupportTitle => 'Dukungan';

  @override
  String get helpSupportSupportIntro =>
      'Gunakan detail ini saat menghubungi dukungan.';

  @override
  String get helpSupportWebsiteLabel => 'Situs web';

  @override
  String get helpSupportEmailLabel => 'Email';

  @override
  String get helpSupportSupportIdLabel => 'ID Dukungan';

  @override
  String get helpSupportCopySupportIdTooltip => 'Salin ID dukungan';

  @override
  String get helpSupportRoadmapLabel => 'Peta jalan';

  @override
  String get helpSupportRoadmapValue => 'Lihat yang akan datang';

  @override
  String helpSupportAppVersionRow(Object version) {
    return 'Versi aplikasi $version';
  }

  @override
  String get helpSupportContactSupportButton => 'Hubungi dukungan';

  @override
  String get helpSupportContactEmailSubject =>
      'Dukungan Kalkulator Biaya Cetak 3D';

  @override
  String helpSupportContactEmailBody(Object supportId, Object version) {
    return 'ID Dukungan: $supportId\nVersi aplikasi: $version\n\nJelaskan masalahnya di sini.';
  }

  @override
  String helpSupportContactEmailBodyNoSupportId(Object version) {
    return 'ID Dukungan: (tidak tersedia)\nVersi aplikasi: $version\n\nJelaskan masalahnya di sini.';
  }

  @override
  String get helpSupportFaqTitle => 'FAQ';

  @override
  String get helpSupportFaqWeightQuestion =>
      'Berat apa yang harus saya masukkan?';

  @override
  String get helpSupportFaqWeightAnswer =>
      'Masukkan berat total spul, bukan filamen sisa. Aplikasi menggunakan berat gulungan penuh untuk menghitung biaya per gram.';

  @override
  String get helpSupportFaqElectricityQuestion => 'Mengapa listrik penting?';

  @override
  String get helpSupportFaqElectricityAnswer =>
      'Pencetakan lama dan printer berdaya tinggi dapat menambah biaya nyata. Melewatkan listrik biasanya membuat harga terlalu rendah.';

  @override
  String get helpSupportFaqRiskQuestion =>
      'Bagaimana risiko kegagalan dihitung?';

  @override
  String get helpSupportFaqRiskAnswer =>
      'Risiko diterapkan hanya pada biaya cetak dasar seperti filamen dan listrik. Ini memperkirakan kerugian yang diharapkan dari pencetakan yang gagal.';

  @override
  String get helpSupportFaqLabourQuestion =>
      'Apa itu waktu tenaga kerja / pengolahan?';

  @override
  String get helpSupportFaqLabourAnswer =>
      'Ini mencakup persiapan, pembersihan, pasca-pemrosesan, dan pemantauan. Tetap aktifkan untuk layanan di mana waktu Anda penting.';

  @override
  String get helpSupportFaqMarkupQuestion => 'Apa itu markup?';

  @override
  String get helpSupportFaqMarkupAnswer =>
      'Markup adalah persentase yang ditambahkan di atas biaya total untuk mencapai harga jual Anda. Ini mencakup margin, overhead, dan keuntungan.';

  @override
  String get helpSupportFaqSetupQuestion => 'Apa itu biaya setup?';

  @override
  String get helpSupportFaqSetupAnswer =>
      'Biaya setup adalah biaya tetap per pekerjaan untuk kalibrasi, persiapan mesin, dan administrasi. Ini membantu cetakan kecil menutupi overhead.';

  @override
  String get wattageFaqHint => 'Lihat FAQ untuk detail watt';

  @override
  String get helpSupportFaqWattageQuestion =>
      'Daya tertera vs daya rata-rata - apa bedanya?';

  @override
  String get helpSupportFaqWattageAnswer =>
      'Daya tertera adalah daya maksimum yang dapat ditarik printer dari stopkontak (tertera pada pelat nama). Daya rata-rata adalah daya tipikalnya saat mencetak, idealnya diukur dengan meter colokan. Gunakan Daya rata-rata untuk biaya listrik yang akurat, atau Daya tertera sebagai batas atas yang aman.';

  @override
  String get helpSupportLinksTitle => 'Tautan';

  @override
  String get helpSupportPrivacyPolicyLabel => 'Kebijakan privasi';

  @override
  String get helpSupportTermsOfUseLabel => 'Ketentuan penggunaan';

  @override
  String get helpSupportXTwitterLabel => 'X / Twitter';

  @override
  String get helpSupportInstagramLabel => 'Instagram';

  @override
  String get helpSupportMastodonLabel => 'Mastodon';

  @override
  String get helpSupportThreadsLabel => 'Threads';

  @override
  String get helpSupportAboutTitle => 'Tentang';

  @override
  String get helpSupportAboutIntro =>
      'Kalkulator Biaya Cetak 3D dibuat untuk penetapan harga lokal terlebih dahulu. Ini membantu pembuat dan bisnis cetak kecil mengutip pekerjaan dengan lebih sedikit kejutan.';

  @override
  String get helpSupportTrustNoAccounts => 'Tanpa akun';

  @override
  String get helpSupportTrustNoCloudSync => 'Tanpa sinkronisasi cloud';

  @override
  String get helpSupportTrustNoTracking => 'Tanpa pelacakan';

  @override
  String get helpSupportTrustLocalData => 'Data lokal';

  @override
  String get helpSupportAboutCalculator =>
      'Kalkulator menggabungkan biaya filamen, listrik, risiko kegagalan, tenaga kerja, dan alat penetapan harga opsional seperti markup dan biaya setup.';

  @override
  String get helpSupportAboutOutcome =>
      'Itu membuat kutipan tetap terikat pada biaya sebenarnya, bukan hanya pengeluaran material.';

  @override
  String get supportEmailPrefix => 'Jika ada masalah, silakan email saya di ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Harap sertakan ID Dukungan Anda: ';

  @override
  String get supportEmailSubject => 'Dukungan 3D Print Cost Calculator';

  @override
  String get clickToCopy => '(ketuk untuk menyalin)';

  @override
  String get materialWeightExplanation =>
      'Berat bahan adalah total berat bahan sumber, yaitu seluruh gulungan filamen. Biaya adalah harga seluruh unit.';

  @override
  String get supportIdCopied => 'ID Dukungan disalin';

  @override
  String get exportSuccess => 'Ekspor berhasil';

  @override
  String get exportError => 'Ekspor gagal';

  @override
  String get exportButton => 'Ekspor';

  @override
  String get scheduleAutomaticBackupButton => 'Jadwalkan cadangan otomatis';

  @override
  String get automaticBackupDailyLabel => 'Harian';

  @override
  String get automaticBackupWeeklyLabel => 'Mingguan';

  @override
  String get automaticBackupMonthlyLabel => 'Bulanan';

  @override
  String get automaticBackupNote =>
      'Cadangan otomatis berjalan di latar belakang saat perangkat Anda mengizinkannya. Ritme yang dipilih hanya membuat cadangan kembali layak; sistem operasi bisa menunda eksekusi sebenarnya.';

  @override
  String get automaticBackupStatusPending => 'Tertunda';

  @override
  String get automaticBackupStatusSuccess => 'Berhasil';

  @override
  String get automaticBackupStatusFailure => 'Gagal';

  @override
  String get automaticBackupScheduleSuccess => 'Cadangan otomatis dijadwalkan';

  @override
  String get automaticBackupScheduleError =>
      'Tidak dapat menjadwalkan cadangan otomatis';

  @override
  String automaticBackupStatusLabel(Object cadence, Object result) {
    return 'Cadangan otomatis: $cadence • $result';
  }

  @override
  String automaticBackupExpectedRunWithDate(Object dateTime) {
    return 'Perkiraan jalan: pada atau setelah $dateTime, saat perangkat Anda mengizinkannya.';
  }

  @override
  String get automaticBackupExpectedRunNoSuccess =>
      'Perkiraan jalan: saat perangkat Anda kembali mengizinkan pekerjaan latar belakang.';

  @override
  String get privacyPolicyLink => 'Kebijakan Privasi';

  @override
  String get websiteLink => 'Situs web';

  @override
  String get termsOfUseLink => 'Ketentuan Penggunaan';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Tutup';

  @override
  String get cancelFeedbackPromptTitle =>
      'Sepertinya Anda membatalkan perpanjangan. Mau beri tahu alasannya?';

  @override
  String get feedbackSubmitButton => 'Kirim masukan';

  @override
  String get cancelFeedbackReasonTooExpensive => 'Terlalu mahal';

  @override
  String get cancelFeedbackReasonMissingFeatures => 'Fitur kurang';

  @override
  String get cancelFeedbackReasonNotEnoughValue => 'Nilainya kurang terasa';

  @override
  String get cancelFeedbackReasonConfusingToUse =>
      'Membingungkan untuk digunakan';

  @override
  String get cancelFeedbackReasonJustTesting =>
      'Saya hanya mencoba aplikasinya';

  @override
  String get cancelFeedbackReasonOther => 'Lainnya';

  @override
  String get testDataToolsTitle => 'Alat data uji';

  @override
  String get testDataToolsBody =>
      'Tindakan ini hanya untuk pengujian lokal. Menanam data akan mengganti pengaturan lokal saat ini dengan data demo. Menghapus akan menghapus permanen data lokal aplikasi di perangkat ini.';

  @override
  String get seedTestDataButton => 'Tanam data uji';

  @override
  String get purgeLocalDataButton => 'Hapus data lokal';

  @override
  String get enablePremiumButton => 'Aktifkan premium';

  @override
  String get forceUpdateAvailableButton => 'Paksa pembaruan tersedia';

  @override
  String get forceNoUpdateButton => 'Paksa tidak ada pembaruan';

  @override
  String get clearUpdateCooldownButton => 'Hapus jeda pembaruan';

  @override
  String get previewCancelFeedbackButton => 'Pratinjau umpan balik pembatalan';

  @override
  String get previewCustomPaywallButton => 'Pratinjau paywall kustom';

  @override
  String get sendHandledSentryTestButton => 'Kirim uji Sentry yang tertangani';

  @override
  String get sendUnhandledSentryTestButton =>
      'Kirim uji Sentry yang tidak tertangani';

  @override
  String get enableBatchCostingButton => 'Aktifkan penetapan harga batch';

  @override
  String get batchCostingSummarySaveButton => 'Simpan kutipan';

  @override
  String get batchCostingSummarySaveSuccessTitle => 'Kutipan disimpan';

  @override
  String get batchCostingSummarySaveSuccessBody => 'Disimpan ke riwayat.';

  @override
  String get batchCostingSummaryViewHistoryButton => 'Lihat riwayat';

  @override
  String get batchCostingSummarySaveErrorMessage =>
      'Tidak dapat menyimpan kutipan';

  @override
  String get batchCostingSummaryDefaultQuoteName => 'Kutipan batch';

  @override
  String get batchCostingSummaryQuoteNameDialogTitle =>
      'Beri nama kutipan Anda';

  @override
  String get batchCostingSummaryQuoteNameHint => 'Nama kutipan';

  @override
  String get batchHistoryItemsTitle => 'Item batch';

  @override
  String batchHistorySummaryLine(int itemCount, int totalQuantity) {
    return '$itemCount item • $totalQuantity salinan';
  }

  @override
  String batchHistoryItemRow(Object name, Object quantity) {
    return '$name × $quantity';
  }

  @override
  String get showWhatsNewButton => 'Show What\'s New';

  @override
  String get enablePremiumTitle => 'Aktifkan premium';

  @override
  String get enablePremiumBody =>
      'Masukkan kode konfirmasi untuk mengaktifkan pengujian premium lokal';

  @override
  String get invalidConfirmationCodeMessage => 'Kode konfirmasi tidak valid';

  @override
  String get seedTestDataConfirmTitle => 'Tanam data uji?';

  @override
  String get seedTestDataConfirmBody =>
      'Ini akan mengganti pengaturan lokal saat ini dengan data demo deterministik.';

  @override
  String get purgeLocalDataConfirmTitle => 'Hapus data lokal?';

  @override
  String get purgeLocalDataConfirmBody =>
      'Ini akan menghapus permanen semua data lokal aplikasi di perangkat ini.';

  @override
  String get testDataSeededMessage => 'Data uji ditanam';

  @override
  String get testDataPurgedMessage => 'Data lokal dihapus';

  @override
  String get testDataActionFailedMessage => 'Tindakan data uji gagal';

  @override
  String get updatePromptTitle => 'Pembaruan tersedia';

  @override
  String updatePromptBody(Object storeVersion, Object currentVersion) {
    return 'Versi $storeVersion tersedia. Anda sudah memasang $currentVersion.';
  }

  @override
  String get updatePromptBodyUnknown => 'Ada versi yang lebih baru tersedia.';

  @override
  String get updatePromptOpenStoreButton => 'Buka toko';

  @override
  String get mailClientError => 'Tidak dapat membuka klien email';

  @override
  String get offeringsError => 'Kesalahan: ';

  @override
  String get currentOfferings => 'Penawaran saat ini';

  @override
  String get purchaseError =>
      'Terjadi kesalahan saat memproses pembelian Anda. Silakan coba lagi nanti.';

  @override
  String get restorePurchases => 'Pulihkan pembelian';

  @override
  String get printersHeader => 'Printer';

  @override
  String get materialsHeader => 'Bahan';

  @override
  String get filamentCostLabel => 'Filamen';

  @override
  String get labourCostLabel => 'Tenaga kerja';

  @override
  String get additionalCostLabel => 'Biaya tambahan';

  @override
  String get additionalCostNoteLabel => 'Catatan biaya tambahan';

  @override
  String get additionalCostNoteDialogTitle => 'Catatan biaya tambahan';

  @override
  String get riskCostLabel => 'Risiko';

  @override
  String get totalCostLabel => 'Total biaya';

  @override
  String get costTotalLabel => 'Biaya';

  @override
  String get markupLabel => 'Markup';

  @override
  String get setupFeeLabel => 'Biaya penyiapan';

  @override
  String get roundingAdjustmentLabel => 'Penyesuaian pembulatan';

  @override
  String get finalPriceLabel => 'Harga akhir';

  @override
  String get jobPricingOverridesLabel => 'Pengaturan tugas';

  @override
  String pricingOverridesSummary(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'override diterapkan',
      one: 'override diterapkan',
    );
    return '$count $_temp0';
  }

  @override
  String get pricingMarkupPercentLabel => '% markup';

  @override
  String get pricingSetupFeeLabel => 'Biaya penyiapan';

  @override
  String get pricingRoundingLabel => 'Pembulatan';

  @override
  String get pricingRoundingNoneLabel => 'Tidak ada';

  @override
  String get pricingRoundingWholeDollarLabel => 'Unit utuh';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Berakhir .99';

  @override
  String get currencySymbolLabel => 'Simbol mata uang';

  @override
  String get currencyPositionLabel => 'Posisi simbol mata uang';

  @override
  String get currencyPositionBeforeLabel => 'Sebelum';

  @override
  String get currencyPositionAfterLabel => 'Sesudah';

  @override
  String get currencySpacingLabel => 'Spasi dengan simbol';

  @override
  String get currencyPreviewLabel => 'Pratinjau';

  @override
  String materialCostPerKilogramLabel(Object cost) {
    return '$cost/kg';
  }

  @override
  String historyTimeCompactLabel(Object hours, Object minutes) {
    return '$hours j $minutes mnt';
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
  String get workCostsLabel => 'Biaya kerja';

  @override
  String get enterNumber => 'Harap masukkan angka';

  @override
  String get invalidNumber => 'Angka tidak valid';

  @override
  String get validationRequired => 'Wajib';

  @override
  String get validationEnterValidNumber => 'Masukkan angka yang valid';

  @override
  String get validationMustBeGreaterThanZero => 'Harus lebih besar dari 0';

  @override
  String get validationMustBeZeroOrMore => 'Harus 0 atau lebih';

  @override
  String get lockedValuePlaceholder => 'Hanya Premium';

  @override
  String get printerLimitReachedMessage =>
      'Anda dapat menyimpan hingga 2 printer di Free. Upgrade ke Premium untuk printer tanpa batas.';

  @override
  String get materialLimitReachedMessage =>
      'Anda dapat menyimpan hingga 5 material di Free. Upgrade ke Premium untuk material tanpa batas.';

  @override
  String get batchItemLimitReachedMessage =>
      'Anda dapat menambahkan hingga 3 item batch di Free. Upgrade ke Premium untuk item batch tanpa batas.';

  @override
  String get historySearchHint => 'Cari berdasarkan nama atau printer';

  @override
  String get historyExportMenuTitle => 'Ekspor cetakan';

  @override
  String get historyExportRangeAll => 'Semua';

  @override
  String get historyExportRangeLast7Days => '7 hari terakhir';

  @override
  String get historyExportRangeLast30Days => '30 hari terakhir';

  @override
  String get historyEmptyTitle => 'Belum ada cetakan yang disimpan';

  @override
  String get historyEmptyDescription =>
      'Gunakan kembali cetakan lama di kalkulator';

  @override
  String get historyUpsellTitle => 'Gunakan kembali cetakan lama seketika';

  @override
  String get historyUpsellDescription =>
      'Anda dapat menyimpan hingga 7 cetakan di Free. Upgrade ke Premium untuk riwayat dan ekspor tanpa batas.';

  @override
  String get historyNoMoreRecords => 'Tidak ada data lagi';

  @override
  String get historyOverflowHint => 'Tindakan lainnya ada di ⋯';

  @override
  String historyLoadError(Object error) {
    return 'Gagal memuat riwayat: $error';
  }

  @override
  String get historyCsvHeader =>
      'Tanggal,Printer,Bahan,Bahan,Berat (g),Waktu,Listrik,Filamen,Tenaga kerja,Risiko,Total,% markup,Jumlah markup,Biaya penyiapan,Mode pembulatan,Subtotal sebelum pembulatan,Penyesuaian pembulatan,Harga akhir';

  @override
  String get historyExportShareText => 'Ekspor riwayat biaya cetak 3D';

  @override
  String get batchQuoteExportShareText => 'Ekspor penawaran batch cetak 3D';

  @override
  String get mixedHistoryExportShareText => 'Ekspor riwayat biaya cetak 3D';

  @override
  String get historyTeaserTitle =>
      'Simpan setiap estimasi cetak di satu tempat';

  @override
  String get historyTeaserDescription =>
      'Pengguna Free dapat menyimpan hingga 7 cetakan. Upgrade ke Premium untuk riwayat dan ekspor tanpa batas.';

  @override
  String get historyTeaserCta => 'Upgrade ke Premium untuk riwayat tanpa batas';

  @override
  String get historyExportPreviewEntry => 'Pratinjau ekspor CSV';

  @override
  String get historyExportPreviewTitle => 'Pratinjau CSV';

  @override
  String get historyExportPreviewDescription =>
      'Ekspor riwayat massal adalah fitur Premium. Unduh dan bagikan dibuka dengan Premium.';

  @override
  String get historyExportPreviewSampleLabel => '[Contoh]';

  @override
  String get historyExportPreviewAction => 'Unduh / Bagikan dengan Premium';

  @override
  String get unsavedMaterialOptionLabel => 'Material belum disimpan';

  @override
  String get unsavedMaterialHeader => 'Material Kustom';

  @override
  String get customMaterialWeightLabel => 'Berat';

  @override
  String get customMaterialCostLabel => 'Biaya';

  @override
  String get customMaterialUsedLabel => 'Terpakai';

  @override
  String get addMaterialButton => 'Tambahkan bahan';

  @override
  String get useSingleTotalWeightAction => 'Gunakan total berat tunggal';

  @override
  String get addAtLeastOneMaterial => 'Tambahkan setidaknya satu material.';

  @override
  String get searchMaterialsHint => 'Cari nama atau merek';

  @override
  String get materialBreakdownLabel => 'Rincian bahan';

  @override
  String materialsCountLabel(num count) {
    return '$count bahan';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'Total berat material: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'Versi $version';
  }

  @override
  String get materialFallback => 'Bahan';

  @override
  String get durationPickerLabel => 'Waktu pencetakan (hh:mm)';

  @override
  String get importGcodeButton => 'Impor G-code (Isi otomatis)';

  @override
  String get importGcodePageTitle => 'Impor G-code (Beta)';

  @override
  String get importGcodeIntro =>
      'Pilih file .gcode lokal. Slicer yang didukung: PrusaSlicer, OrcaSlicer, Bambu Studio, dan Cura.';

  @override
  String get importGcodeSelectFileButton => 'Pilih file G-code';

  @override
  String get importGcodePickAnotherButton => 'Pilih file lain';

  @override
  String get importGcodeSelectedFileLabel => 'File dipilih';

  @override
  String get gcodeImportFeedbackTitle => 'Masukan Impor G-code Beta';

  @override
  String get gcodeImportFeedbackBetaFeature => 'Fitur beta';

  @override
  String get gcodeImportFeedbackBetaDescription =>
      'Ceritakan apa yang berhasil, apa yang bermasalah, atau apa yang masih terlihat salah.';

  @override
  String get gcodeImportFeedbackSlicerLabel => 'Slicer';

  @override
  String get gcodeImportFeedbackOtherSlicerLabel => 'Slicer yang mana?';

  @override
  String get gcodeImportFeedbackPreviewLabel => 'Hasil pratinjau';

  @override
  String get gcodeImportFeedbackMetadataLabel => 'Hasil metadata';

  @override
  String get gcodeImportFeedbackDescriptionLabel =>
      'Apa yang berhasil, apa yang bermasalah, atau apa yang terlihat salah?';

  @override
  String get gcodeImportFeedbackAttachmentLabel =>
      'Lampirkan file G-code yang diimpor';

  @override
  String get gcodeImportFeedbackNoAttachmentAvailable =>
      'Tidak ada file G-code yang diimpor untuk dilampirkan.';

  @override
  String get gcodeImportFeedbackSendCta => 'Kirim masukan';

  @override
  String get gcodeImportFeedbackSentMessage => 'Masukan terkirim';

  @override
  String get gcodeFeedbackPreviewLoaded => 'Pratinjau dimuat';

  @override
  String get gcodeFeedbackPreviewMissing => 'Pratinjau hilang';

  @override
  String get gcodeFeedbackPreviewIncorrect => 'Pratinjau tidak benar';

  @override
  String get gcodeFeedbackPreviewNotSure => 'Tidak yakin';

  @override
  String get gcodeFeedbackMetadataCorrect => 'Terlihat benar';

  @override
  String get gcodeFeedbackMetadataMissing => 'Data hilang';

  @override
  String get gcodeFeedbackMetadataIncorrect => 'Data tidak benar';

  @override
  String get gcodeFeedbackMetadataNotSure => 'Tidak yakin';

  @override
  String get importGcodeSummaryTitle => 'Ringkasan impor';

  @override
  String get importGcodeSupportedSlicersNote =>
      'Slicer yang didukung: PrusaSlicer, OrcaSlicer, Bambu Studio, dan Cura.';

  @override
  String get importGcodeCalculatorNote =>
      'Nilai yang diimpor hanya mengisi ulang waktu dan berat material total. Printer, material, dan biaya akhir berasal dari pengaturan kalkulator Anda.';

  @override
  String get importGcodeUseValuesButton => 'Gunakan nilai ini';

  @override
  String get importGcodeQuantityLabel => 'Jumlah';

  @override
  String get importGcodeCreateBatchButton => 'Buat batch';

  @override
  String get importGcodeBatchRequiresDetectedValues =>
      'Pembuatan batch memerlukan durasi dan berat filamen yang terdeteksi.';

  @override
  String get importGcodeSlicerLabel => 'Slicer';

  @override
  String get importGcodeDurationLabel => 'Estimasi durasi';

  @override
  String get importGcodeFilamentWeightLabel => 'Berat filamen';

  @override
  String get importGcodeFilamentLengthLabel => 'Panjang filamen';

  @override
  String get importGcodeLayerHeightLabel => 'Tinggi lapisan';

  @override
  String get importGcodePreviewLabel => 'Pratinjau';

  @override
  String get importGcodePreviewAvailable => 'Tersedia';

  @override
  String get importGcodePreviewView => 'Lihat';

  @override
  String get importGcodePreviewUnavailable => 'Tidak ada pratinjau';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Metadata pratinjau ditemukan tetapi gambar tidak dapat ditampilkan.';

  @override
  String get importGcodePreviewCuraNote =>
      'Pratinjau Cura mungkin memerlukan skrip pasca-pemrosesan untuk menyematkan thumbnail.';

  @override
  String get importGcodeWarningsTitle => 'Peringatan';

  @override
  String get importGcodeUnsupportedTypeError =>
      'File ini tidak terlihat seperti file G-code yang didukung.';

  @override
  String get importGcodeUnsupportedFileError =>
      'File ini tidak terlihat seperti file G-code yang didukung.';

  @override
  String importGcodeTooLargeError(Object maxSizeMb) {
    return 'File ini terlalu besar untuk diimpor. Pilih file yang lebih kecil dari $maxSizeMb MB.';
  }

  @override
  String get importGcodeReadError => 'File yang dipilih tidak dapat dibaca.';

  @override
  String get importGcodeUnknownSlicerValue => 'Tidak diketahui';

  @override
  String get importGcodeMissingValue => 'Tidak ditemukan';

  @override
  String get importGcodeWarningUnknownSlicer =>
      'Slicer tidak teridentifikasi. Tinjau nilai sebelum menerapkan.';

  @override
  String get importGcodeWarningMissingDuration =>
      'Waktu cetak tidak dapat dideteksi.';

  @override
  String get importGcodeWarningMissingFilament =>
      'Penggunaan filamen tidak lengkap.';

  @override
  String get importGcodeWarningMissingFilamentWeight => 'Berat filamen hilang.';

  @override
  String get importGcodeWarningPartialMetadata => 'Beberapa metadata hilang.';

  @override
  String get importGcodeWarningMixedMaterials =>
      'Ditemukan beberapa total material. Tinjau sebelum menerapkan.';

  @override
  String get importGcodeAppliedMessage =>
      'Nilai yang diimpor diterapkan ke kalkulator';

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
  String get slicerOther => 'Lainnya';

  @override
  String get slicerUnknown => 'Tidak Dikenal';

  @override
  String get materialsAppBarTitle => 'Material';

  @override
  String get materialsNavLabel => 'Material';

  @override
  String get brandLabel => 'Merek';

  @override
  String get materialTypeLabel => 'Jenis material';

  @override
  String get colorHexLabel => 'Hex warna (opsional)';

  @override
  String get notesLabel => 'Catatan';

  @override
  String get materialsEmpty => 'Belum ada material. Ketuk + untuk menambah.';

  @override
  String get materialsFilterAll => 'Semua';

  @override
  String get materialsFilterInStock => 'Tersedia';

  @override
  String get materialsFilterLowStock => 'Stok rendah';

  @override
  String get materialsFilterOutOfStock => 'Habis';

  @override
  String get csvImportTitle => 'Impor material';

  @override
  String get csvTemplateButton => 'Template';

  @override
  String get csvTemplateShareText => 'Template CSV material';

  @override
  String get csvTemplateError => 'Tidak dapat membagikan template.';

  @override
  String get csvImportIntro => 'Impor material dari file CSV.';

  @override
  String get csvSelectFileButton => 'Pilih file CSV';

  @override
  String get csvImportButton => 'Impor baris yang valid';

  @override
  String get csvReadError => 'File yang dipilih tidak dapat dibaca.';

  @override
  String get csvFileTypeError => 'Pilih file .csv';

  @override
  String get csvNameRequiredError => 'Nama wajib diisi';

  @override
  String get csvColorRequiredError => 'Warna wajib diisi';

  @override
  String get csvSpoolWeightRequiredError => 'Berat spool wajib diisi';

  @override
  String get csvSpoolWeightPositiveError => 'Berat spool harus > 0';

  @override
  String get csvCostRequiredError => 'Biaya wajib diisi';

  @override
  String get csvCostPositiveError => 'Biaya harus > 0';

  @override
  String csvImportSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count material diimpor',
      one: '1 material diimpor',
    );
    return '$_temp0';
  }

  @override
  String get csvNoValidRowsError => 'Tidak ada baris valid untuk diimpor.';

  @override
  String get csvImportQuotaExceededError =>
      'Impor ini melebihi batas material Anda.';

  @override
  String csvPreviewSummary(int total, int valid, int invalid) {
    return '$total baris: $valid valid, $invalid dengan error';
  }

  @override
  String get csvEmptyNamePlaceholder => '(kosong)';

  @override
  String get editButton => 'Sunting';

  @override
  String get duplicateButton => 'Duplikat';

  @override
  String get duplicateMaterialSuccessMessage => 'Material digandakan';

  @override
  String get duplicateMaterialErrorMessage => 'Gagal menggandakan material';

  @override
  String get materialsSwipeHint =>
      'Geser material untuk mengedit, menggandakan, atau menghapus.';

  @override
  String get stockBadgeOut => 'Habis';

  @override
  String get stockBadgeLow => 'Stok rendah';

  @override
  String get stockBadgeInStock => 'Tersedia';

  @override
  String get stockBadgeNoTracking => 'Tidak dilacak';

  @override
  String get batchCostingReviewAppBarTitle => 'Tinjauan item batch';

  @override
  String get batchCostingReviewSubtitle =>
      'Tinjau item batch sebelum penugasan printer.';

  @override
  String get batchCostingReviewAddManualItemButton => 'Tambah item manual';

  @override
  String get batchCostingReviewEmptyTitle => 'Belum ada item batch';

  @override
  String get batchCostingReviewEmptyBody =>
      'Tambahkan cetakan manual untuk melanjutkan.';

  @override
  String get batchCostingReviewImportGcodeButton => 'Impor file G-code';

  @override
  String get batchCostingReviewImportGcodeButtonPremium =>
      'Impor file G-code (Premium)';

  @override
  String get batchGcodeImportTitle => 'Impor G-code batch';

  @override
  String get batchGcodeImportBody =>
      'Pilih satu atau beberapa file G-code. Setiap file diurai sendiri.';

  @override
  String get batchGcodeImportPickButton => 'Pilih file';

  @override
  String get batchGcodeImportSuccessLabel => 'Berhasil diimpor';

  @override
  String get batchGcodeImportFailureLabel => 'Impor gagal';

  @override
  String get batchGcodeImportParseFailure => 'File ini tidak dapat diimpor.';

  @override
  String get batchGcodeImportContinueButton => 'Lanjut ke tinjauan batch';

  @override
  String get batchGcodeImportRetryButton => 'Pilih lagi';

  @override
  String get batchGcodeImportImportingLabel => 'Mengimpor…';

  @override
  String get batchGcodeImportPendingLabel => 'Tertunda';

  @override
  String get batchGcodeImportNeedsDetailsLabel => 'Detail diperlukan';

  @override
  String get batchGcodeImportReadyLabel => 'Siap';

  @override
  String get batchGcodeImportNeedsWeight => 'Berat diperlukan';

  @override
  String get batchGcodeImportNeedsDuration => 'Durasi diperlukan';

  @override
  String get batchGcodeImportApply => 'Terapkan';

  @override
  String get batchGcodeImportAddButton => 'Tambahkan ke tinjauan batch';

  @override
  String get batchGcodeImportDetailsButton => 'Detail';

  @override
  String get batchGcodeImportDuplicateMessage =>
      'Beberapa file sudah ditambahkan.';

  @override
  String get batchGcodeImportQuantityHint =>
      'Jumlah dapat disesuaikan pada langkah berikutnya.';

  @override
  String get batchCostingReviewContinueButton =>
      'Lanjutkan ke penugasan printer';

  @override
  String get batchCostingReviewQuantityLabel => 'Jumlah';

  @override
  String get batchCostingReviewRemoveButton => 'Hapus';

  @override
  String get batchCostingReviewSourceLabel => 'Sumber';

  @override
  String get batchCostingReviewSourceManual => 'Manual';

  @override
  String get batchCostingReviewSourceGcode => 'G-code';

  @override
  String get batchCostingReviewSourceUnknown => 'Tidak diketahui';

  @override
  String get batchCostingReviewWeightLabel => 'Berat';

  @override
  String get batchCostingReviewDurationLabel => 'Durasi';

  @override
  String get batchCostingReviewWeightRequired => 'Berat diperlukan';

  @override
  String get batchCostingReviewDurationRequired => 'Durasi diperlukan';

  @override
  String get batchCostingReviewMissingFieldsError =>
      'Lengkapi bidang yang diperlukan';

  @override
  String get batchCostingItemEditorAddTitle => 'Tambah item manual';

  @override
  String get batchCostingItemEditorEditTitle => 'Edit item batch';

  @override
  String get batchCostingItemNameLabel => 'Nama item / model';

  @override
  String get batchCostingPrinterAssignmentAppBarTitle => 'Penugasan printer';

  @override
  String get batchCostingPrinterAssignmentSubtitle =>
      'Tetapkan printer sebelum material.';

  @override
  String get batchCostingPrinterAssignmentBatchWideMode => 'Satu batch';

  @override
  String get batchCostingPrinterAssignmentPerItemMode => 'Per item';

  @override
  String get batchCostingPrinterAssignmentBatchWideHint =>
      'Pilih satu printer untuk semua item.';

  @override
  String get batchCostingPrinterAssignmentPerItemHint =>
      'Pilih printer untuk item ini.';

  @override
  String get batchCostingAssignmentSplitCopiesButton => 'Bagi salinan';

  @override
  String batchCostingAssignmentSplitCopiesDialogTitle(Object itemName) {
    return 'Bagi salinan untuk $itemName';
  }

  @override
  String batchCostingAssignmentSplitCopiesTotalError(Object total) {
    return 'Total harus sama dengan $total';
  }

  @override
  String get batchCostingAssignmentQuantityChangedMessage =>
      'Penugasan diatur ulang karena kuantitas berubah.';

  @override
  String get batchCostingAssignmentCopiesLabel => 'Salinan';

  @override
  String get batchCostingAllocationPickerSearchLabel => 'Cari opsi';

  @override
  String get batchCostingAllocationPickerAvailableLabel => 'Tersedia';

  @override
  String get batchCostingAllocationPickerSelectedLabel => 'Dipilih';

  @override
  String get batchCostingAllocationPickerAddButton => 'Tambah';

  @override
  String get batchCostingAllocationPickerNoResultsLabel => 'Tidak ada hasil.';

  @override
  String get batchCostingPrinterAssignmentRequiredError =>
      'Pilih printer untuk lanjut.';

  @override
  String get batchCostingPrinterAssignmentPreviousButton => 'Sebelumnya';

  @override
  String get batchCostingPrinterAssignmentNextButton => 'Selanjutnya';

  @override
  String get batchCostingPrinterAssignmentNoPrintersMessage =>
      'Belum ada printer yang tersedia.';

  @override
  String get batchCostingMaterialAssignmentAppBarTitle => 'Penugasan material';

  @override
  String get batchCostingMaterialAssignmentSubtitle =>
      'Tetapkan material atau spool sebelum harga.';

  @override
  String get batchCostingMaterialAssignmentMaterialLabel =>
      'Material atau spool';

  @override
  String get batchCostingMaterialAssignmentBatchWideMode => 'Seluruh batch';

  @override
  String get batchCostingMaterialAssignmentPerItemMode => 'Per item';

  @override
  String get batchCostingMaterialAssignmentBatchWideHint =>
      'Pilih satu material untuk semua item.';

  @override
  String get batchCostingMaterialAssignmentPerItemHint =>
      'Pilih material untuk item ini.';

  @override
  String get batchCostingMaterialAssignmentRequiredError =>
      'Pilih material untuk melanjutkan.';

  @override
  String get batchCostingMaterialAssignmentPreviousButton => 'Sebelumnya';

  @override
  String get batchCostingMaterialAssignmentNextButton => 'Selanjutnya';

  @override
  String get batchCostingMaterialAssignmentNoMaterialsMessage =>
      'Tambahkan setidaknya satu material atau spool untuk melanjutkan.';

  @override
  String batchCostingMaterialAssignmentStockWarning(
    Object available,
    Object required,
  ) {
    return 'Yang dibutuhkan $required melebihi stok terpilih $available.';
  }

  @override
  String get batchCostingPricingScopeAppBarTitle => 'Ruang harga';

  @override
  String get batchCostingPricingScopeSubtitle =>
      'Atur di mana setiap nilai harga berlaku.';

  @override
  String get batchCostingPricingScopeItemMode => 'Item';

  @override
  String get batchCostingPricingScopeBatchMode => 'Batch';

  @override
  String get batchCostingPricingScopeItemSummaryLabel => 'Item (per salinan)';

  @override
  String get batchCostingPricingScopeBatchSummaryLabel => 'Batch (sekali)';

  @override
  String get batchCostingPricingScopeScopeLabel => 'Lingkup';

  @override
  String get batchCostingSummaryAppBarTitle => 'Ringkasan batch';

  @override
  String get batchCostingSummarySubtitle =>
      'Tinjau batch sebelum membuat kutipan.';

  @override
  String get batchCostingSummaryOverviewTitle => 'Ringkasan';

  @override
  String get batchCostingSummaryItemCountLabel => 'Item';

  @override
  String get batchCostingSummaryTotalQuantityLabel => 'Jumlah total';

  @override
  String get batchCostingSummaryTotalWeightLabel => 'Berat total';

  @override
  String get batchCostingSummaryTotalDurationLabel => 'Waktu cetak total';

  @override
  String get batchCostingSummaryItemWeightLabel => 'Berat';

  @override
  String get batchCostingSummaryItemDurationLabel => 'Waktu cetak';

  @override
  String get batchCostingSummaryItemBaseCostLabel => 'Biaya dasar';

  @override
  String get batchCostingSummaryItemAdjustmentLabel => 'Penyesuaian';

  @override
  String get batchCostingSummaryItemTotalLabel => 'Total item';

  @override
  String get batchCostingSummaryFinalTotalLabel => 'Total akhir';

  @override
  String get batchCostingSummaryBackButton => 'Kembali ke cakupan harga';

  @override
  String get batchCostingSummaryReturnToCalculatorButton =>
      'Kembali ke kalkulator';

  @override
  String get batchCostingSummaryStartNewBatchButton => 'Mulai batch baru';

  @override
  String get batchCostingSummaryEmptyTitle => 'Belum ada ringkasan batch';

  @override
  String get batchCostingSummaryEmptyBody =>
      'Tambahkan item dan atur cakupan harga sebelum meninjau ringkasan.';

  @override
  String get batchCostingSummaryPricingTitle => 'Penetapan harga';

  @override
  String get batchCostingSummaryItemsTitle => 'Item';

  @override
  String get batchCostingNewBatchDialogTitle => 'Mulai batch baru';

  @override
  String get batchCostingNewBatchDialogBody =>
      'Ini akan membuang semua kemajuan batch saat ini. Mulai batch baru?';

  @override
  String batchCostingSummaryPricingItemScopeFormat(
    Object lineTotal,
    Object perUnit,
  ) {
    return '$perUnit per → $lineTotal total';
  }

  @override
  String get batchCostingAssignmentPrinterLabel => 'Printer';

  @override
  String get batchCostingEntryButton => 'Mulai penawaran batch';

  @override
  String get paywallTitle => 'Buka Premium';

  @override
  String get paywallPitchLine =>
      'Material tanpa batas, printer tanpa batas, ekspor batch, harga lanjutan';

  @override
  String get paywallSubtitle =>
      'Buka semua fitur dengan pembelian satu kali atau langganan. Tanpa akun, tanpa pelacakan, hanya data Anda di perangkat Anda.';

  @override
  String get paywallOfferingError =>
      'Tidak dapat memuat paket. Periksa koneksi Anda dan coba lagi.';

  @override
  String get paywallCta => 'Buka Premium';

  @override
  String get paywallRestore => 'Pulihkan Pembelian';

  @override
  String get paywallRowPrintersLabel => 'Printer';

  @override
  String get paywallRowMaterialsLabel => 'Material';

  @override
  String get paywallRowHistoryLabel => 'Simpanan riwayat';

  @override
  String get paywallRowBatchCostingLabel => 'Penetapan biaya batch';

  @override
  String get paywallRowAdvancedPricingLabel => 'Harga lanjutan';

  @override
  String get paywallRowExportToolsLabel => 'Alat ekspor';

  @override
  String get paywallRowInventoryTrackingLabel => 'Pelacakan stok';

  @override
  String get paywallValueUnlimited => 'Tanpa batas';

  @override
  String get paywallValueYes => 'Ya';

  @override
  String get paywallValueNo => 'Tidak';

  @override
  String get paywallValueBasic => 'Dasar';

  @override
  String get paywallValueFull => 'Penuh';

  @override
  String get paywallValueSingleJob => 'Satu pekerjaan';

  @override
  String get paywallValueFullSuite => 'Paket lengkap';

  @override
  String paywallValueUpToModels(Object limit) {
    return 'Hingga $limit model';
  }

  @override
  String get paywallBestValue => 'Nilai terbaik';

  @override
  String get paywallPlanMonthly => 'Bulanan';

  @override
  String get paywallPlanQuarterly => 'Triwulanan';

  @override
  String get paywallPlanAnnual => 'Tahunan';

  @override
  String get paywallPlanLifetime => 'Seumur hidup';

  @override
  String paywallPlanPriceMonthly(Object price) {
    return '$price / bulan';
  }

  @override
  String paywallPlanPriceQuarterly(Object price) {
    return '$price / 3 bulan';
  }

  @override
  String paywallPlanPriceAnnual(Object price) {
    return '$price / tahun';
  }

  @override
  String paywallPlanPriceLifetime(Object price) {
    return '$price sekali';
  }

  @override
  String get paywallPlanTrial => 'Uji coba gratis 7 hari';

  @override
  String get paywallPlanCancelAnytime => 'Batalkan kapan saja';

  @override
  String get paywallPlanOwnForever => 'Miliki Premium selamanya';

  @override
  String get paywallTrustLine => 'Utamakan offline • Tanpa akun';

  @override
  String get paywallCtaAnnualTrial => 'Mulai uji coba gratis 7 hari';

  @override
  String paywallCtaQuarterly(Object price) {
    return 'Upgrade seharga $price';
  }

  @override
  String paywallCtaLifetime(Object price) {
    return 'Buka Premium seharga $price';
  }

  @override
  String paywallCtaGeneric(Object price) {
    return 'Upgrade seharga $price';
  }

  @override
  String paywallValueSaves(Object limit) {
    return '$limit penyimpanan';
  }

  @override
  String get paywallFeatureMaterialsTitle => 'Material tanpa batas';

  @override
  String get paywallFeatureMaterialsDesc =>
      'Simpan dan kelola spool filamen dan material tanpa batas.';

  @override
  String get paywallFeaturePrintersTitle => 'Printer tanpa batas';

  @override
  String get paywallFeaturePrintersDesc =>
      'Buat dan kelola profil printer tanpa batas.';

  @override
  String get paywallFeatureHistoryExportTitle => 'Ekspor riwayat';

  @override
  String get paywallFeatureHistoryExportDesc =>
      'Ekspor entri riwayat individual ke CSV.';

  @override
  String get paywallFeatureBulkHistoryExportTitle => 'Ekspor riwayat massal';

  @override
  String get paywallFeatureBulkHistoryExportDesc =>
      'Ekspor semua riwayat sekaligus ke CSV.';

  @override
  String get paywallFeatureBatchGcodeImportTitle => 'Impor G-code batch';

  @override
  String get paywallFeatureBatchGcodeImportDesc =>
      'Impor beberapa file G-code sekaligus untuk penetapan biaya batch.';

  @override
  String get paywallFeatureBatchExportTitle => 'Ekspor batch';

  @override
  String get paywallFeatureBatchExportDesc =>
      'Ekspor penawaran batch dan ringkasan.';

  @override
  String get paywallFeatureLabourPricingTitle => 'Harga tenaga kerja';

  @override
  String get paywallFeatureLabourPricingDesc =>
      'Tambahkan tarif tenaga kerja per jam ke perhitungan biaya.';

  @override
  String get paywallFeatureRiskPricingTitle => 'Harga risiko';

  @override
  String get paywallFeatureRiskPricingDesc =>
      'Masukkan risiko kegagalan ke harga secara otomatis.';

  @override
  String get paywallFeatureAdvancedPricingConfigTitle => 'Harga lanjutan';

  @override
  String get paywallFeatureAdvancedPricingConfigDesc =>
      'Atur markup, biaya penyiapan, dan pembulatan.';

  @override
  String get paywallFeatureCsvMaterialImportTitle => 'Impor material CSV';

  @override
  String get paywallFeatureCsvMaterialImportDesc =>
      'Impor material secara massal dari file CSV.';

  @override
  String get paywallFeatureStockTrackingTitle => 'Pelacakan stok';

  @override
  String get paywallFeatureStockTrackingDesc =>
      'Lacak stok filamen dan dapatkan peringatan stok rendah.';

  @override
  String get paywallRestoreSuccess => 'Pembelian berhasil dipulihkan.';

  @override
  String get paywallRestoreError =>
      'Gagal memulihkan pembelian. Silakan coba lagi nanti.';

  @override
  String get paywallEmptyOfferings =>
      'Saat ini tidak ada paket langganan yang tersedia. Silakan coba lagi nanti.';

  @override
  String get helpSupportFaqPremiumQuestion => 'Apa yang ditambahkan Premium?';

  @override
  String get helpSupportFaqPremiumAnswer =>
      'Free mencakup semua yang diperlukan untuk menghitung biaya cetak, termasuk listrik, cetakan multi-material, impor G-code, dan penetapan biaya batch.\n\nPremium menambahkan alat penetapan harga lanjutan seperti tenaga kerja, risiko kegagalan, markup, biaya penyiapan, rincian biaya terperinci, penyimpanan data tak terbatas, dan pelacakan inventaris filamen.';

  @override
  String get helpSupportFaqPremiumUpgradeCta => 'Tingkatkan ke Premium';

  @override
  String get helpSupportFaqPremiumComparisonCta =>
      'Lihat perbandingan lengkap →';

  @override
  String get dataBackupRestoreHeader => 'Data / Cadangkan & Pulihkan';

  @override
  String get dataBackupRestoreBody =>
      'Cadangan mencakup pengaturan aplikasi lokal, printer, material, dan data tersimpan Anda. Pembelian tidak termasuk.';

  @override
  String get dataBackupExportButton => 'Ekspor cadangan';

  @override
  String get dataBackupRestoreButton => 'Pulihkan cadangan';

  @override
  String get dataBackupRestoreConfirmTitle => 'Pulihkan cadangan?';

  @override
  String get dataBackupRestoreConfirmBody =>
      'Memulihkan cadangan dapat menggantikan data lokal Anda saat ini. Lanjutkan?';

  @override
  String get dataBackupExportSuccess => 'Cadangan diekspor';

  @override
  String get dataBackupExportError => 'Ekspor cadangan gagal';

  @override
  String get dataBackupRestoreSuccess => 'Cadangan dipulihkan';

  @override
  String get dataBackupRestoreError => 'Pemulihan cadangan gagal';

  @override
  String get dataBackupJsonFileTypeLabel => 'JSON';

  @override
  String get settingsPremiumCardTitle => 'Tingkatkan ke Premium';

  @override
  String get settingsPremiumCardBody =>
      'Alat penetapan harga lanjutan, penggunaan tanpa batas, dan pelacakan inventaris.';

  @override
  String get settingsPremiumCardCta => 'Tingkatkan';

  @override
  String get calculatorPremiumFooterBody =>
      'Premium menambahkan alat penetapan harga lanjutan.';

  @override
  String get calculatorPremiumFooterCta => 'Pelajari lebih lanjut →';

  @override
  String automaticBackupLastSuccessWithDate(Object dateTime) {
    return 'Cadangan berhasil terakhir: $dateTime.';
  }

  @override
  String get automaticBackupLastSuccessNoBackup =>
      'Cadangan berhasil terakhir: belum ada.';
}
