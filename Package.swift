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
            targets: ["PrebidMobile"]),

        .library(
            name: "PrebidMobileAdditional",
            targets: ["PrebidMobileAdditional"]),

        .library(
            name: "SomeLibbraryName",
            targets: ["PrebidMobileAdditional2"])
        
            
    ],

    targets: [
        .target(
            name: "PrebidMobile",
            path: "PrebidMobile"
        ),
        
        .target(
            name: "PrebidMobileAdditional",
            dependencies: [
                "PrebidMobile"
            ],
            path: "PrebidMobileAdditional"
        ),
        
        .target(
            name: "PrebidMobileAdditional2",
            dependencies: [
                "PrebidMobile"
            ],
            path: "PrebidMobileAdditional2"
        )
    ],
    
    swiftLanguageVersions: [.v5]

)
