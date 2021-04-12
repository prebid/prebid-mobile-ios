//
//  VideoEventsTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

@testable import OpenXApolloSDK
import Foundation
import XCTest

class VideoEventsTest : XCTestCase, OXMCreativeViewDelegate, OXMVideoViewDelegate {
   
    let viewController = MockViewController()
    let modalManager = OXMModalManager()
    var oxmVideoCreative:OXMVideoCreative!
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationCreativeDidComplete:XCTestExpectation!
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
        self.continueAfterFailure = true
        OXASDKConfiguration.singleton.forcedIsViewable = true

        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")
        self.expectationVideoDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        self.expectationCreativeDidDisplay = self.expectation(description: "expectationCreativeDidDisplay")
        
        //Make an OXMServerConnection and redirect its network requests to the Mock Server
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Change the inline response to claim that it will respond with m4v
        var inlineResponse = UtilitiesForTesting.loadFileAsStringFromBundle("document_with_one_inline_ad.xml")!
        let needle = MockServerMimeType.MP4.rawValue
        let replaceWith = MockServerMimeType.MP4.rawValue
        inlineResponse = inlineResponse.OXMstringByReplacingRegex(needle, replaceWith:replaceWith)
        
        //Rule for VAST
        let ruleVAST =  MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)
        
        //Add a rule for video File
        let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: "small.mp4")
        MockServer.singleton().resetRules([ruleVAST, ruleVideo])
        
        //Create adConfiguration
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
//        adConfiguration.domain = "foo.com/inline"
        
        //Create CreativeModel
        let creativeModel = OXMCreativeModel(adConfiguration:adConfiguration)
        creativeModel.videoFileURL = "http://get_video_file"
        
        let eventTracker = MockOXMAdModelEventTracker(creativeModel: creativeModel, serverConnection: connection)
        
        let expectationTrackEvent = expectation(description:"expectationTrackEvent")
        var trackEventCalled = false // Need to check general usage. Testing of particular events is performed by another test.
        eventTracker.mock_trackEvent = { _ in
            if !trackEventCalled {
                expectationTrackEvent.fulfill()
                trackEventCalled = true
            }
        }
        
        let expectationVideoAdLoaded = expectation(description:"expectationVideoAdLoaded")
        eventTracker.mock_trackVideoAdLoaded = { _ in
            expectationVideoAdLoaded.fulfill()
        }
        
        let expectationStartVideo = expectation(description:"expectationStartVideo")
        eventTracker.mock_trackStartVideo = { _, _ in
            expectationStartVideo.fulfill()
        }
        
        let expectationVolumeChanged = expectation(description:"expectationVolumeChanged")
        var trackVolumeChanged = false // Need to check general usage.
        eventTracker.mock_trackVolumeChanged = { _, _ in
            if !trackVolumeChanged {
                expectationVolumeChanged.fulfill()
                trackVolumeChanged = true
            }
        }
        
        creativeModel.eventTracker = eventTracker
        
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        transaction.creativeModels = [creativeModel]

        //Get a Creative
        
        let creativeFactory = OXMCreativeFactory(serverConnection:connection, transaction: transaction, finishedCallback: { creatives, error in
            
            if (error != nil) {
                XCTFail("error: \(error?.localizedDescription ?? "")")
            }
                
            self.expectationDownloadCompleted.fulfill()
            expectationVideoAdLoaded.fulfill()
            guard let oxmVideoCreative = creatives?.first as? OXMVideoCreative else {
                XCTFail("Could not cast creative as OXMVideoCreative")
                return
            }
            
            oxmVideoCreative.creativeViewDelegate = self
            oxmVideoCreative.videoView.videoViewDelegate = self
            self.oxmVideoCreative = oxmVideoCreative
            
            DispatchQueue.main.async {
                self.oxmVideoCreative.display(withRootViewController: self.viewController)
                self.oxmVideoCreative.videoView.avPlayer.volume = 0.33
            }
        })
        
        DispatchQueue.global().async {
            creativeFactory.start()
        }
        
        self.waitForExpectations(timeout: 10, handler:nil)
    }
    
    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
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
        self.modalManager.popModal()
    }
    
    func videoWasClicked() {}
}
