import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/providers/materials_providers.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_card.dart';
import 'package:threed_print_cost_calculator/materials/widgets/material_filters.dart';
import 'package:threed_print_cost_calculator/settings/materials/material_form.dart';
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
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.deleteDialogTitle),
                              content: Text(l10n.deleteDialogContent),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.cancelButton),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(l10n.deleteButton),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await materialsRepo.deleteMaterial(material.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.deleteMaterialSuccessMessage,
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.deleteRecordErrorMessage),
                                ),
                              );
                            }
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
