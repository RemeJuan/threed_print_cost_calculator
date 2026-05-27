part of 'gcode_import_parser.dart';

final List<RegExp> _layerHeightPatterns = [
  RegExp(r'^;\s*layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
  RegExp(r'^;\s*Layer height\s*:\s*(.+?)\s*$', caseSensitive: false),
  RegExp(r'^;\s*first_layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
];

final List<RegExp> _durationPatterns = [
  RegExp(r'^;\s*total estimated time\s*=\s*(.+?)\s*$', caseSensitive: false),
  RegExp(
    r'^;\s*estimated printing time \(normal mode\)\s*=\s*(.+?)\s*$',
    caseSensitive: false,
  ),
  RegExp(r'^;\s*TIME\s*:\s*(.+?)\s*$', caseSensitive: false),
];

final List<RegExp> _filamentLengthMmPatterns = [
  RegExp(
    r'^;\s*total filament length \[mm\]\s*=\s*(.+?)\s*$',
    caseSensitive: false,
  ),
  RegExp(r'^;\s*filament used \[mm\]\s*=\s*(.+?)\s*$', caseSensitive: false),
  RegExp(r'^;\s*Filament used\s*:\s*(.+?)\s*$', caseSensitive: false),
];

final List<RegExp> _filamentLengthCmPatterns = [
  RegExp(r'^;\s*filament used \[cm\]\s*=\s*(.+?)\s*$', caseSensitive: false),
  RegExp(
    r'^;\s*filament\s+(?:used|length)\s*[=:]\s*(.+?)\s*cm\s*$',
    caseSensitive: false,
  ),
];

final List<RegExp> _filamentLengthMPatterns = [
  RegExp(r'^;\s*filament used \[m\]\s*=\s*(.+?)\s*$', caseSensitive: false),
  RegExp(
    r'^;\s*filament\s+(?:used|length)\s*[=:]\s*(.+?)\s*m\s*$',
    caseSensitive: false,
  ),
];

final List<RegExp> _filamentWeightPatterns = [
  RegExp(
    r'^;\s*total filament weight \[g\]\s*=\s*(.+?)\s*$',
    caseSensitive: false,
  ),
  RegExp(r'^;\s*filament used \[g\]\s*=\s*(.+?)\s*$', caseSensitive: false),
];

final RegExp _thumbnailBeginRegex = RegExp(
  r'^;\s*(thumbnail(?:_QOI)?)\s+begin\s+(\d+)x(\d+)\s+(\d+)\s*$',
  caseSensitive: false,
);

final RegExp _thumbnailEndRegex = RegExp(
  r'^;\s*thumbnail(?:_QOI)?\s+end\s*$',
  caseSensitive: false,
);

const int _maxPreviewDimension = 2048;
