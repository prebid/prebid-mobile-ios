// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    name: "PrebidMobile",

    platforms: [
        .iOS(.v10)
    ],
    
    products: [
        
        .library(
            name: "PrebidMobile",
            targets: ["PrebidMobile"])
    ],

    targets: [
        .target(
            name: "PrebidMobile",
            path: "PrebidMobile"
        )
    ],
    
    swiftLanguageVersions: [.v5]

)
