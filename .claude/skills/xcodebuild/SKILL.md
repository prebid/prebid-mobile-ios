---
name: xcodebuild
description: Run xcodebuild tests for a scheme or specific test class in PrebidMobile.xcworkspace
---

Run xcodebuild tests for this iOS project. The workspace is `PrebidMobile.xcworkspace`.

Available schemes:
- `PrebidMobileTests` — core SDK unit tests
- `PrebidMobileGAMEventHandlersTests` — GAM adapter tests
- `PrebidMobileAdMobAdaptersTests` — AdMob adapter tests
- `PrebidMobileMAXAdaptersTests` — MAX adapter tests

Default simulator destination: `platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest`

If the user provides a test class or test method, append `-only-testing <Scheme>/<TestClass>` or `-only-testing <Scheme>/<TestClass>/<testMethod>`.

Steps:
1. If the named simulator doesn't exist yet, create it first:
   ```
   xcrun simctl create iPhone-16-Pro-PrebidMobile com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro
   ```
2. Build for testing:
   ```
   xcodebuild \
     -workspace PrebidMobile.xcworkspace \
     -scheme <SCHEME> \
     -sdk iphonesimulator \
     -configuration Debug \
     -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
     -destination-timeout 60 \
     build-for-testing
   ```
3. Run tests:
   ```
   xcodebuild \
     -workspace PrebidMobile.xcworkspace \
     -scheme <SCHEME> \
     -sdk iphonesimulator \
     -destination 'platform=iOS Simulator,name=iPhone-16-Pro-PrebidMobile,OS=latest' \
     -destination-timeout 60 \
     [-only-testing <TARGET>/<CLASS>] \
     test-without-building
   ```

If no scheme is specified by the user, default to `PrebidMobileTests`.
Report pass/fail clearly after the run.
