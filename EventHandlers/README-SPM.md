# PrebidMobile Adapters SDK

This repository contains mediation adapters and event handlers for PrebidMobile iOS, split from the main [PrebidMobile](https://github.com/prebid/PrebidMobile) repository.
Adapters extend **PrebidMobile iOS SDK** to integrate with mediation platforms and ad servers such as GAM, AdMob, and MAX.

## Installation

### Swift Package Manager

#### Xcode
1. Open your project in Xcode.
2. Go to **File > Add Package Dependencies…**
3. Enter the repository URL:
   ```
   https://github.com/prebid/prebid-mobile-ios-sdk
   ```
4. Select the version of the **PrebidMobile Adapters SDK** you want to use. For new projects, we recommend using the `Up to Next Major Version`.
5. In the package selection screen, make sure to check only the adapter products you need for your integration and link it to your application target.

#### Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/prebid/prebid-mobile-ios-adapters",
        .upToNextMajor(from: "x.y.z")
    )
]
```

Add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "PrebidMobileGAMEventHandlers", package: "prebid-mobile-ios-adapters"),
        .product(name: "PrebidMobileAdMobAdapters", package: "prebid-mobile-ios-adapters")

    ]
)
```

## Documentation

- [Official docs](https://docs.prebid.org/prebid-mobile/pbm-api/ios/code-integration-ios.html) 
- [Demo applications](https://github.com/prebid/prebid-mobile-ios/tree/master/Example/PrebidDemo)

## Issues & support

Please report issues in the main [PrebidMobile repository](https://github.com/prebid/prebid-mobile-ios/issues).

## License

Apache 2.0. See [LICENSE](https://github.com/prebid/prebid-mobile-ios-adapters/blob/main/LICENSE).