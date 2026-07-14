import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class SettingsPremiumCard extends ConsumerWidget {
  const SettingsPremiumCard({super.key, required this.policy});

  final PremiumAccessPolicy policy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsPremiumCardTitle,
            key: const ValueKey<String>('settings.premium.title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TEXT_PRIMARY,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kAppSpace8),
          Text(
            l10n.settingsPremiumCardBody,
            key: const ValueKey<String>('settings.premium.body'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
          ),
          const SizedBox(height: kAppSpace12),
          SizedBox(
            width: double.infinity,
            child: AppSecondaryButton(
              key: const ValueKey<String>('settings.premium.button'),
              onPressed: () {
                AppAnalytics.safeLog(
                  () => AppAnalytics.premiumFeatureTapped(
                    'settings_premium_card',
                    isPro: policy.isPremium,
                    source: 'settings',
                  ),
                );
                ref
                    .read(paywallPresenterProvider)
                    .present(
                      'pro',
                      triggerFeature: 'settings_premium_card',
                      purchaseSource: 'settings',
                      source: 'settings',
                    );
              },
              label: l10n.settingsPremiumCardCta,
              minHeight: 42,
            ),
          ),
        ],
      ),
    );
  }
}
