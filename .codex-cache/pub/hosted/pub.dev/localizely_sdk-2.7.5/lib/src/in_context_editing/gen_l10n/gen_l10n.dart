import 'dart:convert' as convert;

import '../api/api.dart';
import '../../sdk_data.dart';

bool _isDetected = false;

void _detectCodeGen() {
  if (!_isDetected) {
    sendWebSocketMessage(
      convert.jsonEncode({'type': 'code_gen_detected', 'codeGen': 'gen_l10n'}),
    );
    _isDetected = true;
  }
}

String? getText(String locale, String stringKey) {
  if (!SdkData.hasInContextEditingData) {
    return null;
  }

  _detectCodeGen();

  var translationChangeTyped = SdkData.inContextEditingData!.getEditedData(
    locale,
    stringKey,
  );

  return translationChangeTyped?.value;
}
