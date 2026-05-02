import 'package:flutter/material.dart';

const _namedColors = <String, String>{
  'red': '#FF0000',
  'dark red': '#8B0000',
  'crimson': '#DC143C',
  'firebrick': '#B22222',
  'pink': '#FFC0CB',
  'hot pink': '#FF69B4',
  'deep pink': '#FF1493',
  'rose': '#FF007F',
  'coral': '#FF7F50',
  'salmon': '#FA8072',
  'tomato': '#FF6347',
  'orange': '#FFA500',
  'dark orange': '#FF8C00',
  'gold': '#FFD700',
  'yellow': '#FFFF00',
  'light yellow': '#FFFFE0',
  'lemon': '#FFF700',
  'lime': '#00FF00',
  'green': '#008000',
  'dark green': '#006400',
  'forest green': '#228B22',
  'lime green': '#32CD32',
  'olive': '#808000',
  'teal': '#008080',
  'cyan': '#00FFFF',
  'aqua': '#00FFFF',
  'turquoise': '#40E0D0',
  'blue': '#0000FF',
  'dark blue': '#00008B',
  'navy': '#000080',
  'royal blue': '#4169E1',
  'sky blue': '#87CEEB',
  'light blue': '#ADD8E6',
  'steel blue': '#4682B4',
  'purple': '#800080',
  'violet': '#EE82EE',
  'lavender': '#E6E6FA',
  'magenta': '#FF00FF',
  'indigo': '#4B0082',
  'brown': '#A52A2A',
  'saddle brown': '#8B4513',
  'sienna': '#A0522D',
  'chocolate': '#D2691E',
  'tan': '#D2B48C',
  'beige': '#F5F5DC',
  'white': '#FFFFFF',
  'off white': '#FAF9F6',
  'ivory': '#FFFFF0',
  'cream': '#FFFDD0',
  'gray': '#808080',
  'grey': '#808080',
  'dark gray': '#404040',
  'dark grey': '#404040',
  'light gray': '#D3D3D3',
  'light grey': '#D3D3D3',
  'silver': '#C0C0C0',
  'charcoal': '#36454F',
  'black': '#000000',
  'transparent': '#00000000',
};

Color colorFromMaterial(MaterialColorInput input) {
  if (input.colorHex.isNotEmpty) {
    final hex = input.colorHex.replaceFirst('#', '');
    if (hex.length == 6 || hex.length == 8) {
      final prefix = hex.length == 6 ? 'FF' : '';
      final parsed = int.tryParse('$prefix$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    }
  }

  if (input.colorName.isNotEmpty) {
    final lower = input.colorName.toLowerCase().trim();
    final exact = _namedColors[lower];
    if (exact != null) {
      final hex = exact.replaceFirst('#', '');
      final prefix = hex.length == 6 ? 'FF' : '';
      final parsed = int.tryParse('$prefix$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    }

    for (final entry in _namedColors.entries) {
      if (lower.contains(entry.key)) {
        final hex = entry.value.replaceFirst('#', '');
        final prefix2 = hex.length == 6 ? 'FF' : '';
        final parsed = int.tryParse('$prefix2$hex', radix: 16);
        if (parsed != null) return Color(parsed);
      }
    }
  }

  final hash = _hashCode(input.colorName);
  final hue = (hash & 0xFFFF) / 65536.0 * 360.0;
  final saturation = 0.5 + ((hash >> 16) & 0xFF) / 512.0;
  final lightness = 0.4 + ((hash >> 24) & 0xFF) / 640.0;
  return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
}

int _hashCode(String s) {
  var hash = 0;
  for (var i = 0; i < s.length; i++) {
    hash = (hash * 31 + s.codeUnitAt(i)) & 0x7FFFFFFF;
  }
  return hash == 0 ? 42 : hash;
}

class MaterialColorInput {
  final String colorName;
  final String colorHex;

  const MaterialColorInput({this.colorName = '', this.colorHex = ''});
}
