//
//  VideoFileTypeTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//
import Foundation
import XCTest

@testable import PrebidMobileRendering

class VideoFileTypeTest : XCTestCase, OXMCreativeViewDelegate, OXMVideoViewDelegate {
    
    let viewController = MockViewController()
    var oxmVideoCreative:OXMVideoCreative!
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidDisplay:XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
        
        OXASDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testTypes() {
        OXASDKConfiguration.singleton.forcedIsViewable = true
        self.continueAfterFailure = true
        
        let typesToTest: [(MockServerMimeType, String)] = [
            (.MP4, "small.mp4"),
            (.MOV, "small.mov"),
            (.M4V, "small.m4v"),
            (.XM4V, "small.m4v")
        ]
        
        for (mimeType, fileName) in typesToTest {
            
            for view in self.viewController.view.subviews {
                view.removeFromSuperview()
            }
            
            self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
            self.expectationVideoDidComplete = self.expectation(description: "expectationVideoDidComplete")
            self.expectationCreativeDidDisplay = self.expectation(description: "expectationCreativeDidDisplay")
            
            //Change the inline response to claim that it will respond with m4v
            var inlineResponse = UtilitiesForTesting.loadFileAsStringFromBundle("document_with_one_inline_ad.xml")!
            let needle = MockServerMimeType.MP4.rawValue
            let replaceWith = mimeType.rawValue
            inlineResponse = inlineResponse.OXMstringByReplacingRegex(needle, replaceWith:replaceWith)
            
            //Make an OXMServerConnection and redirect its network requests to the Mock Server
            let connection = UtilitiesForTesting.createConnectionForMockedTest()
            
            //Rule for VAST
            let ruleVAST =  MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)
            
            //Add a rule for video File
            let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType: mimeType.rawValue, connectionID: connection.internalID, fileName: fileName)
            MockServer.singleton().resetRules([ruleVAST, ruleVideo])
            
            //Create adConfiguration
            let adConfiguration = OXMAdConfiguration()
            adConfiguration.adFormat = .video
//            adConfiguration.domain = "foo.com/inline"
            
            //Create CreativeModel
            let creativeModel = OXMCreativeModel(adConfiguration:adConfiguration)
            creativeModel.videoFileURL = "http://get_video_file"
            
            let transaction = UtilitiesForTesting.createEmptyTransaction()
            transaction.creativeModels = [creativeModel]

            //Get a Creative
            let creativeFactory = OXMCreativeFactory(serverConnection:connection, transaction: transaction, finishedCallback: { creativesArray, error in
                
                    if (error != nil) {
                        XCTFail("error: \(error?.localizedDescription ?? "")")
                    }
                    
                    self.expectationDownloadCompleted.fulfill()
                    
                    guard let oxmVideoCreative = creativesArray?.first as? OXMVideoCreative else {
                        XCTFail("Could not cast creative as OXMVideoCreative")
                        return
                    }
                    
                    oxmVideoCreative.creativeViewDelegate = self
                    oxmVideoCreative.videoView.videoViewDelegate = self
                    self.oxmVideoCreative = oxmVideoCreative
                    
                    DispatchQueue.main.async {
                        self.oxmVideoCreative.display(withRootViewController: self.viewController)
                    }
                }
            )
            
            DispatchQueue.global().async {
                creativeFactory.start()
            }
            
            self.waitForExpectations(timeout: 10, handler:nil)
        }
    }
    
    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative: OXMAbstractCreative) {}
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {}
    func creativeReady(toReimplant creative: OXMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {}
    
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
    
    // MARK: - OXMVideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        self.expectationVideoDidComplete.fulfill()
    }
    
    func videoWasClicked() {}
}
