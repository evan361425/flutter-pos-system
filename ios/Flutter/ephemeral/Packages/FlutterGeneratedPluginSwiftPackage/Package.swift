// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "file_picker_darwin", path: "../.packages/file_picker_darwin-2.4.2"),
        .package(name: "firebase_analytics", path: "../.packages/firebase_analytics-12.6.1"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-6.7.1"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.15.2"),
        .package(name: "firebase_crashlytics", path: "../.packages/firebase_crashlytics-5.4.1"),
        .package(name: "firebase_in_app_messaging", path: "../.packages/firebase_in_app_messaging-0.9.5"),
        .package(name: "firebase_performance", path: "../.packages/firebase_performance-0.11.7"),
        .package(name: "flutter_blue_plus_darwin", path: "../.packages/flutter_blue_plus_darwin-9.0.5"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios-6.4.0"),
        .package(name: "image_cropper", path: "../.packages/image_cropper-13.0.0"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.13"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-10.2.2"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.4.1"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.4"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin-2.4.5"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.3.2"),
        .package(name: "wakelock_plus", path: "../.packages/wakelock_plus-1.8.0"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "file-picker-darwin", package: "file_picker_darwin"),
                .product(name: "firebase-analytics", package: "firebase_analytics"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-in-app-messaging", package: "firebase_in_app_messaging"),
                .product(name: "firebase-performance", package: "firebase_performance"),
                .product(name: "flutter-blue-plus-darwin", package: "flutter_blue_plus_darwin"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "image-cropper", package: "image_cropper"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "wakelock-plus", package: "wakelock_plus"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
