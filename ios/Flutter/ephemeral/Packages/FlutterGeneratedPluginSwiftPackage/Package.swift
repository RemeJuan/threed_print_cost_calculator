// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "integration_test", path: "../.packages/integration_test"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.1"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-10.1.0"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "share_plus", path: "../.packages/share_plus-13.1.0"),
        .package(name: "rate_my_app", path: "../.packages/rate_my_app-2.4.0"),
        .package(name: "purchases_ui_flutter", path: "../.packages/purchases_ui_flutter-10.2.3"),
        .package(name: "purchases_flutter", path: "../.packages/purchases_flutter-10.2.3"),
        .package(name: "flutter_secure_storage_darwin", path: "../.packages/flutter_secure_storage_darwin-0.3.2"),
        .package(name: "flutter_email_sender_method_channel", path: "../.packages/flutter_email_sender_method_channel-1.0.0"),
        .package(name: "firebase_crashlytics", path: "../.packages/firebase_crashlytics-5.2.3"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.10.0"),
        .package(name: "firebase_app_check", path: "../.packages/firebase_app_check-0.4.4+2"),
        .package(name: "firebase_analytics", path: "../.packages/firebase_analytics-12.4.2"),
        .package(name: "file_selector_ios", path: "../.packages/file_selector_ios-0.5.3+5"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "integration-test", package: "integration_test"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "share-plus", package: "share_plus"),
                .product(name: "rate-my-app", package: "rate_my_app"),
                .product(name: "purchases-ui-flutter", package: "purchases_ui_flutter"),
                .product(name: "purchases-flutter", package: "purchases_flutter"),
                .product(name: "flutter-secure-storage-darwin", package: "flutter_secure_storage_darwin"),
                .product(name: "flutter-email-sender-method-channel", package: "flutter_email_sender_method_channel"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-app-check", package: "firebase_app_check"),
                .product(name: "firebase-analytics", package: "firebase_analytics"),
                .product(name: "file-selector-ios", package: "file_selector_ios"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
