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
import UIKit

@objc(PBMVastCreativeCompanionAds)
@_spi(PBMInternal) public class VastCreativeCompanionAds: VastCreativeAbstract {

    // Untyped `NSMutableArray`: surviving ObjC parser code appends in place.
    // Elements are `VastCreativeCompanionAdsCompanion`.
    @objc public var companions = NSMutableArray()
    @objc public var requiredMode = ""

    // Computed on first use and cached, like the ObjC original: companions added afterwards are not picked up.
    private var myFeasibleCompanions: [VastCreativeCompanionAdsCompanion]?

    @objc public override init() {
        super.init()
    }

    // MARK: - Public

    @objc public func feasibleCompanions() -> [VastCreativeCompanionAdsCompanion] {
        if let cachedCompanions = myFeasibleCompanions {
            return cachedCompanions
        }

        let screenSize = UIScreen.main.bounds.size
        let feasibleCompanions = companions.compactMap { $0 as? VastCreativeCompanionAdsCompanion }.filter { companion in
            if companion.resourceType == .staticResource && companion.staticType == "application/x-shockwave-flash" {
                return false
            }
            return CGFloat(companion.width) < screenSize.width || CGFloat(companion.height) < screenSize.height
        }
        myFeasibleCompanions = feasibleCompanions
        return feasibleCompanions
    }

    @objc public func canPlayRequiredCompanions() -> Bool {
        // The `PBMVastRequiredMode` constants are ObjC-only (S2.1-A), so the raw strings are used here.
        if requiredMode == "all" {
            // Can we play all of them?
            return feasibleCompanions().count == companions.count
        }
        if requiredMode == "any" {
            // Can we play any of them?

            // TODO: This logic always returns true.
            if companions.count == 0 {
                return true
            }
            return !feasibleCompanions().isEmpty
        }
        return true
    }

    @objc(copyTracking:)
    public func copyTracking(fromCompanionAds: VastCreativeCompanionAds) {
        for case let fromCompanion as VastCreativeCompanionAdsCompanion in fromCompanionAds.companions {
            for case let toCompanion as VastCreativeCompanionAdsCompanion in companions {
                toCompanion.clickTrackingURIs.addObjects(from: Array(fromCompanion.clickTrackingURIs))
                toCompanion.trackingEvents.addTrackingEvents(fromCompanion.trackingEvents)
            }
        }
    }
}
