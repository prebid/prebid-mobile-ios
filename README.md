[![Build Status](https://api.travis-ci.org/prebid/prebid-mobile-ios.svg?branch=master)](https://travis-ci.org/prebid/prebid-mobile-ios)

# Prebid Mobile iOS SDK

Get started with Prebid Mobile by creating a Prebid Server account [here](http://prebid.org/prebid-mobile/prebid-mobile-pbs.html)

## Use Cocoapods?

Easily include the Prebid Mobile SDK for your priamy ad server in your Podfile/

```
platform :ios, '8.0'

target 'MyAmazingApp' do 
    pod 'PrebidMobile'
end
```

## Build framework from source

Build Prebid Mobile from source code. After cloning the repo, from the root directory run

```
./scripts/buildPrebidMobile.sh
```

to output the PrebidMobileForDFP & PrebidMobileForMoPub frameworks.


## Test Prebid Mobile

Run the test script to run unit tests and integration tests.

```
./scripts/testPrebidMobile.sh
```
