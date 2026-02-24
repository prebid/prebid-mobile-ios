// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
    name: "PrebidMobile",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "PrebidMobile",
            targets: ["PrebidMobile", "__PrebidMobileInternal"]
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
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", .upToNextMajor(from: "13.0.0")),
    ],
    targets: [
        .target(
            name: "PrebidMobile",
            path: "PrebidMobile",
            sources: ["Swift"]
        ),
        .target(
            name: "__PrebidMobileInternal",
            dependencies: [
                "PrebidMobile",
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
