import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

enum GCodeImportFeedbackSlicer {
  cura,
  prusaSlicer,
  orcaSlicer,
  bambuStudio,
  crealityPrint,
  simplify3D,
  superSlicer,
  ideaMaker,
  other,
}

extension GCodeImportFeedbackSlicerX on GCodeImportFeedbackSlicer {
  String label(AppLocalizations l10n) => switch (this) {
    GCodeImportFeedbackSlicer.cura => l10n.slicerCura,
    GCodeImportFeedbackSlicer.prusaSlicer => l10n.slicerPrusaSlicer,
    GCodeImportFeedbackSlicer.orcaSlicer => l10n.slicerOrcaSlicer,
    GCodeImportFeedbackSlicer.bambuStudio => l10n.slicerBambuStudio,
    GCodeImportFeedbackSlicer.crealityPrint => l10n.slicerCrealityPrint,
    GCodeImportFeedbackSlicer.simplify3D => l10n.slicerSimplify3D,
    GCodeImportFeedbackSlicer.superSlicer => l10n.slicerSuperSlicer,
    GCodeImportFeedbackSlicer.ideaMaker => l10n.slicerIdeaMaker,
    GCodeImportFeedbackSlicer.other => l10n.slicerOther,
  };

  String bodyLabel() => switch (this) {
    GCodeImportFeedbackSlicer.cura => 'Cura',
    GCodeImportFeedbackSlicer.prusaSlicer => 'PrusaSlicer',
    GCodeImportFeedbackSlicer.orcaSlicer => 'OrcaSlicer',
    GCodeImportFeedbackSlicer.bambuStudio => 'Bambu Studio',
    GCodeImportFeedbackSlicer.crealityPrint => 'Creality Print',
    GCodeImportFeedbackSlicer.simplify3D => 'Simplify3D',
    GCodeImportFeedbackSlicer.superSlicer => 'SuperSlicer',
    GCodeImportFeedbackSlicer.ideaMaker => 'IdeaMaker',
    GCodeImportFeedbackSlicer.other => 'Other',
  };
}

enum GCodeImportFeedbackPreviewResult {
  loaded,
  missing,
  incorrect,
  notSure,
}

extension GCodeImportFeedbackPreviewResultX on GCodeImportFeedbackPreviewResult {
  String label(AppLocalizations l10n) => switch (this) {
    GCodeImportFeedbackPreviewResult.loaded => l10n.gcodeFeedbackPreviewLoaded,
    GCodeImportFeedbackPreviewResult.missing => l10n.gcodeFeedbackPreviewMissing,
    GCodeImportFeedbackPreviewResult.incorrect =>
      l10n.gcodeFeedbackPreviewIncorrect,
    GCodeImportFeedbackPreviewResult.notSure => l10n.gcodeFeedbackPreviewNotSure,
  };

  String bodyLabel() => switch (this) {
    GCodeImportFeedbackPreviewResult.loaded => 'Preview loaded',
    GCodeImportFeedbackPreviewResult.missing => 'Preview missing',
    GCodeImportFeedbackPreviewResult.incorrect => 'Preview incorrect',
    GCodeImportFeedbackPreviewResult.notSure => 'Not sure',
  };
}

enum GCodeImportFeedbackMetadataResult {
  correct,
  missing,
  incorrect,
  notSure,
}

extension GCodeImportFeedbackMetadataResultX on GCodeImportFeedbackMetadataResult {
  String label(AppLocalizations l10n) => switch (this) {
    GCodeImportFeedbackMetadataResult.correct =>
      l10n.gcodeFeedbackMetadataCorrect,
    GCodeImportFeedbackMetadataResult.missing =>
      l10n.gcodeFeedbackMetadataMissing,
    GCodeImportFeedbackMetadataResult.incorrect =>
      l10n.gcodeFeedbackMetadataIncorrect,
    GCodeImportFeedbackMetadataResult.notSure =>
      l10n.gcodeFeedbackMetadataNotSure,
  };

  String bodyLabel() => switch (this) {
    GCodeImportFeedbackMetadataResult.correct => 'Looks correct',
    GCodeImportFeedbackMetadataResult.missing => 'Missing data',
    GCodeImportFeedbackMetadataResult.incorrect => 'Incorrect data',
    GCodeImportFeedbackMetadataResult.notSure => 'Not sure',
  };
}

class GCodeImportFeedbackSubmission {
  const GCodeImportFeedbackSubmission({
    required this.slicer,
    required this.previewResult,
    required this.metadataResult,
    required this.description,
    required this.attachImportedFile,
    this.otherSlicer,
    this.importedFileName,
    this.importedFilePath,
    this.importFailureContext,
  });

  final GCodeImportFeedbackSlicer slicer;
  final String? otherSlicer;
  final GCodeImportFeedbackPreviewResult previewResult;
  final GCodeImportFeedbackMetadataResult metadataResult;
  final String description;
  final bool attachImportedFile;
  final String? importedFileName;
  final String? importedFilePath;
  final String? importFailureContext;
}

class GCodeImportFeedbackMetadata {
  const GCodeImportFeedbackMetadata({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    this.deviceModel,
  });

  final String appVersion;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final String? deviceModel;
}
