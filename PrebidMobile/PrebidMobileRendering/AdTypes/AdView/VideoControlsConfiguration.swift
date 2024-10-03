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
    public var skipDelay = PBMConstants.SKIP_DELAY_DEFAULT.doubleValue
    
    /// This property indicates whether mute controls is visible on the screen.
    public var isSoundButtonVisible = false
    
    /// Use to initialize video controls with server values.
    public func initialize(with ortbAdConfiguration: PBMORTBAdConfiguration?) {
        
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
    }
    
    // MARK: - Private properties
    
    private var _closeButtonArea = PBMConstants.BUTTON_AREA_DEFAULT.doubleValue
    private var _closeButtonPosition = Position.topRight
    
    private var _skipButtonArea = PBMConstants.BUTTON_AREA_DEFAULT.doubleValue
    private var _skipButtonPosition = Position.topLeft
}
