import 'package:bot_toast/bot_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/backup_restore_service.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class BackupRestoreSection extends ConsumerWidget {
  const BackupRestoreSection({super.key});

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
        ],
      ),
    );
  }
}
