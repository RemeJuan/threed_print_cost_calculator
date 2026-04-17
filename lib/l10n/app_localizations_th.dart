// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get calculatorAppBarTitle => 'เครื่องคิดเลขการพิมพ์ 3 มิติ';

  @override
  String get historyAppBarTitle => 'ประวัติ';

  @override
  String get settingsAppBarTitle => 'การตั้งค่า';

  @override
  String get calculatorNavLabel => 'เครื่องคิดเลข';

  @override
  String get historyNavLabel => 'ประวัติ';

  @override
  String get settingsNavLabel => 'การตั้งค่า';

  @override
  String get generalHeader => 'ทั่วไป';

  @override
  String get wattLabel => 'วัตต์ (เครื่องพิมพ์ 3D)';

  @override
  String get printWeightLabel => 'น้ำหนักของการพิมพ์';

  @override
  String get hoursLabel => 'เวลาในการพิมพ์ (ชั่วโมง)';

  @override
  String get wearAndTearLabel => 'วัสดุ/การสึกหรอ + ฉีกขาด';

  @override
  String get labourRateLabel => 'อัตราชั่วโมง';

  @override
  String get labourTimeLabel => 'ระยะเวลาดำเนินการ';

  @override
  String get failureRiskLabel => 'ความเสี่ยงจากความล้มเหลว (%)';

  @override
  String get minutesLabel => 'นาที';

  @override
  String get spoolWeightLabel => 'น้ำหนักเส้น/เรซิน';

  @override
  String get spoolCostLabel => 'ค่าเส้น/เรซิน';

  @override
  String get electricityCostLabel => 'ค่าไฟฟ้า';

  @override
  String get electricityCostSettingsLabel => 'ค่าไฟฟ้า';

  @override
  String get submitButton => 'คำนวณ';

  @override
  String get resultElectricityPrefix => 'ค่าไฟฟ้าทั้งหมด: ';

  @override
  String get resultFilamentPrefix => 'ต้นทุนรวมสำหรับเส้นใย: ';

  @override
  String get resultTotalPrefix => 'ค่าใช้จ่ายทั้งหมด: ';

  @override
  String get riskTotalPrefix => 'ต้นทุนความเสี่ยง: ';

  @override
  String get premiumHeader => 'ผู้ใช้ระดับพรีเมียมเท่านั้น:';

  @override
  String get labourCostPrefix => 'ค่าแรง/วัสดุ: ';

  @override
  String get selectPrinterHint => 'เลือกเครื่องพิมพ์';

  @override
  String get watt => 'วัตต์';

  @override
  String get kwh => 'kWh';

  @override
  String get savePrintButton => 'บันทึกงานพิมพ์';

  @override
  String get printNameHint => 'ชื่องานพิมพ์';

  @override
  String get printerNameLabel => 'ชื่อ *';

  @override
  String get bedSizeLabel => 'ขนาดฐานพิมพ์ *';

  @override
  String get wattageLabel => 'กำลังไฟ *';

  @override
  String get materialNameLabel => 'ชื่อวัสดุ *';

  @override
  String get colorLabel => 'สี *';

  @override
  String get weightLabel => 'น้ำหนัก *';

  @override
  String get costLabel => 'ราคา *';

  @override
  String get saveButton => 'บันทึก';

  @override
  String get deleteDialogTitle => 'ลบ';

  @override
  String get deleteDialogContent => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?';

  @override
  String get cancelButton => 'ยกเลิก';

  @override
  String get deleteButton => 'ลบ';

  @override
  String get selectMaterialHint => 'กำหนดเอง (ยังไม่ได้บันทึก)';

  @override
  String get materialNone => 'ไม่มี';

  @override
  String get gramsSuffix => 'g';

  @override
  String get remainingLabel => 'คงเหลือ:';

  @override
  String get trackRemainingFilamentLabel => 'ติดตามฟิลาเมนต์คงเหลือ';

  @override
  String get remainingFilamentLabel => 'ฟิลาเมนต์คงเหลือ';

  @override
  String get savePrintErrorMessage => 'เกิดข้อผิดพลาดขณะบันทึกงานพิมพ์';

  @override
  String get savePrintSuccessMessage => 'บันทึกงานพิมพ์แล้ว';

  @override
  String get historyLoadAction => 'แก้ไขในเครื่องคิดเลข';

  @override
  String get historyLoadSuccessMessage => 'โหลดจากประวัติแล้ว';

  @override
  String get historyLoadReplacementWarning =>
      'บางรายการไม่พร้อมใช้งานและถูกแทนที่แล้ว';

  @override
  String get numberExampleHint => 'เช่น 123';

  @override
  String materialsLoadError(Object error) {
    return 'โหลดวัสดุไม่สำเร็จ: $error';
  }

  @override
  String printersLoadError(Object error) {
    return 'โหลดเครื่องพิมพ์ไม่สำเร็จ: $error';
  }

  @override
  String get retryButton => 'ลองอีกครั้ง';

  @override
  String get wattsSuffix => 'w';

  @override
  String get needHelpTitle => 'ต้องการความช่วยเหลือ?';

  @override
  String get supportEmailPrefix => 'หากมีปัญหา กรุณาส่งอีเมลมาที่ ';

  @override
  String get supportEmail => 'google@remej.dev';

  @override
  String get supportIdLabel => 'โปรดระบุรหัสสนับสนุนของคุณ: ';

  @override
  String get clickToCopy => '(แตะเพื่อคัดลอก)';

  @override
  String get materialWeightExplanation =>
      'น้ำหนักวัสดุคือน้ำหนักรวมของวัสดุต้นทาง หรือก็คือน้ำหนักของม้วนฟิลาเมนต์ทั้งม้วน ค่าใช้จ่ายคือราคาของหน่วยทั้งหมด';

  @override
  String get supportIdCopied => 'คัดลอกรหัสสนับสนุนแล้ว';

  @override
  String get exportSuccess => 'ส่งออกสำเร็จ';

  @override
  String get exportError => 'ส่งออกล้มเหลว';

  @override
  String get exportButton => 'ส่งออก';

  @override
  String get privacyPolicyLink => 'นโยบายความเป็นส่วนตัว';

  @override
  String get termsOfUseLink => 'ข้อกำหนดการใช้งาน';

  @override
  String get separator => ' | ';

  @override
  String get closeButton => 'ปิด';

  @override
  String get mailClientError => 'ไม่สามารถเปิดแอปอีเมลได้';

  @override
  String get offeringsError => 'ข้อผิดพลาด: ';

  @override
  String get currentOfferings => 'ข้อเสนอปัจจุบัน';

  @override
  String get purchaseError =>
      'เกิดข้อผิดพลาดในการประมวลผลการซื้อของคุณ โปรดลองอีกครั้งในภายหลัง';

  @override
  String get restorePurchases => 'กู้คืนการซื้อ';

  @override
  String get printersHeader => 'เครื่องพิมพ์';

  @override
  String get materialsHeader => 'วัสดุ';

  @override
  String get filamentCostLabel => 'ฟิลาเมนต์';

  @override
  String get labourCostLabel => 'ค่าแรง';

  @override
  String get riskCostLabel => 'ความเสี่ยง';

  @override
  String get totalCostLabel => 'ทั้งหมด';

  @override
  String get workCostsLabel => 'ค่าใช้จ่ายงาน';

  @override
  String get enterNumber => 'กรุณาใส่ตัวเลข';

  @override
  String get invalidNumber => 'ตัวเลขไม่ถูกต้อง';

  @override
  String get validationRequired => 'จำเป็น';

  @override
  String get validationEnterValidNumber => 'กรอกตัวเลขที่ถูกต้อง';

  @override
  String get validationMustBeGreaterThanZero => 'ต้องมากกว่า 0';

  @override
  String get validationMustBeZeroOrMore => 'ต้องเป็น 0 หรือมากกว่า';

  @override
  String get lockedValuePlaceholder => 'ถูกล็อก';

  @override
  String get hideProPromotionsTitle => 'ซ่อนโปรโมชัน Pro';

  @override
  String get hideProPromotionsSubtitle => 'ซ่อนแบนเนอร์และข้อความอัปเกรด';

  @override
  String get historySearchHint => 'ค้นหาตามชื่อหรือเครื่องพิมพ์';

  @override
  String get historyExportMenuTitle => 'ส่งออกงานพิมพ์';

  @override
  String get historyExportRangeAll => 'ทั้งหมด';

  @override
  String get historyExportRangeLast7Days => '7 วันที่ผ่านมา';

  @override
  String get historyExportRangeLast30Days => '30 วันที่ผ่านมา';

  @override
  String get historyEmptyTitle => 'ยังไม่มีงานพิมพ์ที่บันทึกไว้';

  @override
  String get historyEmptyDescription =>
      'นำงานพิมพ์ที่ผ่านมาไปใช้ซ้ำในเครื่องคิดเลข';

  @override
  String get historyUpsellTitle => 'นำงานพิมพ์ที่ผ่านมาไปใช้ซ้ำได้ทันที';

  @override
  String get historyUpsellDescription => 'ปลดล็อกการแก้ไขขั้นสูงและการส่งออก';

  @override
  String get historyNoMoreRecords => 'ไม่มีบันทึกเพิ่มเติม';

  @override
  String get historyOverflowHint => 'การทำงานเพิ่มเติมอยู่ใน ⋯';

  @override
  String historyLoadError(Object error) {
    return 'ไม่สามารถโหลดประวัติได้: $error';
  }

  @override
  String get historyCsvHeader =>
      'วันที่,เครื่องพิมพ์,วัสดุ,วัสดุ,น้ำหนัก (ก.),เวลา,ไฟฟ้า,เส้นใย,ค่าแรง,ความเสี่ยง,รวม';

  @override
  String get historyExportShareText => 'การส่งออกประวัติต้นทุนการพิมพ์ 3D';

  @override
  String get historyTeaserTitle => 'เก็บค่าประมาณการพิมพ์ทุกชิ้นไว้ในที่เดียว';

  @override
  String get historyTeaserDescription =>
      'ดูว่าประวัติทำงานอย่างไรก่อนอัปเกรด บันทึกค่าประมาณการที่เสร็จแล้วและส่งออกได้ทุกเมื่อด้วย Pro';

  @override
  String get historyTeaserCta => 'บันทึกและส่งออกประวัติกับ Pro';

  @override
  String get historyExportPreviewEntry => 'ดูตัวอย่างการส่งออก CSV';

  @override
  String get historyExportPreviewTitle => 'ตัวอย่าง CSV';

  @override
  String get historyExportPreviewDescription =>
      'ดูว่าการส่งออกของคุณจะเป็นอย่างไร การดาวน์โหลดและการแชร์ปลดล็อกด้วย Pro';

  @override
  String get historyExportPreviewSampleLabel => '[ตัวอย่าง]';

  @override
  String get historyExportPreviewAction => 'ดาวน์โหลด / แชร์ด้วย Pro';

  @override
  String get addMaterialButton => 'เพิ่มวัสดุ';

  @override
  String get useSingleTotalWeightAction => 'ใช้ค่าน้ำหนักรวมเดียว';

  @override
  String get addAtLeastOneMaterial => 'เพิ่มวัสดุอย่างน้อย 1 รายการ';

  @override
  String get searchMaterialsHint => 'ค้นหาวัสดุ';

  @override
  String get materialBreakdownLabel => 'รายละเอียดวัสดุ';

  @override
  String materialsCountLabel(num count) {
    return '$count วัสดุ';
  }

  @override
  String totalMaterialWeightLabel(num grams) {
    return 'น้ำหนักวัสดุรวม: ${grams}g';
  }

  @override
  String versionLabel(Object version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get materialFallback => 'วัสดุ';
}
