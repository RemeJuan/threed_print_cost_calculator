import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';

class HeaderActions extends HookWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = useState<bool>(false);

    useEffect(
      () {
        Purchases.addCustomerInfoUpdateListener((info) {
          premium.value = info.entitlements.active.isNotEmpty;
        });
      },
      [],
    );

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: premium.value
          ? const SizedBox.shrink()
          : IconButton(
              onPressed: () async => showModalBottomSheet(
                context: context,
                builder: (_) => const Subscriptions(),
              ),
              icon: const Icon(
                Icons.attach_money_sharp,
                color: Colors.white54,
              ),
            ),
    );
  }
}
