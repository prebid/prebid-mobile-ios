/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

/// Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) banner object
@objcMembers
public class BannerParameters: NSObject {
    
    /// List of supported API frameworks for this impression. If an API is not explicitly listed, it is assumed not to be supported.
    public var api: [Signals.Api]?
    
    /// Min width percentage value for interstitial
    public var interstitialMinWidthPerc: Int?
    
    /// Min height percentage value for interstitial
    public var interstitialMinHeightPerc: Int?
    
    /// Ad sizes of the ad
    public var adSizes: [CGSize]?
    
    // MARK: - Helpers
    
    /// Helper for `api` values
    public var rawAPI: [Int]? {
        get {
            api?.toIntArray()
        }
    }
}
