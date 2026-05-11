import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

const calculationCountPreferenceKey = 'calculation_count';
const hasUsedGcodeImportPreferenceKey = 'has_used_gcode_import';

final appUsageServiceProvider = Provider<AppUsageService>(AppUsageService.new);

class AppUsageService {
  AppUsageService(this.ref);

  final Ref ref;

  SharedPreferences? get _prefs {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }

  int get calculationCount =>
      _prefs?.getInt(calculationCountPreferenceKey) ?? 0;

  bool get hasUsedGcodeImport =>
      _prefs?.getBool(hasUsedGcodeImportPreferenceKey) ?? false;

  Future<void> recordCalculation() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }

    await prefs.setInt(calculationCountPreferenceKey, calculationCount + 1);
  }

  Future<void> markGcodeImportUsed() async {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }

    await prefs.setBool(hasUsedGcodeImportPreferenceKey, true);
  }

  static String calculationCountBucket(int count) {
    if (count <= 0) return '0';
    if (count == 1) return '1';
    if (count <= 4) return '2_4';
    if (count <= 9) return '5_9';
    return '10_plus';
  }
}
