//
//  OXMRewardedVideoViewTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMRewardedVideoViewTest: XCTestCase, OXMCreativeResolutionDelegate, OXMCreativeViewDelegate, OXMVideoViewDelegate {
    
    var vc = UIViewController()
    var videoCreative:OXMVideoCreative!
    let connection = UtilitiesForTesting.createConnectionForMockedTest()
    
    var expectationDownloadCompleted:XCTestExpectation?
    var expectationCreativeReady:XCTestExpectation?
    var expectationCreativeDidDisplay:XCTestExpectation?
    var expectationCreativeDidComplete:XCTestExpectation?
    var expectationDownloadFailed:XCTestExpectation?
    var expectationCreativeWasClicked:XCTestExpectation?
    var expectationClickthroughBrowserClosed:XCTestExpectation?
    var expectationVideoViewCompletedDisplay:XCTestExpectation?
    
    // MARK: - Setup
    
    override func setUp() {
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
    }
    
    // MARK: - Tests
    
    func testLearnMoreButtonReadyAndWorks() {
        
        //Wait for creative to be ready
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        self.setupVideoCreative()
        self.videoCreative.creativeModel?.clickThroughURL = "www.openx.com"
        self.vc = UIViewController()
        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        waitForExpectations(timeout: 15, handler:nil)

        //Force a click
        self.expectationCreativeWasClicked = expectation(description: "expectationCreativeWasClicked")
        showAndTapLearnMore()
        waitForExpectations(timeout: 15, handler:nil)
    }
    
    func testHandlePeriodicTimeEvent() {
        //Wait for creative to be ready
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        self.setupVideoCreative()
        XCTAssertNotNil(self.videoCreative.creativeModel)
        self.videoCreative.creativeModel?.clickThroughURL = "www.openx.com"
        self.vc = UIViewController()
        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        waitForExpectations(timeout: 15, handler:nil)
        let rewardedVideoView = self.videoCreative.videoView
        let remaining = rewardedVideoView?.handlePeriodicTimeEvent()
        XCTAssert(remaining != 0.0)
    }

    func testHandlePeriodicTimeEvent_NoAvPlayer() {
        self.setupVideoCreative()
        let rewardedVideoView = self.videoCreative.videoView
        let remaining = rewardedVideoView?.handlePeriodicTimeEvent()
        XCTAssert(remaining == 0)
    }
    
    func testRequiredVideoDuration() {
        //Wait for creative to be ready
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        self.setupVideoCreative()
        XCTAssertNotNil(self.videoCreative.creativeModel)
        self.videoCreative.creativeModel?.clickThroughURL = "www.openx.com"
        self.vc = UIViewController()
        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        waitForExpectations(timeout: 15, handler:nil)

        let rewardedVideoView = self.videoCreative.videoView
        XCTAssertNotNil(rewardedVideoView?.creative?.creativeModel)
        
        let duration = rewardedVideoView?.requiredVideoDuration()
        let playerDuration = CGFloat(CMTimeGetSeconds(rewardedVideoView!.avPlayer.currentItem!.asset.duration))
        let vastDuration = rewardedVideoView?.creative?.creativeModel?.displayDurationInSeconds as! CGFloat
        XCTAssertEqual(duration, CGFloat.minimum(playerDuration, vastDuration))
    }
    
    // MARK: - OXMCreativeResolutionDelegate
    func creativeReady(_ creative:OXMAbstractCreative) {
        self.expectationCreativeReady?.fulfill()
    }
    
    func creativeFailed(_ error:Error) {
        self.fulfillOrFail(self.expectationDownloadFailed, "expectationCreativeFailed")
    }
    
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {
        self.expectationDownloadFailed?.fulfill()
    }
    
    
    // MARK: - OXMVideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    func videoViewCompletedDisplay() {}
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
        model.displayDurationInSeconds = 6
        model.adConfiguration?.isOptIn = true
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadVideoData")
        
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
    
    
    private func showAndTapLearnMore() {
        
        self.vc.view.addSubview(videoCreative.view!)
        self.videoCreative.display(withRootViewController: self.vc)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            guard let videoView = self.videoCreative.view as? OXMVideoView else {
                XCTFail("Couldn't get Video View")
                return
            }
            
            videoView.btnLearnMoreClick()
        })
    }
}

