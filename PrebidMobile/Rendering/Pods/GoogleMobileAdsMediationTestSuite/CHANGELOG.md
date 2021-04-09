# Mediation Test Suite for Google Mobile Ads SDK for iOS

### 1.3.0
- Minor design updates.
- Updated MaterialComponents dependency version to 111.0.

### 1.2.1
- Added Fyber Marketplace support.
- Updated MaterialComponents dependency version to 109.0.

### 1.2.0
- Added ability to load Open Bidding ads.
- Updated MaterialComponents dependency version to 103.0.

### 1.1.1
- Fixed issue with loading rewarded ads on newer adapter versions.
- Fixed presentation issue on iOS 13.
- Updated MaterialComponents dependency version to 94.0.
- Minimum required version is now iOS 9.0.

### 1.1.0
- Added initial open bidding support (ability to review configurations, cannot load ads).
- Added support for Du Ad Platform and Verizon Media networks, as well as MoPub rewarded ads.
- Added `GoogleMobileAdsMediationTestSuite presentOnViewController:delegate:` API which doesn't require app ID - uses AdMob app ID from Info.plist.
- Deprecated `GoogleMobileAdsMediationTestSuite presentWithAppID:onViewController:delegate:` API.

### 1.0.0
- General release out of beta.

### 0.9.3
- Fixed bug where custom events would not load ads.

### 0.9.2
- Fixed issue with Mediation Test Suite loading ads from other networks when testing a network.
- Add Native Assets view for Native Ads loading.
- Add support for legacy 'Banner,Interstitial' ad units.
- Add safeguards against launching the test suite in production.
Mediation Test Suite will no longer launch in App Store builds, unless running on a device whose AdMob device ID is explicitly whitelisted. See https://developers.google.com/admob/ios/mediation-test-suite#enabling_testing_in_production for details.
- Added localization of test suite for JA, KO, VI, ZH-CN.
- Update Material Components dependency to 76.0.

### 0.9.1
- Update Material Components dependency to 63.0.

### 0.9.0
- Open beta with new design.
- Added ability to batch test.
- Updated to material design standards.

### 0.0.5
- Updated to support Mediation Groups.
- Updated UI.

### 0.0.4
- Initial Version.
