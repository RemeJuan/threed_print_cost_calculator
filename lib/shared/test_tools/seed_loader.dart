import 'dart:convert';

import 'package:flutter/services.dart';

class SeedDataBundle {
  const SeedDataBundle({
    required this.generalSettings,
    required this.sharedPreferences,
    required this.printers,
    required this.materials,
    required this.history,
  });

  final Map<String, dynamic> generalSettings;
  final Map<String, dynamic> sharedPreferences;
  final List<Map<String, dynamic>> printers;
  final List<Map<String, dynamic>> materials;
  final List<Map<String, dynamic>> history;
}

class SeedLoader {
  SeedLoader({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<SeedDataBundle> load() async {
    final settings = _decodeMap(await _load('assets/test_data/settings.json'));
    return SeedDataBundle(
      generalSettings: _requiredMap(
        settings['generalSettings'],
        'settings.json',
      ),
      sharedPreferences: _optionalMap(
        settings['sharedPreferences'],
        'settings.json',
      ),
      printers: _requiredList(
        _decodeMap(await _load('assets/test_data/printers.json'))['printers'],
        'printers.json',
      ),
      materials: _requiredList(
        _decodeMap(await _load('assets/test_data/materials.json'))['materials'],
        'materials.json',
      ),
      history: _requiredList(
        _decodeMap(await _load('assets/test_data/history.json'))['history'],
        'history.json',
      ),
    );
  }

  Future<String> _load(String path) => _bundle.loadString(path);

  Map<String, dynamic> _decodeMap(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected JSON object');
    }
    return decoded;
  }

  Map<String, dynamic> _requiredMap(Object? value, String fileName) {
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Expected object in $fileName');
  }

  Map<String, dynamic> _optionalMap(Object? value, String fileName) {
    if (value == null) return const <String, dynamic>{};
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Expected object in $fileName');
  }

  List<Map<String, dynamic>> _requiredList(Object? value, String fileName) {
    if (value is! List) {
      throw FormatException('Expected array in $fileName');
    }

    return value.map((entry) {
      if (entry is! Map) {
        throw FormatException('Expected object entries in $fileName');
      }
      return entry.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }
}
