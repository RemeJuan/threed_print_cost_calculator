import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_email.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_models.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_page.dart';

import '../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('renders feedback form', (tester) async {
    final mailer = _FakeMailer();
    await tester.pumpApp(
      const GCodeImportFeedbackPage(
        importedFileName: 'preview_issue.gcode',
        importedFilePath: '/tmp/preview_issue.gcode',
        importFailureContext: null,
      ),
      [
        gcodeImportFeedbackMailerProvider.overrideWithValue(mailer),
        gcodeImportFeedbackMetadataSourceProvider.overrideWithValue(
          const _FakeMetadataSource(),
        ),
      ],
    );

    expect(find.text('G-code Import Beta Feedback'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('gcode_feedback.slicer')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('gcode_feedback.preview')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('gcode_feedback.metadata')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('gcode_feedback.description')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('gcode_feedback.submit')), findsOneWidget);
  });

  testWidgets('other slicer reveals required field', (tester) async {
    await tester.pumpApp(
      const GCodeImportFeedbackPage(
        importedFileName: 'preview_issue.gcode',
        importedFilePath: '/tmp/preview_issue.gcode',
        importFailureContext: null,
        initialSlicer: GCodeImportFeedbackSlicer.other,
        initialOtherSlicer: 'Lychee Slicer',
      ),
      [
        gcodeImportFeedbackMailerProvider.overrideWithValue(_FakeMailer()),
        gcodeImportFeedbackMetadataSourceProvider.overrideWithValue(
          const _FakeMetadataSource(),
        ),
      ],
    );

    expect(find.byKey(const ValueKey<String>('gcode_feedback.other_slicer')), findsOneWidget);
  });

  testWidgets('blocks submit until valid', (tester) async {
    final mailer = _FakeMailer();
    await tester.pumpApp(
      const GCodeImportFeedbackPage(
        importedFileName: 'preview_issue.gcode',
        importedFilePath: '/tmp/preview_issue.gcode',
        importFailureContext: null,
      ),
      [
        gcodeImportFeedbackMailerProvider.overrideWithValue(mailer),
        gcodeImportFeedbackMetadataSourceProvider.overrideWithValue(
          const _FakeMetadataSource(),
        ),
      ],
    );

    await tester.ensureVisible(find.byKey(const ValueKey<String>('gcode_feedback.submit')));
    await tester.tap(find.byKey(const ValueKey<String>('gcode_feedback.submit')));
    await tester.pumpAndSettle();

    expect(mailer.drafts, isEmpty);
  });

  testWidgets('builds email body with attachment path', (tester) async {
    final draft = buildGCodeImportFeedbackEmailDraft(
      recipient: 'google@remej.dev',
      metadata: const GCodeImportFeedbackMetadata(
        appVersion: '1.2.3',
        buildNumber: '45',
        platform: 'android',
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
      ),
      submission: const GCodeImportFeedbackSubmission(
        slicer: GCodeImportFeedbackSlicer.other,
        otherSlicer: 'Kiri:Moto',
        previewResult: GCodeImportFeedbackPreviewResult.loaded,
        metadataResult: GCodeImportFeedbackMetadataResult.correct,
        description: 'Printed fine, but preview thumbnail looked wrong.',
        attachImportedFile: true,
        importedFileName: 'preview_issue.gcode',
        importedFilePath: '/tmp/preview_issue.gcode',
        importFailureContext: 'This file did not contain supported G-code metadata.',
      ),
    );
    expect(draft.subject, 'G-code Import Beta Feedback');
    expect(draft.body, contains('App version: 1.2.3+45'));
    expect(draft.body, contains('Device model: Pixel 8'));
    expect(draft.body, contains('Selected slicer: Other'));
    expect(draft.body, contains('Which slicer?: Kiri:Moto'));
    expect(draft.body, contains('Preview result: Preview loaded'));
    expect(draft.body, contains('Metadata result: Looks correct'));
    expect(draft.body, contains('Import result: Failed - This file did not contain supported G-code metadata.'));
    expect(draft.body, contains('Attached G-code file: yes'));
    expect(draft.body, contains('Attachment path: /tmp/preview_issue.gcode'));
    expect(draft.attachmentPaths, ['/tmp/preview_issue.gcode']);
  });

  testWidgets('builds email body without attachment', (tester) async {
    final draft = buildGCodeImportFeedbackEmailDraft(
      recipient: 'google@remej.dev',
      metadata: const GCodeImportFeedbackMetadata(
        appVersion: '1.2.3',
        buildNumber: '45',
        platform: 'android',
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
      ),
      submission: const GCodeImportFeedbackSubmission(
        slicer: GCodeImportFeedbackSlicer.cura,
        previewResult: GCodeImportFeedbackPreviewResult.loaded,
        metadataResult: GCodeImportFeedbackMetadataResult.correct,
        description: 'Looks good overall.',
        attachImportedFile: false,
        importedFileName: 'preview_issue.gcode',
        importedFilePath: null,
      ),
    );
    expect(draft.body, contains('Attached G-code file: no'));
    expect(draft.attachmentPaths, isEmpty);
  });
}

class _FakeMailer extends GCodeImportFeedbackMailer {
  _FakeMailer();

  final drafts = <GCodeImportFeedbackEmailDraft>[];

  @override
  Future<void> send(GCodeImportFeedbackEmailDraft draft) async {
    drafts.add(draft);
  }
}

class _FakeMetadataSource extends GCodeImportFeedbackMetadataSource {
  const _FakeMetadataSource();

  @override
  Future<GCodeImportFeedbackMetadata> load() async {
    return const GCodeImportFeedbackMetadata(
      appVersion: '1.2.3',
      buildNumber: '45',
      platform: 'android',
      osVersion: 'Android 14',
      deviceModel: 'Pixel 8',
    );
  }
}
