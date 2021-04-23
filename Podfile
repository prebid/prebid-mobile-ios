# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

workspace 'PrebidMobile'

project 'PrebidMobile.xcodeproj'
project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'

def prebid_demo_pods
  use_frameworks!
  
  pod 'Google-Mobile-Ads-SDK'
  pod 'mopub-ios-sdk'
  pod 'GoogleAds-IMA-iOS-SDK'
end

target 'PrebidDemoSwift' do
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  
  prebid_demo_pods
  
  target 'PrebidDemoTests' do
    inherit! :search_paths
  end
end

target 'PrebidDemoObjectiveC' do
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  
  prebid_demo_pods
end

target 'Dr.Prebid' do
  project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'
  
  prebid_demo_pods
end

#target 'PrebidDemoTemp' do
#  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  
#  pod 'PrebidMobile', :path => '/Users/alex/Desktop/GL/RubiconProject/Prebid/ios/SDKPrebid/contributing.0/prebid-mobile-ios/PrebidMobile.podspec'
#  pod 'PrebidMobileAdditional', :path => '/Users/alex/Desktop/GL/RubiconProject/Prebid/ios/SDKPrebid/contributing.0/prebid-mobile-ios/PrebidMobileAdditional.podspec'
#end
