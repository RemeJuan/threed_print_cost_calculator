import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

void logGCodeImportBreadcrumb(
  String stage, {
  String? fileName,
  String? originalFileName,
  String? mimeType,
  int? fileSizeBytes,
  String? reason,
}) {
  final params = <String, Object?>{
    'stage': stage,
    ...?(fileName?.isNotEmpty ?? false ? {'file_name': fileName} : null),
    ...?(originalFileName?.isNotEmpty ?? false
        ? {'original_file_name': originalFileName}
        : null),
    ...?(mimeType?.isNotEmpty ?? false ? {'mime_type': mimeType} : null),
    ...?(fileSizeBytes != null ? {'file_size_bytes': fileSizeBytes} : null),
    ...?(reason?.isNotEmpty ?? false ? {'reason': reason} : null),
  };

  AppAnalytics.safeLog(
    () => AppAnalytics.log('gcode_import_breadcrumb', params: params),
  );

  try {
    FirebaseCrashlytics.instance.log(
      [
        'gcode_import',
        'stage=$stage',
        if (fileName != null && fileName.isNotEmpty) 'file=$fileName',
        if (originalFileName != null && originalFileName.isNotEmpty)
          'original=$originalFileName',
        if (mimeType != null && mimeType.isNotEmpty) 'mime=$mimeType',
        if (fileSizeBytes != null) 'size=$fileSizeBytes',
        if (reason != null && reason.isNotEmpty) 'reason=$reason',
      ].join(' '),
    );
  } catch (_) {
    // Best-effort breadcrumb only.
  }
}
