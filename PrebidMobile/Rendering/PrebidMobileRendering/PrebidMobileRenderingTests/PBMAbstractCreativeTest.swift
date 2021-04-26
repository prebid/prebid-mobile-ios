//
//  PBMAbstractCreativeTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMAbstractCreativeTest: XCTestCase, PBMCreativeResolutionDelegate {
    
    var expectation:XCTestExpectation?
    var pbmAbstractCreative: PBMAbstractCreative!
    let msgAbstractFunctionCalled = "Abstract function called"
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        self.pbmAbstractCreative = PBMAbstractCreative(creativeModel:PBMCreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction())
        self.pbmAbstractCreative.creativeResolutionDelegate = self
    }
    
    override func tearDown() {
        logToFile = nil
        self.pbmAbstractCreative = nil;
        
        super.tearDown()
    }
    
    func testIsOpened() {
        XCTAssertFalse(self.pbmAbstractCreative.isOpened)
    }
    
    func testSetupViewBackground() {
        logToFile = .init()
        
        self.pbmAbstractCreative.setupView(withThread: MockNSThread(mockIsMainThread: false))
        
        UtilitiesForTesting.checkLogContains("Attempting to set up view on background thread")
    }
    
    func testModalManagerDidFinishPop() {
        logToFile = .init()
        let state = PBMModalState(view: PBMWebView(), adConfiguration:PBMAdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        self.pbmAbstractCreative.modalManagerDidFinishPop(state)
		let log = PBMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }

    func testModalManagerDidLeaveApp() {
        logToFile = .init()
        let state = PBMModalState(view: PBMWebView(), adConfiguration:PBMAdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        pbmAbstractCreative.modalManagerDidLeaveApp(state)
        let log = PBMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }
    
    func testOnResolutionCompleted() {
        expectation = self.expectation(description: "Expected downloadCompleted to be called")
        pbmAbstractCreative.isDownloaded = false
        pbmAbstractCreative.onResolutionCompleted()
        waitForExpectations(timeout: 4, handler: { _ in
            XCTAssertTrue(self.pbmAbstractCreative.isDownloaded)
        })
    }
    
    func testOnResolutionFailed() {        
        self.expectation = self.expectation(description: "Expected downloadFailed to be called")
        pbmAbstractCreative.isDownloaded = false
        pbmAbstractCreative.onResolutionFailed(NSError(domain: "OpenXSDK", code: 123, userInfo: [:]))
        waitForExpectations(timeout: 4, handler: { _ in
            XCTAssertTrue(self.pbmAbstractCreative.isDownloaded)
        })
    }
    
    //MARK - PBMCreativeResolutionDelegate
    
    func creativeReady(_ creative: PBMAbstractCreative) {
        expectation?.fulfill()
        XCTAssertTrue(creative.isDownloaded)
    }
    
    func creativeFailed(_ error: Error) {
        expectation?.fulfill()
        XCTAssertTrue(self.pbmAbstractCreative.isDownloaded)
    }
    
    //MARK - Open Measurement

    func testOpenMeasurement() {
        logToFile = .init()
        self.pbmAbstractCreative.createOpenMeasurementSession()
        UtilitiesForTesting.checkLogContains("Abstract function called")
    }
}
