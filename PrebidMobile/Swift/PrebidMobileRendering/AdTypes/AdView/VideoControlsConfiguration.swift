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

/// A class representing the configuration for video controls in an ad.
/// This includes properties for video duration, mute status, and button positioning and visibility.
/// Configuration values can be initialized from bid response or set directly by the user.
@objc(PBMVideoControlsConfiguration) @objcMembers
public class VideoControlsConfiguration: NSObject {
    
    /// This property indicates maximum video duration.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.maxvideoduration.
    private(set) public var maxVideoDuration: NSNumber?
    
    /// This property indicates whether the ad should run playback with sound or not.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.ismuted or set by user.
    public var isMuted: Bool = false
    
    /// This property indicates the area which the close button should occupy on the screen.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.closebuttonarea or set by user.
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
    
    /// This property indicates the position of the close button on the screen.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.closebuttonposition or set by user.
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
    
    /// This property indicates the area which the skip button should occupy on the screen.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.skipbuttonarea or set by user.
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
    
    /// This property indicates the position of the skip button on the screen.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.skipbuttonposition or set by user.
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
    
    /// This property indicates the number of seconds which should be passed from the start of playback until the skip or close button should be shown.
    /// Obtained from the field ext,prebid.passthrough[].adConfiguration.skipdelay or set by user.
    public var skipDelay = PrebidConstants.SKIP_DELAY_DEFAULT.doubleValue
    
    /// This property indicates whether mute controls is visible on the screen.
    public var isSoundButtonVisible = false

    /// Indicates whether a non-rewarded full-screen video without a companion ad closes automatically when playback completes.
    ///
    /// The default value is `true`, preserving the SDK's existing auto-close behavior. Set this property to `false`
    /// to keep the interstitial open and display a **Watch Again** button until the user closes the ad. Rewarded ads
    /// use the `rwdd.close.action` configuration instead.
    /// Obtained from `ext.prebid.passthrough[].adConfiguration.isautocloseoncompletionenabled` or set by the user.
    public var isAutoCloseOnCompletionEnabled = true

    /// Indicates whether the remaining-time countdown indicator is visible during full-screen video playback.
    ///
    /// The default preserves the SDK's existing behavior: the indicator is shown for rewarded ads and hidden for
    /// interstitials. Set this property explicitly to show it on interstitials or hide it on rewarded ads.
    /// Obtained from `ext.prebid.passthrough[].adConfiguration.isvideoprogressindicatorvisible` or set by the user.
    public var isVideoProgressIndicatorVisible: Bool {
        set { _isVideoProgressIndicatorVisible = newValue as NSNumber }
        get { _isVideoProgressIndicatorVisible?.boolValue ?? true }
    }
    
    /// Use to initialize video controls with server values.
    public func initialize(with ortbAdConfiguration: ORTBAdConfiguration?) {
        
        guard let ortbAdConfiguration = ortbAdConfiguration else {
            return
        }
        
        maxVideoDuration = ortbAdConfiguration.maxVideoDuration
        
        if let ortbIsMuted = ortbAdConfiguration.isMuted {
            isMuted = ortbIsMuted.boolValue
        }
    
        if let ortbCloseButtonArea = ortbAdConfiguration.closeButtonArea {
            closeButtonArea = ortbCloseButtonArea.doubleValue
        }
        
        if let ortbCloseButtonPosition = ortbAdConfiguration.closeButtonPosition {
            if let closeButtonPosition = Position.getPositionByStringLiteral(ortbCloseButtonPosition) {
                self.closeButtonPosition = closeButtonPosition
            }
        }
        
        if let ortbSkipButtonArea = ortbAdConfiguration.skipButtonArea {
            skipButtonArea = ortbSkipButtonArea.doubleValue
        }
        
        if let ortbSkipButtonPosition = ortbAdConfiguration.skipButtonPosition {
            if let skipButtonPosition = Position.getPositionByStringLiteral(ortbSkipButtonPosition) {
                self.skipButtonPosition = skipButtonPosition
            }
        }
        
        if let ortbSkipDelay = ortbAdConfiguration.skipDelay {
            skipDelay = ortbSkipDelay.doubleValue
        }

        if let ortbIsAutoCloseOnCompletionEnabled = ortbAdConfiguration.isAutoCloseOnCompletionEnabled {
            isAutoCloseOnCompletionEnabled = ortbIsAutoCloseOnCompletionEnabled.boolValue
        }

        if let ortbIsVideoProgressIndicatorVisible = ortbAdConfiguration.isVideoProgressIndicatorVisible {
            isVideoProgressIndicatorVisible = ortbIsVideoProgressIndicatorVisible.boolValue
        }
    }
    
    /// SDK-internal. Distinguishes an explicit override of `isVideoProgressIndicatorVisible` (set by the publisher
    /// or the bid response) from the ad-type-specific default that applies when neither has touched it.
    /// `public` only so `PBMVideoView` can read it; not intended for use outside the SDK.
    private(set) public var isVideoProgressIndicatorVisibleOverride: NSNumber? {
        get { _isVideoProgressIndicatorVisible }
        set { _isVideoProgressIndicatorVisible = newValue }
    }

    // MARK: - Private properties

    private var _closeButtonArea = PrebidConstants.BUTTON_AREA_DEFAULT.doubleValue
    private var _closeButtonPosition = Position.topRight

    private var _skipButtonArea = PrebidConstants.BUTTON_AREA_DEFAULT.doubleValue
    private var _skipButtonPosition = Position.topLeft

    private var _isVideoProgressIndicatorVisible: NSNumber?
}
