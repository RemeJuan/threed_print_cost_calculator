import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

void showWhatsNewSheet(
  BuildContext context, {
  required WhatsNewAnnouncement announcement,
  required Future<void> Function() onDismiss,
  required String wnId,
  required String locale,
  required bool isPremium,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(kAppSurfaceRadiusLarge),
      ),
    ),
    builder: (context) => PopScope(
      canPop: false,
      child: WhatsNewSheet(
        announcement: announcement,
        onDismiss: onDismiss,
        wnId: wnId,
        locale: locale,
        isPremium: isPremium,
      ),
    ),
  );
}

class WhatsNewSheet extends ConsumerStatefulWidget {
  final WhatsNewAnnouncement announcement;
  final Future<void> Function() onDismiss;
  final String wnId;
  final String locale;
  final bool isPremium;

  const WhatsNewSheet({
    super.key,
    required this.announcement,
    required this.onDismiss,
    required this.wnId,
    required this.locale,
    required this.isPremium,
  });

  @override
  ConsumerState<WhatsNewSheet> createState() => _WhatsNewSheetState();
}

class _WhatsNewSheetState extends ConsumerState<WhatsNewSheet> {
  @override
  void initState() {
    super.initState();
    AppAnalytics.safeLog(
      () => AppAnalytics.whatsNewShown(
        wnId: widget.wnId,
        locale: widget.locale,
        isPremium: widget.isPremium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = widget.locale;
    final title = widget.announcement.getLocalizedTitle(languageCode);
    final body = widget.announcement.getLocalizedBody(languageCode);
    final cta = widget.announcement.getLocalizedCta(languageCode);
    final unlockProCta = widget.announcement.getLocalizedUnlockProCta(
      languageCode,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(kAppSpace16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kAppSpace12,
                    vertical: kAppSpace4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(kAppPillRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.celebration_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: kAppSpace4),
                      Text(
                        l10n.newAnnouncementBadgeLabel,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: kAppSpace16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kAppSpace12),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kAppSpace16),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                onPressed: () async {
                  await widget.onDismiss();
                  if (!context.mounted) return;
                  AppAnalytics.safeLog(
                    () => AppAnalytics.whatsNewDismissed(
                      wnId: widget.wnId,
                      locale: widget.locale,
                      isPremium: widget.isPremium,
                    ),
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                label: cta,
              ),
            ),
            const SizedBox(height: kAppSpace12),
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                onPressed: () async {
                  AppAnalytics.safeLog(
                    () => AppAnalytics.whatsNewUnlockProTapped(
                      wnId: widget.wnId,
                      locale: widget.locale,
                      source: 'whats_new',
                    ),
                  );
                  AppAnalytics.safeLog(
                    () => AppAnalytics.premiumFeatureTapped(
                      'whats_new',
                      isPro: widget.isPremium,
                      source: 'whats_new',
                    ),
                  );
                  await widget.onDismiss();
                  if (!context.mounted) return;
                  final presenter = ref.read(paywallPresenterProvider);
                  Navigator.of(context).pop();
                  await presenter.present(
                    'pro',
                    triggerFeature: 'whats_new',
                    purchaseSource: 'whats_new',
                    source: 'whats_new',
                  );
                },
                label: unlockProCta,
              ),
            ),
            const SizedBox(height: kAppSpace8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => openUrl(helpSupportRoadmapUrl),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                ),
                child: Text(
                  l10n.whatsNewSeeRecentUpdates,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
