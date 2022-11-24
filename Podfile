$xcode_version = %x[xcrun xcodebuild -version | head -1 | awk '{print $2}']
#'
# ^ %x '' conflict with syntax highlight
# Xcode 14: targets iOS 11-
# Xcode 12,13: targets iOS 9-
$iosVersion = '12.0'
if Gem::Version.new($xcode_version) < Gem::Version.new('14')
  $iosVersion = '10.0'
end

platform :ios, $iosVersion
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

def prebid_demo_pods
  use_frameworks!
  
  pod 'GoogleAds-IMA-iOS-SDK'
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
  puts "Using #$xcode_version and iOSv #$iosVersion"
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = '$(inherited)'
      if Gem::Version.new($iosVersion) > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iosVersion
        puts "Version :#{config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']}"
      end
    end
  end
end
