import 'dart:io';

import 'package:localizely_sdk/src/common/gen_l10n/generator.dart';

Future<void> main(List<String> args) async {
  try {
    await generate();
  } catch (e) {
    stderr.writeln('ERROR: Failed to generate localization files.\n$e');
    exit(2);
  }
}
