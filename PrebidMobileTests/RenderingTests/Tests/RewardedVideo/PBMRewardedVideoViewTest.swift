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

import XCTest
@testable @_spi(PBMInternal) import PrebidMobile

class PBMRewardedVideoViewTest: XCTestCase, CreativeResolutionDelegate, CreativeViewDelegate, PBMVideoViewDelegate {
    
    var vc = UIViewController()
    var videoCreative:PBMVideoCreative!
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
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
    }
    
    // MARK: - Tests
    
    func testLearnMoreButtonReadyAndWorks() {
        
        //Wait for creative to be ready
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        self.setupVideoCreative()
        self.videoCreative.creativeModel.clickThroughURL = "www.openx.com"
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
        self.videoCreative.creativeModel.clickThroughURL = "www.openx.com"
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
        self.videoCreative.creativeModel.clickThroughURL = "www.openx.com"
        self.vc = UIViewController()
        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        waitForExpectations(timeout: 15, handler:nil)
        
        let rewardedVideoView = self.videoCreative.videoView
        XCTAssertNotNil(rewardedVideoView?.creative?.creativeModel)
        
        let duration = rewardedVideoView?.requiredVideoDuration()
        let playerDuration = CGFloat(CMTimeGetSeconds(rewardedVideoView!.avPlayer.currentItem!.asset.duration))
        let vastDuration = rewardedVideoView?.creative?.creativeModel.displayDurationInSeconds as! CGFloat
        XCTAssertEqual(duration, CGFloat.minimum(playerDuration, vastDuration))
    }
    
    // MARK: - PBMCreativeResolutionDelegate
    func creativeReady(_ creative: AbstractCreative) {
        self.expectationCreativeReady?.fulfill()
    }
    
    func creativeFailed(_ error:Error) {
        self.fulfillOrFail(self.expectationDownloadFailed, "expectationCreativeFailed")
    }
    
    func creativeDidDisplay(_ creative: AbstractCreative) {
        self.expectationDownloadFailed?.fulfill()
    }
    
    
    // MARK: - PBMVideoViewDelegate
    
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    func videoViewCompletedDisplay() {}
    func videoWasClicked() {}
    
    func videoClickthroughBrowserClosed() {
        self.expectationClickthroughBrowserClosed?.fulfill()
    }
    
    func trackEvent(_ trackingEvent: TrackingEvent) {}
    
    // MARK: - CreativeViewDelegate
    
    func creativeDidComplete(_ creative: AbstractCreative) {
        self.expectationCreativeDidComplete?.fulfill()
    }
    
    func creativeWasClicked(_ creative: AbstractCreative) {
        self.expectationCreativeWasClicked?.fulfill()
    }
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    
    // MARK: - Helper Methods
    private func setupVideoCreative(videoFileURL:String = "http://get_video/small.mp4", localVideoFileName:String = "small.mp4") {
        let rule = MockServerRule(urlNeedle: videoFileURL, mimeType: MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: localVideoFileName)
        MockServer.shared.resetRules([rule])
        
        //Create model
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.videoFileURL = videoFileURL
        model.displayDurationInSeconds = 6
        model.adConfiguration?.isRewarded = true
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadVideoData")
        
        let url = URL(string: model.videoFileURL!)
        let downloader = PBMDownloadDataHelper(serverConnection:connection)
        downloader.downloadData(for: url, maxSize: PBMVideoCreative.maxSizeForPreRenderContent, completionClosure: { (data:Data?, error:Error?) in
            
            DispatchQueue.main.async {
                //Create and start creative
                self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: data!)
                self.videoCreative.creativeResolutionDelegate = self
                self.videoCreative.creativeViewDelegate = self
                
                self.expectationDownloadCompleted?.fulfill()
            }
        })
        
        wait(for: [self.expectationDownloadCompleted!], timeout: 15)
    }
    
    
    private func showAndTapLearnMore() {
        
        self.vc.view.addSubview(videoCreative.view!)
        self.videoCreative.display(rootViewController: self.vc)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            guard let videoView = self.videoCreative.view as? PBMVideoView else {
                XCTFail("Couldn't get Video View")
                return
            }
            
            videoView.btnLearnMoreClick()
        })
    }
}

