import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

class HeaderActions extends ConsumerWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: isPremium
          ? IconButton(
              tooltip: l10n.importGcodePageTitle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GCodeImportPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.upload_file_outlined,
                color: Colors.white54,
              ),
            )
          : IconButton(
              onPressed: () async => showModalBottomSheet(
                context: context,
                builder: (_) => const Subscriptions(),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.white54),
            ),
    );
  }
}
