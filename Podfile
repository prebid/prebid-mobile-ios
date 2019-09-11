# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

workspace 'PrebidMobile'

project 'PrebidMobile.xcodeproj'
project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'

#Shared pods
def prebid_demo_pods
  
  pod 'Google-Mobile-Ads-SDK'
  pod 'mopub-ios-sdk'
end

def shared_ima_pod
  pod 'GoogleAds-IMA-iOS-SDK', '~> 3.9'
end

#Prebid Mobile targets
target 'PrebidMobile' do
  project 'PrebidMobile.xcodeproj'

  use_frameworks!
  
  shared_ima_pod
  
  target 'PrebidMobileTests' do
    inherit! :complete
  end

end

target 'PrebidMobileCore' do
  project 'PrebidMobile.xcodeproj'

  use_frameworks!

end

target 'PrebidMobileVideoIMA' do
 project 'PrebidMobile.xcodeproj'

 use_frameworks!
 
 shared_ima_pod

end

#Prebid Demo targets
target 'PrebidDemoSwift' do
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  
  use_frameworks!
  
  prebid_demo_pods
  
  target 'PrebidDemoTests' do
    inherit! :search_paths
  end
end

target 'PrebidDemoObjectiveC' do
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  
  use_frameworks!
    
  prebid_demo_pods
end

#Dr.Prebid targets
target 'Dr.Prebid' do
  project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'
  
  use_frameworks!
    
  prebid_demo_pods
end
