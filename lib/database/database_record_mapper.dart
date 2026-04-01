import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';

Map<String, dynamic>? castDatabaseRecord(
  Object? raw, {
  required String storeName,
  Object? key,
  AppLogger? logger,
}) {
  if (raw is! Map) {
    logger?.warn(
      AppLogCategory.migration,
      'Skipping malformed database record',
      context: {
        'store': storeName,
        'key': key,
        'expectedType': 'Map',
        'actualType': raw.runtimeType.toString(),
      },
    );
    return null;
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}
