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

import UIKit

/**
 Contains all the data needed to load an ad.
 */
@objc(PBMAdConfiguration) @objcMembers
public class AdConfiguration: AutoRefreshCountConfig {
    
    // MARK: - Request
    
    public var isOriginalAPI = false
    
    public var adFormats: Set<AdFormat> = [.banner]
    
    /**
     Describes an OpenRTB banner object
     */
    public lazy var bannerParameters = BannerParameters()
    
    /**
     Describes an OpenRTB video object
     */
    public lazy var videoParameters = VideoParameters(mimes: [])
    
    // MARK: - Interstitial
    
    /**
     Whether or not this ad configuration is intended to represent an intersitial ad.

     Setting this to true will disable auto refresh.
     */
    public var isInterstitialAd = false
    
    /**
     Whether or not this ad configuration is intended to represent an ad as an intersitial one (regardless of original designation).
     Overrides `isInterstitialAd`

     Setting this to true will disable auto refresh.
     */
    public var forceInterstitialPresentation: NSNumber?
    
    /**
     Whether or not this ad configuration is intended to represent an intersitial ad.
     Returns the effective result by combining `isInterstitialAd` and `forceInterstitialPresentation`
     */
    public var presentAsInterstitial: Bool {
        return forceInterstitialPresentation != nil ? forceInterstitialPresentation.boolValue ?? false : isInterstitialAd
    }
    
    /**
     Interstitial layout
     */
    public var interstitialLayout = PBMInterstitialLayout.undefined
    
    /**
     Size for the ad.
     */
    public var size = CGSize.zero
    
    /**
     Sets an ad unit as an rewarded
     */
    public var isRewarded = false
    
    /**
     Indicates whether the ad is built-in video e.g. 300x250.
     */
    public var isBuiltInVideo = false
    
    // MARK: - Response
    
    /**
     This property indicated winning bid ad format (ext.prebid.type)
     */
    public var winningBidAdFormat: AdFormat?
    
    /**
     This property represents video controls custom configuration.
     */
    public lazy var videoControlsConfig = VideoControlsConfiguration()
    
    /// Server-side configuration for rewarded ads (bid.ext.rwdd)
    public var rewardedConfig: RewardedConfig?
    
    // MARK: - Impression Tracking
    
    public var pollFrequency: TimeInterval = 0.2
    
    public var viewableArea = 1
    
    public var viewableDuration = 0
    
    // MARK: - Auto Refresh
    
    public override var autoRefreshDelay: TimeInterval? {
        set {
            if let newValue = newValue, newValue > 0 {
                let clampedValue = PBMFunctions.clampAutoRefresh(newValue)
                _autoRefreshDelay = clampedValue
            } else {
                _autoRefreshDelay = nil
            }
        }
        get {
            return !presentAsInterstitial ? _autoRefreshDelay : nil
        }
    }
    
    // MARK: - Other
    
    public var clickHandlerOverride: ((PBMVoidBlock) -> Void)?
    
    // MARK: Private properties
    
    private var _autoRefreshDelay: TimeInterval? = PBMAutoRefresh.AUTO_REFRESH_DELAY_DEFAULT
    
    public var impORTBConfig: String?
    
    @available(*, deprecated, message: "This property is deprecated in favour of `impORTBConfig`.")
    public var ortbConfig: String?
    
    @available(*, deprecated, message: "This method is deprecated and will be removed in future versions.")
    public func getCheckedOrtbConfig() -> [String: Any]? {
        //return ortbConfig in dictionary form after checking if it's valid json
        if let jsonString = ortbConfig {
            if let data = jsonString.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    Log.warn("The provided ortbConfig object is not valid JSON and will be ignored.")
                }
            }
        }
        return [:]
    }
}
