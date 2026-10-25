// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
    name: "PrebidMobile",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "PrebidMobile",
            targets: ["PrebidMobile"]
        ),
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
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", exact: "13.11.0"),
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", exact: "13.6.4"),
    ],
    targets: [
        .target(
            name: "PrebidMobile",
            dependencies: [
                "PrebidMobileOMSDK",
            ],
            path: "PrebidMobile",
            sources: ["Swift"]
        ),
        .binaryTarget(
            name: "PrebidMobileOMSDK",
            path: "Frameworks/OMSDK_Prebidorg.xcframework"
        ),
        .target(
            name: "PrebidMobileAdMobAdapters",
            dependencies: [
                "PrebidMobile",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "EventHandlers/PrebidMobileAdMobAdapters",
            sources: ["Sources"]
        ),
        .target(
            name: "PrebidMobileGAMEventHandlers",
            dependencies: [
                "PrebidMobile",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "EventHandlers/PrebidMobileGAMEventHandlers",
            sources: ["Sources"]
        ),
        .target(
            name: "PrebidMobileMAXAdapters",
            dependencies: [
                "PrebidMobile",
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
            ],
            path: "EventHandlers/PrebidMobileMAXAdapters",
            sources: ["Sources"]
        ),
    ]
)
