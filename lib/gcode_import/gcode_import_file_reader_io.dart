import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<String> readGCodeTextFromPath(String path) async {
  final bytes = await File(path).readAsBytes();
  return utf8.decode(bytes, allowMalformed: true);
}

Future<Uint8List> readGCodeSampleFromPath(String path, int maxBytes) async {
  final bytes = BytesBuilder(copy: false);

  await for (final chunk in File(path).openRead()) {
    final remaining = maxBytes - bytes.length;
    if (remaining <= 0) break;

    if (chunk.length <= remaining) {
      bytes.add(chunk);
    } else {
      bytes.add(chunk.sublist(0, remaining));
    }

    if (bytes.length >= maxBytes) break;
  }

  return bytes.takeBytes();
}

Future<int?> readGCodeLengthFromPath(String path) async {
  try {
    return await File(path).length();
  } on FileSystemException {
    return null;
  }
}

Stream<String> openGCodeLinesFromPath(String path) {
  return File(path)
      .openRead()
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter());
}
