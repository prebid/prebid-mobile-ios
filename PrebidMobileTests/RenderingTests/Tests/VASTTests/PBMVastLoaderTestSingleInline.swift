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

import XCTest

@testable import PrebidMobile

class PBMVastLoaderTestSingleInline: XCTestCase {
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!

    override func setUp() {
        self.continueAfterFailure = true
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {

        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        //Make an PrebidServerConnection and redirect its network requests to the Mock Server
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.requestCompletedSuccess(response)
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail("\(error)")
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_inline_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }

    //MARK: PBMVastLoaderDelegate
    
    func requestCompletedSuccess(_ vastResponse: PBMAdRequestResponseVAST) {
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        PBMAssertEq(vastResponse.ads?.count, 1)
        guard let ad = vastResponse.ads?.first as? PBMVastInlineAd else {
            XCTFail()
            return;
        }
        
        PBMAssertEq(ad.title, "VAST 2.0 Instream Test 1")
        PBMAssertEq(ad.adSystem, "Inline AdSystem")
        PBMAssertEq(ad.adSystemVersion, "1.0")
        PBMAssertEq(ad.advertiser, "Example Advertiser")
        PBMAssertEq(ad.errorURIs, ["http://myErrorURL/AdError"])
        PBMAssertEq(ad.impressionURIs, ["http://myTrackingURL/inline/impression", "http://myTrackingURL/inline/anotherImpression"])
        
        //There should be 3 creatives:
        //a Linear Creative
        //a Companion ad Creative composed of two companions (an image and an iframe)
        //And a NonlinearAds Creative composed of two Nonlinear ads (an image and an iframe)
        PBMAssertEq(ad.creatives.count, 3)
        
        //Creative 1  - Linear
        let pbmVastCreativeLinear = ad.creatives[0] as! PBMVastCreativeLinear
        PBMAssertEq(pbmVastCreativeLinear.AdId, "601364")
        PBMAssertEq(pbmVastCreativeLinear.id, "6012")
        PBMAssertEq(pbmVastCreativeLinear.sequence, 1)
        PBMAssertEq(pbmVastCreativeLinear.duration, 6)
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["creativeView"], ["http://myTrackingURL/inline/creativeView"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["start"], ["http://myTrackingURL/inline/start1", "http://myTrackingURL/inline/start2"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["midpoint"], ["http://myTrackingURL/inline/midpoint"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["firstQuartile"], ["http://myTrackingURL/inline/firstQuartile"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["thirdQuartile"], ["http://myTrackingURL/inline/thirdQuartile"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["complete"], ["http://myTrackingURL/inline/complete"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["mute"], ["http://myTrackingURL/inline/mute"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["unmute"], ["http://myTrackingURL/inline/unmute"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["pause"], ["http://myTrackingURL/inline/pause"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["rewind"], ["http://myTrackingURL/inline/rewind"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["resume"], ["http://myTrackingURL/inline/resume"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["fullscreen"], ["http://myTrackingURL/inline/fullscreen"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["expand"], ["http://myTrackingURL/inline/expand"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["collapse"], ["http://myTrackingURL/inline/collapse"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["acceptInvitation"], ["http://myTrackingURL/inline/acceptInvitation"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["close"], ["http://myTrackingURL/inline/close"])
        
        PBMAssertEq(pbmVastCreativeLinear.adParameters, "params=for&request=gohere")
        PBMAssertEq(pbmVastCreativeLinear.clickThroughURI, "http://www.openx.com")
        PBMAssertEq(pbmVastCreativeLinear.clickTrackingURIs, ["http://myTrackingURL/inline/click1", "http://myTrackingURL/inline/click2", "http://myTrackingURL/inline/custom1", "http://myTrackingURL/inline/custom2"])
        
        PBMAssertEq(pbmVastCreativeLinear.mediaFiles.count, 1)
        
        let mediaFile = pbmVastCreativeLinear.mediaFiles.firstObject as! PBMVastMediaFile
        PBMAssertEq(mediaFile.id, "firstFile")
        PBMAssertEq(mediaFile.streamingDeliver, false)
        PBMAssertEq(mediaFile.type, "video/mp4")
        PBMAssertEq(mediaFile.bitrate, 500)
        PBMAssertEq(mediaFile.width, 400)
        PBMAssertEq(mediaFile.height, 300)
        PBMAssertEq(mediaFile.scalable, true)
        PBMAssertEq(mediaFile.maintainAspectRatio, true)
        PBMAssertEq(mediaFile.apiFramework, "VPAID")
        PBMAssertEq(mediaFile.mediaURI, "http://get_video_file")
        
        
        //Creative 2 - CompanionAds
        let pbmVastCreativeCompanionAds = ad.creatives[1] as! PBMVastCreativeCompanionAds
        PBMAssertEq(pbmVastCreativeCompanionAds.companions.count, 2)
        
        //First Companion
        var pbmVastCreativeCompanionAdsCompanion = pbmVastCreativeCompanionAds.companions[0] as! PBMVastCreativeCompanionAdsCompanion
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.companionIdentifier, "big_box")
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.width, 300)
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.height, 250)
        //Should we support expandedWidth="600" expandedHeight="500" apiFramework="VPAID" ??
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.resource, "http://demo.tremormedia.com/proddev/vast/Blistex1.jpg")
        
        //TODO: change from "staticResource" to "jpeg" or something?
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.resourceType, PBMVastResourceType.staticResource)
        let trackingEvents = pbmVastCreativeCompanionAdsCompanion.trackingEvents.trackingEvents
        PBMAssertEq(trackingEvents.count, 1)
        PBMAssertEq(trackingEvents["creativeView"], ["http://myTrackingURL/inline/firstCompanionCreativeView"])
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.clickThroughURI, "http://www.openx.com")
        
        //Second Companion
        pbmVastCreativeCompanionAdsCompanion = pbmVastCreativeCompanionAds.companions[1] as! PBMVastCreativeCompanionAdsCompanion
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.resource, "http://ad3.liverail.com/util/companions.php")
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.resourceType, PBMVastResourceType.iFrameResource)
        
        //Creative 3 - NonLinearAds
        let pbmVastCreativeNonLinearAds = ad.creatives[2] as! PBMVastCreativeNonLinearAds
        PBMAssertEq(pbmVastCreativeNonLinearAds.nonLinears.count, 2)
        
        //First NonLinear
        var pbmVastCreativeNonLinearAdsNonLinear = pbmVastCreativeNonLinearAds.nonLinears[0] as! PBMVastCreativeNonLinearAdsNonLinear
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.resource, "http://cdn.liverail.com/adasset/228/330/overlay.jpg")
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.id, "special_overlay")
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.width, 300)
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.height, 50)
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.apiFramework, "VPAID")
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.scalable, true)
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.maintainAspectRatio, true)
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.clickThroughURI, "http://t3.liverail.com")
        
        //Second NonLinear
        pbmVastCreativeNonLinearAdsNonLinear = pbmVastCreativeNonLinearAds.nonLinears[1] as! PBMVastCreativeNonLinearAdsNonLinear
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.resource, "http://ad3.liverail.com/util/non_linear.php")
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.width, 728)
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.height, 90)
        PBMAssertEq(pbmVastCreativeNonLinearAdsNonLinear.clickThroughURI, "http://www.openx.com")
        
        // Must be in the end of the method
        self.vastRequestSuccessfulExpectation.fulfill()
    }
}
