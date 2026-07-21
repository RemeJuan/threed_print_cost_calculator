import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page_actions.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_single_file_content.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';

import 'gcode_import_controller.dart';

class GCodeImportPage extends ConsumerStatefulWidget {
  const GCodeImportPage({super.key, this.source = 'unknown'});

  final String source;

  @override
  ConsumerState<GCodeImportPage> createState() => _GCodeImportPageState();
}

class _GCodeImportPageState extends ConsumerState<GCodeImportPage> {
  final _actions = const GCodeImportPageActions();
  bool _multiMode = false;
  bool _hasLoggedImportStarted = false;
  List<GCodePickedFile> _multiFiles = const [];

  @override
  void initState() {
    super.initState();
    AppAnalytics.safeLog(() => AppAnalytics.gcodeImportOpened());
  }

  @override
  void dispose() {
    if (!_multiMode) {
      AppAnalytics.safeLog(() => AppAnalytics.gcodeImportAbandoned());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(gcodeImportControllerProvider);
    final controller = ref.read(gcodeImportControllerProvider.notifier);
    final parseStatus = state.result?.hasPartialMetadata == true
        ? 'partial'
        : 'success';
    final fileSizeBytes = state.selectedFileSizeBytes ?? 0;

    return Scaffold(
      appBar: AppScreenHeader(
        title: _multiMode
            ? l10n.batchGcodeImportTitle
            : l10n.importGcodePageTitle,
      ),
      body: SafeArea(
        child: _multiMode
            ? BatchGCodeImportPage(initialFiles: _multiFiles, embedded: true)
            : GCodeImportSingleFileContent(
                l10n: l10n,
                state: state,
                fileSizeBytes: fileSizeBytes,
                parseStatus: parseStatus,
                errorMessage: state.error == null
                    ? null
                    : _actions.errorMessage(l10n, state.error!),
                isPrimaryActionEnabled:
                    state.result != null &&
                    _actions.isPrimaryActionEnabled(state.result!),
                onSelectFile: state.status == GCodeImportStatus.loading
                    ? null
                    : () => _pickFiles(controller),
                onPrimaryAction: state.result == null
                    ? null
                    : () => _actions.handlePrimaryAction(
                        context,
                        ref,
                        l10n,
                        result: state.result!,
                        fileSizeBytes: fileSizeBytes,
                        parseStatus: parseStatus,
                      ),
              ),
      ),
    );
  }

  Future<void> _pickFiles(GCodeImportController controller) async {
    _logImportStartedIfNeeded();
    final policy = ref.read(premiumAccessPolicyProvider);
    if (policy.batchGcodeImport().allowed) {
      final files = await ref.read(gcodeImportFilePickerProvider).pickMany();
      if (!mounted) return;
      if (files.isEmpty) {
        AppAnalytics.safeLog(
          () => AppAnalytics.gcodePickerCancelled(source: widget.source),
        );
        return;
      }
      if (files.length > 1) {
        AppAnalytics.safeLog(
          () => AppAnalytics.gcodeFlowDivertedToBatch(source: widget.source),
        );
        setState(() {
          _multiMode = true;
          _multiFiles = files;
        });
        return;
      }
      await controller.parsePickedFile(files.single);
      return;
    }

    final file = await ref.read(gcodeImportFilePickerProvider).pick();
    if (!mounted) return;
    if (file == null) {
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodePickerCancelled(source: widget.source),
      );
      return;
    }
    await controller.parsePickedFile(file);
  }

  void _logImportStartedIfNeeded() {
    if (_hasLoggedImportStarted) return;
    _hasLoggedImportStarted = true;
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeImportStarted(source: widget.source),
    );
  }
}
