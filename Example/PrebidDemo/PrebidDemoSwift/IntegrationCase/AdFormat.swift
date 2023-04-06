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
    
    case displayBanner
    case videoBanner
    case nativeBanner
    case displayInterstitial
    case videoInterstitial
    case videoRewarded
    case videoInstream
    case native
    case multiformatBanner
    case multiformatInterstitial
    
    var description: String {
        switch self {
        case .displayBanner:
            return "Display Banner"
        case .videoBanner:
            return "Video Banner"
        case .nativeBanner:
            return "Native Banner"
        case .displayInterstitial:
            return "Display Interstitial"
        case .videoInterstitial:
            return "Video Interstitial"
        case .videoRewarded:
            return "Video Rewarded"
        case .videoInstream:
            return "Video In-stream"
        case .native:
            return "Native"
        case .multiformatBanner:
            return "Multiformat Banner"
        case .multiformatInterstitial:
            return "Multiformat Interstitial"
        }
    }
}
