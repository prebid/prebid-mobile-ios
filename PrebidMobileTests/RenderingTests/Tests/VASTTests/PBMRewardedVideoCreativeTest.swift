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
import UIKit
import XCTest
import AVFoundation

@testable @_spi(PBMInternal) import PrebidMobile


class PBMModalManagerTest: ModalManager {
    var expectationCreativeDidComplete: XCTestExpectation?
    
    @objc override func creativeDisplayCompleted(_ creative: AbstractCreative) {
        expectationCreativeDidComplete?.fulfill()
    }
    
}

class PBMRewardedVideoCreativeTest: XCTestCase, CreativeResolutionDelegate, CreativeViewDelegate {
    
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidComplete:XCTestExpectation!
    
    func testCreativeViewDelegateHasCompanionAd() {
        
        self.expectationCreativeDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        
        //Create the creative, set the delegate, and fire.
        let model = CreativeModel(adConfiguration: AdConfiguration())
        model.videoFileURL = "example.com"
        model.hasCompanionAd = true
        
        let videoCreative = PBMVideoCreative(creativeModel:model,transaction:UtilitiesForTesting.createEmptyTransaction(),videoData: Data())
        videoCreative.creativeViewDelegate = self
        videoCreative.videoViewCompletedDisplay()
        
        
        self.waitForExpectations(timeout: 3, handler:nil)
    }
    
    func testCreativeViewDelegateNoCompanionAd() {
        
        self.expectationCreativeDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        
        //Create the creative, set the delegate, and fire.
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.videoFileURL = "example.com"
        
        let modalManager = PBMModalManagerTest()
        modalManager.expectationCreativeDidComplete = self.expectationCreativeDidComplete
        
        let videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(),  videoData: Data())
        videoCreative.modalManager = modalManager
        videoCreative.creativeViewDelegate = self
        videoCreative.videoViewCompletedDisplay()
        
        self.waitForExpectations(timeout: 1, handler:nil)
    }
    
    // MARK: CreativeViewDelegate
    
    func creativeDidComplete(_ creative: AbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    
    func creativeReady(_ creative: AbstractCreative) {
        self.expectationDownloadCompleted.fulfill()
    }
    
    func creativeFailed(_ error: Error) {
        XCTFail("error: \(error)")
    }
}
