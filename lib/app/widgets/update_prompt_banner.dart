import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/providers/update_checker_provider.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class UpdatePromptBanner extends ConsumerStatefulWidget {
  const UpdatePromptBanner({super.key});

  @override
  ConsumerState<UpdatePromptBanner> createState() => _UpdatePromptBannerState();
}

class _UpdatePromptBannerState extends ConsumerState<UpdatePromptBanner> {
  String? _lastLoggedPromptKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final info = ref.watch(updateCheckerProvider).asData?.value.info;

    if (info == null || !info.shouldShow) return const SizedBox.shrink();

    final promptKey = [
      info.currentVersion,
      info.storeVersion ?? '',
      info.platform,
      info.source,
    ].join('|');
    if (_lastLoggedPromptKey != promptKey) {
      _lastLoggedPromptKey = promptKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppAnalytics.safeLog(
          () => AppAnalytics.updatePromptShown(
            currentVersion: info.currentVersion,
            storeVersion: info.storeVersion,
            platform: info.platform,
            source: info.source,
          ),
        );
      });
    }

    final storeVersion = info.storeVersion;
    final body =
        info.showStoreVersion && storeVersion != null && storeVersion.isNotEmpty
        ? l10n.updatePromptBody(storeVersion, info.currentVersion)
        : l10n.updatePromptBodyUnknown;

    return Card(
      margin: const EdgeInsets.fromLTRB(kAppSpace16, kAppSpace12, kAppSpace16, 0),
      child: Padding(
        padding: const EdgeInsets.all(kAppSpace16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.updatePromptTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: kAppSpace8),
            Text(body),
            const SizedBox(height: kAppSpace12),
            Wrap(
              spacing: kAppSpace8,
              runSpacing: kAppSpace8,
              children: [
                AppPrimaryButton(
                  onPressed: () async {
                    AppAnalytics.safeLog(
                      () => AppAnalytics.updatePromptTapped(
                        currentVersion: info.currentVersion,
                        storeVersion: info.storeVersion,
                        platform: info.platform,
                        source: info.source,
                      ),
                    );
                    await openAppStoreForPlatform();
                  },
                  label: l10n.updatePromptOpenStoreButton,
                ),
                AppTertiaryButton(
                  onPressed: () {
                    AppAnalytics.safeLog(
                      () => AppAnalytics.updatePromptDismissed(
                        currentVersion: info.currentVersion,
                        storeVersion: info.storeVersion,
                        platform: info.platform,
                        source: info.source,
                      ),
                    );
                    ref.read(updateCheckerProvider.notifier).dismissPrompt();
                  },
                  label: l10n.closeButton,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
