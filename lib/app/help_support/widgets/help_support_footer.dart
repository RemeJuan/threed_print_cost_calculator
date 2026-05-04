import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportFooter extends StatelessWidget {
  const HelpSupportFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.website'),
              tooltip: l10n.helpSupportWebsiteLabel,
              icon: const Icon(Icons.public_outlined, size: 18),
              onPressed: () => openUrl('https://printcostcalc.app'),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.x'),
              tooltip: l10n.helpSupportXTwitterLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedNewTwitter,
                size: 18,
              ),
              onPressed: () => openUrl('https://x.com/PrintCostCalc'),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.instagram'),
              tooltip: l10n.helpSupportInstagramLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedInstagram,
                size: 18,
              ),
              onPressed: () =>
                  openUrl('https://www.instagram.com/3dprintcostcalculator'),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              key: const ValueKey<String>('helpSupport.footer.mastodon'),
              tooltip: l10n.helpSupportMastodonLabel,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMastodon,
                size: 18,
              ),
              onPressed: () =>
                  openUrl('https://mastodon.social/@printcostcalc'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              key: const ValueKey<String>('helpSupport.footer.privacy'),
              onPressed: () =>
                  openUrl('https://printcostcalc.app/privacy.html'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
              ),
              child: Text(l10n.helpSupportPrivacyPolicyLabel, style: muted),
            ),
            Text(l10n.separator, style: muted),
            TextButton(
              key: const ValueKey<String>('helpSupport.footer.terms'),
              onPressed: () => openUrl(
                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
              ),
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

Future<void> openUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
