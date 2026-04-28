import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_email.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_models.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class GCodeImportFeedbackPage extends ConsumerStatefulWidget {
  const GCodeImportFeedbackPage({
    required this.importedFileName,
    required this.importedFilePath,
    required this.importFailureContext,
    this.initialSlicer,
    this.initialOtherSlicer,
    this.initialPreviewResult,
    this.initialMetadataResult,
    this.initialDescription,
    this.initialAttachImportedFile = false,
    super.key,
  });

  final String? importedFileName;
  final String? importedFilePath;
  final String? importFailureContext;
  final GCodeImportFeedbackSlicer? initialSlicer;
  final String? initialOtherSlicer;
  final GCodeImportFeedbackPreviewResult? initialPreviewResult;
  final GCodeImportFeedbackMetadataResult? initialMetadataResult;
  final String? initialDescription;
  final bool initialAttachImportedFile;

  @override
  ConsumerState<GCodeImportFeedbackPage> createState() =>
      _GCodeImportFeedbackPageState();
}

class _GCodeImportFeedbackPageState
    extends ConsumerState<GCodeImportFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _otherSlicerController = TextEditingController();

  GCodeImportFeedbackSlicer? _slicer;
  GCodeImportFeedbackPreviewResult? _previewResult;
  GCodeImportFeedbackMetadataResult? _metadataResult;
  bool _attachImportedFile = false;
  bool _sending = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _otherSlicerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _slicer = widget.initialSlicer;
    _previewResult = widget.initialPreviewResult;
    _metadataResult = widget.initialMetadataResult;
    _attachImportedFile = widget.initialAttachImportedFile;
    _descriptionController.text = widget.initialDescription ?? '';
    _otherSlicerController.text = widget.initialOtherSlicer ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gcodeImportFeedbackTitle)),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.gcodeImportFeedbackBetaFeature,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (widget.importFailureContext != null) ...[
                const SizedBox(height: 12),
                Text(
                  widget.importFailureContext!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              if (widget.importedFileName != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${l10n.importGcodeSelectedFileLabel}: ${widget.importedFileName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              DropdownButtonFormField<GCodeImportFeedbackSlicer>(
                key: const ValueKey<String>('gcode_feedback.slicer'),
                initialValue: _slicer,
                decoration: InputDecoration(labelText: l10n.gcodeImportFeedbackSlicerLabel),
                items: GCodeImportFeedbackSlicer.values
                    .map(
                      (slicer) => DropdownMenuItem(
                        value: slicer,
                        child: Text(slicer.label(l10n)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _slicer = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return l10n.validationRequired;
                  }
                  return null;
                },
              ),
              if (_slicer == GCodeImportFeedbackSlicer.other) ...[
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey<String>('gcode_feedback.other_slicer'),
                  controller: _otherSlicerController,
                  decoration: InputDecoration(
                    labelText: l10n.gcodeImportFeedbackOtherSlicerLabel,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (_slicer != GCodeImportFeedbackSlicer.other) {
                      return null;
                    }
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired;
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<GCodeImportFeedbackPreviewResult>(
                key: const ValueKey<String>('gcode_feedback.preview'),
                initialValue: _previewResult,
                decoration: InputDecoration(
                  labelText: l10n.gcodeImportFeedbackPreviewLabel,
                ),
                items: GCodeImportFeedbackPreviewResult.values
                    .map(
                      (result) => DropdownMenuItem(
                        value: result,
                        child: Text(result.label(l10n)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _previewResult = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return l10n.validationRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GCodeImportFeedbackMetadataResult>(
                key: const ValueKey<String>('gcode_feedback.metadata'),
                initialValue: _metadataResult,
                decoration: InputDecoration(
                  labelText: l10n.gcodeImportFeedbackMetadataLabel,
                ),
                items: GCodeImportFeedbackMetadataResult.values
                    .map(
                      (result) => DropdownMenuItem(
                        value: result,
                        child: Text(result.label(l10n)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  setState(() {
                    _metadataResult = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return l10n.validationRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey<String>('gcode_feedback.description'),
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.gcodeImportFeedbackDescriptionLabel,
                ),
                minLines: 4,
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationRequired;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              if (widget.importedFilePath != null)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _attachImportedFile,
                  onChanged: (value) {
                    setState(() {
                      _attachImportedFile = value ?? false;
                    });
                  },
                  title: Text(l10n.gcodeImportFeedbackAttachmentLabel),
                )
              else
                Text(
                  l10n.gcodeImportFeedbackNoAttachmentAvailable,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey<String>('gcode_feedback.submit'),
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.gcodeImportFeedbackSendCta),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_slicer == null || _previewResult == null || _metadataResult == null) {
      _formKey.currentState?.validate();
      return;
    }

    if (_descriptionController.text.trim().isEmpty ||
        (_slicer == GCodeImportFeedbackSlicer.other &&
            _otherSlicerController.text.trim().isEmpty)) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final metadata = await ref
          .read(gcodeImportFeedbackMetadataSourceProvider)
          .load();
      final draft = buildGCodeImportFeedbackEmailDraft(
        recipient: l10n.supportEmail,
        metadata: metadata,
        submission: GCodeImportFeedbackSubmission(
          slicer: _slicer!,
          otherSlicer: _slicer == GCodeImportFeedbackSlicer.other
              ? _otherSlicerController.text.trim()
              : null,
          previewResult: _previewResult!,
          metadataResult: _metadataResult!,
          description: _descriptionController.text.trim(),
          attachImportedFile: _attachImportedFile,
          importedFileName: widget.importedFileName,
          importedFilePath: widget.importedFilePath,
          importFailureContext: widget.importFailureContext,
        ),
      );

      await ref.read(gcodeImportFeedbackMailerProvider).send(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gcodeImportFeedbackSentMessage)),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mailClientError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }
}
