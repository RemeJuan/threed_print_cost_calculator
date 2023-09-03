import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdContainer extends HookWidget {
  const AdContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerAd = useState<BannerAd?>(null);
    final bannerAdIsLoaded = useState(false);

    useEffect(
      () {
        const android = kDebugMode
            ? 'ca-app-pub-3940256099942544/6300978111'
            : 'ca-app-pub-5128251160825100/5787545814';
        const ios = kDebugMode
            ? 'ca-app-pub-3940256099942544/2934735716'
            : 'ca-app-pub-5128251160825100/8919037816';

        final adUnitId = Platform.isAndroid ? android : ios;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(seconds: 1), () {
            bannerAd.value = BannerAd(
              adUnitId: adUnitId,
              request: const AdRequest(),
              size: AdSize.banner,
              listener: BannerAdListener(
                // Called when an ad is successfully received.
                onAdLoaded: (ad) {
                  debugPrint('$ad loaded.');
                  bannerAdIsLoaded.value = true;
                },
                // Called when an ad request failed.
                onAdFailedToLoad: (ad, error) {
                  debugPrint('BannerAd failed to load: $error');
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
              ),
            )..load();
          });
        });

        return null;
      },
      [],
    );

    if (!bannerAdIsLoaded.value) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320, // minimum recommended width
        minHeight: 50, // minimum recommended height
        maxWidth: 320,
        maxHeight: 50,
      ),
      child: AdWidget(ad: bannerAd.value!),
    );
  }
}
