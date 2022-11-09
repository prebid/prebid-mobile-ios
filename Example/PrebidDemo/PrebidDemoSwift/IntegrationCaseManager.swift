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

// Test case title template: [AdServer] [AdFormat] [Size] (Original API)
//
// [AdServer]: In-App, GAM, AdMob, MAX
// [AdFormat]: Display Banner, Video Banner, Display Interstitial, Video Interstitial, Rewarded, Native, In-stream Video
// [Size]: creative size
// (Original API) - only for test cases built using original api

struct IntegrationCaseManager {
    
    static var allCases: [IntegrationCase] = [
        IntegrationCase(
            title: "GAM Display Banner 320x50 (Original API)",
            integrationKind: IntegrationKind.originalGAM,
            adFormat: .bannerDisplay,
            viewController: OriginalBannerDisplayViewController(bannerSize: CGSize(width: 320, height: 50))
        ),
    ]
}
