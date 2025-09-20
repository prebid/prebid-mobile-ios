Pod::Spec.new do |s|

  s.name         = "VeonPrebidMobileGAMEventHandlers"
  s.version      = "0.0.2"
  s.summary      = "The bridge between PrebidMobile SDK and GMA SDK."

  s.description  = "GAM Event Handlers manages rendering of Prebid or GAM ads respectively to the winning bid."
  s.homepage     = "https://www.veon.com"


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

  s.author		= { "Veon AdTech" => "veon.com" }
  s.platform     	= :ios, "12.0"
  s.swift_version 	= '5.0'
  s.source       	= { :git => "https://github.com/veonadtech/prebid-ios-sdk.git", :tag => "#{s.version}" }
  s.xcconfig 		= { :LIBRARY_SEARCH_PATHS => '$(inherited)',
  			    :OTHER_CFLAGS => '$(inherited)',
			    :OTHER_LDFLAGS => '$(inherited)',
			    :HEADER_SEARCH_PATHS => '$(inherited)',
			    :FRAMEWORK_SEARCH_PATHS => '$(inherited)'
			  }

  s.source_files = 'EventHandlers/PrebidMobileGAMEventHandlers/**/*.{h,m,swift}'
  s.static_framework = true

  s.dependency 'VeonPrebidMobile', '0.0.2'
  s.dependency 'Google-Mobile-Ads-SDK', '>= 12.0.0'

  s.pod_target_xcconfig = {
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'DEFINES_MODULE' => 'YES',
    'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'PrebidMobile-Swift.h'
  }
end
