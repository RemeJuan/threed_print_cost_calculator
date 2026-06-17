import 'package:bot_toast/bot_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_service.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/automatic_backup_service.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';
import 'package:auto_backup_platform/auto_backup_platform.dart';

class BackupRestoreSection extends ConsumerWidget {
  const BackupRestoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final backupConfig = ref.watch(automaticBackupConfigProvider);
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dataBackupRestoreHeader,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TEXT_PRIMARY,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: kAppSpace8),
          Text(
            l10n.dataBackupRestoreBody,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: TEXT_SECONDARY),
          ),
          const SizedBox(height: kAppSpace12),
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(backupRestoreServiceProvider)
                          .exportBackup();
                      if (context.mounted) {
                        BotToast.showText(text: l10n.dataBackupExportSuccess);
                      }
                    } catch (_) {
                      if (context.mounted) {
                        BotToast.showText(text: l10n.dataBackupExportError);
                      }
                    }
                  },
                  label: l10n.dataBackupExportButton,
                ),
              ),
              const SizedBox(width: kAppSpace8),
              Expanded(
                child: AppPrimaryButton(
                  onPressed: () async {
                    final file = await openFile(
                      acceptedTypeGroups: [
                        const XTypeGroup(label: 'JSON', extensions: ['json']),
                      ],
                    );
                    if (file == null) return;
                    if (!context.mounted) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.dataBackupRestoreConfirmTitle),
                        content: Text(l10n.dataBackupRestoreConfirmBody),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(l10n.cancelButton),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: Text(l10n.dataBackupRestoreButton),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    try {
                      await ref
                          .read(backupRestoreServiceProvider)
                          .restoreBackupFromFile(file);
                      if (context.mounted) {
                        BotToast.showText(text: l10n.dataBackupRestoreSuccess);
                      }
                    } catch (_) {
                      if (context.mounted) {
                        BotToast.showText(text: l10n.dataBackupRestoreError);
                      }
                    }
                  },
                  label: l10n.dataBackupRestoreButton,
                ),
              ),
            ],
          ),
          if (automaticBackupAccess.allowed) ...[
            const SizedBox(height: kAppSpace12),
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                onPressed: () =>
                    _scheduleBackup(context, ref, automaticBackupAccess),
                label: l10n.scheduleAutomaticBackupButton,
                minHeight: 42,
              ),
            ),
            const SizedBox(height: kAppSpace8),
            Text(
              l10n.automaticBackupNote,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY),
            ),
            backupConfig.when(
              data: (config) {
                if (config == null || !config.enabled) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: kAppSpace8),
                  child: Text(
                    l10n.automaticBackupStatusLabel(
                      _cadenceLabel(l10n, config.cadenceValue),
                      config.displayLabel,
                      _resultLabel(l10n, config.lastResult),
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scheduleBackup(
    BuildContext context,
    WidgetRef ref,
    FeatureAccess access,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!access.allowed) {
      await ref
          .read(paywallPresenterProvider)
          .present(
            'pro',
            triggerFeature: 'automatic_backup',
            purchaseSource: 'settings',
            source: 'settings',
          );
      return;
    }
    final cadence = await showModalBottomSheet<AutomaticBackupCadence>(
      context: context,
      builder: (sheetContext) => _CadencePickerSheet(l10n: l10n),
    );
    if (cadence == null) return;
    final destination = await _pickDestination();
    if (destination == null) return;
    final config = AutomaticBackupConfig(
      enabled: true,
      cadence: cadence.value,
      accessToken: destination['accessToken'] as String,
      displayLabel: destination['displayLabel'] as String,
      platform: destination['platform'] as String,
    );
    final service = ref.read(automaticBackupServiceProvider);
    try {
      final writable = await service.verifyDestination(config);
      if (!writable) throw StateError('destination not writable');
      await service.schedule(config);
      final runResult = await service.runOnce(force: true);
      if (runResult != AutomaticBackupRunResult.success) {
        throw StateError('initial backup failed');
      }
      if (context.mounted) {
        BotToast.showText(text: l10n.automaticBackupScheduleSuccess);
      }
    } catch (_) {
      if (context.mounted) {
        BotToast.showText(text: l10n.automaticBackupScheduleError);
      }
    }
  }

  Future<Map<String, Object?>?> _pickDestination() async {
    return AutoBackupPlatform().pickDestination();
  }

  String _cadenceLabel(AppLocalizations l10n, AutomaticBackupCadence cadence) {
    return switch (cadence) {
      AutomaticBackupCadence.daily => l10n.automaticBackupDailyLabel,
      AutomaticBackupCadence.weekly => l10n.automaticBackupWeeklyLabel,
      AutomaticBackupCadence.monthly => l10n.automaticBackupMonthlyLabel,
    };
  }

  String _resultLabel(AppLocalizations l10n, String? result) {
    return switch (AutomaticBackupRunResult.fromValue(result)) {
      AutomaticBackupRunResult.success => l10n.automaticBackupStatusSuccess,
      AutomaticBackupRunResult.failure => l10n.automaticBackupStatusFailure,
      AutomaticBackupRunResult.skipped ||
      null => l10n.automaticBackupStatusPending,
    };
  }
}

class _CadencePickerSheet extends StatelessWidget {
  const _CadencePickerSheet({required this.l10n});
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in [
            (AutomaticBackupCadence.daily, l10n.automaticBackupDailyLabel),
            (AutomaticBackupCadence.weekly, l10n.automaticBackupWeeklyLabel),
            (AutomaticBackupCadence.monthly, l10n.automaticBackupMonthlyLabel),
          ])
            ListTile(
              title: Text(entry.$2),
              onTap: () => Navigator.of(context).pop(entry.$1),
            ),
        ],
      ),
    );
  }
}
