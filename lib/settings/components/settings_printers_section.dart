import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
import 'package:threed_print_cost_calculator/settings/settings_section.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class SettingsPrintersSection extends ConsumerWidget {
  const SettingsPrintersSection({
    super.key,
    required this.policy,
    required this.titleStyle,
  });

  final PremiumAccessPolicy policy;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final printersAsync = ref.watch(printersStreamProvider);
    final printerCount = printersAsync.maybeWhen(
      data: (printers) => printers.length,
      orElse: () => null,
    );
    final canAddPrinter =
        printerCount != null && policy.canCreatePrinter(printerCount).allowed;
    final showPrinterLimitMessage =
        printerCount != null && !policy.isPremium && !canAddPrinter;

    return SettingsSection(
      headerKey: const ValueKey<String>('settings.printers.section'),
      bodyKey: const ValueKey<String>('settings.printers.body'),
      title: Text(l10n.printersHeader, style: titleStyle),
      action: IconButton(
        key: const ValueKey<String>('settings.printers.add.button'),
        onPressed: !canAddPrinter
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AddPrinter()),
                );
              },
        icon: const Icon(Icons.add),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Printers(),
          if (showPrinterLimitMessage)
            Padding(
              padding: const EdgeInsets.only(top: kAppSpace8),
              child: Text(
                l10n.printerLimitReachedMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
              ),
            ),
        ],
      ),
    );
  }
}
