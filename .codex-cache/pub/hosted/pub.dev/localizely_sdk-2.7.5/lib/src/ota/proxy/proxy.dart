// ignore_for_file:implementation_imports
import 'package:intl/src/intl_helpers.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:logger/logger.dart';

import '../../sdk_data.dart';

class MessageLookupProxy implements MessageLookup {
  static final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final MessageLookup _messageLookup;

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
      var labels = SdkData.getData(currentLocale);
      var origArgs = SdkData.getOrigArgs(name);

      if (labels == null ||
          !labels.containsKey(name) ||
          origArgs == null ||
          args == null) {
        return _messageLookup.lookupMessage(
          messageText,
          locale,
          name,
          args,
          meaning,
          ifAbsent: ifAbsent,
        );
      }

      var label = labels[name];
      var labelArgs = label!.getArgs();

      var isLabelArgsValid = _validateLabelArgs(origArgs, labelArgs);
      if (!isLabelArgsValid) {
        _logger.w(
          "String '${label.key}' received Over-the-air for locale '$currentLocale' has unsupported placeholders.",
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

      var argsMap = _mapArgs(origArgs, args);

      var translation = label.getTranslation(argsMap);
      if (translation == null) {
        _logger.w(
          "String '${label.key}' received Over-the-air for locale '$currentLocale' has not-well formatted message.",
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
