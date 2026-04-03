import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

class HeaderActions extends ConsumerWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: isPremium
          ? const SizedBox.shrink()
          : IconButton(
              onPressed: () async => showModalBottomSheet(
                context: context,
                builder: (_) => const Subscriptions(),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.white54),
            ),
    );
  }
}
