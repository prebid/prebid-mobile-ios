

import Foundation
import UIKit
import XCTest
import AVFoundation

@testable import PrebidMobileRendering

class OXMModalManagerTest : OXMModalManager {
    
    var expectationCreativeDidComplete: XCTestExpectation?

    override func creativeDisplayCompleted(_ creative: OXMAbstractCreative) {
        expectationCreativeDidComplete?.fulfill()
    }
}

class OXMRewardedVideoCreativeTest: XCTestCase, OXMCreativeResolutionDelegate, OXMCreativeViewDelegate {
    
    var expectationDownloadCompleted:XCTestExpectation!
    var expectationCreativeDidComplete:XCTestExpectation!
    
    func testCreativeViewDelegateHasCompanionAd() {
        
        self.expectationCreativeDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        
        //Create the creative, set the delegate, and fire.
        let model = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        model.videoFileURL = "example.com"
        model.hasCompanionAd = true
        
        let videoCreative = OXMVideoCreative(creativeModel:model,transaction:UtilitiesForTesting.createEmptyTransaction(),videoData: Data())
        videoCreative.creativeViewDelegate = self
        videoCreative.videoViewCompletedDisplay()

        
        self.waitForExpectations(timeout: 3, handler:nil)
    }
    
    func testCreativeViewDelegateNoCompanionAd() {
        
        self.expectationCreativeDidComplete = self.expectation(description: "expectationCreativeDidComplete")
        
        //Create the creative, set the delegate, and fire.
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.videoFileURL = "example.com"
        
        let modalManager = OXMModalManagerTest()
        modalManager.expectationCreativeDidComplete = self.expectationCreativeDidComplete
        
        let videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(),  videoData: Data())        
        videoCreative.modalManager = modalManager
        videoCreative.creativeViewDelegate = self
        videoCreative.videoViewCompletedDisplay()
        
        self.waitForExpectations(timeout: 1, handler:nil)
    }
    
    // MARK - OXMCreativeViewDelegate
    
    func creativeDidComplete(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {}
    func creativeWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {}
    func creativeReady(toReimplant creative: OXMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
    
    func creativeReady(_ creative: OXMAbstractCreative) {
        self.expectationDownloadCompleted.fulfill()
    }
    
    func creativeFailed(_ error: Error) {
         XCTFail("error: \(error)")
    }
}
