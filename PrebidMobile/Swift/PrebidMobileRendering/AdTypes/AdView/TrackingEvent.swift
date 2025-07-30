//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@objc(PBMTrackingEvent)
public enum TrackingEvent: Int {
    case request = 0
    case impression
    case click
    case overlayClick
    case companionClick // split these or no?
    
    case play
    case pause
    case resume
    case rewind
    case skip
    
    case creativeView
    case start
    case firstQuartile
    case midpoint
    case thirdQuartile
    case complete
    
    case mute
    case unmute
    
    case fullscreen
    case exitFullscreen
    case normal
    case expand
    case collapse
    
    case closeLinear
    case closeOverlay
    
    case acceptInvitation
    
    case error
    
    case loaded
    
    case prebidWin
    
    case unknown
    
    init(_ description: String) {
        // Note that the capitalization of `firstquartile` and `thirdquartile` here differs from
        // the values returned by description. Is this intentional?
        switch description {
            case "creativeModelTrackingKey_Request"         : self = .request
            case "creativeModelTrackingKey_Impression"      : self = .impression
            case "creativeModelTrackingKey_Click"           : self = .click
            case "creativeModelTrackingKey_OverlayClick"    : self = .overlayClick
            case "creativeModelTrackingKey_CompanionClick"  : self = .companionClick
            case "creativeModelTrackingKey_Play"            : self = .play
            case "pause"                                    : self = .pause
            case "rewind"                                   : self = .rewind
            case "resume"                                   : self = .resume
            case "creativeModelTrackingKey_Skip"            : self = .skip
            case "creativeView"                             : self = .creativeView
            case "start"                                    : self = .start
            case "firstquartile"                            : self = .firstQuartile
            case "midpoint"                                 : self = .midpoint
            case "thirdquartile"                            : self = .thirdQuartile
            case "complete"                                 : self = .complete
            case "mute"                                     : self = .mute
            case "unmute"                                   : self = .unmute
            case "fullscreen"                               : self = .fullscreen
            case "creativeModelTrackingKey_ExitFullscreen"  : self = .exitFullscreen
            case "normal"                                   : self = .normal
            case "expand"                                   : self = .expand
            case "collapse"                                 : self = .collapse
            case "close"                                    : self = .closeLinear
            case "creativeModelTrackingKey_CloseOverlay"    : self = .closeOverlay
            case "creativeModelTrackingKey_Error"           : self = .error
            case "acceptInvitation"                         : self = .acceptInvitation
            case "loaded"                                   : self = .loaded
            case "prebid_Win"                               : self = .prebidWin
            case "unknown"                                  : self = .unknown
            default                                         : self = .unknown
        }
    }
    
    var description: String {
        switch self {
            case .request            : return "creativeModelTrackingKey_Request"
            case .impression         : return "creativeModelTrackingKey_Impression"
            case .click              : return "creativeModelTrackingKey_Click"
            case .overlayClick       : return "creativeModelTrackingKey_OverlayClick"
            case .companionClick     : return "creativeModelTrackingKey_CompanionClick"
            case .play               : return "creativeModelTrackingKey_Play"
            case .pause              : return "pause"
            case .rewind             : return "rewind"
            case .resume             : return "resume"
            case .skip               : return "creativeModelTrackingKey_Skip"
            case .creativeView       : return "creativeView"
            case .start              : return "start"
            case .firstQuartile      : return "firstQuartile"
            case .midpoint           : return "midpoint"
            case .thirdQuartile      : return "thirdQuartile"
            case .complete           : return "complete"
            case .mute               : return "mute"
            case .unmute             : return "unmute"
            case .fullscreen         : return "fullscreen"
            case .exitFullscreen     : return "creativeModelTrackingKey_ExitFullscreen"
            case .normal             : return "normal"
            case .expand             : return "expand"
            case .collapse           : return "collapse"
            case .closeLinear        : return "close"
            case .closeOverlay       : return "creativeModelTrackingKey_CloseOverlay"
            case .error              : return "creativeModelTrackingKey_Error"
            case .acceptInvitation   : return "acceptInvitation"
            case .loaded             : return "loaded"
            case .prebidWin          : return "prebid_Win"
            case .unknown            : return "unknown"
        }
    }
}

@objc(PBMTrackingEventDescription) @_spi(PBMInternal) public
class TrackingEventDescription: NSObject {
    
    @objc public static func getDescription(_ event: TrackingEvent) -> String {
        event.description
    }
    
    @objc public static func getEvent(with description: String) -> TrackingEvent {
        .init(description)
    }
    
}
