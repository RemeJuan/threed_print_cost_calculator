import 'dart:io';

Future<String> readGCodeTextFromPath(String path) {
  return File(path).readAsString();
}
