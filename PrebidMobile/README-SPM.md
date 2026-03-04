# PrebidMobile iOS SDK

This repository contains the **PrebidMobile iOS SDK**, split from the main [PrebidMobile](https://github.com/prebid/PrebidMobile) repository.

The **PrebidMobile iOS SDK** package provides the fundamental PrebidMobile functionality required to build header bidding and demand integrations on iOS.

## Installation

### Swift Package Manager

#### Xcode
1. Open your project in Xcode.
2. Go to **File > Add Package Dependencies…**
3. Enter the repository URL:
   ```
   https://github.com/prebid/prebid-mobile-ios-sdk
   ```
4. Select the version of the **PrebidMobile iOS SDK** you want to use. For new projects, we recommend using the `Up to Next Major Version`.
5. In the package selection screen, make sure to check the modules you need for your integration and link it to your application target.

#### Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/prebid/prebid-mobile-ios-sdk",
        .upToNextMajor(from: "x.y.z")
    )
]
```

Add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "PrebidMobile", package: "prebid-mobile-ios-sdk")
    ]
)
```

## Documentation

- [Official docs](https://docs.prebid.org/prebid-mobile/pbm-api/ios/code-integration-ios.html)
- [Demo applications](https://github.com/prebid/prebid-mobile-ios/tree/master/Example/PrebidDemo)

## Issues & support

Please report issues in the main [PrebidMobile repository](https://github.com/prebid/prebid-mobile-ios/issues).

## License

Apache 2.0. See [LICENSE](https://github.com/prebid/prebid-mobile-ios-sdk/blob/main/LICENSE).