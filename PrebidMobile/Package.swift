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
    ]
)
