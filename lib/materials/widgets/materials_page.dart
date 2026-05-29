import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/providers/materials_providers.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_card.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_filters.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_search_bar.dart';

class MaterialsPage extends HookConsumerWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final materials = ref.watch(filteredMaterialsProvider);
    final allMaterials = ref
        .watch(materialsStreamProvider)
        .maybeWhen(data: (items) => items, orElse: () => <MaterialModel>[]);
    final policy = ref.watch(premiumAccessPolicyProvider);
    final materialAccess = policy.canCreateMaterial(allMaterials.length);
    final searchController = useTextEditingController();
    final materialsRepo = ref.read(materialsRepositoryProvider);

    final prefs = ref.read(sharedPreferencesProvider);
    final showSwipeHint = useState(
      !(prefs.getBool('materials_swipe_hint_shown') ?? false),
    );

    void dismissSwipeHint() {
      if (!showSwipeHint.value) return;
      showSwipeHint.value = false;
      prefs.setBool('materials_swipe_hint_shown', true);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: kAppSearchSectionPadding,
            child: AppSearchBar(
              controller: searchController,
              hintText: l10n.searchMaterialsHint,
              showClearButton: true,
              onChanged: (v) {
                ref.read(materialsSearchQueryProvider.notifier).state = v;
              },
              textFieldKey: const ValueKey<String>('materials.search.input'),
              clearButtonKey: const ValueKey<String>(
                'materials.search.clear.button',
              ),
            ),
          ),
          if (showSwipeHint.value)
            Dismissible(
              key: const ValueKey<String>('materials.swipe_hint'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => dismissSwipeHint(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: kAppSpace12,
                  vertical: kAppSpace8,
                ),
                decoration: BoxDecoration(
                  color: LIGHT_BLUE.withAlpha(30),
                  borderRadius: BorderRadius.circular(kAppSurfaceRadius),
                  border: Border.all(color: LIGHT_BLUE.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swipe, size: 16, color: LIGHT_BLUE),
                    const SizedBox(width: kAppSpace8),
                    Expanded(
                      child: Text(
                        l10n.materialsSwipeHint,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: LIGHT_BLUE),
                      ),
                    ),
                    GestureDetector(
                      onTap: dismissSwipeHint,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: LIGHT_BLUE.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const MaterialFilters(),
          const SizedBox(height: 8),
          if (!materialAccess.allowed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.materialLimitReachedMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
              ),
            ),
          Expanded(
            child: materials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: TEXT_TERTIARY,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.materialsEmpty,
                          style: const TextStyle(color: TEXT_TERTIARY),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: materials.length,
                    itemBuilder: (_, i) {
                      final material = materials[i];
                      return MaterialCard(
                        material: material,
                        onEdit: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => MaterialForm(dbRef: material.id),
                          );
                        },
                        onDelete: () async {
                          try {
                            await materialsRepo.deleteMaterial(material.id);
                            if (!context.mounted) return;
                            BotToast.showText(
                              text: l10n.deleteMaterialSuccessMessage,
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            BotToast.showText(
                              text: l10n.deleteRecordErrorMessage,
                            );
                            return;
                          }
                          try {
                            await ref
                                .read(calculatorProvider.notifier)
                                .clearUsagesForDeletedMaterial(material.id);
                          } catch (_) {
                            // Cleanup failure is non-fatal; material is deleted.
                          }
                        },
                        onDuplicate: () async {
                          try {
                            final existing = await materialsRepo
                                .getMaterialById(material.id);
                            if (existing == null) return;
                            final copy = existing.copyWith(
                              id: '',
                              name:
                                  '${existing.name} (${l10n.duplicateButton})',
                            );
                            await materialsRepo.saveMaterial(copy);
                            if (!context.mounted) return;
                            BotToast.showText(
                              text: l10n.duplicateMaterialSuccessMessage,
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            BotToast.showText(
                              text: l10n.duplicateMaterialErrorMessage,
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_material',
        backgroundColor: materialAccess.allowed ? LIGHT_BLUE : TEXT_TERTIARY,
        onPressed: materialAccess.allowed
            ? () {
                showDialog<void>(
                  context: context,
                  builder: (_) => const MaterialForm(),
                );
              }
            : null,
        child: const Icon(Icons.add, color: TEXT_INVERSE),
      ),
    );
  }
}
