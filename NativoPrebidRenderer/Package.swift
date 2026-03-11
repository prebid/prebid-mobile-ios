// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NativoPrebidRenderer",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NativoPrebidRenderer",
            targets: ["NativoPrebidRenderer"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/prebid/prebid-mobile-ios-sdk.git", .upToNextMajor(from: "3.3.0"))
    ],
    targets: [
        .target(
            name: "NativoPrebidRenderer",
            dependencies: [
                .product(name: "PrebidMobile", package: "prebid-mobile-ios-sdk")
            ]
        )
    ]
)
