//
//  OXMAbstractCreativeTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXMAbstractCreativeTest: XCTestCase, OXMCreativeResolutionDelegate {
    
    var expectation:XCTestExpectation?
    var oxmAbstractCreative: OXMAbstractCreative!
    let msgAbstractFunctionCalled = "Abstract function called"
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        self.oxmAbstractCreative = OXMAbstractCreative(creativeModel:OXMCreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction())
        self.oxmAbstractCreative.creativeResolutionDelegate = self
    }
    
    override func tearDown() {
        logToFile = nil
        self.oxmAbstractCreative = nil;
        
        super.tearDown()
    }
    
    func testIsOpened() {
        XCTAssertFalse(self.oxmAbstractCreative.isOpened)
    }
    
    func testSetupViewBackground() {
        logToFile = .init()
        
        self.oxmAbstractCreative.setupView(withThread: MockNSThread(mockIsMainThread: false))
        
        UtilitiesForTesting.checkLogContains("Attempting to set up view on background thread")
    }
    
    func testModalManagerDidFinishPop() {
        logToFile = .init()
        let state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        self.oxmAbstractCreative.modalManagerDidFinishPop(state)
		let log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }

    func testModalManagerDidLeaveApp() {
        logToFile = .init()
        let state = OXMModalState(view: OXMWebView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        oxmAbstractCreative.modalManagerDidLeaveApp(state)
        let log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }
    
    func testOnResolutionCompleted() {
        expectation = self.expectation(description: "Expected downloadCompleted to be called")
        oxmAbstractCreative.isDownloaded = false
        oxmAbstractCreative.onResolutionCompleted()
        waitForExpectations(timeout: 4, handler: { _ in
            XCTAssertTrue(self.oxmAbstractCreative.isDownloaded)
        })
    }
    
    func testOnResolutionFailed() {        
        self.expectation = self.expectation(description: "Expected downloadFailed to be called")
        oxmAbstractCreative.isDownloaded = false
        oxmAbstractCreative.onResolutionFailed(NSError(domain: "OpenXSDK", code: 123, userInfo: [:]))
        waitForExpectations(timeout: 4, handler: { _ in
            XCTAssertTrue(self.oxmAbstractCreative.isDownloaded)
        })
    }
    
    //MARK - OXMCreativeResolutionDelegate
    
    func creativeReady(_ creative: OXMAbstractCreative) {
        expectation?.fulfill()
        XCTAssertTrue(creative.isDownloaded)
    }
    
    func creativeFailed(_ error: Error) {
        expectation?.fulfill()
        XCTAssertTrue(self.oxmAbstractCreative.isDownloaded)
    }
    
    //MARK - Open Measurement

    func testOpenMeasurement() {
        logToFile = .init()
        self.oxmAbstractCreative.createOpenMeasurementSession()
        UtilitiesForTesting.checkLogContains("Abstract function called")
    }
}
