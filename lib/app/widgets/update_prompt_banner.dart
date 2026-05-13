import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/update_checker_provider.dart';

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

    final body = info.showStoreVersion
        ? l10n.updatePromptBody(info.storeVersion!, info.currentVersion)
        : l10n.updatePromptBodyUnknown;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.updatePromptTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () {
                    AppAnalytics.safeLog(
                      () => AppAnalytics.updatePromptTapped(
                        currentVersion: info.currentVersion,
                        storeVersion: info.storeVersion,
                        platform: info.platform,
                        source: info.source,
                      ),
                    );
                    unawaited(openAppStoreForPlatform());
                  },
                  child: Text(l10n.updatePromptOpenStoreButton),
                ),
                TextButton(
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
                  child: Text(l10n.closeButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
