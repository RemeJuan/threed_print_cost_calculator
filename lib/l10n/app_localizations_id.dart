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
  String get wattageLabel => 'Daya *';

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
  String get supportEmailPrefix => 'Jika ada masalah, silakan email saya di ';

  @override
  String get supportEmail => '3d@printcostcalc.app';

  @override
  String get supportIdLabel => 'Harap sertakan ID Dukungan Anda: ';

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
  String get privacyPolicyLink => 'Kebijakan Privasi';

  @override
  String get termsOfUseLink => 'Ketentuan Penggunaan';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'Tutup';

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
  String get costTotalLabel => 'Total biaya';

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
      other: '# override diterapkan',
      one: '# override diterapkan',
    );
    return '$_temp0';
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
  String get pricingRoundingWholeDollarLabel => 'Bulatan penuh';

  @override
  String get pricingRoundingPointNinetyNineLabel => 'Berakhir .99';

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
  String get lockedValuePlaceholder => 'Terkunci';

  @override
  String get hideProPromotionsTitle => 'Sembunyikan promosi Pro';

  @override
  String get hideProPromotionsSubtitle =>
      'Sembunyikan banner dan prompt upgrade';

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
  String get historyUpsellDescription => 'Buka edit lanjutan dan ekspor';

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
  String get historyTeaserTitle =>
      'Simpan setiap estimasi cetak di satu tempat';

  @override
  String get historyTeaserDescription =>
      'Lihat cara kerja riwayat sebelum upgrade. Simpan estimasi yang selesai dan ekspor kapan saja dengan Pro.';

  @override
  String get historyTeaserCta => 'Simpan dan ekspor riwayat dengan Pro';

  @override
  String get historyExportPreviewEntry => 'Pratinjau ekspor CSV';

  @override
  String get historyExportPreviewTitle => 'Pratinjau CSV';

  @override
  String get historyExportPreviewDescription =>
      'Lihat seperti apa hasil ekspor Anda. Unduh dan bagikan dibuka dengan Pro.';

  @override
  String get historyExportPreviewSampleLabel => '[Contoh]';

  @override
  String get historyExportPreviewAction => 'Unduh / Bagikan dengan Pro';

  @override
  String get addMaterialButton => 'Tambahkan bahan';

  @override
  String get useSingleTotalWeightAction => 'Gunakan total berat tunggal';

  @override
  String get addAtLeastOneMaterial => 'Tambahkan setidaknya satu material.';

  @override
  String get searchMaterialsHint => 'Cari bahan';

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
  String get importGcodePreviewUnavailable => 'Tidak tersedia';

  @override
  String get importGcodePreviewDecodeFailed =>
      'Metadata pratinjau ditemukan tetapi gambar tidak dapat ditampilkan.';

  @override
  String get importGcodePreviewCuraNote =>
      'Pratinjau Cura mungkin memerlukan skrip pasca-pemrosesan untuk menyematkan thumbnail.';

  @override
  String get importGcodeWarningsTitle => 'Peringatan';

  @override
  String get importGcodeUnsupportedTypeError => 'Pilih file .gcode.';

  @override
  String get importGcodeUnsupportedFileError =>
      'File ini tidak berisi metadata G-code yang didukung.';

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
  String get startFreeTrialCta => 'Mulai uji coba gratis';
}
