import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class HeaderActions extends ConsumerWidget {
  const HeaderActions({super.key, required this.showGcodeAction});

  final bool showGcodeAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showGcodeAction) return const SizedBox.shrink();

    final policy = ref.watch(premiumAccessPolicyProvider);
    final isPremium = policy.isPremium;
    final l10n = AppLocalizations.of(context)!;

    final gcodeAllowed = policy.gcodeImport().allowed;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: gcodeAllowed
          ? IconButton(
              tooltip: l10n.importGcodePageTitle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GCodeImportPage(source: 'header'),
                  ),
                );
              },
              icon: const Icon(Icons.upload_file_outlined, color: ICON_MUTED),
            )
          : IconButton(
              onPressed: () async {
                AppAnalytics.safeLog(
                  () => AppAnalytics.premiumFeatureTapped(
                    'pro',
                    isPro: isPremium,
                    source: 'header',
                  ),
                );
                await ref
                    .read(paywallPresenterProvider)
                    .present(
                      'pro',
                      triggerFeature: 'pro',
                      purchaseSource: 'header',
                      source: 'header',
                    );
              },
              icon: const Icon(Icons.shopping_cart, color: ICON_MUTED),
            ),
    );
  }
}
