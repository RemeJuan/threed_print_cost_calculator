import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

import 'model/gcode_import_file.dart';
import 'model/gcode_import_result_models.dart';

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
    if (fileName?.isNotEmpty ?? false) 'file_name': '[redacted]',
    if (originalFileName?.isNotEmpty ?? false) 'original_file_name': '[redacted]',
    if (mimeType?.isNotEmpty ?? false) 'mime_type': mimeType,
    ...?fileSizeBytes != null ? {'file_size_bytes': fileSizeBytes} : null,
    if (reason?.isNotEmpty ?? false) 'reason': _sanitizeMessage(reason!),
  };

  AppAnalytics.safeLog(
    () => AppAnalytics.log('gcode_import_breadcrumb', params: params),
  );

  Sentry.addBreadcrumb(
    Breadcrumb(message: 'gcode_import:$stage', data: params),
  );
}

Future<void> captureGCodeImportFailure({
  required String stage,
  required Object error,
  StackTrace? stackTrace,
  GCodePickedFile? file,
  GCodeSlicer? slicer,
  int? lineCount,
  String? parserVersion,
  String? category,
}) async {
  final packageInfo = await _safePackageInfo();
  final extension = _extensionFor(file);
  final sizeBucket = _sizeBucket(file?.size);
  final normalizedStage = _normalizeStage(stage);
  await Sentry.captureException(
    error,
    stackTrace: stackTrace,
    withScope: (scope) {
      scope.setTag('failure_stage', normalizedStage);
      scope.setTag('exception_type', error.runtimeType.toString());
      scope.setTag('app_version', packageInfo.version);
      scope.setTag('app_build', packageInfo.buildNumber);
      scope.setTag('platform', Platform.operatingSystem);
      scope.setTag('file_extension', extension);
      scope.setTag('file_size_bucket', sizeBucket);
      if (lineCount != null) {
        scope.setTag('line_count_bucket', _lineBucket(lineCount));
      }
      if (parserVersion != null) scope.setTag('parser_version', parserVersion);
      if (category != null) scope.setTag('error_category', category);
      if (slicer != null) scope.setTag('slicer', slicer.name);
      scope.setContexts('gcode_import', <String, Object?>{
        if (file != null) 'has_path': file.path != null,
        if (file?.mimeType != null) 'mime_type': file!.mimeType!,
        if (file?.size != null) 'file_size_bytes': file!.size!,
        'sanitized_message': _sanitizeMessage(error.toString()),
        'stage': normalizedStage,
        'exception_type': error.runtimeType.toString(),
      });
    },
  );
}

Future<PackageInfo> _safePackageInfo() async {
  try {
    return await PackageInfo.fromPlatform();
  } catch (_) {
    return PackageInfo(appName: 'unknown', packageName: 'unknown', version: 'unknown', buildNumber: 'unknown');
  }
}

String _extensionFor(GCodePickedFile? file) {
  if (file == null) return 'unknown';
  for (final name in file.candidateNames) {
    final dot = name.lastIndexOf('.');
    if (dot >= 0 && dot < name.length - 1) {
      return name.substring(dot + 1).toLowerCase();
    }
  }
  return 'unknown';
}

String _sizeBucket(int? size) {
  if (size == null) return 'unknown';
  if (size < 100 * 1024) return '<100kb';
  if (size < 1024 * 1024) return '<1mb';
  if (size < 10 * 1024 * 1024) return '<10mb';
  return '>=10mb';
}

String _lineBucket(int count) {
  if (count < 100) return '<100';
  if (count < 1000) return '<1k';
  if (count < 10000) return '<10k';
  return '>=10k';
}

String _sanitizeMessage(String value) {
  return value
      .replaceAll(RegExp(r'([A-Za-z]:)?[\\/][^\s]+'), '[path]')
      .replaceAll(
        RegExp(r'[^\s]+\.(gcode|gco|nc|bin)', caseSensitive: false),
        '[file]',
      );
}

String _normalizeStage(String stage) => stage.replaceAll('_', ' ');
