Pod::Spec.new do |s|

  s.name         = "NativoPrebidSDK"
  s.version      = "3.2.0-alpha.1"
  s.summary      = "Nativo's PrebidMobile wrapper is a lightweight framework that integrates directly with Nativo and Prebid Server."

  s.description  = <<-DESC
    Nativo-Prebid-SDK is a lightweight framework that integrates directly with Prebid Server to increase yield for publishers by adding more mobile buyers."
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

  s.author         = { "Nativo, Inc." => "info@nativo.com" }
  s.platform     	 = :ios, "12.0"
  s.swift_version  = '5.0'
  s.source         = { :git => "https://github.com/NativoPlatform/nativo-prebid-sdk-ios.git", :tag => "#{s.version}" }
  s.xcconfig 		   = { :LIBRARY_SEARCH_PATHS => '$(inherited)',
			       :OTHER_CFLAGS => '$(inherited)',
			       :OTHER_LDFLAGS => '$(inherited)',
			       :HEADER_SEARCH_PATHS => '$(inherited)',
			       :FRAMEWORK_SEARCH_PATHS => '$(inherited)'
			     }
  s.requires_arc = true

  s.frameworks = [ 'UIKit', 
                   'Foundation', 
                   'MapKit', 
                   'SafariServices', 
                   'SystemConfiguration',
                   'AVFoundation',
                   'CoreGraphics',
                   'CoreLocation',
                   'CoreTelephony',
                   'CoreMedia',
                   'QuartzCore'
                 ]
  s.weak_frameworks  = [ 'AdSupport', 'StoreKit', 'WebKit' ]


  s.default_subspecs = ['core']
  s.subspec 'core' do |core|
    core.source_files = [
    'PrebidMobile/**/*.{h,m,swift}',
    'NativoPrebidRenderer/'
    ]
    
    core.private_header_files = [
      'PrebidMobile/Objc/PrivateHeaders/*.h'
    ]
    core.vendored_frameworks = 'Frameworks/OMSDK_Prebidorg.xcframework'
  end

  # Separate subspec for standalone renderer with PrebidMobile dependency
  s.subspec 'renderer' do |renderer|
    renderer.source_files = 'NativoPrebidRenderer/'
    renderer.dependency 'PrebidMobile'
  end

  s.pod_target_xcconfig = {
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'OTHER_LDFLAGS' => '$(inherited) -lObjC -framework OMSDK_Prebidorg',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) @executable_path/Frameworks',
    'OTHER_SWIFT_FLAGS' => '$(inherited) -no-verify-emitted-module-interface'
  }

end
