import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_banner_ad.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';

class _FixedPremiumStateNotifier extends PremiumStateNotifier {
  _FixedPremiumStateNotifier(this.value);

  final PremiumState value;

  @override
  PremiumState build() => value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setupTest);

  Future<void> pumpBanner(
    WidgetTester tester,
    PremiumState state, {
    CalculatorBannerAdLoader? loader,
    CalculatorBannerAdSizeResolver? sizeResolver,
    CalculatorBannerAdInitializer? initializer,
  }) {
    return tester.pumpApp(
      CalculatorBannerAd(
        loader: loader,
        sizeResolver: sizeResolver,
        initializer: initializer,
      ),
      [
        premiumStateProvider.overrideWith(
          () => _FixedPremiumStateNotifier(state),
        ),
      ],
    );
  }

  testWidgets('suppresses banner while premium state resolves', (tester) async {
    await pumpBanner(tester, const PremiumState.loading());

    expect(find.byType(AdWidget), findsNothing);
  });

  testWidgets('suppresses banner for premium users', (tester) async {
    await pumpBanner(
      tester,
      const PremiumState(isPremium: true, isLoading: false),
    );

    expect(find.byType(AdWidget), findsNothing);
  });

  testWidgets('requests banner only after free state resolves', (tester) async {
    var requests = 0;
    await pumpBanner(
      tester,
      const PremiumState(isPremium: false, isLoading: false),
      initializer: () async {},
      loader: ({required adUnitId, required size, required listener}) async {
        requests++;
        return null;
      },
      sizeResolver: (width) async => const AdSize(width: 320, height: 50),
    );
    await tester.pumpAndSettle();

    expect(requests, 1);
    expect(find.byType(AdWidget), findsNothing);
  });
}
