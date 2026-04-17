import 'package:flutter/services.dart';

final List<TextInputFormatter> localizedDecimalInputFormatters =
    List<TextInputFormatter>.unmodifiable([
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    ]);
