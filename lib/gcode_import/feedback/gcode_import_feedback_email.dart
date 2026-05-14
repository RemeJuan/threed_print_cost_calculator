import 'dart:io';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/riverpod.dart';

import 'model/gcode_import_feedback_models.dart';

final gcodeImportFeedbackMailerProvider = Provider<GCodeImportFeedbackMailer>((
  ref,
) {
  return const FlutterGCodeImportFeedbackMailer();
});

final gcodeImportFeedbackMetadataSourceProvider =
    Provider<GCodeImportFeedbackMetadataSource>((ref) {
      return const PlatformGCodeImportFeedbackMetadataSource();
    });

abstract class GCodeImportFeedbackMailer {
  const GCodeImportFeedbackMailer();

  Future<void> send(GCodeImportFeedbackEmailDraft draft);
}

class FlutterGCodeImportFeedbackMailer extends GCodeImportFeedbackMailer {
  const FlutterGCodeImportFeedbackMailer();

  @override
  Future<void> send(GCodeImportFeedbackEmailDraft draft) async {
    final email = Email(
      recipients: draft.recipients,
      subject: draft.subject,
      body: draft.body,
      attachmentPaths: draft.attachmentPaths,
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }
}

abstract class GCodeImportFeedbackMetadataSource {
  const GCodeImportFeedbackMetadataSource();

  Future<GCodeImportFeedbackMetadata> load();
}

class PlatformGCodeImportFeedbackMetadataSource
    extends GCodeImportFeedbackMetadataSource {
  const PlatformGCodeImportFeedbackMetadataSource();

  @override
  Future<GCodeImportFeedbackMetadata> load() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return GCodeImportFeedbackMetadata(
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
    );
  }
}

GCodeImportFeedbackEmailDraft buildGCodeImportFeedbackEmailDraft({
  required String recipient,
  required GCodeImportFeedbackMetadata metadata,
  required GCodeImportFeedbackSubmission submission,
}) {
  final attachmentPaths =
      submission.attachImportedFile && submission.importedFilePath != null
      ? [submission.importedFilePath!]
      : const <String>[];

  final lines = <String>[
    'G-code Import Beta Feedback',
    '',
    'App version: ${metadata.appVersion}+${metadata.buildNumber}',
    'Platform: ${metadata.platform}',
    'OS version: ${metadata.osVersion}',
    if (metadata.deviceModel != null && metadata.deviceModel!.isNotEmpty)
      'Device model: ${metadata.deviceModel}',
    if (submission.importedFileName != null)
      'Imported file: ${submission.importedFileName}',
    'Attached G-code file: ${attachmentPaths.isNotEmpty ? 'yes' : 'no'}',
    if (attachmentPaths.isNotEmpty) 'Attachment path: ${attachmentPaths.first}',
    if (submission.importFailureContext != null)
      'Import result: Failed - ${submission.importFailureContext}'
    else
      'Import result: Success',
    '',
    'Selected slicer: ${submission.slicer.bodyLabel()}',
    if (submission.slicer == GCodeImportFeedbackSlicer.other &&
        submission.otherSlicer != null &&
        submission.otherSlicer!.trim().isNotEmpty)
      'Which slicer?: ${submission.otherSlicer!.trim()}',
    'Preview result: ${submission.previewResult.bodyLabel()}',
    'Metadata result: ${submission.metadataResult.bodyLabel()}',
    '',
    'Feedback:',
    submission.description,
  ];

  return GCodeImportFeedbackEmailDraft(
    recipients: [recipient],
    subject: 'G-code Import Beta Feedback',
    body: lines.join('\n'),
    attachmentPaths: attachmentPaths,
  );
}
