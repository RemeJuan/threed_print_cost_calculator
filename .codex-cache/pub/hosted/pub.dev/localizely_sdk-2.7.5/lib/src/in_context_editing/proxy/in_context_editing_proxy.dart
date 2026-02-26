import 'dart:convert' as convert;

// ignore_for_file:implementation_imports
import 'package:intl/src/intl_helpers.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:logger/logger.dart';

import '../api/api.dart';
import '../../sdk_data.dart';
import '../../ota/model/label.dart';

class MessageLookupProxy extends MessageLookup {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final MessageLookup _messageLookup;

  bool _isDetected = false;

  void _detectCodeGen() {
    if (!_isDetected) {
      sendWebSocketMessage(
        convert.jsonEncode({
          'type': 'code_gen_detected',
          'codeGen': 'intl_utils',
        }),
      );
      _isDetected = true;
    }
  }

  MessageLookupProxy.from(MessageLookup messageLookup)
    : _messageLookup = (messageLookup is UninitializedLocaleData)
          ? CompositeMessageLookup()
          : messageLookup;

  @override
  void addLocale(String localeName, Function findLocale) {
    _messageLookup.addLocale(localeName, findLocale);
  }

  @override
  String? lookupMessage(
    String? messageText,
    String? locale,
    String? name,
    List<Object>? args,
    String? meaning, {
    MessageIfAbsent? ifAbsent,
  }) {
    try {
      var currentLocale = locale ?? Intl.getCurrentLocale();
      var origArgs = SdkData.getOrigArgs(name);

      if (name == null || args == null) {
        return _messageLookup.lookupMessage(
          messageText,
          locale,
          name,
          args,
          meaning,
          ifAbsent: ifAbsent,
        );
      }

      if (origArgs == null) {
        _logger.w(
          "The In-Context Editing is enabled but missing metadata. Please ensure 'ota_enabled' is set to 'true' within 'flutter_intl/localizely' section of the 'pubspec.yaml' file.",
        );
        return _messageLookup.lookupMessage(
          messageText,
          locale,
          name,
          args,
          meaning,
          ifAbsent: ifAbsent,
        );
      }

      // Code generated with the gen_l10n tool may call lookupMessage method (e.g. ICU Select message)
      // but will have name and args arguments set to null.
      _detectCodeGen();

      var translationChangeTyped = SdkData.inContextEditingData?.getEditedData(
        currentLocale,
        name,
      );
      if (translationChangeTyped == null) {
        return _messageLookup.lookupMessage(
          messageText,
          locale,
          name,
          args,
          meaning,
          ifAbsent: ifAbsent,
        );
      }

      var label = Label(
        key: translationChangeTyped.key,
        value: translationChangeTyped.value,
      );
      var labelArgs = label.getArgs();

      var isLabelArgsValid = _validateLabelArgs(origArgs, labelArgs);
      if (!isLabelArgsValid) {
        _logger.w(
          "String '${label.key}' received in In-Context Editing for locale '$currentLocale' has unsupported placeholders.",
        );
        return '\u26A0 Invalid message';
      }

      var argsMap = _mapArgs(origArgs, args);

      var translation = label.getTranslation(argsMap);
      if (translation == null) {
        _logger.w(
          "String '${label.key}' received in In-Context Editing for locale '$currentLocale' has not-well formatted message.",
        );
        return '\u26A0️ Invalid message';
      }

      return translation;
    } catch (e) {
      _logger.w('Failed to lookup message.', error: e);
      return _messageLookup.lookupMessage(
        messageText,
        locale,
        name,
        args,
        meaning,
        ifAbsent: ifAbsent,
      );
    }
  }

  bool _validateLabelArgs(List<String> oldArgs, List<String> newArgs) {
    if (newArgs.length > oldArgs.length) {
      return false;
    }

    for (var newArg in newArgs) {
      if (!oldArgs.contains(newArg)) {
        return false;
      }
    }

    return true;
  }

  Map<String, Object> _mapArgs(List<String> argNames, List<Object> argsValues) {
    var argsMap = <String, Object>{};

    for (var i = 0; i < argNames.length; i++) {
      argsMap.putIfAbsent(argNames.elementAt(i), () => argsValues.elementAt(i));
    }

    return argsMap;
  }
}
