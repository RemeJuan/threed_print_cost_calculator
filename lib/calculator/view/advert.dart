import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdContainer extends HookWidget {
  const AdContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final nativeAd = useState<NativeAd?>(null);
    final nativeAdIsLoaded = useState(false);

    useEffect(
      () {
        final adUnitId = Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/2247696110'
            : 'ca-app-pub-3940256099942544/3986624511';

        nativeAd.value = NativeAd(
          adUnitId: adUnitId,
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              debugPrint('$NativeAd loaded.');
              nativeAdIsLoaded.value = true;
            },
            onAdFailedToLoad: (ad, error) {
              // Dispose the ad here to free resources.
              debugPrint('$NativeAd failed to load: $error');
              ad.dispose();
            },
          ),
          request: const AdRequest(),
          // Styling
          nativeTemplateStyle: NativeTemplateStyle(
            // Required: Choose a template.
            templateType: TemplateType.small,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10,
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: Colors.cyan,
              backgroundColor: Colors.red,
              style: NativeTemplateFontStyle.monospace,
              size: 16,
            ),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.red,
              backgroundColor: Colors.cyan,
              style: NativeTemplateFontStyle.italic,
              size: 16,
            ),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.green,
              backgroundColor: Colors.black,
              style: NativeTemplateFontStyle.bold,
              size: 16,
            ),
            tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: Colors.brown,
              backgroundColor: Colors.amber,
              style: NativeTemplateFontStyle.normal,
              size: 16,
            ),
          ),
        )..load();
        return null;
      },
      [],
    );

    if (!nativeAdIsLoaded.value) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320, // minimum recommended width
        minHeight: 90, // minimum recommended height
        maxWidth: 400,
        maxHeight: 200,
      ),
      child: AdWidget(ad: nativeAd.value!),
    );
  }
}
