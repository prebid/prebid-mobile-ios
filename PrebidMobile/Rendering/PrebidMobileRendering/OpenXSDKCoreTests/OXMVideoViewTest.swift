//
//  OXMVideoViewTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMVideoViewTest: XCTestCase, OXMCreativeResolutionDelegate, OXMCreativeViewDelegate, OXMVideoViewDelegate {

    var vc: UIViewController?
    let connection = UtilitiesForTesting.createConnectionForMockedTest()
    
    var videoCreative:OXMVideoCreative!
    var expectationDownloadCompleted:XCTestExpectation?
    var expectationCreativeReady:XCTestExpectation?
    var expectationCreativeDidComplete:XCTestExpectation?
    var expectationCreativeWasClicked:XCTestExpectation?
    var expectationClickthroughBrowserClosed:XCTestExpectation?
    var expectationVideoViewCompletedDisplay:XCTestExpectation?
    
    var isVideoViewCompletedDisplay = false;    
    
    // MARK: - Setup
    
    override func setUp() {
        MockServer.singleton().reset()
    }

    override func tearDown() {
        MockServer.singleton().reset()
        self.videoCreative = nil
        self.expectationDownloadCompleted = nil
        self.expectationCreativeReady = nil
        self.expectationCreativeDidComplete = nil
        self.expectationCreativeWasClicked = nil
        self.expectationClickthroughBrowserClosed = nil
        self.expectationVideoViewCompletedDisplay = nil
    }
    
    // MARK: - Tests
    
    func testLearnMoreButton() {
        self.setupVideoCreative()
        
        self.videoCreative.creativeModel!.clickThroughURL = "www.openx.com"
        
        self.vc = UIViewController()
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 15, handler:nil)
        
        //Wait half a second, then force a click
        self.vc?.view.addSubview(videoCreative.view!)
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        self.expectationCreativeWasClicked = expectation(description: "expectationCreativeWasClicked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            
            guard let strongSelf = self else {
                XCTFail("Self deallocated")
                return
            }
            
            guard let videoView = strongSelf.videoCreative.view as? OXMVideoView else {
                XCTFail("Couldn't get Video View")
                return
            }
            
            videoView.btnLearnMoreClick()
        })
        
        
        self.waitForExpectations(timeout: 15, handler:nil)
    }
    
    func testVastDuration() {
        // Expected duration of video medium.mp4 is 60 sec
        let expectedVastDuration = 10.0
        setupVideoCreative(videoFileURL: "http://get_video/medium.mp4", localVideoFileName: "medium.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVastDuration as NSNumber // VAST Duration
        
        setupVideoDurationTest(expectedDuration: expectedVastDuration)
    }
    
    func testVideoDuration() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = 10 // VAST Duration
        
        setupVideoDurationTest(expectedDuration: expectedVideoDuration)
    }
    
    func testPauseVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        self.expectationVideoViewCompletedDisplay?.isInverted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:{
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
            videoView.pause()
        })
        
        waitForExpectations(timeout: 8, handler:nil)
    }
    
    func testUnpauseVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedPausedTime = 3.0

        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        
        // Pause video
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:{
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
            videoView.pause()
            
            // Unpause video
            DispatchQueue.main.asyncAfter(deadline: .now() + expectedPausedTime, execute:{
                XCTAssertFalse(self.isVideoViewCompletedDisplay)
                videoView.resume()
            })
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedPausedTime + 0.5, handler:nil)
    }
    
    func testStopVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 3.0

        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + expectedStoppedDely, execute:{
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
            videoView.stop()
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedStoppedDely + 0.5, handler:nil)
    }
    
    func testStopOnCloseButton() {
        
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 1.0
        let event = OXMTrackingEvent.closeLinear
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        self.expectationVideoViewCompletedDisplay?.isInverted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + expectedStoppedDely, execute:{
            videoView.stop(onCloseButton: event)
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedStoppedDely + 0.5, handler:nil)
    }    
    
    // MARK: - OXMCreativeDownloadDelegate
    
    func creativeReady(_ creative: OXMAbstractCreative) {
        self.expectationCreativeReady?.fulfill()
    }
    
    func creativeFailed(_ error:Error) {}
    
    // MARK: - OXMVideoViewDelegate
    
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        isVideoViewCompletedDisplay = true
        self.expectationVideoViewCompletedDisplay?.fulfill()
    }
    
    func videoWasClicked() {}
    
    func videoClickthroughBrowserClosed() {
        self.expectationClickthroughBrowserClosed?.fulfill()
    }
    
    func trackEvent(_ trackingEvent: OXMTrackingEvent) {}
    
    // MARK: - CreativeViewDelegate
    
    func creativeDidComplete(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidComplete?.fulfill()
    }
    
    func creativeWasClicked(_ creative: OXMAbstractCreative) {
        self.expectationCreativeWasClicked?.fulfill()
    }
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {}
    func creativeReady(toReimplant creative: OXMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {}
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {}
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
   
    
    // MARK: - Helper Methods
    
    private func setupVideoCreative(videoFileURL:String = "http://get_video/small.mp4", localVideoFileName:String = "small.mp4") {
        let rule = MockServerRule(urlNeedle: videoFileURL, mimeType: MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: localVideoFileName)
        MockServer.singleton().resetRules([rule])
        
        //Create model
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.videoFileURL = videoFileURL
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        let url = URL(string: model.videoFileURL!)
        let downloader = OXMDownloadDataHelper(oxmServerConnection:connection)
        downloader.downloadData(for: url, maxSize: OXMVideoCreative.maxSizeForPreRenderContent, completionClosure: { (data:Data?, error:Error?) in
            
            DispatchQueue.main.async {
                //Create and start creative
                self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: data!)
                self.videoCreative.creativeResolutionDelegate = self
                self.videoCreative.creativeViewDelegate = self
                
                self.expectationDownloadCompleted?.fulfill()
            }
        })
        
        wait(for: [self.expectationDownloadCompleted!], timeout: 15)
    }
    
    private func setupVideoDurationTest(expectedDuration: Double) {
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 15, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        
        waitForExpectations(timeout: expectedDuration + 5, handler:nil)

        XCTAssertTrue(self.isVideoViewCompletedDisplay)
    }
}
