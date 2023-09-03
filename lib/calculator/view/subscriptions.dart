import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Subscriptions extends HookWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    final processing = useState<bool>(false);

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Offerings',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        if (processing.value)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final package = offerings.data!.current!.availablePackages
                          .elementAt(index);
                      return ListTile(
                        title: Text(
                          package.storeProduct.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          package.storeProduct.description,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        trailing: Text(
                          package.storeProduct.priceString,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        enabled: !processing.value,
                        onTap: () async {
                          processing.value = true;
                          try {
                            await Purchases.purchasePackage(package)
                                .then((value) => Navigator.pop(context));
                          } on PlatformException catch (e) {
                            debugPrint(e.toString());
                            BotToast.showSimpleNotification(
                              title:
                                  // ignore: lines_longer_than_80_chars
                                  'There was an error processing your purchase. '
                                  'Please try again later.',
                              duration: const Duration(seconds: 5),
                              align: Alignment.bottomCenter,
                            );
                          }
                          processing.value = false;
                        },
                      );
                    },
                    childCount:
                        offerings.data!.current!.availablePackages.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RawMaterialButton(
                      onPressed: () async {
                        await Purchases.restorePurchases();
                      },
                      child: Text(
                        'Restore Purchases',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 16,
                                ),
                      ),
                    ),
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
