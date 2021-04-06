fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios build_sdk
```
fastlane ios build_sdk
```

### ios build_demo_app
```
fastlane ios build_demo_app
```

### ios UnitTests_SDK_iOS_Previous
```
fastlane ios UnitTests_SDK_iOS_Previous
```

### ios UnitTests_SDK_iOS_Latest
```
fastlane ios UnitTests_SDK_iOS_Latest
```

### ios UnitTests_GAM_EH_iOS_Previous
```
fastlane ios UnitTests_GAM_EH_iOS_Previous
```

### ios UnitTests_GAM_EH_iOS_Latest
```
fastlane ios UnitTests_GAM_EH_iOS_Latest
```

### ios UITests_InternalTestApp
```
fastlane ios UITests_InternalTestApp
```

### ios distribute_internal_test_app
```
fastlane ios distribute_internal_test_app
```

### ios distribute_prebid_app
```
fastlane ios distribute_prebid_app
```

### ios distribute_certification_app
```
fastlane ios distribute_certification_app
```

### ios update_certificates
```
fastlane ios update_certificates
```

### ios ui_tests_cocoapods_test_app_swift
```
fastlane ios ui_tests_cocoapods_test_app_swift
```
Running UI tests for OpenXCocoaPodsTestAppSwift
### ios ui_tests_cocoapods_release
```
fastlane ios ui_tests_cocoapods_release
```
Running UI tests for Cocoapods release
### ios cocoapods_push_trunk
```
fastlane ios cocoapods_push_trunk
```
Pushing podspec to CocoaPods trunk
### ios send_slack_message
```
fastlane ios send_slack_message
```
Sends a notification to the Slack channel

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
