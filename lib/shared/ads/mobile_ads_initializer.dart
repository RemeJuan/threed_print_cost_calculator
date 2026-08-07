import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef MobileAdsInitializationErrorReporter =
    void Function(Object error, StackTrace stackTrace);

Future<InitializationStatus>? _mobileAdsInitialization;
MobileAdsInitializationErrorReporter? _mobileAdsErrorReporter;

Future<InitializationStatus> ensureMobileAdsInitialized({
  MobileAdsInitializationErrorReporter? reportError,
}) {
  _mobileAdsErrorReporter ??= reportError;
  return _mobileAdsInitialization ??= _initializeMobileAds();
}

Future<InitializationStatus> _initializeMobileAds() async {
  try {
    return await MobileAds.instance.initialize();
  } catch (error, stackTrace) {
    _mobileAdsErrorReporter?.call(error, stackTrace);
    rethrow;
  }
}

@visibleForTesting
void resetMobileAdsInitializationForTesting() {
  _mobileAdsInitialization = null;
  _mobileAdsErrorReporter = null;
}
