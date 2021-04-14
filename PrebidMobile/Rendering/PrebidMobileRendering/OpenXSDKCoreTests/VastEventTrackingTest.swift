//
//  VastEventTrackingTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation

import XCTest
import CoreFoundation

@testable import PrebidMobileRendering

class VastEventTrackingTest : XCTestCase, OXMCreativeViewDelegate {
  
    let vc = UIViewController()
    let modalManager = OXMModalManager()
    
    var creativeFactory: OXMCreativeFactory?
    
    var vastRequestSuccessfulExpectation: XCTestExpectation?
    
    var expectations = [XCTestExpectation]()

    var vastServerRespose: OXMAdRequestResponseVAST?
    var videoCreative: OXMVideoCreative!
    
    override func setUp() {
        super.setUp()
        
        self.expectations = [XCTestExpectation]()
    }
    
    override func tearDown() {
        self.creativeFactory = nil
        self.expectations.removeAll()
        
        OXASDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testEvents() {
        OXASDKConfiguration.singleton.forcedIsViewable = true
        modalManager.modalViewControllerClass = MockOXMModalViewController.self
    
        //Make an OXMServerConnection and redirect its network requests to the Mock Server
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        prepareMockServer(connectionID: connection.internalID)
        
        //Create adConfiguration
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video

        adConfiguration.isInterstitialAd = true
        
        loadAndRun(connection: connection, adConfiguration: adConfiguration, modalManager: modalManager)
        
        self.wait(for: self.expectations, timeout: 15, enforceOrder: false)
    }

    private func loadAndRun(connection: OXMServerConnectionProtocol, adConfiguration: OXMAdConfiguration, modalManager: OXMModalManager) {
       
        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:connection, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerRespose = response
            self.vastRequestSuccessfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail(error.localizedDescription)
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:connection, adConfiguration: adConfiguration)
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
        
        let modelMaker = OXMCreativeModelCollectionMakerVAST(serverConnection:connection, adConfiguration: adConfiguration)
        
        modelMaker.makeModels(self.vastServerRespose!, successCallback: { models in
            let totalModels = 2     // For video interstitials with End Card, count is 2. Includes all companions.
            XCTAssertEqual(models.count, totalModels)
           
            let companionsModel = models.last!;
            XCTAssertTrue(companionsModel.isCompanionAd)

            inlineVastRequestSuccessfulExpectation.fulfill()
            
            let creativeModel = models[0];
            let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
            transaction.creativeModels = [creativeModel]
            
            self.creativeFactory = OXMCreativeFactory(serverConnection: connection, transaction: transaction,
                finishedCallback: { creatives, error in
                    if (error != nil) {
                        XCTFail("error: \(error?.localizedDescription ?? "")")
                    }
                    
                    guard let creative = creatives?.first as? OXMVideoCreative else {
                        XCTFail("Could not cast creative as OXMVideoCreative")
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
    
    //MARK: - CreativeViewDelegate
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeDidComplete(_ creative:OXMAbstractCreative) {}
    func creativeWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative:OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative:OXMAbstractCreative) {}
    func creativeReady(toReimplant creative: OXMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative:OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative:OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative:OXMAbstractCreative) {}
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
    
    //MARK: - Utility
    
    func prepareMockServer(connectionID: UUID) {
        let ruleInline = MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connectionID, fileName: "document_with_one_inline_ad.xml")
        let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connectionID, fileName: "small.mp4")
        
        addExpectation("didFetchInline", for: ruleInline)
        
        //Note: this has a fulfillment count of 2 because pre-rendering it involves hitting the resource twice:
        //Once, for the headers to determine if it's small enough to preload
        //A second time, to actually download it.
        addExpectation("didFetchVideo", count: 2, for: ruleVideo)
        
        MockServer.singleton().resetRules([
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
        MockServer.singleton().notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
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
                guard let videoView = self.videoCreative.view as? OXMVideoView else {
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
                    self.modalManager.modalViewControllerCloseButtonTapped(self.modalManager.modalViewController!)
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
