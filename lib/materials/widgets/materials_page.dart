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
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class MaterialsPage extends HookConsumerWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final materials = ref.watch(filteredMaterialsProvider);
    final searchController = useTextEditingController();
    useListenable(searchController);
    final searchFocus = useFocusNode();
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: searchController,
              focusNode: searchFocus,
              decoration: InputDecoration(
                hintText: l10n.searchMaterialsHint,
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          searchController.clear();
                          ref
                                  .read(materialsSearchQueryProvider.notifier)
                                  .state =
                              '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color.fromRGBO(26, 28, 43, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) {
                ref.read(materialsSearchQueryProvider.notifier).state = v;
              },
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
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: LIGHT_BLUE.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LIGHT_BLUE.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.swipe, size: 16, color: LIGHT_BLUE),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.materialsSwipeHint,
                        style: TextStyle(color: LIGHT_BLUE, fontSize: 13),
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
          Expanded(
            child: materials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.materialsEmpty,
                          style: const TextStyle(color: Colors.white54),
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
        backgroundColor: LIGHT_BLUE,
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => const MaterialForm(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
