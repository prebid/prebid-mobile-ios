# Prebid Mobile iOS SDK

To work with Prebid Mobile, you will need accesss to a Prebid Server. See [this page](https://docs.prebid.org/prebid-server/overview/prebid-server-overview.html) for options.

## Use Cocoapods?

Easily include the Prebid Mobile SDK for your primary ad server in your Podfile/

```
platform :ios, '11.0'

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

`2.3.0` version is available to build PrebidMobile with Carthage. For that, please, put the following content to your `Cartfile`:

```
github "prebid/prebid-mobile-ios" == 2.3.0-carthage
```
Run this command in order to build PrebidMobile with Carthage:

```
carthage update --use-xcframeworks --platform ios
```
Note that `PrebidMobileGAMEventHandlers`, `PrebidMobileAdMobAdapters`, `PrebidMobileMAXAdapters` are not available to build with Carthage.
