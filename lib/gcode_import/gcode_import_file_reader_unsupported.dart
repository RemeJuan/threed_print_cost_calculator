import 'dart:async';
import 'dart:typed_data';

Future<String> readGCodeTextFromPath(String path) {
  throw UnsupportedError(
    'Path-based file reads are unsupported on this platform.',
  );
}

Future<Uint8List> readGCodeSampleFromPath(String path, int maxBytes) {
  throw UnsupportedError(
    'Path-based file reads are unsupported on this platform.',
  );
}

Future<int?> readGCodeLengthFromPath(String path) {
  throw UnsupportedError(
    'Path-based file reads are unsupported on this platform.',
  );
}

Stream<String> openGCodeLinesFromPath(String path) {
  throw UnsupportedError(
    'Path-based file reads are unsupported on this platform.',
  );
}
