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

@_spi(PBMInternal) @testable import PrebidMobile

class VideoEventsTest : XCTestCase, CreativeViewDelegate, VideoViewDelegate, TransactionDelegate {
    
    let viewController = MockViewController()
    var adWindow: UIWindow?
    let modalManager = ModalManager()
    var pbmVideoCreative:VideoCreative!
    var transaction: Transaction?
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationCreativeDidComplete:XCTestExpectation!
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidDisplay:XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        MockServer.shared.reset()
        // The ad's view goes into `viewController.view`; the viewability tracker counts it as visible only on screen.
        adWindow = UtilitiesForTesting.showOnScreen(viewController)
    }
    
    override func tearDown() {
        adWindow?.isHidden = true
        adWindow = nil
        transaction = nil
        MockServer.shared.reset()
        
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testTypes() {
        self.continueAfterFailure = true
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
        let creativeModel = CreativeModel(adConfiguration:adConfiguration)
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
        
        // Only the tracker fulfills this: the creative forwards the loaded event when it creates its Open Measurement
        // session.
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
        
        // The transaction runs the creative factory and then, on the main thread, creates its first creative's native
        // Open Measurement session, which makes the creative track the loaded event. The mock wrapper supplies that
        // session. `TransactionImpl.init` still reads `OpenMeasurementWrapper.shared`; the test replaces the wrapper
        // after that and before the factory starts.
        let transaction = Factory.createTransaction(serverConnection: connection,
                                                    adConfiguration: adConfiguration,
                                                    models: [creativeModel])
        transaction.measurementWrapper = MockMeasurementWrapper()
        transaction.delegate = self
        self.transaction = transaction
        
        DispatchQueue.global().async {
            transaction.startCreativeFactory()
        }
        
        self.waitForExpectations(timeout: 10, handler:nil)
    }
    
    //MARK: - TransactionDelegate
    func transactionReadyForDisplay(_ transaction: Transaction) {
        self.expectationDownloadCompleted.fulfill()
        guard let pbmVideoCreative = transaction.getFirstCreative() as? VideoCreative else {
            XCTFail("Could not cast creative as VideoCreative")
            return
        }

        pbmVideoCreative.creativeViewDelegate = self
        pbmVideoCreative.videoView.videoViewDelegate = self
        self.pbmVideoCreative = pbmVideoCreative

        DispatchQueue.main.async {
            self.viewController.view.addSubview(self.pbmVideoCreative.view!)
            self.pbmVideoCreative.display(rootViewController: self.viewController)
            self.pbmVideoCreative.videoView.avPlayer.volume = 0.33
        }
    }

    func transactionFailedToLoad(_ transaction: Transaction, error: Error) {
        XCTFail("error: \(error.localizedDescription)")
    }

    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative: AbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    
    func creativeDidDisplay(_ creative: AbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    
    // MARK: - VideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        self.expectationVideoDidComplete.fulfill()
    }
    
    func videoWasClicked() {}
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
}
