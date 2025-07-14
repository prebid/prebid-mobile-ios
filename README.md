# Prebid Mobile iOS SDK

To work with Prebid Mobile, you will need accesss to a Prebid Server. See [this page](https://docs.prebid.org/prebid-server/overview/prebid-server-overview.html) for options.

## Use SPM?

Starting from version `3.1.0`, PrebidMobile supports Swift Package Manager (SPM), making integration much easier and more maintainable compared to manual setups or CocoaPods.

To [add the Prebid Mobile SDK package dependency](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#Add-a-package-dependency) using SPM, follow these steps:

1. In Xcode, install the Prebid Mobile SDK by navigating to File > Add Package Dependencies...
2. In the prompt that appears, search for the Prebid Mobile SDK GitHub repository:
    ```
    https://github.com/prebid/prebid-mobile-ios.git
    ```
3. Select the version of the Prebid Mobile SDK you want to use. For new projects, we recommend using the Up to Next Major Version.
4. In the package selection screen, make sure to check the modules you need for your integration and link it to your application target.

## Use Cocoapods?

Easily include the Prebid Mobile SDK for your primary ad server in your Podfile/

```
platform :ios, '12.0'

target 'MyAmazingApp' do 
    pod 'PrebidMobile'
end
```

## Build framework from source

Build Prebid Mobile from source code. After cloning the repo, from the root directory run

```
./scripts/buildPrebidMobile.sh
```

to output the Prebid Mobile framework.


## Test Prebid Mobile

Run the test script to run unit tests and integration tests.

```
./scripts/testPrebidMobile.sh
```


## Carthage

`3.0.2` version is available to build PrebidMobile with Carthage. For that, please, put the following content to your `Cartfile`:

```
github "prebid/prebid-mobile-ios" == 3.0.2-carthage
```
Run this command in order to build PrebidMobile with Carthage:

```
carthage update --use-xcframeworks --platform ios
```
Note that `PrebidMobileGAMEventHandlers`, `PrebidMobileAdMobAdapters`, `PrebidMobileMAXAdapters` are not available to build with Carthage.
