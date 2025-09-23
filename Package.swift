// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    name: "VeonPrebidMobile",

    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "VeonPrebidMobile",
            targets: ["VeonPrebidMobile", "__VeonPrebidMobileInternal"]
        ),
        .library(
            name: "VeonPrebidMobileAdMobAdapters",
            targets: ["VeonPrebidMobileAdMobAdapters"]
        ),
        .library(
            name: "VeonPrebidMobileGAMEventHandlers",
            targets: ["VeonPrebidMobileGAMEventHandlers"]
        ),
        .library(
            name: "VeonPrebidMobileMAXAdapters",
            targets: ["VeonPrebidMobileMAXAdapters"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "12.0.0")),
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", .upToNextMajor(from: "13.0.0")),
    ],
    targets: [
        .target(
            name: "VeonPrebidMobile",
            path: "PrebidMobile",
            sources: ["Swift"]
        ),
        .target(
            name: "__VeonPrebidMobileInternal",
            dependencies: [
                "VeonPrebidMobile",
                "PrebidMobileOMSDK",
            ],
            path: "PrebidMobile",
            sources: ["Objc"],
            cSettings: [
                .headerSearchPath("./Objc/PrivateHeaders"),
                .define("PrebidMobile_SPM", to: "1"),
            ]
        ),
        .binaryTarget(
            name: "PrebidMobileOMSDK",
            path: "Frameworks/OMSDK_Prebidorg.xcframework"
        ),
        .target(
            name: "VeonPrebidMobileAdMobAdapters",
            dependencies: [
                "VeonPrebidMobile",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "EventHandlers/PrebidMobileAdMobAdapters",
            sources: ["Sources"]
        ),
        .target(
            name: "VeonPrebidMobileGAMEventHandlers",
            dependencies: [
                "VeonPrebidMobile",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "EventHandlers/PrebidMobileGAMEventHandlers",
            sources: ["Sources"]
        ),
        .target(
            name: "VeonPrebidMobileMAXAdapters",
            dependencies: [
                "VeonPrebidMobile",
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
            ],
            path: "EventHandlers/PrebidMobileMAXAdapters",
            sources: ["Sources"]
        ),
    ]
)
