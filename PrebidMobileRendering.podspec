Pod::Spec.new do |s|

  s.name         = "PrebidMobileRendering"
  s.version      = "1.13"
  s.summary      = "The Prebid-Mobile-SDK Rendering module allows publishers to monetize their apps by In-App bidding."

  s.description  = <<-DESC
    Prebid-Mobile-SDK is a lightweight framework that integrates directly with Prebid Server to increase yield for publishers by adding more mobile buyers."
    DESC
  s.homepage     = "https://www.prebid.org"


  s.license      = { :type => "Apache License, Version 2.0", :text => <<-LICENSE
    Copyright 2018-2021 Prebid.org, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
    }

  s.author             = { "Prebid.org, Inc." => "info@prebid.org" }
  s.platform     = :ios, "9.0"
  s.swift_version = '5.0'
  s.source       = { :git => "https://github.com/prebid/prebid-mobile-ios.git", :tag => "#{s.version}" }
  s.xcconfig = {
:LIBRARY_SEARCH_PATHS => '$(inherited)',
:OTHER_CFLAGS => '$(inherited)',
:OTHER_LDFLAGS => '$(inherited)',
:HEADER_SEARCH_PATHS => '$(inherited)',
:RAMEWORK_SEARCH_PATHS => '$(inherited)'
}

  s.requires_arc = true

  s.frameworks = [ 'UIKit', 
                   'Foundation', 
                   'MapKit', 
                   'SafariServices', 
                   'AVFoundation',
                   'CoreGraphics',
                   'CoreLocation',
                   'CoreMedia',
                   'MediaPlayer',
                   'QuartzCore'
                 ]
  s.weak_frameworks  = [ 'AdSupport', 'StoreKit', 'WebKit' ]

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 arm64e armv7 armv7s'}
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 arm64e armv7 armv7s'}
  s.module_map   = 'PrebidMobile/Rendering/PrebidMobileRendering/PrebidMobileRenderingSDK/PrebidMobileRendering.modulemap'


  s.source_files = 'PrebidMobile/Rendering/PrebidMobileRendering/PrebidMobileRendering/**/*.{h,m,swift}', 
                   'PrebidMobile/Rendering/PrebidMobileRendering/PrebidMobileRenderingSDK/**/*.{h,m,swift}'
  s.resources    = 'PrebidMobile/Rendering/PrebidMobileRendering/PrebidMobileRendering/Assets/**/*.{json,png,js,html,xib}'
  s.vendored_frameworks = 'PrebidMobile/Rendering/PrebidMobileRendering/Frameworks/OMSDK_Prebidorg.framework'

  s.static_framework = true
end
