import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';

class WhatsNewSheet extends StatelessWidget {
  final WhatsNewAnnouncement announcement;
  final Future<void> Function() onDismiss;

  const WhatsNewSheet({
    super.key,
    required this.announcement,
    required this.onDismiss,
  });

  static void show(
    BuildContext context,
    WhatsNewAnnouncement announcement,
    Future<void> Function() onDismiss,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => PopScope(
        canPop: false,
        child: WhatsNewSheet(
          announcement: announcement,
          onDismiss: onDismiss,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    final title = announcement.getLocalizedTitle(languageCode);
    final body = announcement.getLocalizedBody(languageCode);
    final cta = announcement.getLocalizedCta(languageCode);
    final unlockProCta = announcement.getLocalizedUnlockProCta(languageCode);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.celebration_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.newAnnouncementBadgeLabel,
                        style: TextStyle(
                          fontSize: 12,
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
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await onDismiss();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(cta),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await onDismiss();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  await showSubscriptionsSheet(context);
                },
                child: Text(unlockProCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
