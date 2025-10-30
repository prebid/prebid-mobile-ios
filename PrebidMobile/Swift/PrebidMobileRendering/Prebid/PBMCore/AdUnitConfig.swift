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
import UIKit

public let refreshIntervalMin: TimeInterval  = 15
public let refreshIntervalMax: TimeInterval = 120
public let refreshIntervalDefault: TimeInterval  = 60

@objcMembers
public class AdUnitConfig: NSObject, NSCopying {

    // MARK: - Public properties
       
    public var configId: String
    
    public let adConfiguration = AdConfiguration()
    
    public var adFormats: Set<AdFormat> {
        didSet {
            updateAdFormat()
        }
    }
    
    public var adSize: CGSize
    
    public var minSizePerc: NSValue?
    
    public var adPosition = AdPosition.undefined

    public var nativeAdConfiguration: NativeAdConfiguration?

    // MARK: - Computed Properties
    
    public var additionalSizes: [CGSize]? {
        get { sizes }
        set { sizes = newValue }
    }
    
    let fingerprint = UUID().uuidString
    
    var _refreshInterval: TimeInterval = refreshIntervalDefault
    public var refreshInterval: TimeInterval {
        get { _refreshInterval }
        set {
            if adConfiguration.winningBidAdFormat == .video {
                Log.warn("'refreshInterval' property is not assignable for Outstream Video ads")
                _refreshInterval = 0
                return
            }
            if newValue < 0 {
                _refreshInterval  = 0
            } else {
                let lowerClamped = max(newValue, refreshIntervalMin);
                let doubleClamped = min(lowerClamped, refreshIntervalMax);
                
                _refreshInterval = doubleClamped;
                
                if self.refreshInterval != newValue {
                    Log.warn("The value \(newValue) is out of range [\(refreshIntervalMin);\(refreshIntervalMax)]. The value \(_refreshInterval) will be used")
                }
            }
        }
    }
    
    public var gpid: String?
    
    public var impORTBConfig: String? {
        get { adConfiguration.impORTBConfig }
        set { adConfiguration.impORTBConfig = newValue }
    }
    
    public var globalORTBConfig: String? {
        get { adConfiguration.globalORTBConfig }
        set { adConfiguration.globalORTBConfig = newValue }
    }

    // MARK: - Public Methods
    
    public convenience init(configId: String) {
        self.init(configId: configId, size: CGSize.zero)
    }
    
    public init(configId: String, size: CGSize) {
        self.configId = configId
        self.adSize = size
        
        adFormats = [.banner]
        
        adConfiguration.autoRefreshDelay = 0
        adConfiguration.size = adSize
    }
    
    // MARK: - The Prebid Ad Slot

    public func setPbAdSlot(_ newElement: String?) {
        pbAdSlot = newElement
    }

    public func getPbAdSlot() -> String? {
        return pbAdSlot
    }

    // MARK: - Private Properties
    
    private var sizes: [CGSize]?

    private var pbAdSlot: String?
    
    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let clone = AdUnitConfig(configId: self.configId, size: self.adSize)
        
        clone.adFormats = self.adFormats
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.adConfiguration.bannerParameters = self.adConfiguration.bannerParameters
        clone.adConfiguration.videoParameters = self.adConfiguration.videoParameters
        clone.adConfiguration.videoControlsConfig = self.adConfiguration.videoControlsConfig
        clone.adConfiguration.winningBidAdFormat = self.adConfiguration.winningBidAdFormat
        clone.sizes = sizes
        clone.adSize = adSize
        clone.minSizePerc = self.minSizePerc
        clone.adPosition = self.adPosition
        clone.additionalSizes = self.additionalSizes
        clone.refreshInterval = self.refreshInterval
        clone.gpid = self.gpid
        clone.adPosition = self.adPosition
        clone.pbAdSlot = self.pbAdSlot
        
        clone.adConfiguration.impORTBConfig = self.adConfiguration.impORTBConfig
        clone.adConfiguration.globalORTBConfig = self.adConfiguration.globalORTBConfig
        clone.adConfiguration.rewardedConfig = self.adConfiguration.rewardedConfig
        clone.adConfiguration.winningBidAdFormat = self.adConfiguration.winningBidAdFormat
        clone.adConfiguration.adFormats = self.adConfiguration.adFormats
        clone.adConfiguration.isOriginalAPI = self.adConfiguration.isOriginalAPI
        clone.adConfiguration.size = self.adConfiguration.size
        clone.adConfiguration.isBuiltInVideo = self.adConfiguration.isBuiltInVideo
        clone.adConfiguration.isInterstitialAd = self.adConfiguration.isInterstitialAd
        clone.adConfiguration.isRewarded = self.adConfiguration.isRewarded
        clone.adConfiguration.forceInterstitialPresentation = self.adConfiguration.forceInterstitialPresentation
        clone.adConfiguration.interstitialLayout = self.adConfiguration.interstitialLayout
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.adConfiguration.bannerParameters = self.adConfiguration.bannerParameters
        clone.adConfiguration.videoParameters = self.adConfiguration.videoParameters
        clone.adConfiguration.videoControlsConfig = self.adConfiguration.videoControlsConfig
        clone.adConfiguration.clickHandlerOverride = self.adConfiguration.clickHandlerOverride
        clone.adConfiguration.autoRefreshDelay = self.adConfiguration.autoRefreshDelay
        clone.adConfiguration.pollFrequency = self.adConfiguration.pollFrequency
        clone.adConfiguration.viewableArea = self.adConfiguration.viewableArea
        clone.adConfiguration.viewableDuration = self.adConfiguration.viewableDuration
        
        return clone
    }
    
    // MARK: - Private Methods

    private func updateAdFormat() {
        if adConfiguration.adFormats == adFormats {
            return
        }
        
        self.adConfiguration.adFormats = adFormats
        self.refreshInterval = (adConfiguration.winningBidAdFormat == .video) ? 0 : refreshIntervalDefault;
    }
}
