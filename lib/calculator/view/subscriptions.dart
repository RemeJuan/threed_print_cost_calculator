import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Subscriptions extends HookWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Offerings>(
      builder: (_, offerings) {
        if (offerings.connectionState == ConnectionState.done) {
          if (offerings.hasError || offerings.data?.current == null) {
            return Text('Error: ${offerings.error}');
          } else {
            return CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Current Offerings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final package = offerings.data!.current!.availablePackages
                          .elementAt(index);
                      return ListTile(
                        title: Text(package.storeProduct.title),
                        subtitle: Text(package.storeProduct.description),
                        trailing: Text(package.storeProduct.priceString),
                        onTap: () async {
                          try {
                            final purchaserInfo =
                                await Purchases.purchasePackage(package);
                            debugPrint(purchaserInfo.toString());
                          } on PlatformException catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                      );
                    },
                    childCount:
                        offerings.data!.current!.availablePackages.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
      future: Purchases.getOfferings(),
    );
  }
}
