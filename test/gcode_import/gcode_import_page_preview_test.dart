import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_preview_section.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';
import 'gcode_import_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupTest();
  });

  testWidgets('renders low-res preview', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 32,
              height: 32,
            ),
            previewImageBytes: validPngBytes(),
            hasSafePreview: true,
          ),
        ),
      ),
    ]);

    expect(find.text('Preview · 32×32'), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).filterQuality,
      FilterQuality.none,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('logs preview available once for safe preview', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return GCodeImportPreviewSection(
            slicer: GCodeSlicer.prusaSlicer,
            hasPreviewMetadata: true,
            previewWidth: 32,
            previewHeight: 32,
            previewImageBytes: validPngBytes(),
            hasSafePreview: true,
            l10n: l10n,
            fileSizeBytes: 2 * 1024 * 1024,
            parseStatus: 'success',
            previewDecoder: (_) async => true,
          );
        },
      ),
      [isPremiumProvider.overrideWithValue(true)],
    );

    await tester.pumpAndSettle();

    expect(analytics.eventNames, contains('gcode_preview_available'));
    expect(
      analytics.events
          .singleWhere((event) => event.name == 'gcode_preview_available')
          .params,
      containsPair('parse_status', 'success'),
    );
  });

  testWidgets('logs preview available for high-res safe preview', (
    tester,
  ) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return GCodeImportPreviewSection(
            slicer: GCodeSlicer.prusaSlicer,
            hasPreviewMetadata: true,
            previewWidth: 256,
            previewHeight: 256,
            previewImageBytes: validPngBytes(),
            hasSafePreview: true,
            l10n: l10n,
            fileSizeBytes: 2 * 1024 * 1024,
            parseStatus: 'success',
            previewDecoder: (_) async => true,
          );
        },
      ),
      [isPremiumProvider.overrideWithValue(true)],
    );

    await tester.pumpAndSettle();

    expect(analytics.eventNames, contains('gcode_preview_available'));
  });

  testWidgets('does not relog when safe preview toggles without new bytes', (
    tester,
  ) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    final bytes = validPngBytes();
    var safe = false;

    await tester.pumpApp(
      StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            children: [
              GCodeImportPreviewSection(
                slicer: GCodeSlicer.prusaSlicer,
                hasPreviewMetadata: true,
                previewWidth: 32,
                previewHeight: 32,
                previewImageBytes: bytes,
                hasSafePreview: safe,
                l10n: l10n,
                fileSizeBytes: 2 * 1024 * 1024,
                parseStatus: 'success',
                previewDecoder: (_) async => true,
              ),
              TextButton(
                onPressed: () => setState(() => safe = !safe),
                child: const Text('toggle'),
              ),
            ],
          );
        },
      ),
      [isPremiumProvider.overrideWithValue(true)],
    );

    await tester.pumpAndSettle();
    expect(analytics.eventNames, isEmpty);

    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    expect(analytics.eventNames, contains('gcode_preview_available'));

    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      hasLength(1),
    );

    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      hasLength(1),
    );
  });

  testWidgets('logs again for replacement preview bytes', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    final first = validPngBytes();
    final second = Uint8List.fromList(first);
    var useFirst = true;

    await tester.pumpApp(
      StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            children: [
              GCodeImportPreviewSection(
                slicer: GCodeSlicer.prusaSlicer,
                hasPreviewMetadata: true,
                previewWidth: 32,
                previewHeight: 32,
                previewImageBytes: useFirst ? first : second,
                hasSafePreview: true,
                l10n: l10n,
                fileSizeBytes: 2 * 1024 * 1024,
                parseStatus: 'success',
                previewDecoder: (_) async => true,
              ),
              TextButton(
                onPressed: () => setState(() => useFirst = !useFirst),
                child: const Text('swap'),
              ),
            ],
          );
        },
      ),
      [isPremiumProvider.overrideWithValue(true)],
    );

    await tester.pumpAndSettle();
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      hasLength(1),
    );

    await tester.tap(find.text('swap'));
    await tester.pumpAndSettle();
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      hasLength(2),
    );
  });

  testWidgets('shows preview decode fallback', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: const GCodePreviewMetadata(
              present: true,
              format: 'PNG',
              width: 256,
              height: 256,
            ),
            previewImageBytes: Uint8List.fromList([0, 1, 2, 3]),
            hasSafePreview: true,
          ),
        ),
      ),
    ]);

    await tester.tap(find.widgetWithText(TextButton, 'View'));
    await tester.pumpAndSettle();

    expect(
      find.text('Preview metadata found, but image could not be displayed.'),
      findsOneWidget,
    );
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      isEmpty,
    );
  });

  testWidgets('throws decoder is treated as invalid', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    await tester.pumpApp(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return GCodeImportPreviewSection(
            slicer: GCodeSlicer.prusaSlicer,
            hasPreviewMetadata: true,
            previewWidth: 32,
            previewHeight: 32,
            previewImageBytes: validPngBytes(),
            hasSafePreview: true,
            l10n: l10n,
            fileSizeBytes: 2 * 1024 * 1024,
            parseStatus: 'success',
            previewDecoder: (_) => Future<bool>.error(StateError('bad')),
          );
        },
      ),
      [isPremiumProvider.overrideWithValue(true)],
    );

    await tester.pumpAndSettle();
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      isEmpty,
    );
  });

  testWidgets('stale completion waits for current bytes', (tester) async {
    final analytics = RecordingAnalytics();
    final originalService = AppAnalytics.service;
    AppAnalytics.service = analytics;
    addTearDown(() => AppAnalytics.service = originalService);

    final first = validPngBytes();
    final second = Uint8List.fromList(first);
    final firstCompleter = Completer<bool>();
    final secondCompleter = Completer<bool>();
    var useFirst = true;

    await tester.pumpApp(
      StatefulBuilder(
        builder: (context, setState) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            children: [
              GCodeImportPreviewSection(
                slicer: GCodeSlicer.prusaSlicer,
                hasPreviewMetadata: true,
                previewWidth: 32,
                previewHeight: 32,
                previewImageBytes: useFirst ? first : second,
                hasSafePreview: true,
                l10n: l10n,
                fileSizeBytes: 2 * 1024 * 1024,
                parseStatus: 'success',
                previewDecoder: (bytes) => identical(bytes, first)
                    ? firstCompleter.future
                    : secondCompleter.future,
              ),
              TextButton(
                onPressed: () => setState(() => useFirst = false),
                child: const Text('swap'),
              ),
            ],
          );
        },
      ),
      [isPremiumProvider.overrideWithValue(true)],
    );

    await tester.pump();
    await tester.tap(find.text('swap'));
    await tester.pump();

    firstCompleter.complete(true);
    await tester.pump();
    expect(analytics.eventNames, isEmpty);

    secondCompleter.complete(true);
    await tester.pumpAndSettle();
    expect(
      analytics.events.where(
        (event) => event.name == 'gcode_preview_available',
      ),
      hasLength(1),
    );
  });

  testWidgets('production decoder accepts valid png and rejects garbage', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final valid = await _makePngBytes();
      expect(await decodePreviewImage(valid), isTrue);
      expect(
        await decodePreviewImage(Uint8List.fromList([0, 1, 2, 3])),
        isFalse,
      );
    });
  });

  testWidgets('shows Cura preview note when preview missing', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.cura,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(
      find.text(
        'Cura previews may require a post-processing script to embed thumbnails in the G-code.',
      ),
      findsOneWidget,
    );
    expect(find.text('No preview'), findsOneWidget);
    expect(find.textContaining('Cura previews may require'), findsOneWidget);
  });

  testWidgets('keeps no-preview summary unchanged', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
      gcodeImportControllerProvider.overrideWith(
        () => FakeController(
          successState(
            slicer: GCodeSlicer.prusaSlicer,
            previewMetadata: null,
            previewImageBytes: null,
          ),
        ),
      ),
    ]);

    expect(find.text('No preview'), findsOneWidget);
    expect(find.textContaining('Cura previews may require'), findsNothing);
    expect(find.text('Send feedback'), findsOneWidget);
  });
}

Future<Uint8List> _makePngBytes() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = const Color(0xFF00FF00);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 8, 8), paint);
  final picture = recorder.endRecording();
  final image = await picture.toImage(8, 8);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}
