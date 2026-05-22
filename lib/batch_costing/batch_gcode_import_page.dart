import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_gcode_import_body.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/home_button.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_gcode_import_handler.dart';

class BatchGCodeImportPage extends ConsumerStatefulWidget {
  const BatchGCodeImportPage({
    super.key,
    this.initialFiles,
    this.embedded = false,
  });

  final List<GCodePickedFile>? initialFiles;
  final bool embedded;

  @override
  ConsumerState<BatchGCodeImportPage> createState() =>
      _BatchGCodeImportPageState();
}

class _BatchGCodeImportPageState extends ConsumerState<BatchGCodeImportPage> {
  final GCodeImportPageState _pageState = GCodeImportPageState();
  late final BatchGCodeImportHandler _handler;

  @override
  void initState() {
    super.initState();
    _handler = BatchGCodeImportHandler(ref: ref);
  }

  @override
  void dispose() {
    _handler.markUnmounted();
    _pageState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = BatchGcodeImportBody(
      rows: _pageState.rows,
      singleImport: _pageState.singleImport,
      singleImportError: _pageState.singleImportError,
      loading: _pageState.loading,
      onPickFiles: () => _handler.pickAndImport(context, _pageState, setState),
      onRemoveSingleImport: () {
        _handler.removeSingleImport(_pageState.singleImport!, setState);
        _pageState.singleImport = null;
      },
      onApplySingleImportDetails: () {
        if (_pageState.singleImport != null) {
          _handler.applySingleImportDetails(_pageState.singleImport!, setState);
        }
      },
      onConfirmSingleImport: () =>
          _handler.confirmSingleImport(context, _pageState.singleImport!),
      onRemoveRow: (row) => _handler.removeRow(row, _pageState.rows, setState),
      onApplyDetails: (row) => _handler.applyDetails(row, setState),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppScreenHeader(
        title: l10n.batchGcodeImportTitle,
        actions: [homeButton(context)],
      ),
      body: SafeArea(child: body),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pageState.autoStarted) return;
    final initialFiles = widget.initialFiles;
    if (initialFiles == null || initialFiles.isEmpty) return;
    _pageState.autoStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handler.startWithFiles(
          initialFiles,
          _pageState,
          setState,
          AppLocalizations.of(context)!,
        );
      }
    });
  }
}
