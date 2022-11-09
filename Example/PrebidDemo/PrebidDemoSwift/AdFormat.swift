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

import Foundation

enum AdFormat: CustomStringConvertible, CaseIterable {
    
    case bannerDisplay
    case interstitialDisplay
    
    case bannerVideo
    case interstitialVideo
    
    case rewarded
    case native
    
    case instreamVideo
    
    var description: String {
        switch self {
        case .bannerDisplay:
            return "Display Banner"
        case .interstitialDisplay:
            return "Display Interstitial"
        case .bannerVideo:
            return "Video Banner"
        case .interstitialVideo:
            return "Video Interstitial"
        case .rewarded:
            return "Rewarded Interstitial"
        case .native:
            return "Native"
        case .instreamVideo:
            return "In-stream Video"
        }
    }
}
