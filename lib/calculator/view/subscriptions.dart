import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class Subscriptions extends HookWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    final processing = useState<bool>(false);
    final linkFont = Theme.of(
      context,
    ).textTheme.displayMedium?.copyWith(fontSize: 12);
    final l10n = S.of(context);

    return FutureBuilder<Offerings>(
      builder: (_, offerings) {
        if (offerings.connectionState == ConnectionState.done) {
          if (offerings.hasError || offerings.data?.current == null) {
            return Text('${l10n.offeringsError}${offerings.error}');
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
                          l10n.currentOfferings,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        if (processing.value)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                            final purchaseParams = PurchaseParams.package(
                              package,
                            );

                            final result = await Purchases.purchase(
                              purchaseParams,
                            );

                            dynamic customerInfo;

                            try {
                              customerInfo =
                                  (result as dynamic).customerInfo ??
                                  (result as dynamic).purchaserInfo ??
                                  result;
                            } catch (_) {
                              customerInfo = result;
                            }

                            if (customerInfo != null) {
                              Navigator.pop(context);
                            }
                          } on PlatformException catch (e) {
                            debugPrint(e.toString());

                            final lowerMessage = (e.message ?? '')
                                .toString()
                                .toLowerCase();
                            final isCancelled = lowerMessage.contains('cancel');

                            if (!isCancelled) {
                              BotToast.showSimpleNotification(
                                title: l10n.purchaseError,
                                duration: const Duration(seconds: 5),
                                align: Alignment.bottomCenter,
                              );
                            }
                          } finally {
                            processing.value = false;
                          }
                        },
                      );
                    },
                    childCount:
                        offerings.data?.current?.availablePackages.length ?? 0,
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
                        l10n.restorePurchases,
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: RawMaterialButton(
                          onPressed: () async {
                            await launchUrl(
                              Uri.parse(
                                'https://github.com/RemeJuan/threed_print_cost_calculator/blob/main/privacy_policy.md',
                              ),
                            );
                          },
                          child: Text(l10n.privacyPolicyLink, style: linkFont),
                        ),
                      ),
                      Text(l10n.separator, style: linkFont),
                      Container(
                        alignment: Alignment.center,
                        child: RawMaterialButton(
                          onPressed: () async {
                            await launchUrl(
                              Uri.parse(
                                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                              ),
                            );
                          },
                          child: Text(l10n.termsOfUseLink, style: linkFont),
                        ),
                      ),
                    ],
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
