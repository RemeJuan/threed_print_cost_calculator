import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/shared/ads/mobile_ads_initializer.dart';
import 'package:threed_print_cost_calculator/shared/ads/revenuecat_ad_revenue_tracker.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

typedef CalculatorBannerAdLoader =
    Future<BannerAd?> Function({
      required String adUnitId,
      required AdSize size,
      required BannerAdListener listener,
    });
typedef CalculatorBannerAdSizeResolver = Future<AdSize?> Function(int width);
typedef CalculatorBannerAdInitializer = Future<void> Function();

class CalculatorBannerAd extends ConsumerStatefulWidget {
  const CalculatorBannerAd({
    super.key,
    this.loader,
    this.sizeResolver,
    this.initializer,
  });

  @visibleForTesting
  final CalculatorBannerAdLoader? loader;

  @visibleForTesting
  final CalculatorBannerAdSizeResolver? sizeResolver;

  @visibleForTesting
  final CalculatorBannerAdInitializer? initializer;

  @override
  ConsumerState<CalculatorBannerAd> createState() => _CalculatorBannerAdState();
}

class _CalculatorBannerAdState extends ConsumerState<CalculatorBannerAd> {
  BannerAd? _ad;
  AdSize? _adSize;
  String? _requestKey;
  String? _failedRequestKey;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        if (width <= 0 || _adUnitId == null) {
          return const SizedBox.shrink();
        }

        final requestKey = '$width-$orientation';
        _loadForWidth(width, orientation, requestKey);

        final ad = _ad;
        final adSize = _adSize;
        if (!_loaded || ad == null || adSize == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: kAppSpace8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CARD_BACKGROUND,
              borderRadius: BorderRadius.circular(kAppSurfaceRadius),
              border: Border.all(color: BORDER_SUBTLE),
            ),
            child: SizedBox(
              width: adSize.width.toDouble(),
              height: adSize.height.toDouble(),
              child: Stack(
                children: [
                  AdWidget(ad: ad),
                  Container(color: APP_BACKGROUND),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _loadForWidth(int width, Orientation orientation, String requestKey) {
    if (_requestKey == requestKey || _failedRequestKey == requestKey) return;

    _disposeAd();
    _requestKey = requestKey;
    _loaded = false;

    () async {
      try {
        await (widget.initializer ?? _initializeMobileAds)();
        if (!mounted || _requestKey != requestKey) return;

        final size =
            await (widget.sizeResolver ??
                AdSize.getLargeAnchoredAdaptiveBannerAdSize)(width);
        if (!mounted || _requestKey != requestKey || size == null) {
          if (mounted && _requestKey == requestKey && size == null) {
            _failedRequestKey = requestKey;
          }
          return;
        }

        final ad = await (widget.loader ?? _loadAd)(
          adUnitId: _adUnitId!,
          size: size,
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              if (!mounted || _requestKey != requestKey) return;
              setState(() => _loaded = true);
            },
            onPaidEvent: (ad, valueMicros, precision, currencyCode) {
              final responseInfo = ad.responseInfo;
              unawaited(
                trackAdMobBannerRevenue(
                  adUnitId: ad.adUnitId,
                  valueMicros: valueMicros,
                  precisionType: precision,
                  currencyCode: currencyCode,
                  impressionId: responseInfo?.responseId,
                  networkName:
                      responseInfo?.loadedAdapterResponseInfo?.adSourceName,
                  placement: kCalculatorBannerAdPlacement,
                ),
              );
            },
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              if (!mounted || _requestKey != requestKey) return;
              setState(() {
                _failedRequestKey = requestKey;
                _ad = null;
                _adSize = null;
                _loaded = false;
              });
            },
          ),
        );
        if (!mounted || _requestKey != requestKey || ad == null) {
          ad?.dispose();
          if (mounted && _requestKey == requestKey && ad == null) {
            _failedRequestKey = requestKey;
          }
          return;
        }
        _ad = ad;
        _adSize = size;
      } catch (_) {
        if (mounted && _requestKey == requestKey) {
          setState(() => _failedRequestKey = requestKey);
        }
      }
    }();
  }

  Future<BannerAd?> _loadAd({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
  }) async {
    final ad = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: listener,
    );
    ad.load();
    return ad;
  }

  Future<void> _initializeMobileAds() async {
    await ensureMobileAdsInitialized();
  }

  String? get _adUnitId {
    if (kIsWeb) return null;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/9214589741'
          : 'ca-app-pub-5128251160825100/5787545814';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2435281174'
          : 'ca-app-pub-5128251160825100/8919037816';
    }
    // Test loaders can exercise gating on desktop hosts without attempting a
    // platform ad request.
    return widget.loader == null
        ? null
        : 'ca-app-pub-3940256099942544/6300978111';
  }

  void _disposeAd({bool resetRequest = false}) {
    _ad?.dispose();
    _ad = null;
    _adSize = null;
    _loaded = false;
    if (resetRequest) {
      _requestKey = null;
      _failedRequestKey = null;
    }
  }

  @override
  void dispose() {
    _requestKey = null;
    _disposeAd();
    super.dispose();
  }
}
