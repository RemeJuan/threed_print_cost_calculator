import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class PaywallPlanSelector extends StatelessWidget {
  const PaywallPlanSelector({
    super.key,
    required this.packages,
    required this.selectedPackage,
    required this.onSelectPackage,
  });

  final List<Package> packages;
  final Package? selectedPackage;
  final ValueChanged<Package> onSelectPackage;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: kAppSpace8),
        child: Text(
          AppLocalizations.of(context)!.paywallEmptyOfferings,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: TEXT_SECONDARY),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < packages.length; i++) ...[
          _PlanCard(
            package: packages[i],
            selected: selectedPackage?.identifier == packages[i].identifier,
            onTap: () => onSelectPackage(packages[i]),
          ),
          if (i != packages.length - 1) const SizedBox(height: kAppSpace8),
        ],
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final Package package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recommended = package.packageType == PackageType.annual;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? LIGHT_BLUE.withValues(alpha: 0.08) : CARD_BACKGROUND,
        borderRadius: BorderRadius.circular(kAppSurfaceRadius),
        border: Border.all(
          color: selected ? LIGHT_BLUE : SHELL_BORDER,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(kAppSurfaceRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(kAppSpace12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? LIGHT_BLUE : TEXT_TERTIARY,
                  ),
                ),
                const SizedBox(width: kAppSpace12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              planTitle(package, l10n),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? TEXT_PRIMARY
                                        : TEXT_SECONDARY,
                                  ),
                            ),
                          ),
                          if (recommended) _bestValueChip(context, l10n),
                          if (recommended) const SizedBox(width: 8),
                          Text(
                            planPriceLine(package, l10n),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: selected ? LIGHT_BLUE : TEXT_PRIMARY,
                                ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        planMetaLine(package, l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: selected ? TEXT_SECONDARY : TEXT_TERTIARY,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bestValueChip(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: LIGHT_BLUE.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(kAppPillRadius),
      ),
      child: Text(
        l10n.paywallBestValue,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: LIGHT_BLUE,
        ),
      ),
    );
  }
}

Package? preferredPackage(List<Package>? packages) {
  if (packages == null || packages.isEmpty) return null;
  return packages.firstWhere(
    (pkg) => pkg.packageType == PackageType.annual,
    orElse: () => packages.first,
  );
}

String planTitle(Package pkg, AppLocalizations l10n) {
  return switch (pkg.packageType) {
    PackageType.monthly => l10n.paywallPlanMonthly,
    PackageType.threeMonth => l10n.paywallPlanQuarterly,
    PackageType.annual => l10n.paywallPlanAnnual,
    PackageType.lifetime => l10n.paywallPlanLifetime,
    _ => pkg.storeProduct.title,
  };
}

String planPriceLine(Package pkg, AppLocalizations l10n) {
  final price = pkg.storeProduct.priceString;
  return switch (pkg.packageType) {
    PackageType.monthly => l10n.paywallPlanPriceMonthly(price),
    PackageType.threeMonth => l10n.paywallPlanPriceQuarterly(price),
    PackageType.annual => l10n.paywallPlanPriceAnnual(price),
    PackageType.lifetime => l10n.paywallPlanPriceLifetime(price),
    _ => price,
  };
}

String planMetaLine(Package pkg, AppLocalizations l10n) {
  final parts = <String>[];

  switch (pkg.packageType) {
    case PackageType.lifetime:
      parts.add(l10n.paywallPlanOwnForever);
      break;
    case PackageType.annual:
      parts.add(l10n.paywallPlanTrial);
      break;
    case PackageType.monthly || PackageType.twoMonth || PackageType.threeMonth:
      parts.add(l10n.paywallPlanCancelAnytime);
      break;
    default:
      break;
  }

  return parts.join(' • ');
}

String ctaLabel(AppLocalizations l10n, Package? pkg) {
  if (pkg == null) return l10n.paywallCta;
  return switch (pkg.packageType) {
    PackageType.annual => l10n.paywallCtaAnnualTrial,
    PackageType.threeMonth => l10n.paywallCtaQuarterly(
      pkg.storeProduct.priceString,
    ),
    PackageType.lifetime => l10n.paywallCtaLifetime(
      pkg.storeProduct.priceString,
    ),
    _ => l10n.paywallCtaGeneric(pkg.storeProduct.priceString),
  };
}
