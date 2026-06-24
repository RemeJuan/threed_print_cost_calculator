import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_service.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class BackupRestoreSection extends ConsumerWidget {
  const BackupRestoreSection({super.key, this.pickBackupFile});

  @visibleForTesting
  final Future<XFile?> Function()? pickBackupFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TEXT_SECONDARY,
            ),
          ),
          const SizedBox(height: kAppSpace12),
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(
                  key: const ValueKey('settings.backup.export.button'),
                  onPressed: () async {
                    try {
                      final result = await ref
                          .read(backupRestoreServiceProvider)
                          .exportBackup();
                      if (result.isEmpty) return;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dataBackupExportSuccess)),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dataBackupExportError)),
                        );
                      }
                    }
                  },
                  label: l10n.dataBackupExportButton,
                ),
              ),
              const SizedBox(width: kAppSpace8),
              Expanded(
                child: AppPrimaryButton(
                  key: const ValueKey('settings.backup.restore.button'),
                  onPressed: () async {
                    final XFile? file;
                    try {
                      file = await (pickBackupFile ??
                          () => openFile(
                                acceptedTypeGroups: backupAcceptedTypeGroups(
                                  defaultTargetPlatform,
                                  l10n,
                                ),
                              ))();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dataBackupRestoreError)),
                        );
                      }
                      return;
                    }
                    if (file == null || !context.mounted) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.dataBackupRestoreConfirmTitle),
                        content: Text(l10n.dataBackupRestoreConfirmBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: Text(l10n.cancelButton),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: Text(l10n.dataBackupRestoreButton),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    try {
                      await restoreBackupAndRefresh(
                        restore: () => ref
                            .read(backupRestoreServiceProvider)
                            .restoreBackupFromFile(file!),
                        resetCalculator: () =>
                            ref.read(calculatorProvider.notifier).resetToDefaults(),
                        refreshHistory: () =>
                            ref.read(historyPagedProvider.notifier).refresh(),
                        waitForEndOfFrame: () => SchedulerBinding.instance.endOfFrame,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dataBackupRestoreSuccess)),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.dataBackupRestoreError)),
                        );
                      }
                    }
                  },
                  label: l10n.dataBackupRestoreButton,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
Future<void> restoreBackupAndRefresh({
  required Future<void> Function() restore,
  required Future<void> Function() resetCalculator,
  required Future<void> Function() refreshHistory,
  required Future<void> Function() waitForEndOfFrame,
}) async {
  await waitForEndOfFrame();
  await restore();
  await resetCalculator();
  await refreshHistory();
}

@visibleForTesting
List<XTypeGroup> backupAcceptedTypeGroups(
  TargetPlatform platform,
  AppLocalizations l10n,
) {
  final label = l10n.dataBackupJsonFileTypeLabel;
  switch (platform) {
    case TargetPlatform.iOS:
      return [
        XTypeGroup(label: label, uniformTypeIdentifiers: ['public.data']),
      ];
    default:
      return [
        XTypeGroup(label: label, extensions: ['json']),
      ];
  }
}
