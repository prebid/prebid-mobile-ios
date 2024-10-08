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

@testable import PrebidMobile

class VideoEventsTest : XCTestCase, PBMCreativeViewDelegate, PBMVideoViewDelegate {
    
    let viewController = MockViewController()
    let modalManager = PBMModalManager()
    var pbmVideoCreative:PBMVideoCreative!
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationCreativeDidComplete:XCTestExpectation!
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidDisplay:XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testTypes() {
        self.continueAfterFailure = true
        Prebid.forcedIsViewable = true
        defer { Prebid.reset() }
        
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")
        self.expectationVideoDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        self.expectationCreativeDidDisplay = self.expectation(description: "expectationCreativeDidDisplay")
        
        //Make an PrebidServerConnection and redirect its network requests to the Mock Server
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Change the inline response to claim that it will respond with m4v
        var inlineResponse = UtilitiesForTesting.loadFileAsStringFromBundle("document_with_one_inline_ad.xml")!
        let needle = MockServerMimeType.MP4.rawValue
        let replaceWith = MockServerMimeType.MP4.rawValue
        inlineResponse = inlineResponse.PBMstringByReplacingRegex(needle, replaceWith:replaceWith)
        
        //Rule for VAST
        let ruleVAST =  MockServerRule(urlNeedle: "foo.com/inline", mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)
        
        //Add a rule for video File
        let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: "small.mp4")
        MockServer.shared.resetRules([ruleVAST, ruleVideo])
        
        //Create adConfiguration
        let adConfiguration = AdConfiguration()
        adConfiguration.adFormats = [.video]
        adConfiguration.winningBidAdFormat = .video
        //        adConfiguration.domain = "foo.com/inline"
        
        //Create CreativeModel
        let creativeModel = PBMCreativeModel(adConfiguration:adConfiguration)
        creativeModel.videoFileURL = "http://get_video_file"
        
        let eventTracker = MockPBMAdModelEventTracker(creativeModel: creativeModel, serverConnection: connection)
        
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
        
        let creativeFactory = PBMCreativeFactory(serverConnection:connection, transaction: transaction, finishedCallback: { creatives, error in
            
            if (error != nil) {
                XCTFail("error: \(error?.localizedDescription ?? "")")
            }
            
            self.expectationDownloadCompleted.fulfill()
            expectationVideoAdLoaded.fulfill()
            guard let pbmVideoCreative = creatives?.first as? PBMVideoCreative else {
                XCTFail("Could not cast creative as PBMVideoCreative")
                return
            }
            
            pbmVideoCreative.creativeViewDelegate = self
            pbmVideoCreative.videoView.videoViewDelegate = self
            self.pbmVideoCreative = pbmVideoCreative
            
            DispatchQueue.main.async {
                self.pbmVideoCreative.display(withRootViewController: self.viewController)
                self.pbmVideoCreative.videoView.avPlayer.volume = 0.33
            }
        })
        
        DispatchQueue.global().async {
            creativeFactory.start()
        }
        
        self.waitForExpectations(timeout: 10, handler:nil)
    }
    
    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: PBMAbstractCreative) {}
    func creativeReady(toReimplant creative: PBMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: PBMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: PBMAbstractCreative) {}
    
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative) {}
    
    // MARK: - PBMVideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        self.expectationVideoDidComplete.fulfill()
    }
    
    func videoWasClicked() {}
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
}
