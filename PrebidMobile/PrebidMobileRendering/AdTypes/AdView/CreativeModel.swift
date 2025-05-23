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

// PBMCreativeModel is visible to the publisher, and defines:
// --- duration indicates the time the creative will display for
// -------- A negative value indicates that this field has not been set
// -------- A value of 0 indicates an indefinite time
// -------- A postitive value indicates that this creative will be displayed for that many seconds
// --- width is the width of the creative, in pixels
// --- height is the height of the creative, in pixels
// --- creativeData is a String:String dictionary that contains all of the data needed to display the creative in a capable view
// -------- Example: An HTML creative would include key "html" with the html code for that creative as the value. A video creative would have a key "videourl" that would point to the asset to be played
// --- trackEvent functions take an enum or string, and cause the tracking URLs associated with those events to be fired
// --- baseURL is an optional base URL to use when loading in an PBMWebView
// @objc and public because it will be used by publishers to display an ad in their own view

@objc(PBMCreativeModel) @_spi(PBMInternal) public
class CreativeModel: NSObject {
    @objc public var adConfiguration: AdConfiguration?
    @objc public var eventTracker: AdModelEventTracker?
    @objc public var displayDurationInSeconds: NSNumber?
    @objc public var skipOffset: NSNumber?
    @objc public var width: Int = 0
    @objc public var height: Int = 0
    @objc public var html: String?
    @objc public var targetURL: String?
    @objc public var videoFileURL: String?
    @objc public var revenue: String?
    @objc public var verificationParameters: VideoVerificationParameters?
    @objc public var trackingURLs = [String : [String]]()

    @objc public var adTrackingTemplateURL: String?
    @objc public var adDetails: PBMAdDetails?
    @objc public var clickThroughURL: String?
    @objc public var isCompanionAd: Bool = false
    @objc public var hasCompanionAd: Bool = false

    // NOTE: for rewarded ads only
    @objc public var userHasEarnedReward: Bool = false
    @objc public var userPostRewardEventSent: Bool = false

    @objc public var rewardTime: NSNumber?
    @objc public var postRewardTime: NSNumber?
    
    @objc public override init() {
        super.init()
    }
    
    @objc public init(adConfiguration: AdConfiguration) {
        self.adConfiguration = adConfiguration
    }
    
    @objc func trackEvent(_ event: TrackingEvent) {
        eventTracker?.trackEvent(event)
    }
}
