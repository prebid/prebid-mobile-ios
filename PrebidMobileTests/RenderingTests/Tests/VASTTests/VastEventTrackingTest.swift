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

class VastEventTrackingTest : XCTestCase, PBMCreativeViewDelegate {
  
    let vc = UIViewController()
    let modalManager = PBMModalManager()
    
    var creativeFactory: PBMCreativeFactory?
    
    var vastRequestSuccessfulExpectation: XCTestExpectation?
    
    var expectations = [XCTestExpectation]()

    var vastServerRespose: PBMAdRequestResponseVAST?
    var videoCreative: PBMVideoCreative!
    
    override func setUp() {
        super.setUp()
        
        self.expectations = [XCTestExpectation]()
    }
    
    override func tearDown() {
        self.creativeFactory = nil
        self.expectations.removeAll()
        
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testEvents() {
        Prebid.forcedIsViewable = true
        defer { Prebid.reset() }

        modalManager.modalViewControllerClass = MockPBMModalViewController.self
    
        //Make an PrebidServerConnection and redirect its network requests to the Mock Server
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        prepareMockServer(connectionID: connection.internalID)
        
        //Create adConfiguration
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        adConfiguration.winningBidAdFormat = .video

        adConfiguration.isInterstitialAd = true
        
        loadAndRun(connection: connection, adConfiguration: adConfiguration, modalManager: modalManager)
        
        self.wait(for: self.expectations, timeout: 15, enforceOrder: false)
    }

    private func loadAndRun(connection: PrebidServerConnectionProtocol, adConfiguration: AdConfiguration, modalManager: PBMModalManager) {
       
        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        let adLoadManager = MockPBMAdLoadManagerVAST(bid: RawWinningBidFabricator.makeWinningBid(price: 0.1, bidder: "bidder", cacheID: "cache-id"), connection:connection, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerRespose = response
            self.vastRequestSuccessfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail(error.localizedDescription)
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:connection, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml") {
            requester.buildAdsArray(data)
        }
                
        self.wait(for: [vastRequestSuccessfulExpectation!], timeout: 2)
        
        XCTAssertNotNil(self.vastServerRespose)
        if self.vastServerRespose == nil {
            return
        }
        
        let inlineVastRequestSuccessfulExpectation = self.expectation(description: "Expected Inline VAST Load to be successful")
        
        let modelMaker = PBMCreativeModelCollectionMakerVAST(serverConnection:connection, adConfiguration: adConfiguration)
        
        modelMaker.makeModels(self.vastServerRespose!, successCallback: { models in
            let totalModels = 2     // For video interstitials with End Card, count is 2. Includes all companions.
            XCTAssertEqual(models.count, totalModels)
           
            let companionsModel = models.last!;
            XCTAssertTrue(companionsModel.isCompanionAd)

            inlineVastRequestSuccessfulExpectation.fulfill()
            
            let creativeModel = models[0];
            let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
            transaction.creativeModels = [creativeModel]
            
            self.creativeFactory = PBMCreativeFactory(serverConnection: connection, transaction: transaction,
                finishedCallback: { creatives, error in
                    if (error != nil) {
                        XCTFail("error: \(error?.localizedDescription ?? "")")
                    }
                    
                    guard let creative = creatives?.first as? PBMVideoCreative else {
                        XCTFail("Could not cast creative as PBMVideoCreative")
                        return
                    }
                    
                    creative.modalManager = modalManager
                    
                    self.videoCreative = creative
                    self.videoCreative.creativeViewDelegate = self
                    
                    DispatchQueue.main.async {
                        self.vc.view.addSubview(self.videoCreative.view!)
                        self.videoCreative.display(withRootViewController: self.vc)
                    }
            })
            
            DispatchQueue.global().async {
                self.creativeFactory?.start()
            }
            }, failureCallback: { error in
                inlineVastRequestSuccessfulExpectation.fulfill()
                XCTFail(error.localizedDescription)
            })
        
        self.wait(for: [inlineVastRequestSuccessfulExpectation], timeout: 1)
    }
    
    // MARK: - CreativeViewDelegate
    
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeDidComplete(_ creative:PBMAbstractCreative) {}
    func creativeWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative:PBMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative:PBMAbstractCreative) {}
    func creativeReady(toReimplant creative: PBMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative:PBMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative:PBMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative:PBMAbstractCreative) {}
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative) {}
    
    //MARK: - Utility
    
    func prepareMockServer(connectionID: UUID) {
        let ruleInline = MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connectionID, fileName: "document_with_one_inline_ad.xml")
        let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connectionID, fileName: "small.mp4")
        
        addExpectation("didFetchInline", for: ruleInline)
        
        //Note: this has a fulfillment count of 2 because pre-rendering it involves hitting the resource twice:
        //Once, for the headers to determine if it's small enough to preload
        //A second time, to actually download it.
        addExpectation("didFetchVideo", count: 2, for: ruleVideo)
        
        MockServer.shared.resetRules([
            //Load the ad
            ruleInline,
            ruleVideo,
            
            // Expect that the following URIs will get hit before playback reaches the midpoint:
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
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/midpoint", connectionID: connectionID),
            
            cretaeMiddlepointRuleEndExpectation(needle: "http://myTrackingURL/inline/midpoint", connectionID: connectionID),
            
            // Expect that the following URIs will get hit after the midpoint:
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/pause", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/pause", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/click1", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/click1", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/click2", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/click2", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/custom1", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/custom1", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/custom2", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/custom2", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/resume", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/resume", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/thirdQuartile", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/thirdQuartile", connectionID: connectionID),
            
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/inline/complete", connectionID: connectionID),
            createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle: "myTrackingURL/wrapper/complete", connectionID: connectionID)
            ])
        
        //Handle 404's
        MockServer.shared.notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
    }
    
    func addExpectation(_ description: String, count: UInt = 1)  -> XCTestExpectation {
        let expectation = XCTestExpectation(description: description)
        expectation.expectedFulfillmentCount = Int(count)
        
        self.expectations.append(expectation)
        
        return expectation
    }
    
    func cretaeMiddlepointRuleEndExpectation(needle:String, connectionID: UUID) -> MockServerRule {
        let rule = MockServerRule(fireAndForgetURLNeedle: "http://myTrackingURL/inline/midpoint", connectionID: connectionID)
        addExpectation("expectationMidpoint", for: rule, completion: {
            //Once we've reached the midpoint, force a tap on the Learn More Button.
            //This should pause the video and summon the clickthrough.
            DispatchQueue.main.async {
                guard let videoView = self.videoCreative.view as? PBMVideoView else {
                    XCTFail("Couldn't get Video View")
                    return
                }
                
                //Note: this does not simulate an actual touch event but it's the best that
                //can be done for unit testing purposes.
                videoView.btnLearnMoreClick()
                
                //Wait 3 seconds then fire a close event
                DispatchQueue.main.asyncAfter(deadline:.now() + 3.0) { [weak self] in
                    guard let self = self else {
                        return;
                    }
                    
                    // Simulate SFSafariViewController closing
                    self.videoCreative.safariOpener!.safariViewControllerDidFinish(self.videoCreative.safariOpener!.safariViewController!)
                }
            }
        })
        
        return rule
    }
    
    func createTrackingEventRuleAndExpectation(fireAndForgetUrlNeedle:String, connectionID: UUID) -> MockServerRule {
        let rule = MockServerRule(fireAndForgetURLNeedle: fireAndForgetUrlNeedle, connectionID: connectionID)
        addExpectation(fireAndForgetUrlNeedle, for: rule)
        
        return rule
    }
    
    func addExpectation(_ description: String, count: UInt = 1, for rule: MockServerRule, completion: (() -> Void)? = nil) {
        let expectation = addExpectation(description, count: count)
        
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            expectation.fulfill()
            
            completion?()
        }
    }
}
