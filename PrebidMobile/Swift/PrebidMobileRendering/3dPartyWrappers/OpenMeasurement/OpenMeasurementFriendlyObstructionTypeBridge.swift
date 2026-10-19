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
import OMSDK_Prebidorg

// Transitional: `public` with a raw-value seam until the ObjC `PBMOpenMeasurementSession` is ported, so no OMID type is exposed.
@objc(PBMOpenMeasurementFriendlyObstructionTypeBridge)
public class OpenMeasurementFriendlyObstructionTypeBridge: NSObject {

    static func obstructionType(of purpose: OpenMeasurementFriendlyObstructionPurpose) -> OMIDFriendlyObstructionType {
        switch purpose {
        case .modalViewControllerClose:
            return .closeAd
        case .videoViewProgressBar:
            return .mediaControls
        default:
            return .other
        }
    }

    @objc(obstructionTypeOfObstructionPurpose:)
    public static func obstructionTypeRawValue(of purpose: OpenMeasurementFriendlyObstructionPurpose) -> UInt {
        obstructionType(of: purpose).rawValue
    }

    /// Returns `nil` for `.purposesCount`: the ObjC original returned `nil` from `default:` although its header said `nonnull`.
    @objc(describeFriendlyObstructionPurpose:)
    public static func describe(_ purpose: OpenMeasurementFriendlyObstructionPurpose) -> String? {

        // Can be nil.
        // If not nil, must be 50 characters or less and only contain characers
        // * `A-z`, `0-9`, or spaces.

        switch purpose {
        case .windowLockerBackground:
            return "Fullscreen UI locker or loading the ad"
        case .windowLockerActivityIndicator:
            return "Activity Indicator for loading the ad"
        case .modalViewControllerView:
            return "Fullscreen modal ad view container"
        case .modalViewControllerClose:
            return "Close button"
        case .videoViewLearnMoreButton:
            return "Learn More  button"
        case .videoViewProgressBar:
            return "Video playback Progress Bar"
        case .purposesCount:
            return nil
        }
    }
}
