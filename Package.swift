// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    
    name: "NativoPrebidSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "NativoPrebidSDK",
            targets: ["NativoPrebidSDK", "__PrebidMobileInternal"]
        ),
        .library(
            name: "NativoPrebidSDKAdMobAdapters",
            targets: ["NativoPrebidSDKAdMobAdapters"]
        ),
        .library(
            name: "NativoPrebidSDKGAMEventHandlers",
            targets: ["NativoPrebidSDKGAMEventHandlers"]
        ),
        .library(
            name: "NativoPrebidSDKMAXAdapters",
            targets: ["NativoPrebidSDKMAXAdapters"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            "12.0.0"..<"14.0.0"
        ),
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", .upToNextMajor(from: "13.0.0")),
    ],
    targets: [
        .target(
            name: "NativoPrebidSDK",
            path: "PrebidMobile",
            sources: ["Swift"]
        ),
        .target(
            name: "__PrebidMobileInternal",
            dependencies: [
                "NativoPrebidSDK",
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
            name: "NativoPrebidSDKAdMobAdapters",
            dependencies: [
                "NativoPrebidSDK",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "EventHandlers/PrebidMobileAdMobAdapters",
            sources: ["Sources"]
        ),
        .target(
            name: "NativoPrebidSDKGAMEventHandlers",
            dependencies: [
                "NativoPrebidSDK",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "EventHandlers/PrebidMobileGAMEventHandlers",
            sources: ["Sources"]
        ),
        .target(
            name: "NativoPrebidSDKMAXAdapters",
            dependencies: [
                "NativoPrebidSDK",
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
            ],
            path: "EventHandlers/PrebidMobileMAXAdapters",
            sources: ["Sources"]
        ),
    ]
)
