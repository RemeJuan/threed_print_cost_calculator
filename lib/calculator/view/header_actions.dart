import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';

class HeaderActions extends StatelessWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerInfo>(
      builder: (_, info) {
        if (info.connectionState == ConnectionState.done) {
          if (info.hasError) {
            return const Icon(Icons.question_mark);
          } else {
            if (info.data?.entitlements.all['Premium']?.isActive ?? false) {
              return const Icon(Icons.check_circle);
            } else {
              return IconButton(
                onPressed: () async => showModalBottomSheet(
                  context: context,
                  builder: (_) => const Subscriptions(),
                ),
                icon: const Icon(Icons.attach_money_sharp),
              );
            }
          }
        } else {
          return Container(
            margin: const EdgeInsets.only(right: 16),
            width: 24,
            height: 24,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }
      },
      future: Purchases.getCustomerInfo(),
    );
  }
}
