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

import 'dart:convert';

import 'package:intl/intl.dart' as intl;
import 'package:logger/logger.dart';

import 'gen_l10n_types.dart';
import 'message_parser.dart';
import 'localizations_utils.dart';
import '../../ota/gen_l10n/gen_l10n.dart' as ota;
import '../../in_context_editing/gen_l10n/gen_l10n.dart' as inctx;

/// List of possible cases for plurals defined the ICU messageFormat syntax.
Map<String, String> pluralCases = <String, String>{
  '0': 'zero',
  '1': 'one',
  '2': 'two',
  'zero': 'zero',
  'one': 'one',
  'two': 'two',
  'few': 'few',
  'many': 'many',
  'other': 'other',
};

class LocalizelyGenL10n {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // This field represents the last loaded locale in the (gen_l10n) Flutter app.
  //
  // Note: A single app can load several locales simultaneously,
  // so this field should not be used for accessing the localization messages.
  static String? _currentLocale;

  static void setCurrentLocale(String locale) {
    _currentLocale = locale;
  }

  static String? getCurrentLocale() {
    return _currentLocale;
  }

  static String? getText(
    String locale,
    String stringKey, [
    List<Object> args = const [],
    Map<String, Object> metadata = const {},
    Map<String, Object> localeMetadata = const {},
    bool useRelaxedSyntax = false,
    bool useEscaping = false,
  ]) {
    var inctxText = inctx.getText(locale, stringKey);
    if (inctxText != null) {
      try {
        var arbFile = _generateArbFile(
          locale,
          stringKey,
          inctxText,
          metadata,
          localeMetadata,
        );

        var arbTemplate = AppResourceBundle.parse(arbFile);
        var arbCollection = AppResourceBundleCollection.parse([arbFile]);

        var message = Message(
          arbTemplate,
          arbCollection,
          stringKey,
          false,
          useRelaxedSyntax: useRelaxedSyntax,
          useEscaping: useEscaping,
        );

        var localeInfo = LocaleInfo.fromString(locale);

        var argsMap = <String, Object>{};
        var placeholders = message.getPlaceholders(localeInfo);
        if (args.length != placeholders.length) {
          throw LocalizelyException(
            'The message updated via In-Context Editing does not match the expected format. '
            'It should have the same number of placeholders as the original message within the app. '
            'Please ensure that the number of placeholders is aligned.',
          );
        }
        for (var i = 0; i < placeholders.length; i++) {
          argsMap[placeholders.elementAt(i).name] = args[i];
        }

        return _handleMessage(locale, message, argsMap);
      } catch (e) {
        _logger.w(
          "String '$stringKey' received in In-Context Editing for locale '$locale' has not-well formatted message.",
          error: e,
        );
        return '\u26A0️ Invalid message';
      }
    }

    var otaText = ota.getText(locale, stringKey);
    if (otaText != null) {
      try {
        var arbFile = _generateArbFile(
          locale,
          stringKey,
          otaText,
          metadata,
          localeMetadata,
        );

        var arbTemplate = AppResourceBundle.parse(arbFile);
        var arbCollection = AppResourceBundleCollection.parse([arbFile]);

        var message = Message(
          arbTemplate,
          arbCollection,
          stringKey,
          false,
          useRelaxedSyntax: useRelaxedSyntax,
          useEscaping: useEscaping,
        );

        var localeInfo = LocaleInfo.fromString(locale);

        var argsMap = <String, Object>{};
        var placeholders = message.getPlaceholders(localeInfo);
        if (args.length != placeholders.length) {
          throw LocalizelyException(
            'The message updated via Over-the-Air does not match the expected format. '
            'It should have the same number of placeholders as the original message within the app. '
            'Please ensure that the number of placeholders is aligned.',
          );
        }
        for (var i = 0; i < placeholders.length; i++) {
          argsMap[placeholders.elementAt(i).name] = args[i];
        }

        return _handleMessage(locale, message, argsMap);
      } catch (e) {
        _logger.w(
          "String '$stringKey' received via Over-the-Air for locale '$locale' has not-well formatted message.",
          error: e,
        );
        return null;
      }
    }

    return null;
  }

  static String? _handleMessage(
    String localeStr,
    Message message,
    Map<String, Object> argsMap,
  ) {
    var locale = LocaleInfo.fromString(localeStr);

    final String translationForMessage = message.messages[locale]!;
    final Node node = message.parsedMessages[locale]!;

    // If the placeholders list is empty, then return a getter method.
    if (message.templatePlaceholders.isEmpty) {
      // Use the parsed translation to handle escaping with the same behavior.
      return node.children.map((Node child) => child.value!).join();
    }

    // Do a DFS post order traversal through placeholderExpr, pluralExpr, and selectExpr nodes.
    // When traversing through a placeholderExpr node, return "$placeholderName".
    // When traversing through a pluralExpr node, return "$tempVarN" and add variable declaration in "tempVariables".
    // When traversing through a selectExpr node, return "$tempVarN" and add variable declaration in "tempVariables".
    // When traversing through an argumentExpr node, return "$tempVarN" and add variable declaration in "tempVariables".
    // When traversing through a message node, return concatenation of all of "generateVariables(child)" for each child.
    String generateTranslation(Node node, {bool isRoot = false}) {
      switch (node.type) {
        case ST.message:
          final List<String> expressions = node.children.map<String>((
            Node node,
          ) {
            if (node.type == ST.string) {
              return node.value!;
            }
            return generateTranslation(node);
          }).toList();

          return expressions.join();
        case ST.placeholderExpr:
          assert(node.children[1].type == ST.identifier);
          final String identifier = node.children[1].value!;
          final Placeholder placeholder =
              message.localePlaceholders[locale]?[identifier] ??
              message.templatePlaceholders[identifier]!;

          if (placeholder.requiresFormatting) {
            return _handlePlaceholderFormatting(
              localeStr,
              placeholder,
              argsMap[identifier]!,
            );
          }
          return argsMap[identifier].toString();

        case ST.pluralExpr:
          final Map<String, String> pluralLogicArgs = <String, String>{};
          // Recall that pluralExpr are of the form
          // pluralExpr := "{" ID "," "plural" "," pluralParts "}"
          assert(node.children[1].type == ST.identifier);
          assert(node.children[5].type == ST.pluralParts);

          final Node identifier = node.children[1];
          final Node pluralParts = node.children[5];

          for (final Node pluralPart in pluralParts.children.reversed) {
            String pluralCase;
            Node pluralMessage;
            if (pluralPart.children[0].value == '=') {
              assert(pluralPart.children[1].type == ST.number);
              assert(pluralPart.children[3].type == ST.message);
              pluralCase = pluralPart.children[1].value!;
              pluralMessage = pluralPart.children[3];
            } else {
              assert(
                pluralPart.children[0].type == ST.identifier ||
                    pluralPart.children[0].type == ST.other,
              );
              assert(pluralPart.children[2].type == ST.message);
              pluralCase = pluralPart.children[0].value!;
              pluralMessage = pluralPart.children[2];
            }
            if (!pluralLogicArgs.containsKey(pluralCases[pluralCase])) {
              final String pluralPartExpression = generateTranslation(
                pluralMessage,
              );
              final String? transformedPluralCase = pluralCases[pluralCase];
              // A valid plural case is one of "=0", "=1", "=2", "zero", "one", "two", "few", "many", or "other".
              if (transformedPluralCase == null) {
                throw L10nParserException(
                  '''
The plural cases must be one of "=0", "=1", "=2", "zero", "one", "two", "few", "many", or "other.
    $pluralCase is not a valid plural case.''',
                  message.resourceId,
                  translationForMessage,
                  pluralPart.positionInMessage,
                );
              }

              pluralLogicArgs[transformedPluralCase] = pluralPartExpression;
            }
          }

          return intl.Intl.pluralLogic(
            argsMap[identifier.value!] as num,
            locale: localeStr,
            zero: pluralLogicArgs['zero'],
            one: pluralLogicArgs['one'],
            two: pluralLogicArgs['two'],
            few: pluralLogicArgs['few'],
            many: pluralLogicArgs['many'],
            other: pluralLogicArgs['other'] ?? '',
          );

        case ST.selectExpr:
          // Recall that pluralExpr are of the form
          // pluralExpr := "{" ID "," "plural" "," pluralParts "}"
          assert(node.children[1].type == ST.identifier);
          assert(node.children[5].type == ST.selectParts);

          final Node identifier = node.children[1];
          final Map<String, String> selectLogicArgs = <String, String>{};
          final Node selectParts = node.children[5];
          for (final Node selectPart in selectParts.children) {
            assert(
              selectPart.children[0].type == ST.identifier ||
                  selectPart.children[0].type == ST.other,
            );
            assert(selectPart.children[2].type == ST.message);
            final String selectCase = selectPart.children[0].value!;
            final Node selectMessage = selectPart.children[2];
            final String selectPartExpression = generateTranslation(
              selectMessage,
            );
            selectLogicArgs.putIfAbsent(selectCase, () => selectPartExpression);
          }
          return intl.Intl.selectLogic(
            argsMap[identifier.value]!,
            selectLogicArgs,
          );
        case ST.argumentExpr:
          assert(node.children[1].type == ST.identifier);
          assert(node.children[3].type == ST.argType);
          assert(node.children[7].type == ST.identifier);
          final String identifierName = node.children[1].value!;
          final Node formatType = node.children[7];
          // Check that formatType is a valid intl.DateFormat.
          if (!validDateFormats.contains(formatType.value)) {
            throw L10nParserException(
              'Date format "${formatType.value!}" for placeholder '
              '$identifierName does not have a corresponding DateFormat '
              "constructor\n. Check the intl library's DateFormat class "
              'constructors for allowed date formats, or set "isCustomDateFormat" attribute '
              'to "true".',
              message.resourceId,
              translationForMessage,
              formatType.positionInMessage,
            );
          }

          return _handleArgumentExpression(
            localeStr,
            formatType.value!,
            argsMap[identifierName]!,
          );
        // ignore: no_default_cases
        default:
          throw Exception(
            'Cannot call "generateHelperMethod" on node type ${node.type}',
          );
      }
    }

    return generateTranslation(node, isRoot: true);
  }

  static String _handleArgumentExpression(
    String locale,
    String format,
    Object value,
  ) {
    return intl.DateFormat(format, locale).format(value as DateTime);
  }

  static String _handlePlaceholderFormatting(
    String locale,
    Placeholder placeholder,
    Object value,
  ) {
    if (placeholder.requiresDateFormatting) {
      return _formatDateTime(locale, placeholder, value as DateTime);
    }

    if (placeholder.requiresNumFormatting) {
      return _formatNumber(locale, placeholder, value as num);
    }

    return value.toString();
  }

  static String _formatDateTime(
    String locale,
    Placeholder placeholder,
    DateTime value,
  ) {
    final format = placeholder.format!;
    final isCustomDateFormat = placeholder.isCustomDateFormat;

    if (isCustomDateFormat == true) {
      return intl.DateFormat(format, locale).format(value);
    }

    List<String> dateFormatParts = format.split(dateFormatPartsDelimiter);

    var dateFormat = intl.DateFormat(dateFormatParts.first, locale);
    for (int i = 1; i < dateFormatParts.length; i++) {
      String part = dateFormatParts[i];
      dateFormat.addPattern(part);
    }

    return dateFormat.format(value);
  }

  static String _formatNumber(
    String locale,
    Placeholder placeholder,
    num value,
  ) {
    final String? format = placeholder.format;
    final List<OptionalParameter> optionalParameters =
        placeholder.optionalParameters;

    final Map<String, dynamic> optionals = {
      for (var param in optionalParameters) param.name: param.value,
    };

    switch (format) {
      case 'compact':
        return intl.NumberFormat.compact(locale: locale).format(value);
      case 'compactCurrency':
        return intl.NumberFormat.compactCurrency(
          locale: locale,
          name: optionals['name'] as String?,
          symbol: optionals['symbol'] as String?,
          decimalDigits: optionals['decimalDigits'] as int?,
        ).format(value);
      case 'compactSimpleCurrency':
        return intl.NumberFormat.compactSimpleCurrency(
          locale: locale,
          name: optionals['name'] as String?,
          decimalDigits: optionals['decimalDigits'] as int?,
        ).format(value);
      case 'compactLong':
        return intl.NumberFormat.compactLong(locale: locale).format(value);
      case 'currency':
        return intl.NumberFormat.currency(
          locale: locale,
          name: optionals['name'] as String?,
          symbol: optionals['symbol'] as String?,
          decimalDigits: optionals['decimalDigits'] as int?,
          customPattern: optionals['customPattern'] as String?,
        ).format(value);
      case 'decimalPattern':
        return intl.NumberFormat.decimalPattern().format(value);
      case 'decimalPatternDigits':
        return intl.NumberFormat.decimalPatternDigits(
          locale: locale,
          decimalDigits: optionals['decimalDigits'] as int?,
        ).format(value);
      case 'decimalPercentPattern':
        return intl.NumberFormat.decimalPercentPattern(
          locale: locale,
          decimalDigits: optionals['decimalDigits'] as int?,
        ).format(value);
      case 'percentPattern':
        return intl.NumberFormat.percentPattern().format(value);
      case 'scientificPattern':
        return intl.NumberFormat.scientificPattern().format(value);
      case 'simpleCurrency':
        return intl.NumberFormat.simpleCurrency(
          locale: locale,
          name: optionals['name'] as String?,
          decimalDigits: optionals['decimalDigits'] as int?,
        ).format(value);
      default:
        return value.toString();
    }
  }

  static String _generateArbFile(
    String locale,
    String stringKey,
    String translation,
    Map<String, Object> metadata,
    Map<String, Object> localeMetadata,
  ) {
    final Map<String, Object> extractedMetadata = metadata["@$stringKey"] is Map
        ? Map<String, Object>.from(metadata["@$stringKey"] as Map)
        : <String, Object>{};

    // Merge locale-specific placeholder data if available.
    if (localeMetadata.containsKey(locale) &&
        extractedMetadata.containsKey('placeholders')) {
      final Map<String, Object> placeholders = Map<String, Object>.from(
        extractedMetadata['placeholders'] as Map,
      );
      final Map<String, Object> localePlaceholders = Map<String, Object>.from(
        localeMetadata[locale] as Map,
      );

      localePlaceholders.forEach((key, value) {
        if (placeholders.containsKey(key)) {
          final originalValue = placeholders[key];
          if (originalValue is Map && value is Map) {
            final Map<String, Object> mergedValue = Map<String, Object>.from(
              originalValue,
            )..addAll(value.map((k, v) => MapEntry(k, v)));
            placeholders[key] = mergedValue;
          }
        }
      });

      extractedMetadata['placeholders'] = placeholders;
    }

    return json.encode({
      "@@locale": locale,
      stringKey: translation,
      "@$stringKey": extractedMetadata,
    });
  }
}

class LocalizelyException implements Exception {
  LocalizelyException(this.message);

  final String message;

  @override
  String toString() => message;
}
