# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

workspace 'PrebidMobile'
project 'PrebidMobile.xcodeproj'
project 'Example/PrebidDemo/PrebidDemo.xcodeproj'

def prebid_demo_pods
  use_frameworks!
  
  pod 'Google-Mobile-Ads-SDK'
  pod 'mopub-ios-sdk'
end

target 'PrebidMobile' do
  
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  project 'PrebidMobile.xcodeproj'

end

target 'PrebidDemoSwift' do

  prebid_demo_pods
  
  target 'PrebidDemoSwiftTests' do
    inherit! :search_paths
  end
end

target 'PrebidDemoObjectiveC' do
  
  prebid_demo_pods
end
