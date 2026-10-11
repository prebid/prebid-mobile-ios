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

@objc(PBMVastCreativeNonLinearAds)
@_spi(PBMInternal) public class VastCreativeNonLinearAds: VastCreativeAbstract, VastResourceContainer {

    // Untyped `NSMutableArray`: surviving ObjC parser code appends in place.
    // Elements are `VastCreativeNonLinearAdsNonLinear`.
    @objc public var nonLinears = NSMutableArray()

    // VastResourceContainer
    @objc public var resourceType = VastResourceType.staticResource
    @objc public var resource: String?
    @objc public var staticType: String?

    @objc public override init() {
        super.init()
    }

    @objc(copyTracking:)
    public func copyTracking(fromNonLinearAds: VastCreativeNonLinearAds) {
        for case let fromNonLinear as VastCreativeNonLinearAdsNonLinear in fromNonLinearAds.nonLinears {
            for case let toNonLinear as VastCreativeNonLinearAdsNonLinear in nonLinears {
                toNonLinear.clickTrackingURIs.addObjects(from: Array(fromNonLinear.clickTrackingURIs))
                toNonLinear.vastTrackingEvents.addTrackingEvents(fromNonLinear.vastTrackingEvents)
            }
        }
    }
}
