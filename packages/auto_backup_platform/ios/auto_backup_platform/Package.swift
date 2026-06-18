// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "auto_backup_platform",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(
      name: "auto-backup-platform",
      targets: ["auto_backup_platform"]
    ),
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    .target(
      name: "auto_backup_platform",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ]
    ),
  ]
)
