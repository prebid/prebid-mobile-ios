# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

workspace 'PrebidMobile'

project 'PrebidMobile.xcodeproj'
project 'EventHandlers/EventHandlers.xcodeproj'
project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'

def gma_pods
    pod 'Google-Mobile-Ads-SDK'
end

def applovin_pods
    pod 'AppLovinSDK'
end

def event_handlers_project
  project 'EventHandlers/EventHandlers.xcodeproj'
  use_frameworks!
end

target 'PrebidMobileGAMEventHandlers' do
  event_handlers_project
  gma_pods
end

target 'PrebidMobileGAMEventHandlersTests' do
  event_handlers_project
  gma_pods
end

target 'PrebidMobileAdMobAdapters' do
  event_handlers_project
  gma_pods

end

target 'PrebidMobileAdMobAdaptersTests' do
  event_handlers_project
  gma_pods
end

target 'PrebidMobileMAXAdapters' do
  event_handlers_project
  applovin_pods
end

target 'PrebidMobileMAXAdaptersTests' do
  event_handlers_project
  applovin_pods
end

def prebid_demo_pods
  use_frameworks!
  
  pod 'GoogleAds-IMA-iOS-SDK', '~> 3.16.3'
  gma_pods
  applovin_pods
end

target 'PrebidDemoSwift' do
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  platform :ios, '12.0'
  
  prebid_demo_pods
  
  target 'PrebidDemoTests' do
    inherit! :search_paths
  end
end

target 'PrebidDemoObjectiveC' do
  project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
  platform :ios, '12.0'
  
  prebid_demo_pods
end

target 'Dr.Prebid' do
  project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'
  platform :ios, '12.0'
  
  prebid_demo_pods
end

def internalTestApp_pods
  pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'xcode12'
  pod 'SVProgressHUD'
  
  applovin_pods
  gma_pods
end

target 'InternalTestApp' do
  use_frameworks!
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  internalTestApp_pods
end

target 'InternalTestAppTests' do
  use_frameworks!
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  internalTestApp_pods
  pod 'Google-Mobile-Ads-SDK'
end

target 'OpenXMockServer' do
  use_frameworks!
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  
  pod 'Alamofire', '4.9.1'
  pod 'RxSwift'
end
