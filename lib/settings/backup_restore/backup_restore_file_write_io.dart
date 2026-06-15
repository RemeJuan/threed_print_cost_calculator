import 'dart:io';

Future<void> writeStringToFile(String path, String contents) async {
  final file = File(path);
  await file.writeAsString(contents);
}
