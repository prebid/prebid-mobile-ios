/*   Copyright 2018-2019 Prebid.org, Inc.

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

@available(*, deprecated, message: "This class is deprecated. Please, use InterstitialAdUnit with video adFormat.")
public class VideoInterstitialAdUnit: VideoBaseAdUnit {

    public init(configId: String) {
        super.init(configId: configId, size: nil)
        
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adFormats = [.video]
        adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
    }
    
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
        
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
}
