import 'dart:collection';

import 'package:intl/intl.dart';

import '../parser/parser.dart';
import '../parser/message_format.dart';

IcuParser parser = IcuParser();

enum ContentType { literal, argument, plural, gender, select, compound }

class Label {
  final String? key;
  final String? value;

  Label({this.key, this.value});

  Label.fromJson(Map<String, dynamic> json)
    : key = json['key'],
      value = json['value'];

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  List<String> getArgs() {
    var parsedContent = parser.parse(value ?? '');
    if (parsedContent == null) {
      return [];
    }

    return _getArgsFromParsedContent(parsedContent);
  }

  List<String> _getArgsFromParsedContent(List<BaseElement> elements) {
    var args = <String>[];

    for (var element in elements) {
      switch (element.type) {
        case ElementType.argument:
          {
            args.add(element.value);
            break;
          }
        case ElementType.plural:
          {
            var pluralElement = element as PluralElement;
            args.add(element.value);
            for (var option in pluralElement.options) {
              args.addAll(_getArgsFromParsedContent(option.value));
            }
            break;
          }
        case ElementType.gender:
          {
            var genderElement = element as GenderElement;
            args.add(element.value);
            for (var option in genderElement.options) {
              args.addAll(_getArgsFromParsedContent(option.value));
            }
            break;
          }
        case ElementType.select:
          {
            var selectElement = element as SelectElement;
            args.add(element.value);
            for (var option in selectElement.options) {
              args.addAll(_getArgsFromParsedContent(option.value));
            }
            break;
          }
        default:
          {}
      }
    }

    return LinkedHashSet<String>.from(args).toList();
  }

  String? getTranslation(Map<String, Object> args) {
    var parsedContent = parser.parse(value ?? '');
    if (parsedContent == null) {
      return null;
    }

    var contentType = _getContentType(parsedContent, args);

    switch (contentType) {
      case ContentType.literal:
        {
          return value;
        }
      case ContentType.argument:
        {
          return _generateArgumentContent(parsedContent, args);
        }
      case ContentType.plural:
        {
          return _generatePluralContent(parsedContent, args);
        }
      case ContentType.gender:
        {
          return _generateGenderContent(parsedContent, args);
        }
      case ContentType.select:
        {
          return _generateSelectContent(parsedContent, args);
        }
      case ContentType.compound:
        {
          return _generateCompoundContent(parsedContent, args);
        }
    }
  }

  ContentType _getContentType(
    List<BaseElement> data,
    Map<String, Object> args,
  ) {
    if (_isLiteral(data) && args.isEmpty) {
      return ContentType.literal;
    } else if (_isArgument(data) && args.isNotEmpty) {
      return ContentType.argument;
    } else if (_isPlural(data) && args.isNotEmpty) {
      return ContentType.plural;
    } else if (_isGender(data) && args.isNotEmpty) {
      return ContentType.gender;
    } else if (_isSelect(data) && args.isNotEmpty) {
      return ContentType.select;
    } else {
      return ContentType.compound;
    }
  }

  bool _isLiteral(List<BaseElement> data) {
    return (data.isNotEmpty &&
        data
            .map((item) => item.type == ElementType.literal)
            .reduce((bool acc, bool curr) => acc && curr));
  }

  bool _isArgument(List<BaseElement> data) {
    return (data.isNotEmpty &&
        data
            .map(
              (item) => [
                ElementType.argument,
                ElementType.literal,
              ].contains(item.type),
            )
            .reduce((bool acc, bool curr) => acc && curr));
  }

  bool _isPlural(List<BaseElement> data) {
    return (data.length == 1 && data[0].type == ElementType.plural);
  }

  bool _isGender(List<BaseElement> data) {
    return (data.length == 1 && data[0].type == ElementType.gender);
  }

  bool _isSelect(List<BaseElement> data) {
    return (data.length == 1 && data[0].type == ElementType.select);
  }

  String _generateArgumentContent(
    List<BaseElement> data,
    Map<String, Object> args,
  ) {
    return data.map((element) {
      switch (element.type) {
        case ElementType.literal:
          {
            return element.value;
          }
        case ElementType.argument:
          {
            return args[element.value];
          }
        default:
          {
            return '';
          }
      }
    }).join();
  }

  String _generatePluralContent(
    List<BaseElement> data,
    Map<String, Object> args,
  ) {
    var pluralElement = data.elementAt(
      0,
    ); // simplified solution - handle just first plural element
    var options = _generatePluralOptions(pluralElement as PluralElement, args);

    return Intl.plural(
      args[pluralElement.value]! as num,
      zero: options['zero'],
      one: options['one'],
      two: options['two'],
      few: options['few'],
      many: options['many'],
      other: options['other'] ?? '',
    );
  }

  Map<String, String> _generatePluralOptions(
    PluralElement pluralElement,
    Map<String, Object> args,
  ) {
    var options = <String, String>{};

    _sanitizePluralOptions(pluralElement.options).forEach((option) {
      switch (option.name) {
        case '=0':
        case 'zero':
          {
            options.putIfAbsent(
              'zero',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case '=1':
        case 'one':
          {
            options.putIfAbsent(
              'one',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case '=2':
        case 'two':
          {
            options.putIfAbsent(
              'two',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case 'few':
          {
            options.putIfAbsent(
              'few',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case 'many':
          {
            options.putIfAbsent(
              'many',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case 'other':
          {
            options.putIfAbsent(
              'other',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        default:
          {}
      }
    });

    return options;
  }

  /// remove duplicates and print warnings in case of irregularity
  List<Option> _sanitizePluralOptions(List<Option> options) {
    var keys = options.map((option) => option.name);
    var uniqueKeys = LinkedHashSet<String>.from(keys);
    if (uniqueKeys.contains('zero') && uniqueKeys.contains('=0')) {
      uniqueKeys.remove('=0');
    }
    if (uniqueKeys.contains('one') && uniqueKeys.contains('=1')) {
      uniqueKeys.remove('=1');
    }
    if (uniqueKeys.contains('two') && uniqueKeys.contains('=2')) {
      uniqueKeys.remove('=2');
    }

    var sanitized = uniqueKeys
        .map(
          (uniqueKey) =>
              options.firstWhere((option) => option.name == uniqueKey),
        )
        .toList();

    return sanitized;
  }

  String _generateGenderContent(
    List<BaseElement> data,
    Map<String, Object> args,
  ) {
    var genderElement = data.elementAt(
      0,
    ); // simplified solution - handle just first gender element
    var options = _generateGenderOptions(genderElement as GenderElement, args);

    return Intl.gender(
      args[genderElement.value]! as String,
      male: options['male'],
      female: options['female'],
      other: options['other'] ?? '',
    );
  }

  Map<String, String> _generateGenderOptions(
    GenderElement genderElement,
    Map<String, Object> args,
  ) {
    var options = <String, String>{};

    _sanitizeGenderOrSelectOptions(genderElement.options).forEach((option) {
      switch (option.name) {
        case 'male':
          {
            options.putIfAbsent(
              'male',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case 'female':
          {
            options.putIfAbsent(
              'female',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        case 'other':
          {
            options.putIfAbsent(
              'other',
              () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
            );
            break;
          }
        default:
          {}
      }
    });

    return options;
  }

  String _generateSelectContent(
    List<BaseElement> data,
    Map<String, Object> args,
  ) {
    var selectElement = data.elementAt(
      0,
    ); // simplified solution - handle just first select element
    var options = _generateSelectOptions(selectElement as SelectElement, args);

    return Intl.select(args[selectElement.value] ?? '', options);
  }

  Map<Object, String> _generateSelectOptions(
    SelectElement selectElement,
    Map<String, Object> args,
  ) {
    var options = <Object, String>{};

    _sanitizeGenderOrSelectOptions(selectElement.options).forEach(
      (option) => options.putIfAbsent(
        option.name,
        () => _generatePluralOrGenderOrSelectOptionMessage(option, args),
      ),
    );

    return options;
  }

  /// remove duplicates and print warnings in case of irregularity
  List<Option> _sanitizeGenderOrSelectOptions(List<Option> options) {
    var keys = options.map((option) => option.name);
    var uniqueKeys = LinkedHashSet<String>.from(keys);

    var sanitized = uniqueKeys
        .map(
          (uniqueKey) =>
              options.firstWhere((option) => option.name == uniqueKey),
        )
        .toList();

    return sanitized;
  }

  String _generateCompoundContent(
    List<BaseElement> data,
    Map<String, Object> args,
  ) {
    var response = '';

    for (var element in data) {
      switch (element.type) {
        case ElementType.literal:
          {
            response += element.value;
            break;
          }
        case ElementType.argument:
          {
            response += _generateArgumentContent([element], args);
            break;
          }
        case ElementType.plural:
          {
            response += _generatePluralContent([element], args);
            break;
          }
        case ElementType.gender:
          {
            response += _generateGenderContent([element], args);
            break;
          }
        case ElementType.select:
          {
            response += _generateSelectContent([element], args);
            break;
          }
      }
    }

    return response;
  }

  String _generatePluralOrGenderOrSelectOptionMessage(
    Option option,
    Map<String, Object> args,
  ) {
    var data = option.value;
    var isValid = _validatePluralOrGenderOrSelectOption(data);

    return isValid
        ? data.map((item) {
            switch (item.type) {
              case ElementType.literal:
                {
                  return item.value;
                }
              case ElementType.argument:
                {
                  return args[item.value];
                }
              default:
                {
                  return '';
                }
            }
          }).join()
        : _getRawPluralOrGenderOrSelectOption(option);
  }

  /// current implementation only supports trivial plural, gender and select options (literal and argument messages)
  bool _validatePluralOrGenderOrSelectOption(List<BaseElement> data) {
    return data
        .map(
          (item) =>
              [ElementType.literal, ElementType.argument].contains(item.type),
        )
        .reduce((acc, curr) => acc && curr);
  }

  String _getRawPluralOrGenderOrSelectOption(Option option) {
    if (value == null) return '';

    var startIndex = _findOptionStartIndex(value!, option);
    var endIndex = _findOptionEndIndex(value!, startIndex);

    return value!.substring(startIndex, endIndex);
  }

  int _findOptionStartIndex(String content, Option option) {
    var counter = 0;
    for (var i = 0; i < content.length; i++) {
      var char = content[i];
      switch (char) {
        case '{':
          {
            counter++;
            break;
          }
        case '}':
          {
            counter--;
            break;
          }
      }

      if (counter == 2) {
        var chunk = content.substring(0, i + 1);

        var optionIndex = chunk.lastIndexOf(RegExp('${option.name}(\\s)*{'));
        if (optionIndex != -1 &&
            chunk.substring(optionIndex, i).trim() == option.name) {
          return i + 1;
        }
      }
    }

    return -1;
  }

  int _findOptionEndIndex(String content, int startIndex) {
    var substring = content.substring(startIndex);

    var counter = 1; // option starts with '{'
    for (var i = 0; i < substring.length; i++) {
      var char = substring[i];
      switch (char) {
        case '{':
          {
            counter++;
            break;
          }
        case '}':
          {
            counter--;
            break;
          }
      }

      if (counter == 0) {
        return startIndex + i;
      }
    }

    return -1;
  }
}
