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

class PBMVastLoaderTestWrapperPlusInline: XCTestCase {
    
    var didFetchInline:XCTestExpectation!
    var vastRequestSuccessfulExpectation:XCTestExpectation!
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    override func setUp() {
        self.continueAfterFailure = true
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        self.didFetchInline = nil
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {
        
        self.didFetchInline = self.expectation(description: "Expected PrebidServerConnection to hit foo.com/inline")
        self.vastRequestSuccessfulExpectation = self.expectation(description: "vastRequestSuccessfulExpectation #1")
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        ////////////////////////////
        //Mock a server at "foo.com"
        ////////////////////////////
        MockServer.shared.reset()
        let ruleInline =  MockServerRule(urlNeedle: "foo.com/inline/vast", mimeType:  MockServerMimeType.XML.rawValue, connectionID: conn.internalID, fileName: "document_with_one_inline_ad.xml")
        ruleInline.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            Log.info("didFetchInline.fulfill()")
            self.didFetchInline.fulfill()
        }
        
        MockServer.shared.resetRules([ruleInline])
        
        //Handle 404's
        MockServer.shared.notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
        
        //////////////////////////////////////////////////////////////////////////////////
        //Make an PrebidServerConnection and redirect its network requests to the Mock Server
        //////////////////////////////////////////////////////////////////////////////////
        
        
        let adConfiguration = AdConfiguration()
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.vastRequestSuccessfulExpectation.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail(error.localizedDescription)
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        guard let response = self.vastServerResponse else {
            XCTFail()
            return
        }
        
        check(response)
        
        let inlineVastRequestSuccessfulExpectation = self.expectation(description: "Expected Inline VAST Load to be successful")
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        
        modelMaker.makeModels(response,
                              successCallback: { models in
            let createModelCount = 2  // For video interstitials with End Card, count is 2. Includes all companions.
            XCTAssertEqual(models.count, createModelCount)
            inlineVastRequestSuccessfulExpectation.fulfill()
        },
                              failureCallback: { error in
            inlineVastRequestSuccessfulExpectation.fulfill()
            XCTFail(error.localizedDescription)
        })
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    // MARK: - Check result
    
    func check(_ response: NSObject) {
        guard let vastResponse = response as? PBMAdRequestResponseVAST else {
            XCTFail()
            return
        }
        
        guard let ads = vastResponse.ads else {
            XCTFail()
            return
        }
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        if (ads.count != 1) {
            XCTFail("Expected 1 ad, got \(ads.count)")
            return
        }
        
        let ad = ads.first!
        
        PBMAssertEq(ad.adSystem, "Inline AdSystem")
        PBMAssertEq(ad.adSystemVersion, "1.0")
        PBMAssertEq(ad.errorURIs, ["http://myErrorURL/AdError"])
        PBMAssertEq(ad.impressionURIs, ["http://myTrackingURL/inline/impression", "http://myTrackingURL/inline/anotherImpression", "http://myTrackingURL/wrapper/impression", "http://myTrackingURL/wrapper/anotherImpression"])
        
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
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["creativeView"], ["http://myTrackingURL/inline/creativeView", "http://myTrackingURL/wrapper/creativeView"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["start"], ["http://myTrackingURL/inline/start1", "http://myTrackingURL/inline/start2", "http://myTrackingURL/wrapper/start1", "http://myTrackingURL/wrapper/start2"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["midpoint"], ["http://myTrackingURL/inline/midpoint", "http://myTrackingURL/wrapper/midpoint"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["firstQuartile"], ["http://myTrackingURL/inline/firstQuartile", "http://myTrackingURL/wrapper/firstQuartile"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["thirdQuartile"], ["http://myTrackingURL/inline/thirdQuartile", "http://myTrackingURL/wrapper/thirdQuartile"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["complete"], ["http://myTrackingURL/inline/complete", "http://myTrackingURL/wrapper/complete"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["mute"], ["http://myTrackingURL/inline/mute", "http://myTrackingURL/wrapper/mute"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["unmute"], ["http://myTrackingURL/inline/unmute", "http://myTrackingURL/wrapper/unmute"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["pause"], ["http://myTrackingURL/inline/pause", "http://myTrackingURL/wrapper/pause"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["rewind"], ["http://myTrackingURL/inline/rewind", "http://myTrackingURL/wrapper/rewind"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["resume"], ["http://myTrackingURL/inline/resume", "http://myTrackingURL/wrapper/resume"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["fullscreen"], ["http://myTrackingURL/inline/fullscreen", "http://myTrackingURL/wrapper/fullscreen"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["expand"], ["http://myTrackingURL/inline/expand", "http://myTrackingURL/wrapper/expand"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["collapse"], ["http://myTrackingURL/inline/collapse", "http://myTrackingURL/wrapper/collapse"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["acceptInvitation"], ["http://myTrackingURL/inline/acceptInvitation", "http://myTrackingURL/wrapper/acceptInvitation"])
        PBMAssertEq(pbmVastCreativeLinear.vastTrackingEvents.trackingEvents["close"], ["http://myTrackingURL/inline/close", "http://myTrackingURL/wrapper/close"])
        
        PBMAssertEq(pbmVastCreativeLinear.adParameters, "params=for&request=gohere")
        PBMAssertEq(pbmVastCreativeLinear.clickThroughURI, "http://www.openx.com")
        PBMAssertEq(pbmVastCreativeLinear.clickTrackingURIs, ["http://myTrackingURL/inline/click1", "http://myTrackingURL/inline/click2", "http://myTrackingURL/inline/custom1", "http://myTrackingURL/inline/custom2", "http://myTrackingURL/wrapper/click1", "http://myTrackingURL/wrapper/click2", "http://myTrackingURL/wrapper/custom1", "http://myTrackingURL/wrapper/custom2"])
        
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
        let pbmVastCreativeCompanionAdsCompanion = pbmVastCreativeCompanionAds.companions[0] as! PBMVastCreativeCompanionAdsCompanion
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.companionIdentifier, "big_box")
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.width, 300)
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.height, 250)
        //Should we support expandedWidth="600" expandedHeight="500" apiFramework="VPAID" ??
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.resource, "http://demo.tremormedia.com/proddev/vast/Blistex1.jpg")
        
        //TODO: change from "staticResource" to "jpeg" or something?
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.resourceType, PBMVastResourceType.staticResource)
        let trackingEvents = pbmVastCreativeCompanionAdsCompanion.trackingEvents.trackingEvents
        PBMAssertEq(trackingEvents.count, 2)
        PBMAssertEq(trackingEvents["creativeView"], ["http://myTrackingURL/inline/firstCompanionCreativeView"])
        PBMAssertEq(trackingEvents["creativeViewFromWrapper"], ["http://myTrackingURL/wrapper/firstCompanionCreativeView"])
        PBMAssertEq(pbmVastCreativeCompanionAdsCompanion.clickThroughURI, "http://www.openx.com")
        
    }
}
