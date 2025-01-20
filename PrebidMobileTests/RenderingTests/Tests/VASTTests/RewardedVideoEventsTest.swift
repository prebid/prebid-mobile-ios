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

import Foundation

import XCTest
import CoreFoundation

@testable import PrebidMobile

class RewardedVideoEventsTest : XCTestCase, PBMCreativeViewDelegate {
    
    let vc = UIViewController()
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!
    
    var vastServerResponse: PBMAdRequestResponseVAST?
    
    var expectationCreativeWasClicked:XCTestExpectation!
    var expectationCreativeClickthroughDidClose:XCTestExpectation!
    var expectationCreativeDidDisplay:XCTestExpectation!
    
    var expectationDidFetchInline:XCTestExpectation!
    var expectationDidFetchVideo:XCTestExpectation!
    
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationTrackingEventMidpoint:XCTestExpectation!
    
    var pbmVideoCreative:PBMVideoCreative!
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared.reset()
        Prebid.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        
        MockServer.shared.reset()
        Prebid.reset()
    }
    
    func testEvents() {
        self.initExpectations()
        Prebid.forcedIsViewable = true
        defer { Prebid.reset() }
        
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        let adConfiguration = self.initAdConfiguration()
        adConfiguration.winningBidAdFormat = .video
        
        MockServer.shared.resetRules(
            self.createGeneralMockServerRules(connectionID: connection.internalID) +
            self.createTrackingEventRuleAndExpectations_BeforeMidpoint(connectionID: connection.internalID) +
            self.createTrackingEventRuleAndExpectations_AfterMidpoint(connectionID: connection.internalID)
        )
        
        self.vastRequestSuccessfulExpectation = self.expectation(description: "vastRequestSuccessfulExpectation")
        
        //Create CreativeModel
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:connection, adConfiguration: self.initAdConfiguration())
        
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
        
        var creativeFactory: PBMCreativeFactory?
        
        modelMaker.makeModels(self.vastServerResponse!, successCallback: { models in
            // count should include 1 video creative and 1 html creative (end card) for a total of 2.
            XCTAssertEqual(models.count, 2)
            
            guard let creativeModel: PBMCreativeModel = models.first else {
                XCTFail("Models is empty")
                return
            }
            
            let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
            transaction.creativeModels = [creativeModel]
            
            //Get a Creative
            creativeFactory = PBMCreativeFactory(serverConnection: connection,
                                                 transaction: transaction, finishedCallback: { creatives, error in
                if (error != nil) {
                    XCTFail("error: \(error?.localizedDescription ?? "")")
                }
                
                self.expectationDownloadCompleted.fulfill()
                
                guard let pbmVideoCreative = creatives?.first as? PBMVideoCreative else {
                    XCTFail("Could not cast creative as PBMRewardedVideoCreative")
                    return
                }
                
                
                self.pbmVideoCreative = pbmVideoCreative
                pbmVideoCreative.creativeViewDelegate = self
                
                DispatchQueue.main.async {
                    self.vc.view.addSubview(self.pbmVideoCreative.view!)
                    self.pbmVideoCreative.display(withRootViewController: self.vc)
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
    func creativeWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative:PBMAbstractCreative) {}
    
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func creativeDidComplete(_ creative:PBMAbstractCreative) {}
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative:PBMAbstractCreative) {}
    func creativeReady(toReimplant creative:PBMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative:PBMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative:PBMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative:PBMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative) {}
    
    //MARK: - Utility
    
    func createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle:String, connectionID: UUID) -> MockServerRule {
        let expectation = self.expectation(description: fireAndForgetUrlNeedle)
        let rule = MockServerRule(fireAndForgetURLNeedle: fireAndForgetUrlNeedle, connectionID: connectionID)
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            Log.info("VAST Event: \(urlRequest.description)")
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
        MockServer.shared.reset()
        
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
        MockServer.shared.notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
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
    
    func initAdConfiguration() -> AdConfiguration {
        //Create adConfiguration
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        adConfiguration.isInterstitialAd = true
        adConfiguration.isRewarded = true
        return adConfiguration
    }
    
    func creativeFactorySuccess(creative:PBMAbstractCreative)->() {
        self.expectationDownloadCompleted.fulfill()
        
        guard let pbmVideoCreative = creative as? PBMVideoCreative else {
            XCTFail("Could not cast \(creative) as PBMVideoCreative")
            return
        }
        
        self.pbmVideoCreative = pbmVideoCreative
        pbmVideoCreative.creativeViewDelegate = self
        
        DispatchQueue.main.async {
            self.vc.view.addSubview(self.pbmVideoCreative.view!)
            self.pbmVideoCreative.display(withRootViewController: self.vc)
        }
    }
}
