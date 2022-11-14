/*   Copyright 2019-2022 Prebid.org, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

/**
    Integration case title template - [IntegrationKind] [AdFormat] [Description]
 */

struct IntegrationCaseManager {
    
    static var allCases: [IntegrationCase] = [
        IntegrationCase(
            integrationKind: .gamOriginal,
            adFormat: .displayBanner,
            description: "320x50",
            configurationClosure: {
                GAMOriginalAPIBannerDisplayViewController()
            }
        ),
        
        IntegrationCase(
            integrationKind: .gamOriginal,
            adFormat: .displayInterstitial,
            description: "320x480",
            configurationClosure: {
                GAMOriginalAPIDisplayInterstitialViewController()
            }
        ),
        
        IntegrationCase(
            integrationKind: .gamOriginal,
            adFormat: .videoRewarded,
            description: "320x480",
            configurationClosure: {
                GAMOriginalAPIVideoRewardedViewController()
            }
        ),
        
        IntegrationCase(
            integrationKind: .gamOriginal,
            adFormat: .nativeBanner,
            description: "",
            configurationClosure: {
                GAMOriginalAPINativeBannerViewController()
            }
        ),
        
        IntegrationCase(
            integrationKind: .gamOriginal,
            adFormat: .native,
            description: "",
            configurationClosure: {
                GAMOriginalAPINativeViewController()
            }
        ),
        
        IntegrationCase(
            integrationKind: .gamOriginal,
            adFormat: .videoInstream,
            description: "",
            configurationClosure: {
                GAMOriginalAPIVideoInstreamViewController()
            }
        ),
    ]
}
