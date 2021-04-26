//
//  RewardedVideo_CompanionTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class RewardedVideo_CompanionTest: XCTestCase  {
    
    let vc = UIViewController()
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    var expectationCreativeWasClicked:XCTestExpectation!
    var expectationCreativeClickthroughDidClose:XCTestExpectation!
    
    var expectationDidFetchInline:XCTestExpectation!
    var expectationDidFetchVideo:XCTestExpectation!
    
    
    var pbmRewardedVideoCreative:PBMVideoCreative!
    
    var expectationTrackingEventCreativeView:XCTestExpectation!
    let trackingUrlCreativeView = "http://myTrackingURL/inline/firstCompanionCreativeView"
    
    var expectationTrackingEventCompanionClickTracking:XCTestExpectation!
    let trackingUrlCompanionClickTracking = "http://CompanionClickTracking"
    
    override func setUp() {
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
    }
    
    func testCompanionCreativeCreation() {
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        let adConfiguration = self.initAdConfiguration()

        self.initExpectations()
        self.initMockServer(connectionID: connection.internalID)
        
        //Create CreativeModel
        
        let adLoadManager = MockPBMAdLoadManagerVAST(connection:connection, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.vastRequestSuccessfulExpectation.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail(error.localizedDescription)
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:connection, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.wait(for: [vastRequestSuccessfulExpectation], timeout: 2)
        
        XCTAssertNotNil(self.vastServerResponse)
        if self.vastServerResponse == nil {
            return // to avoid crash on force unwrap
        }
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:connection, adConfiguration: adConfiguration)
        
        modelMaker.makeModels(self.vastServerResponse!,
            successCallback: { models in
                // count should include 1 video creative and 1 html creative (end card) for a total of 2.
                XCTAssertEqual(models.count, 2)

                guard let _:PBMCreativeModel = models.first else {
                    XCTFail("Models is empty")
                    return
                }

                // Verify that the 2nd item is a Companion Model
                if models.count == 2 {
                    let companionModel:PBMCreativeModel = models[1]
                    XCTAssertTrue(companionModel.isCompanionAd)
                    XCTAssertFalse(companionModel.hasCompanionAd)

                    // Verify that the currect number of tracking urls are present.
                    XCTAssertEqual(companionModel.trackingURLs["creativeView"]?.count, 1, "Expected tracking URLs not found")

                    // Verify that the currect number of tracking urls are present.
                    XCTAssertEqual(companionModel.trackingURLs["creativeModelTrackingKey_CompanionClick"]?.count, 1, "Expected companiong click tracking URLs not found")

                    var expected : String
                    var actual : String?

                    expected = self.trackingUrlCreativeView
                    actual = companionModel.trackingURLs["creativeView"]![0]
                    XCTAssertEqual(actual, expected, "Invalid tracking url")

                    // Generate a tracking event.
                    let eventTracker = PBMAdModelEventTracker(creativeModel: companionModel, serverConnection: connection)
                    eventTracker.trackEvent(PBMTrackingEvent.creativeView)
                    
                    // Companion ClickTracking
                    expected = self.trackingUrlCompanionClickTracking
                    actual = companionModel.trackingURLs["creativeModelTrackingKey_CompanionClick"]?[0]
                    XCTAssertEqual(actual, expected, "Invalid companion click tracking url")
                    // Generate companion click tracking
                    eventTracker.trackEvent(PBMTrackingEvent.companionClick)
                }
                else {
                    XCTFail("Unexpected number of models.");
                }
            },
            failureCallback: { error in
                XCTFail(error.localizedDescription)
            })
        
        self.waitForExpectations(timeout: 10, handler:nil)

    }
    
    //MARK: - Utility

    func initExpectations() {
        self.vastRequestSuccessfulExpectation = self.expectation(description: "vastRequestSuccessfulExpectation")
        self.expectationDidFetchInline = self.expectation(description: "expectationDidFetchInline")
        self.expectationTrackingEventCreativeView = self.expectation(description: "expectationTrackingEventCreativeView")
        self.expectationTrackingEventCompanionClickTracking = self.expectation(description: "expectationTrackingEventCompanionClickTracking")
    }
    
    func initMockServer(connectionID: UUID) {
        
        let ruleInline = MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connectionID, fileName: "document_with_one_inline_ad.xml")
        ruleInline.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.expectationDidFetchInline.fulfill()
        }
        
        // Create a rule to handle the companion create view event.
        let ruleTrack1 = MockServerRule(fireAndForgetURLNeedle: self.trackingUrlCreativeView, connectionID: connectionID)
        ruleTrack1.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            // Received a CreateView tracking event
            self.expectationTrackingEventCreativeView.fulfill()
        }

        // Create a rule to handle the companion click tracking event.
        let ruleTrack2 = MockServerRule(fireAndForgetURLNeedle: self.trackingUrlCompanionClickTracking, connectionID: connectionID)
        ruleTrack2.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            // Received a Companion click tracking event
            self.expectationTrackingEventCompanionClickTracking.fulfill()
        }
        MockServer.singleton().resetRules([ruleInline, ruleTrack1, ruleTrack2])
        
        //Handle 404's
        MockServer.singleton().notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
    }
    
    func initAdConfiguration() -> PBMAdConfiguration {
        //Create adConfiguration
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .videoInternal

        adConfiguration.isInterstitialAd = true
        adConfiguration.isOptIn = true
        return adConfiguration
    }
}
