platform :ios, '12.0'

workspace 'PrebidMobile'

project 'PrebidMobile.xcodeproj'
project 'EventHandlers/EventHandlers.xcodeproj'
project 'Example/PrebidDemo/PrebidDemo.xcodeproj'
project 'tools/PrebidValidator/Dr.Prebid.xcodeproj'

def gma_pods
  pod 'Google-Mobile-Ads-SDK', '<= 11.13.0'
end

def applovin_pods
  pod 'AppLovinSDK'
end

def event_handlers_project
  project 'EventHandlers/EventHandlers.xcodeproj'
  use_frameworks!
end

def ima_pod
  pod 'GoogleAds-IMA-iOS-SDK'
end

def prebid_demo_pods
  use_frameworks!
  
  ima_pod
  gma_pods
  applovin_pods
end

def internalTestApp_pods
  pod 'Eureka'
  pod 'SVProgressHUD'
  
  applovin_pods
  gma_pods
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

target 'InternalTestApp' do
  use_frameworks!
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  internalTestApp_pods
  ima_pod
end

target 'InternalTestApp-Skadn' do
  use_frameworks!
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  internalTestApp_pods
  ima_pod
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

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
    end
  end
end
