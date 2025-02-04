Pod::Spec.new do |s|

  s.name         = "PrebidMobile"
  s.version      = "2.4.0"
  s.summary      = "PrebidMobile is a lightweight framework that integrates directly with Prebid Server."

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

  s.author                 = { "Prebid.org, Inc." => "info@prebid.org" }
  s.platform     	   = :ios, "11.0"
  s.swift_version 	   = '5.0'
  s.source      	   = { :git => "https://github.com/prebid/prebid-mobile-ios.git", :tag => "#{s.version}" }
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

  # Support previous intagration
  s.default_subspec = 'core'

  s.subspec 'core' do |core|
    core.source_files = 'PrebidMobile/**/*.{h,m,swift}'
    
    core.private_header_files = [ 
      'PrebidMobile/PrebidMobileRendering/Networking/Parameters/PBMParameterBuilderService.h', 
      'PrebidMobile/PrebidMobileRendering/Prebid+TestExtension.h',
      'PrebidMobile/PrebidMobileRendering/3dPartyWrappers/OpenMeasurement/PBMOpenMeasurementFriendlyObstructionTypeBridge.h',
      'PrebidMobile/ConfigurationAndTargeting/InternalUserConsentDataManager.h',
      'PrebidMobile/PrebidMobileRendering/Networking/Parameters/PBMUserConsentParameterBuilder.h'
    ]
    core.vendored_frameworks = 'Frameworks/OMSDK-Static_Prebidorg.xcframework'
  end
end
