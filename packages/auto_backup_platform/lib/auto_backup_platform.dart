import 'package:flutter/services.dart';

class AutoBackupPlatform {
  static const MethodChannel _channel = MethodChannel('auto_backup_platform');

  Future<Map<String, dynamic>?> pickDestination() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pickDestination',
    );
    return result;
  }

  Future<Map<String, dynamic>> verifyDestination({
    required String accessToken,
    required String displayLabel,
    required String fileName,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'verifyDestination',
      {
        'accessToken': accessToken,
        'displayLabel': displayLabel,
        'fileName': fileName,
      },
    );
    return Map<String, dynamic>.from(result ?? const {});
  }

  Future<Map<String, dynamic>> writeBackup({
    required String accessToken,
    required String displayLabel,
    required String fileName,
    required String contents,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'writeBackup',
      {
        'accessToken': accessToken,
        'displayLabel': displayLabel,
        'fileName': fileName,
        'contents': contents,
      },
    );
    return Map<String, dynamic>.from(result ?? const {});
  }
}
