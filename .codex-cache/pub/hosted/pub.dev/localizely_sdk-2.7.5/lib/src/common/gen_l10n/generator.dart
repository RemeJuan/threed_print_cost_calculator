// This file incorporates work covered by the following copyright and
// permission notice:
//
//     Copyright 2014 The Flutter Authors. All rights reserved.
//
//     Redistribution and use in source and binary forms, with or without modification,
//     are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//     copyright notice, this list of conditions and the following
//     disclaimer in the documentation and/or other materials provided
//     with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//     contributors may be used to endorse or promote products derived
//     from this software without specific prior written permission.
//
//     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//     ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//     ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//     --------------------------------------------------------------------------------
//
//     Copyright 2014 The Flutter Authors. All rights reserved.
//     Use of this source code is governed by a BSD-style license that can be
//     found in the LICENSE file.
//
// Partially modified code of the gen_l10n tool.
// Flutter 3.29.0 (https://github.com/flutter/flutter/tree/35c388afb57ef061d06a39b537336c87e0e3d1b1)

import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

import 'gen_l10n_types.dart';
import 'localizations_utils.dart';
import '../util/util.dart';

Future<void> generate() async {
  final config = getGenL10nConfigSync();

  final arb = AppResourceBundle(
    File(path.join(config.arbDir, config.templateArbFile)),
  );
  final arbCollection = AppResourceBundleCollection(
    Directory(path.join(config.arbDir)),
  );

  final lyLocalizationsFileContents = generateLyLocalizationsContents(
    arb,
    arbCollection,
    config,
  );

  File lyLocalizationsFile = File(
    path.join(config.outputDir, 'localizely_localizations.dart'),
  );

  await lyLocalizationsFile.create(recursive: true);

  await lyLocalizationsFile.writeAsString(
    lyLocalizationsFileContents,
    mode: FileMode.writeOnly,
    flush: true,
  );
}

String generateLyLocalizationsContents(
  AppResourceBundle arb,
  AppResourceBundleCollection arbCollection,
  GenL10nConfig config,
) {
  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/widgets.dart';");
  buffer.writeln(
    "import 'package:flutter_localizations/flutter_localizations.dart';",
  );
  buffer.writeln("import 'package:localizely_sdk/localizely_sdk.dart';");
  buffer.writeln('');
  buffer.writeln("import '${config.outputLocalizationFile}';");
  buffer.writeln('');
  buffer.writeln('// ignore_for_file: type=lint');
  buffer.writeln('');
  buffer.writeln(
    'class LocalizelyLocalizations extends ${config.outputClass} {',
  );
  buffer.writeln('  final ${config.outputClass} _fallback;');
  buffer.writeln('');
  buffer.writeln(
    '  LocalizelyLocalizations(String locale, ${config.outputClass} fallback) : _fallback = fallback, super(locale);',
  );
  buffer.writeln('');
  buffer.writeln(
    '  static const LocalizationsDelegate<${config.outputClass}> delegate = _LocalizelyLocalizationsDelegate();',
  );
  buffer.writeln('');
  buffer.writeln(
    '  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[',
  );
  buffer.writeln('    delegate,');
  buffer.writeln('    GlobalMaterialLocalizations.delegate,');
  buffer.writeln('    GlobalCupertinoLocalizations.delegate,');
  buffer.writeln('    GlobalWidgetsLocalizations.delegate,');
  buffer.writeln('  ];');
  buffer.writeln('');
  buffer.writeln(
    '  static const List<Locale> supportedLocales = ${config.outputClass}.supportedLocales;',
  );

  final needsConfigArgs = config.useRelaxedSyntax || config.useEscaping;
  final messages = arb.resourceIds
      .map(
        (id) => Message(
          arb,
          arbCollection,
          id,
          false,
          useRelaxedSyntax: config.useRelaxedSyntax,
          useEscaping: config.useEscaping,
        ),
      )
      .toList(growable: false);

  for (final message in messages) {
    final id = message.resourceId;
    final placeholders = message.templatePlaceholders.values.toList();
    final methodParameters = _generateMethodParameters(message);
    final params = methodParameters.join(', ');
    final namedParams = methodParameters
        .map((param) => 'required $param')
        .join(', ');
    final placeholderValues = placeholders.map(
      (placeholder) => placeholder.name,
    );
    final values = placeholderValues.join(', ');
    final namedValues = placeholderValues
        .map((name) => '$name: $name')
        .join(', ');
    final metadata = _generateMetadata(message);
    final localeMetadata = _generateLocaleMetadata(message);

    buffer.writeln('');
    buffer.writeln('  @override');
    if (placeholders.isEmpty) {
      final additionalArgs = needsConfigArgs
          ? ', [], {}, {}, ${config.useRelaxedSyntax}, ${config.useEscaping}'
          : '';
      buffer.writeln(
        "  String get $id => LocalizelyGenL10n.getText(localeName, '$id'$additionalArgs) ?? _fallback.$id;",
      );
    } else {
      final additionalArgs = needsConfigArgs
          ? ', [$values], $metadata, $localeMetadata, ${config.useRelaxedSyntax}, ${config.useEscaping}'
          : ', [$values], $metadata, $localeMetadata';
      buffer.writeln(
        config.useNamedParameters
            ? "  String $id({$namedParams}) => LocalizelyGenL10n.getText(localeName, '$id'$additionalArgs) ?? _fallback.$id($namedValues);"
            : "  String $id($params) => LocalizelyGenL10n.getText(localeName, '$id'$additionalArgs) ?? _fallback.$id($values);",
      );
    }
  }
  buffer.writeln('}');
  buffer.writeln('');
  buffer.writeln(
    'class _LocalizelyLocalizationsDelegate extends LocalizationsDelegate<${config.outputClass}> {',
  );
  buffer.writeln('  const _LocalizelyLocalizationsDelegate();');
  buffer.writeln('');
  buffer.writeln('  @override');
  buffer.writeln(
    '  Future<${config.outputClass}> load(Locale locale) => ${config.outputClass}.delegate.load(locale).then((${Util.generateInstanceName(config.outputClass)}) {',
  );
  buffer.writeln(
    '    LocalizelyGenL10n.setCurrentLocale(${Util.generateInstanceName(config.outputClass)}.localeName);',
  );
  buffer.writeln(
    '    return LocalizelyLocalizations(${Util.generateInstanceName(config.outputClass)}.localeName, ${Util.generateInstanceName(config.outputClass)});',
  );
  buffer.writeln('  });');
  buffer.writeln('');
  buffer.writeln('  @override');
  buffer.writeln(
    '  bool isSupported(Locale locale) => ${config.outputClass}.delegate.isSupported(locale);',
  );
  buffer.writeln('');
  buffer.writeln('  @override');
  buffer.writeln(
    '  bool shouldReload(_LocalizelyLocalizationsDelegate old) => false;',
  );
  buffer.writeln('}');

  return buffer.toString();
}

Map<String, Object> _generateMetadata(Message message) {
  Map<String, Object> combine(
    Map<String, Object> acc,
    Map<String, Object> curr,
  ) => ({...acc, ...curr});

  var placeholders = message.templatePlaceholders.values.toList();

  return {
    '"@${message.resourceId}"': {
      '"placeholders"': {
        ...placeholders
            .map(
              (placeholder) => ({
                '"${placeholder.name}"': {
                  ...(placeholder.type != null
                      ? {'"type"': '"${placeholder.type}"'}
                      : {}),
                  ...(placeholder.format != null
                      ? {'"format"': '"${generateString(placeholder.format!)}"'}
                      : {}),
                  ...(placeholder.optionalParameters.isNotEmpty
                      ? {
                          '"optionalParameters"': {
                            ...placeholder.optionalParameters
                                .map(
                                  (optionalParameter) => ({
                                    '"${optionalParameter.name}"':
                                        optionalParameter.value is String
                                        ? '"${generateString(optionalParameter.value as String)}"'
                                        : '${optionalParameter.value}',
                                  }),
                                )
                                .fold(<String, Object>{}, combine),
                          },
                        }
                      : {}),
                  ...(placeholder.isCustomDateFormat == true
                      ? {'"isCustomDateFormat"': '"true"'}
                      : {}),
                },
              }),
            )
            .fold(<String, Object>{}, combine),
      },
    },
  };
}

// In some cases, placeholders might have different formats and optional parameter configurations across ARB files.
// This applies only to placeholders with defined types such as int, num, double, or DateTime, all of which support formatting.
//
// Note: It is not possible to have a different placeholder type across ARB files for the same placeholder and message.
// However, differences in format and optional parameter configurations are permitted.
// If a locale-specific placeholder has a different format or optional parameters compared to the template placeholder,
// we generate locale-specific metadata to ensure we can mimic the original behavior during translation updates from the Localizely platform.
Map<String, Object> _generateLocaleMetadata(Message message) {
  final templatePlaceholders = message.templatePlaceholders.values.toList();
  if (templatePlaceholders.isEmpty) {
    return {};
  }

  final localeMetadata = <String, Object>{};
  for (final entry in message.localePlaceholders.entries) {
    final localeInfo = entry.key;
    final placeholders = entry.value.values.toList();

    for (final localePlaceholder in placeholders) {
      final templatePlaceholder = templatePlaceholders
          .where((placeholder) => placeholder.name == localePlaceholder.name)
          .firstOrNull;
      if (templatePlaceholder == null) continue; // This should not happen

      final hasDifferentFormat =
          localePlaceholder.format != templatePlaceholder.format;
      final hasDifferentOptionalParameters =
          localePlaceholder.optionalParameters.length !=
              templatePlaceholder.optionalParameters.length ||
          localePlaceholder.optionalParameters.any(
            (lop) => !templatePlaceholder.optionalParameters.any(
              (top) => lop.name == top.name && lop.value == top.value,
            ),
          );
      final hasDifferentIsCustomDateFormat =
          localePlaceholder.isCustomDateFormat !=
          templatePlaceholder.isCustomDateFormat;

      if (hasDifferentFormat ||
          hasDifferentOptionalParameters ||
          hasDifferentIsCustomDateFormat) {
        Map<String, dynamic> differences = {};

        if (hasDifferentFormat) {
          differences['"format"'] =
              '"${generateString(localePlaceholder.format!)}"';
        }

        if (hasDifferentOptionalParameters) {
          differences['"optionalParameters"'] = {
            for (var op in localePlaceholder.optionalParameters)
              '"${op.name}"': op.value is String
                  ? '"${generateString(op.value as String)}"'
                  : op.value,
          };
        }

        if (hasDifferentIsCustomDateFormat) {
          differences['"isCustomDateFormat"'] =
              '"${localePlaceholder.isCustomDateFormat}"';
        }

        localeMetadata.putIfAbsent(
          '"${localeInfo.toString()}"',
          () => <String, dynamic>{},
        );

        Map<String, dynamic> localeEntry =
            localeMetadata['"${localeInfo.toString()}"']
                as Map<String, dynamic>;
        localeEntry['"${localePlaceholder.name}"'] = differences;
      }
    }
  }

  return localeMetadata;
}

List<String> _generateMethodParameters(Message message) {
  var placeholders = message.templatePlaceholders.values.toList();
  assert(placeholders.isNotEmpty);

  return placeholders.map((Placeholder placeholder) {
    final String? type = placeholder.type;
    return '$type ${placeholder.name}';
  }).toList();
}

GenL10nConfig getGenL10nConfigSync() {
  File l10nFile = File('l10n.yaml');

  if (!l10nFile.existsSync()) {
    throw GenL10nException("The 'l10n.yaml' file does not exist.");
  }

  String l10nFileContents = l10nFile.readAsStringSync();

  var l10nYaml = yaml.loadYaml(l10nFileContents);

  bool syntheticPackage = l10nYaml['synthetic-package'] ?? false;
  String arbDir = l10nYaml['arb-dir'] ?? path.join('lib', 'l10n');
  String outputDir = syntheticPackage
      ? path.join('.dart_tool', 'flutter_gen', 'gen_l10n')
      : l10nYaml['output-dir'] ?? arbDir;
  String templateArbFile = l10nYaml['template-arb-file'] ?? 'app_en.arb';
  String outputLocalizationFile =
      l10nYaml['output-localization-file'] ?? 'app_localizations.dart';
  String outputClass = l10nYaml['output-class'] ?? 'AppLocalizations';
  bool useEscaping = l10nYaml['use-escaping'] ?? false;
  bool useRelaxedSyntax = l10nYaml['relax-syntax'] ?? false;
  bool useNamedParameters = l10nYaml['use-named-parameters'] ?? false;

  return GenL10nConfig(
    arbDir: arbDir,
    outputDir: outputDir,
    templateArbFile: templateArbFile,
    outputLocalizationFile: outputLocalizationFile,
    outputClass: outputClass,
    syntheticPackage: syntheticPackage,
    useEscaping: useEscaping,
    useRelaxedSyntax: useRelaxedSyntax,
    useNamedParameters: useNamedParameters,
  );
}

/// The configuration for the gen_l10n tool.
///
/// More info: https://docs.google.com/document/d/10e0saTfAv32OZLRmONy866vnaw0I2jwL8zukykpgWBc/edit#
class GenL10nConfig {
  String arbDir;
  String outputDir;
  String templateArbFile;
  String outputLocalizationFile;
  String outputClass;
  bool syntheticPackage;
  bool useEscaping;
  bool useRelaxedSyntax;
  bool useNamedParameters;

  GenL10nConfig({
    required this.arbDir,
    required this.outputDir,
    required this.templateArbFile,
    required this.outputLocalizationFile,
    required this.outputClass,
    required this.syntheticPackage,
    required this.useEscaping,
    required this.useRelaxedSyntax,
    required this.useNamedParameters,
  });
}

class GenL10nException implements Exception {
  final String message;

  GenL10nException(this.message);

  @override
  String toString() => 'GenL10nException: $message';
}
