platform :ios, '13.0'

workspace 'PrebidMobile'

project 'PrebidMobile.xcodeproj'
project 'EventHandlers/EventHandlers.xcodeproj'
project 'Example/PrebidDemo/PrebidDemo.xcodeproj'

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
  use_frameworks!
  
  pod 'Alamofire', '4.9.1'
  pod 'Eureka'
  pod 'SVProgressHUD'
  pod 'RxSwift'
  
  ima_pod
  gma_pods
  applovin_pods
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

target 'InternalTestApp' do
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  internalTestApp_pods
  
  target 'InternalTestAppTests' do
    inherit! :search_paths
  end
  
  target 'InternalTestAppUITests' do
    inherit! :search_paths
  end
  
  target 'InternalTestApp-Skadn' do
    inherit! :search_paths
  end
end

target 'OpenXMockServer' do
  use_frameworks!
  project 'InternalTestApp/InternalTestApp.xcodeproj'
  
  pod 'Alamofire', '4.9.1'
  pod 'RxSwift'
  
  target 'OpenXMockServerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
