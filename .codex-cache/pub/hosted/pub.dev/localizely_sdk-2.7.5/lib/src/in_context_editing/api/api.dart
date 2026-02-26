import 'dart:convert' as convert;

import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/translation_change_typed.dart';

WebSocketChannel? _channel;

void openWebSocket({
  required String token,
  required String sdkVersion,
  required void Function(TranslationChangeTyped translationChangeTyped) onData,
  required void Function(Object error) onError,
  required void Function(int? closeCode) onDone,
}) {
  assert(_channel == null, 'WebSocket is already opened.');

  final uri = Uri.parse(
    'wss://inctx.localizely.com/inctx/v1/in-context/flutter?token=$token&sdkVersion=$sdkVersion',
  );

  _channel = WebSocketChannel.connect(uri);

  _channel?.stream.listen(
    (data) {
      final Map<String, dynamic> json = convert.jsonDecode(data);
      final String type = json['type'];

      switch (type) {
        case 'ping':
          _channel?.sink.add(convert.jsonEncode({'type': 'pong'}));
          break;
        case 'translation_change_typed':
          final TranslationChangeTyped translationChangeTyped =
              TranslationChangeTyped.fromJson(json);
          onData(translationChangeTyped);
          break;
        default:
          break;
      }
    },
    onError: (error) {
      onError(error);
    },
    onDone: () {
      onDone(_channel?.closeCode);
    },
  );
}

void closeWebSocket() {
  _channel?.sink.close();
  _channel = null;
}

void sendWebSocketMessage(String message) {
  _channel?.sink.add(message);
}
