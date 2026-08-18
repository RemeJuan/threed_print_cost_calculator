import 'package:purchases_flutter/purchases_flutter.dart';

Package? preferredPaywallPackage(List<Package>? packages) {
  if (packages == null || packages.isEmpty) return null;
  return packages.firstWhere(
    (pkg) => pkg.packageType == PackageType.annual,
    orElse: () => packages.first,
  );
}
