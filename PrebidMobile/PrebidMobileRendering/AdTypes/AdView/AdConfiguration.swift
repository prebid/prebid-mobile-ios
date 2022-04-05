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
@objcMembers
public class AdConfiguration: AutoRefreshCountConfig {
    
    // MARK: - Request
    
    public var adFormats: Set<AdFormat> = [.display]
    
    /**
     Placement type for the video.
     */
    public var videoPlacementType = VideoPlacementType.undefined
    
    /**
     Describes an OpenRTB banner object
     */
    public var bannerParameters: BannerParameters?
    /**
     Describes an OpenRTB video object
     */
    public var videoParameters: VideoParameters?
    
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
     Sets a video interstitial ad unit as an opt-in video
     */
    public var isOptIn = false
    
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
     This property indicates the maximum available playback time in seconds.
     */
    public var maxVideoDuration: TimeInterval = PBMVideoConstants.DEFAULT_MAX_VIDEO_DURATION.doubleValue
    
    /**
     This property indicates whether the ad should run playback with sound or not.
     */
    public var isMuted = true
    
    /**
     This property indicates whether mute controls is visible on the screen.
     */
    public var isSoundButtonVisible = false
    
    /**
     This property indicates the area which the close button should occupy on the screen.
     */
    public var closeButtonArea: Double {
        set {
            if newValue <= 1 && newValue >= 0 {
                _closeButtonArea = newValue
            } else {
                Log.warn("The possible values for close button area value are [0...1]")
            }
        }
        get { _closeButtonArea }
    }
    
    /**
     This property indicates the position of the close button on the screen.
     */
    public var closeButtonPosition: Position {
        set {
            if ![Position.topRight, Position.topLeft].contains(newValue) {
                Log.warn("There are two options available for close button posiiton for now: topLeft anf topRight.")
                return
            }
            _closeButtonPosition = newValue
        }
        
        get { _closeButtonPosition }
    }
    
    /**
     This property indicates the area which the skip button should occupy on the screen.
     */
    public var skipButtonArea: Double {
        set {
            if newValue <= 1 && newValue >= 0 {
                _skipButtonArea = newValue
            } else {
                Log.warn("The possible values for skip button area value are [0...1]")
            }
        }
        
        get { _skipButtonArea }
    }
    
    /**
     This property indicates the position of the skip button on the screen.
     */
    public var skipButtonPosition: Position {
        set {
            if ![Position.topRight, Position.topLeft].contains(newValue) {
                Log.warn("There are two options available for skip button posiiton for now: topLeft anf topRight.")
                return
            }
            _skipButtonPosition = newValue
        }
        
        get { _skipButtonPosition }
    }
    
    /**
     This property indicates the number of seconds which should be passed from the start of playback until the skip or close button should be shown.
     */
    public var skipDelay = PBMConstants.SKIP_DELAY_DEFAULT.doubleValue
    
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
    
    private var _closeButtonArea = PBMConstants.BUTTON_AREA_DEFAULT.doubleValue
    private var _closeButtonPosition = Position.topRight
    
    private var _skipButtonArea = PBMConstants.BUTTON_AREA_DEFAULT.doubleValue
    private var _skipButtonPosition = Position.topRight
}
