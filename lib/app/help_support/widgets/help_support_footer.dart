import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class HelpSupportFooter extends ConsumerWidget {
  const HelpSupportFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final logger = ref.read(appLoggerProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.website'),
              tooltip: l10n.helpSupportWebsiteLabel,
              icon: const Icon(Icons.public_outlined, size: 18),
              onPressed: () => openUrl(helpSupportWebsiteUrl, logger: logger),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.x'),
              tooltip: l10n.helpSupportXTwitterLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedNewTwitter,
                size: 18,
              ),
              onPressed: () => openUrl(helpSupportXUrl, logger: logger),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.instagram'),
              tooltip: l10n.helpSupportInstagramLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedInstagram,
                size: 18,
              ),
              onPressed: () => openUrl(helpSupportInstagramUrl, logger: logger),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.threads'),
              tooltip: l10n.helpSupportThreadsLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedThreads,
                size: 18,
              ),
              onPressed: () => openUrl(helpSupportThreadsUrl, logger: logger),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.mastodon'),
              tooltip: l10n.helpSupportMastodonLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMastodon,
                size: 18,
              ),
              onPressed: () => openUrl(helpSupportMastodonUrl, logger: logger),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              key: const ValueKey<String>('helpSupport.footer.privacy'),
              onPressed: () => openUrl(helpSupportPrivacyUrl, logger: logger),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
              ),
              child: Text(l10n.helpSupportPrivacyPolicyLabel, style: muted),
            ),
            Text(l10n.separator, style: muted),
            TextButton(
              key: const ValueKey<String>('helpSupport.footer.terms'),
              onPressed: () => openUrl(helpSupportTermsUrl, logger: logger),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
              ),
              child: Text(l10n.helpSupportTermsOfUseLabel, style: muted),
            ),
          ],
        ),
      ],
    );
  }
}
