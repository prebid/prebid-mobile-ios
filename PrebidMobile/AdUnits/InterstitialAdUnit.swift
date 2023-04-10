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

public class InterstitialAdUnit: BannerBaseAdUnit, BannerBasedAdUnitProtocol, VideoBasedAdUnitProtocol {
    
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    @available(*, deprecated, message: "This initializer is deprecated. Please, use `init(configId:adFormats:)` instead.")
    public convenience init(configId: String) {
        self.init(configId: configId, adFormats: [.display])
    }
    
    @available(*, deprecated, message: "This initializer is deprecated. Please, use `init(configId:adFormats:minWidthPerc:minHeightPerc:)` instead.")
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
    
    public init(configId: String, adFormats: Set<AdFormat>) {
        super.init(configId: configId, size: nil)
        
        self.adFormats = adFormats
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
    }
    
    public convenience init(configId: String, adFormats: Set<AdFormat>, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId, adFormats: adFormats)
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
}
