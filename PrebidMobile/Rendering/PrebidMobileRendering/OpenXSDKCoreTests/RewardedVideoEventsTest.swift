//
//  RewardedVideoTest.swift
//  OpenXSDKCore
//
//  It will serve as the bases for Rewarded Video-specific tests.
//  Copyright © 2017 OpenX. All rights reserved.
//
import Foundation

import XCTest
import CoreFoundation

@testable import PrebidMobileRendering

class RewardedVideoEventsTest : XCTestCase, OXMCreativeViewDelegate {
    
    let vc = UIViewController()
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!
    
    var vastServerResponse: OXMAdRequestResponseVAST?
    
    var expectationCreativeWasClicked:XCTestExpectation!
    var expectationCreativeClickthroughDidClose:XCTestExpectation!
    var expectationCreativeDidDisplay:XCTestExpectation!
    
    var expectationDidFetchInline:XCTestExpectation!
    var expectationDidFetchVideo:XCTestExpectation!
    
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationTrackingEventMidpoint:XCTestExpectation!

    var oxmVideoCreative:OXMVideoCreative!
    
    override func setUp() {
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
        
        OXASDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testEvents() {
        self.initExpectations()
        OXASDKConfiguration.singleton.forcedIsViewable = true

        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        let adConfiguration = self.initAdConfiguration()
        
        MockServer.singleton().resetRules(
                self.createGeneralMockServerRules(connectionID: connection.internalID) +
                self.createTrackingEventRuleAndExpectations_BeforeMidpoint(connectionID: connection.internalID) +
                self.createTrackingEventRuleAndExpectations_AfterMidpoint(connectionID: connection.internalID)
        )
        
        self.vastRequestSuccessfulExpectation = self.expectation(description: "vastRequestSuccessfulExpectation")
        
        //Create CreativeModel
        
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:connection, adConfiguration: self.initAdConfiguration())
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.vastRequestSuccessfulExpectation.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail(error.localizedDescription)
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:connection, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.wait(for: [vastRequestSuccessfulExpectation], timeout: 2)
        
        XCTAssertNotNil(self.vastServerResponse)
        if self.vastServerResponse == nil {
            return // to avoid crash on force unwrap
        }
        
        let modelMaker = OXMCreativeModelCollectionMakerVAST(serverConnection:connection, adConfiguration: adConfiguration)
        
        var creativeFactory: OXMCreativeFactory?
        
        modelMaker.makeModels(self.vastServerResponse!, successCallback: { models in
            // count should include 1 video creative and 1 html creative (end card) for a total of 2.
            XCTAssertEqual(models.count, 2)
            
            guard let creativeModel: OXMCreativeModel = models.first else {
                XCTFail("Models is empty")
                return
            }
        
            let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
            transaction.creativeModels = [creativeModel]

            //Get a Creative
            creativeFactory = OXMCreativeFactory(serverConnection: connection,
                                                     transaction: transaction, finishedCallback: { creatives, error in
                    if (error != nil) {
                        XCTFail("error: \(error?.localizedDescription ?? "")")
                    }

                    self.expectationDownloadCompleted.fulfill()

                    guard let oxmVideoCreative = creatives?.first as? OXMVideoCreative else {
                        XCTFail("Could not cast creative as OXMRewardedVideoCreative")
                        return
                    }


                    self.oxmVideoCreative = oxmVideoCreative
                    oxmVideoCreative.creativeViewDelegate = self

                    DispatchQueue.main.async {
                        self.vc.view.addSubview(self.oxmVideoCreative.view!)
                        self.oxmVideoCreative.display(withRootViewController: self.vc)
                    }
                })

            DispatchQueue.global().async {
                creativeFactory?.start()
            }
        },
        failureCallback: { error in
            XCTFail(error.localizedDescription)
        })
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    //MARK: - CreativeViewDelegate
    func creativeWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative:OXMAbstractCreative) {}
    
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }

    func creativeDidComplete(_ creative:OXMAbstractCreative) {}
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative:OXMAbstractCreative) {}
    func creativeReady(toReimplant creative:OXMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative:OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative:OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative:OXMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
    
    //MARK: - Utility
    
    func createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle:String, connectionID: UUID) -> MockServerRule {
        let expectation = self.expectation(description: fireAndForgetUrlNeedle)
        let rule = MockServerRule(fireAndForgetURLNeedle: fireAndForgetUrlNeedle, connectionID: connectionID)
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            OXMLog.info("VAST Event: \(urlRequest.description)")
            expectation.fulfill()
        }
        
        return rule
    }
    
    func initExpectations() {
        self.expectationCreativeDidDisplay = self.expectation(description:"expectationCreativeDidDisplay")
        
        self.expectationDidFetchInline = self.expectation(description: "expectationDidFetchInline")
        
        //Note: this has a fulfillment count of 2 because pre-rendering it involves hitting the resource twice:
        //Once, for the headers to determine if it's small enough to preload
        //A second time, to actually download it.
        self.expectationDidFetchVideo = self.expectation(description: "expectationDidFetchVideo")
        self.expectationDidFetchVideo.expectedFulfillmentCount = 2
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")
        self.expectationTrackingEventMidpoint = self.expectation(description: "http://myTrackingURL/inline/midpoint")
    }
    
    func createGeneralMockServerRules(connectionID: UUID) -> [MockServerRule] {
        //Mock a server at "foo.com"
        MockServer.singleton().reset()
        
        let ruleInline = MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connectionID, fileName: "document_with_one_inline_ad.xml")
        ruleInline.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.expectationDidFetchInline.fulfill()
        }
        
        let ruleVideoFile = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connectionID, fileName: "small.mp4")
        ruleVideoFile.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.expectationDidFetchVideo.fulfill()
        }
        
        let ruleTrackMidpoint = MockServerRule(fireAndForgetURLNeedle: "http://myTrackingURL/inline/midpoint", connectionID: connectionID)
        ruleTrackMidpoint.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.expectationTrackingEventMidpoint.fulfill()
        }
        
        //Handle 404's
        MockServer.singleton().notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
        
        return [ruleInline, ruleVideoFile, ruleTrackMidpoint]
    }
    
    func createTrackingEventRuleAndExpectations_BeforeMidpoint(connectionID: UUID) -> [MockServerRule] {
        // Expect that the following URIs will get hit before playback reaches the midpoint:
        return [
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/impression", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/impression", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/anotherImpression", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/anotherImpression", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/creativeView", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/creativeView", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/start1", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/start1", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/start2", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/start2", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/firstQuartile", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/firstQuartile", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/midpoint", connectionID: connectionID)
        ]
    }
    
    func createTrackingEventRuleAndExpectations_AfterMidpoint(connectionID: UUID)  -> [MockServerRule] {
        return [
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/thirdQuartile", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/thirdQuartile", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/complete", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/complete", connectionID: connectionID)
        ]
    }
    
    func initAdConfiguration() -> OXMAdConfiguration {
        //Create adConfiguration
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
        adConfiguration.isInterstitialAd = true
        adConfiguration.isOptIn = true
        return adConfiguration
    }
    
    func creativeFactorySuccess(creative:OXMAbstractCreative)->() {
        self.expectationDownloadCompleted.fulfill()
    
        guard let oxmVideoCreative = creative as? OXMVideoCreative else {
            XCTFail("Could not cast \(creative) as OXMVideoCreative")
            return
        }
        
        self.oxmVideoCreative = oxmVideoCreative
        oxmVideoCreative.creativeViewDelegate = self
        
        DispatchQueue.main.async {
            self.vc.view.addSubview(self.oxmVideoCreative.view!)
            self.oxmVideoCreative.display(withRootViewController: self.vc)
        }
    }
    
    
}
