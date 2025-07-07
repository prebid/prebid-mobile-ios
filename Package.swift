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
            targets: ["PrebidMobile", "PrebidMobileObjc"]
        ),
    ],
    targets: [
        .target(
            name: "PrebidMobile",
            path: "PrebidMobile",
            sources: ["Swift"]
        ),
        .target(
            name: "PrebidMobileObjc",
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
    ]
)
