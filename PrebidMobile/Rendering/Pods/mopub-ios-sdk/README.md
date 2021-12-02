# MoPub iOS SDK

Thanks for taking a look at MoPub! We take pride in having an easy-to-use, flexible monetization solution that works across multiple platforms.

Sign up for an account at [http://app.mopub.com/](http://app.mopub.com/).

## Need Help?

You can find integration documentation on our [developer help site](https://developers.mopub.com/publishers/ios/get-started/).

To file an issue with our team, email [support@mopub.com](mailto:support@mopub.com).

## New Pull Requests?

Thank you for submitting pull requests to the MoPub iOS GitHub repository. Our team regularly monitors and investigates all submissions for inclusion in our official SDK releases. Please note that MoPub does not directly merge these pull requests at this time. Please reach out to your account team or [support@mopub.com](mailto:support@mopub.com) if you have further questions.

## Installation

The MoPub SDK supports multiple methods for installing into a project.

The current version of the SDK is 5.15.0

### Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Swift and Objective-C Cocoa projects, which automates and simplifies the process of using 3rd-party libraries like the MoPub SDK in your projects. You can install it with the following command:

```
$ gem install cocoapods
```

**Podfile**
To integrate MoPub SDK into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
  pod 'mopub-ios-sdk', '~> 5.13'
end
```

Then, run the following command:

```
$ pod install
```

### Manual Integration with Dynamic Framework

MoPub provides a prepackaged archive of the dynamic framework:

- **[MoPub SDK Framework.zip](https://github.com/mopub/mopub-ios-sdk/releases/download/5.15.0/mopub-framework-5.15.0.zip)**

  Includes everything you need to serve HTML, MRAID, and Native MoPub advertisements.  Third party ad networks are not included.

Add the dynamic framework to the target's Embedded Binaries section of the General tab.

### Manual Integration with Source Code

MoPub provides two prepackaged archives of source code:

- **[MoPub Base SDK.zip](https://github.com/mopub/mopub-ios-sdk/releases/download/5.15.0/mopub-base-5.15.0.zip)**

  Includes everything you need to serve HTML, MRAID, and Native MoPub advertisements.  Third party ad networks are not included.

- **[MoPub Base SDK Excluding Native.zip](https://github.com/mopub/mopub-ios-sdk/releases/download/5.15.0/mopub-nonnative-5.15.0.zip)**

  Includes everything you need to serve HTML and MRAID advertisements.  Third party ad networks and Native MoPub advertisements are not included.

## Integrate

Integration instructions are available on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started).

## New in this Version

Please view the [changelog](https://github.com/mopub/mopub-ios-sdk/blob/master/CHANGELOG.md) for details.

- **Features**
  - The MoPub iOS SDK now includes Swift 5.
  - Updated countdown animation background color to black for better visibility.
  - Enforce HTTPS for base URLs.
  - Removed native video support.
  - Add support for Snap Audience Network.

- **Bug Fixes**
  - Fixed bug where app foregrounding was requesting a new banner ad instead of resuming the refresh timer.
  - Fixed bug with animated GIFs in VAST end cards.
  - Fixed bug with scheduled deallocation of HTML Viewability trackers.
  - Fixed `SKStoreProductViewController` causing freezes on iOS 13.0 and 13.1 devices.
  - Fixed bug where attempting to instantiate a mediation adapter that does not exist at runtime will not fire the failure callback.

See the [Getting Started Guide](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started#app-transport-security-settings) for instructions on setting up ATS in your app.

## Upgrading to SDK 5.0

Please see the [Getting Started Guide](https://developers.mopub.com/docs/ios/getting-started/) for instructions on upgrading from SDK 4.X to SDK 5.0.

For GDPR-specific upgrading instructions, also see the [GDPR Integration Guide](https://developers.mopub.com/docs/publisher/gdpr).

## Requirements

- iOS 10.0 and up
- Xcode 12.0 and up
- Swift 5

## License

We have launched a new license as of version 3.2.0. To view the full license, visit [http://www.mopub.com/legal/sdk-license-agreement/](http://www.mopub.com/legal/sdk-license-agreement/)

## Open Measurement License

We have partnered with the IAB to provide Viewability measurement via the Open Measurement SDK as of version 5.14.0. To view the full license, visit [https://www.mopub.com/en/omlv1](https://www.mopub.com/en/omlv1)
