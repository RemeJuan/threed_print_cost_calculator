import 'dart:async' show Timer;

import 'package:flutter/material.dart';

// ignore_for_file:implementation_imports
import 'package:intl/src/intl_helpers.dart';

import 'app.dart';
import 'auth.dart';
import 'intro.dart';
import 'loading.dart';
import 'success.dart';
import 'error_token.dart';
import 'error_unknown.dart';
import '../api/api.dart';
import '../proxy/in_context_editing_proxy.dart';
import '../model/translation_change_typed.dart';
import '../model/in_context_editing_data.dart';
import '../../sdk_data.dart';
import '../../common/util/util.dart';

enum InContextEditingPhase {
  intro,
  auth,
  loading,
  success,
  errorToken,
  errorUnknown,
  connected,
  skip,
}

class LocalizelyInContextEditing extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const LocalizelyInContextEditing({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<LocalizelyInContextEditing> createState() =>
      _LocalizelyInContextEditingState();
}

class _LocalizelyInContextEditingState
    extends State<LocalizelyInContextEditing> {
  InContextEditingPhase _inContextEditingPhase = InContextEditingPhase.intro;
  Timer? _timer;

  void _handleSkipClick() {
    setState(() {
      _inContextEditingPhase = InContextEditingPhase.skip;
    });
  }

  void _handleBackClick() {
    closeWebSocket();
    _timer?.cancel();

    setState(() {
      _inContextEditingPhase = InContextEditingPhase.intro;
    });
  }

  void _handleProceedClick() {
    setState(() {
      _inContextEditingPhase = InContextEditingPhase.auth;
    });
  }

  void _handleTokenSubmit(String token) {
    final String sdkVersion = Util.getSdkBuildNumber();

    openWebSocket(
      token: token,
      sdkVersion: sdkVersion,
      onData: (TranslationChangeTyped translationChangeTyped) {
        SdkData.inContextEditingData ??= InContextEditingData();
        SdkData.inContextEditingData!.add(translationChangeTyped);

        _update();
      },
      onError: (Object error) {
        setState(() {
          _inContextEditingPhase = InContextEditingPhase.errorUnknown;
        });
      },
      onDone: (int? closeCode) {
        setState(() {
          _inContextEditingPhase = closeCode == 4401
              ? InContextEditingPhase.errorToken
              : InContextEditingPhase.errorUnknown;

          SdkData.inContextEditingData = null;
        });
      },
    );

    setState(() {
      _inContextEditingPhase = InContextEditingPhase.loading;

      _timer = Timer(Duration(milliseconds: 1000), () {
        if (_inContextEditingPhase == InContextEditingPhase.loading) {
          setState(() {
            _inContextEditingPhase = InContextEditingPhase.success;

            _timer = Timer(Duration(milliseconds: 1400), () {
              if (_inContextEditingPhase == InContextEditingPhase.success) {
                setState(() {
                  _inContextEditingPhase = InContextEditingPhase.connected;
                });
              }
            });
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      messageLookup = MessageLookupProxy.from(messageLookup);
    }
  }

  @override
  void dispose() {
    closeWebSocket();
    _timer?.cancel();
    super.dispose();
  }

  void _update() {
    (context as Element).visitChildren(_rebuild);
  }

  // Rebuild widget tree (a similar approach is used in reassemble method - hot reload)
  void _rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(_rebuild);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled ||
        _inContextEditingPhase == InContextEditingPhase.connected ||
        _inContextEditingPhase == InContextEditingPhase.skip) {
      return widget.child;
    }

    return App(
      child: Builder(
        builder: (context) {
          switch (_inContextEditingPhase) {
            case InContextEditingPhase.intro:
              return Intro(
                onSkip: _handleSkipClick,
                onProceed: _handleProceedClick,
              );
            case InContextEditingPhase.auth:
              return Auth(onSubmit: _handleTokenSubmit);
            case InContextEditingPhase.loading:
              return Loading();
            case InContextEditingPhase.success:
              return Success();
            case InContextEditingPhase.errorToken:
              return ErrorToken(onBack: _handleBackClick);
            default:
              return ErrorUnknown(onBack: _handleBackClick);
          }
        },
      ),
    );
  }
}
