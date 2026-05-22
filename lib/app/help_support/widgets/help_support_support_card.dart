import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/components/settings_version_tap_target.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class HelpSupportSupportCard extends StatelessWidget {
  const HelpSupportSupportCard({
    required this.supportId,
    required this.packageInfoFuture,
    required this.onEmailTap,
    required this.onCopySupportId,
    required this.onRoadmapTap,
    super.key,
  });

  final String supportId;
  final Future<PackageInfo> packageInfoFuture;
  final VoidCallback onEmailTap;
  final VoidCallback onCopySupportId;
  final VoidCallback onRoadmapTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final canCopy = supportId != '—';

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kAppSpace16, kAppSpace16, kAppSpace16, kAppSpace12),
            child: Text(
              l10n.helpSupportSupportIntro,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            key: const ValueKey<String>('helpSupport.support.email'),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: kAppSpace16,
              vertical: 2,
            ),
            title: Text(l10n.helpSupportEmailLabel),
            subtitle: Text(
              l10n.supportEmail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.mark_email_unread_outlined, size: 18),
            onTap: onEmailTap,
          ),
          const Divider(height: 1),
          ListTile(
            key: const ValueKey<String>('helpSupport.support.id'),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: kAppSpace16,
              vertical: 2,
            ),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.helpSupportSupportIdLabel} '),
                  TextSpan(text: supportId),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: canCopy ? onCopySupportId : null,
            trailing: Tooltip(
              message: l10n.helpSupportCopySupportIdTooltip,
              child: const Icon(Icons.copy_outlined, size: 18),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            key: const ValueKey<String>('helpSupport.support.roadmap'),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: kAppSpace16,
              vertical: 2,
            ),
            title: Text(l10n.helpSupportRoadmapLabel),
            subtitle: Text(l10n.helpSupportRoadmapValue),
            trailing: const Icon(Icons.open_in_new_outlined, size: 18),
            onTap: onRoadmapTap,
          ),
          const Divider(height: 1),
          FutureBuilder<PackageInfo>(
            future: packageInfoFuture,
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '—';

              return Stack(
                children: [
                  ListTile(
                    key: const ValueKey<String>('helpSupport.support.version'),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: kAppSpace16,
                      vertical: 2,
                    ),
                    title: Text(
                      AppLocalizations.of(
                        context,
                      )!.helpSupportAppVersionRow(version),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0,
                      child: SettingsVersionTapTarget(
                        tapTargetKey: const ValueKey<String>(
                          'support.version.tapTarget',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
