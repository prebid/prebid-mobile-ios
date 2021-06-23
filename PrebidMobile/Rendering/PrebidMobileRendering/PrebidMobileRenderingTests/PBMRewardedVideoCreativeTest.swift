

import Foundation
import UIKit
import XCTest
import AVFoundation

@testable import PrebidMobile

class PBMModalManagerTest : PBMModalManager {
    
    var expectationCreativeDidComplete: XCTestExpectation?

    override func creativeDisplayCompleted(_ creative: PBMAbstractCreative) {
        expectationCreativeDidComplete?.fulfill()
    }
}

class PBMRewardedVideoCreativeTest: XCTestCase, PBMCreativeResolutionDelegate, PBMCreativeViewDelegate {
    
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidComplete:XCTestExpectation!
    
    func testCreativeViewDelegateHasCompanionAd() {
        
        self.expectationCreativeDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        
        //Create the creative, set the delegate, and fire.
        let model = PBMCreativeModel(adConfiguration: PBMAdConfiguration())
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
        let model = PBMCreativeModel(adConfiguration:PBMAdConfiguration())
        model.videoFileURL = "example.com"
        
        let modalManager = PBMModalManagerTest()
        modalManager.expectationCreativeDidComplete = self.expectationCreativeDidComplete
        
        let videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(),  videoData: Data())        
        videoCreative.modalManager = modalManager
        videoCreative.creativeViewDelegate = self
        videoCreative.videoViewCompletedDisplay()
        
        self.waitForExpectations(timeout: 1, handler:nil)
    }
    
    // MARK - PBMCreativeViewDelegate
    
    func creativeDidComplete(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {}
    func creativeWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: PBMAbstractCreative) {}
    func creativeReady(toReimplant creative: PBMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: PBMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: PBMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    
    func creativeReady(_ creative: PBMAbstractCreative) {
        self.expectationDownloadCompleted.fulfill()
    }
    
    func creativeFailed(_ error: Error) {
         XCTFail("error: \(error)")
    }
}
