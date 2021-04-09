import XCTest

@testable import OpenXApolloSDK

class OXMVastLoaderTestSingleInline: XCTestCase {
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!

    override func setUp() {
        self.continueAfterFailure = true
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {

        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        //Make an OXMServerConnection and redirect its network requests to the Mock Server
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
        
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.requestCompletedSuccess(response)
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail("\(error)")
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_inline_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }

    //MARK: OXMVastLoaderDelegate
    
    func requestCompletedSuccess(_ vastResponse: OXMAdRequestResponseVAST) {
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        OXMAssertEq(vastResponse.ads?.count, 1)
        guard let ad = vastResponse.ads?.first as? OXMVastInlineAd else {
            XCTFail()
            return;
        }
        
        OXMAssertEq(ad.title, "VAST 2.0 Instream Test 1")
        OXMAssertEq(ad.adSystem, "Inline AdSystem")
        OXMAssertEq(ad.adSystemVersion, "1.0")
        OXMAssertEq(ad.advertiser, "Example Advertiser")
        OXMAssertEq(ad.errorURIs, ["http://myErrorURL/AdError"])
        OXMAssertEq(ad.impressionURIs, ["http://myTrackingURL/inline/impression", "http://myTrackingURL/inline/anotherImpression"])
        
        //There should be 3 creatives:
        //a Linear Creative
        //a Companion ad Creative composed of two companions (an image and an iframe)
        //And a NonlinearAds Creative composed of two Nonlinear ads (an image and an iframe)
        OXMAssertEq(ad.creatives.count, 3)
        
        //Creative 1  - Linear
        let oxmVastCreativeLinear = ad.creatives[0] as! OXMVastCreativeLinear
        OXMAssertEq(oxmVastCreativeLinear.AdId, "601364")
        OXMAssertEq(oxmVastCreativeLinear.id, "6012")
        OXMAssertEq(oxmVastCreativeLinear.sequence, 1)
        OXMAssertEq(oxmVastCreativeLinear.duration, 6)
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["creativeView"], ["http://myTrackingURL/inline/creativeView"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["start"], ["http://myTrackingURL/inline/start1", "http://myTrackingURL/inline/start2"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["midpoint"], ["http://myTrackingURL/inline/midpoint"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["firstQuartile"], ["http://myTrackingURL/inline/firstQuartile"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["thirdQuartile"], ["http://myTrackingURL/inline/thirdQuartile"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["complete"], ["http://myTrackingURL/inline/complete"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["mute"], ["http://myTrackingURL/inline/mute"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["unmute"], ["http://myTrackingURL/inline/unmute"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["pause"], ["http://myTrackingURL/inline/pause"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["rewind"], ["http://myTrackingURL/inline/rewind"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["resume"], ["http://myTrackingURL/inline/resume"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["fullscreen"], ["http://myTrackingURL/inline/fullscreen"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["expand"], ["http://myTrackingURL/inline/expand"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["collapse"], ["http://myTrackingURL/inline/collapse"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["acceptInvitation"], ["http://myTrackingURL/inline/acceptInvitation"])
        OXMAssertEq(oxmVastCreativeLinear.vastTrackingEvents.trackingEvents["close"], ["http://myTrackingURL/inline/close"])
        
        OXMAssertEq(oxmVastCreativeLinear.adParameters, "params=for&request=gohere")
        OXMAssertEq(oxmVastCreativeLinear.clickThroughURI, "http://www.openx.com")
        OXMAssertEq(oxmVastCreativeLinear.clickTrackingURIs, ["http://myTrackingURL/inline/click1", "http://myTrackingURL/inline/click2", "http://myTrackingURL/inline/custom1", "http://myTrackingURL/inline/custom2"])
        
        OXMAssertEq(oxmVastCreativeLinear.mediaFiles.count, 1)
        
        let mediaFile = oxmVastCreativeLinear.mediaFiles.firstObject as! OXMVastMediaFile
        OXMAssertEq(mediaFile.id, "firstFile")
        OXMAssertEq(mediaFile.streamingDeliver, false)
        OXMAssertEq(mediaFile.type, "video/mp4")
        OXMAssertEq(mediaFile.bitrate, 500)
        OXMAssertEq(mediaFile.width, 400)
        OXMAssertEq(mediaFile.height, 300)
        OXMAssertEq(mediaFile.scalable, true)
        OXMAssertEq(mediaFile.maintainAspectRatio, true)
        OXMAssertEq(mediaFile.apiFramework, "VPAID")
        OXMAssertEq(mediaFile.mediaURI, "http://get_video_file")
        
        
        //Creative 2 - CompanionAds
        let oxmVastCreativeCompanionAds = ad.creatives[1] as! OXMVastCreativeCompanionAds
        OXMAssertEq(oxmVastCreativeCompanionAds.companions.count, 2)
        
        //First Companion
        var oxmVastCreativeCompanionAdsCompanion = oxmVastCreativeCompanionAds.companions[0] as! OXMVastCreativeCompanionAdsCompanion
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.companionIdentifier, "big_box")
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.width, 300)
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.height, 250)
        //Should we support expandedWidth="600" expandedHeight="500" apiFramework="VPAID" ??
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.resource, "http://demo.tremormedia.com/proddev/vast/Blistex1.jpg")
        
        //TODO: change from "staticResource" to "jpeg" or something?
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.resourceType, OXMVastResourceType.staticResource)
        let trackingEvents = oxmVastCreativeCompanionAdsCompanion.trackingEvents.trackingEvents
        OXMAssertEq(trackingEvents.count, 1)
        OXMAssertEq(trackingEvents["creativeView"], ["http://myTrackingURL/inline/firstCompanionCreativeView"])
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.clickThroughURI, "http://www.openx.com")
        
        //Second Companion
        oxmVastCreativeCompanionAdsCompanion = oxmVastCreativeCompanionAds.companions[1] as! OXMVastCreativeCompanionAdsCompanion
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.resource, "http://ad3.liverail.com/util/companions.php")
        OXMAssertEq(oxmVastCreativeCompanionAdsCompanion.resourceType, OXMVastResourceType.iFrameResource)
        
        //Creative 3 - NonLinearAds
        let oxmVastCreativeNonLinearAds = ad.creatives[2] as! OXMVastCreativeNonLinearAds
        OXMAssertEq(oxmVastCreativeNonLinearAds.nonLinears.count, 2)
        
        //First NonLinear
        var oxmVastCreativeNonLinearAdsNonLinear = oxmVastCreativeNonLinearAds.nonLinears[0] as! OXMVastCreativeNonLinearAdsNonLinear
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.resource, "http://cdn.liverail.com/adasset/228/330/overlay.jpg")
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.id, "special_overlay")
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.width, 300)
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.height, 50)
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.apiFramework, "VPAID")
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.scalable, true)
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.maintainAspectRatio, true)
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.clickThroughURI, "http://t3.liverail.com")
        
        //Second NonLinear
        oxmVastCreativeNonLinearAdsNonLinear = oxmVastCreativeNonLinearAds.nonLinears[1] as! OXMVastCreativeNonLinearAdsNonLinear
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.resource, "http://ad3.liverail.com/util/non_linear.php")
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.width, 728)
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.height, 90)
        OXMAssertEq(oxmVastCreativeNonLinearAdsNonLinear.clickThroughURI, "http://www.openx.com")
        
        // Must be in the end of the method
        self.vastRequestSuccessfulExpectation.fulfill()
    }
}
