import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class BackupRestoreSettingsMergeResult {
  const BackupRestoreSettingsMergeResult({
    required this.settings,
    required this.skippedPremiumSettings,
  });

  final GeneralSettingsModel settings;
  final bool skippedPremiumSettings;
}

BackupRestoreSettingsMergeResult mergeBackupRestoreSettings({
  required GeneralSettingsModel restored,
  required GeneralSettingsModel current,
  required bool isPremium,
}) {
  if (isPremium) {
    return BackupRestoreSettingsMergeResult(
      settings: restored,
      skippedPremiumSettings: false,
    );
  }

  final merged = restored.copyWith(
    wearAndTear: current.wearAndTear,
    failureRisk: current.failureRisk,
    labourRate: current.labourRate,
    pricingMarkupPercent: current.pricingMarkupPercent,
    pricingSetupFee: current.pricingSetupFee,
    pricingRoundingMode: current.pricingRoundingMode,
    currencySymbol: current.currencySymbol,
    currencyPosition: current.currencyPosition,
    currencySpacing: current.currencySpacing,
  );

  return BackupRestoreSettingsMergeResult(
    settings: merged,
    skippedPremiumSettings: _premiumOnlySettingsChanged(restored, merged),
  );
}

bool _premiumOnlySettingsChanged(
  GeneralSettingsModel left,
  GeneralSettingsModel right,
) {
  return left.wearAndTear != right.wearAndTear ||
      left.failureRisk != right.failureRisk ||
      left.labourRate != right.labourRate ||
      left.pricingMarkupPercent != right.pricingMarkupPercent ||
      left.pricingSetupFee != right.pricingSetupFee ||
      left.pricingRoundingMode != right.pricingRoundingMode ||
      left.currencySymbol != right.currencySymbol ||
      left.currencyPosition != right.currencyPosition ||
      left.currencySpacing != right.currencySpacing;
}
