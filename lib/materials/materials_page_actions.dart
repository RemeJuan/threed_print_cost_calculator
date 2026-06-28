import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';

const materialsSwipeHintShownPreferenceKey = 'materials_swipe_hint_shown';

class MaterialsPageActions {
  MaterialsPageActions({
    required this.ref,
    required this.l10n,
    required this.materialsRepository,
    required this.policy,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final MaterialsRepository materialsRepository;
  final PremiumAccessPolicy policy;

  Future<int> _currentMaterialCount() async {
    final currentMaterials = ref
        .read(materialsStreamProvider)
        .maybeWhen(data: (items) => items.length, orElse: () => null);
    return currentMaterials ?? materialsRepository.count();
  }

  void dismissSwipeHint({
    required ValueNotifier<bool> showSwipeHint,
    required SharedPreferences prefs,
  }) {
    if (!showSwipeHint.value) return;
    showSwipeHint.value = false;
    prefs.setBool(materialsSwipeHintShownPreferenceKey, true);
  }

  Future<void> deleteMaterial({
    required BuildContext context,
    required String materialId,
  }) async {
    try {
      await materialsRepository.deleteMaterial(materialId);
      if (context.mounted) {
        BotToast.showText(text: l10n.deleteMaterialSuccessMessage);
      }
    } catch (_) {
      if (!context.mounted) return;
      BotToast.showText(text: l10n.deleteRecordErrorMessage);
      return;
    }

    try {
      await ref
          .read(calculatorProvider.notifier)
          .clearUsagesForDeletedMaterial(materialId);
    } catch (_) {
      // Cleanup failure is non-fatal; material is deleted.
    }
  }

  Future<void> duplicateMaterial({
    required BuildContext context,
    required String materialId,
  }) async {
    try {
      final duplicateAccess = policy.canCreateMaterial(
        await _currentMaterialCount(),
      );
      if (!duplicateAccess.allowed) {
        if (!context.mounted) return;
        BotToast.showText(text: l10n.materialLimitReachedMessage);
        return;
      }

      final existing = await materialsRepository.getMaterialById(materialId);
      if (existing == null) return;
      final copy = existing.copyWith(
        id: '',
        name: '${existing.name} (${l10n.duplicateButton})',
      );
      await materialsRepository.saveMaterial(copy);
      if (!context.mounted) return;
      BotToast.showText(text: l10n.duplicateMaterialSuccessMessage);
    } catch (_) {
      if (!context.mounted) return;
      BotToast.showText(text: l10n.duplicateMaterialErrorMessage);
    }
  }
}
