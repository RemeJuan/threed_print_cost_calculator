import 'package:flutter/foundation.dart';

Map<String, dynamic>? castDatabaseRecord(
  Object? raw, {
  required String storeName,
  Object? key,
}) {
  if (raw is! Map) {
    if (kDebugMode) {
      debugPrint(
        'Skipping malformed $storeName record for key=$key: expected Map, got ${raw.runtimeType}',
      );
    }
    return null;
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}
