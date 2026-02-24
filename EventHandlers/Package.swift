// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
    name: "PrebidMobileAdapters",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "PrebidMobileAdMobAdapters",
            targets: ["PrebidMobileAdMobAdapters"]
        ),
        .library(
            name: "PrebidMobileGAMEventHandlers",
            targets: ["PrebidMobileGAMEventHandlers"]
        ),
        .library(
            name: "PrebidMobileMAXAdapters",
            targets: ["PrebidMobileMAXAdapters"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/prebid/prebid-mobile-ios-sdk.git", .upToNextMajor(from: "3.2.0"))
    ],
    targets: [
        .target(
            name: "PrebidMobileAdMobAdapters",
            dependencies: [
                .product(name: "PrebidMobile", package: "prebid-mobile-ios-sdk"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "PrebidMobileAdMobAdapters",
            sources: ["Sources"]
        ),
        .target(
            name: "PrebidMobileGAMEventHandlers",
            dependencies: [
                .product(name: "PrebidMobile", package: "prebid-mobile-ios-sdk"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "PrebidMobileGAMEventHandlers",
            sources: ["Sources"]
        ),
        .target(
            name: "PrebidMobileMAXAdapters",
            dependencies: [
                .product(name: "PrebidMobile", package: "prebid-mobile-ios-sdk"),
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
            ],
            path: "PrebidMobileMAXAdapters",
            sources: ["Sources"]
        ),
    ]
)
