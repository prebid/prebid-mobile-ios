# Ozone Prebid Mobile iOS SDK

To work with Ozone Prebid Mobile, you will need accesss to the Ozone Prebid Server. Contact your Ozone representative or email hello@ozoneproject.com

## Use Cocoapods?

Easily include the Ozone Prebid Mobile SDK for your primary ad server in your Podfile - NOTE you must set the :source to get the Ozone version.

```
platform :ios, '11.0'

target 'MyAmazingApp' do 
    pod 'PrebidMobile', '2.0.8', :source => 'https://github.com/ozone-project/inapp-sdk-ios-podspec.git'
    pod 'Google-Mobile-Ads-SDK', '10.3.0'
end
```

## Build framework from source

Build Ozone Prebid Mobile from source code. After cloning the repo, from the root directory run

```
./scripts/buildPrebidMobile.sh
```

to output the Ozone Prebid Mobile framework.

