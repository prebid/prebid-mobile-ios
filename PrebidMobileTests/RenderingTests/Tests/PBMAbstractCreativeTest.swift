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

@testable import PrebidMobile

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
        let state = PBMModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        self.pbmAbstractCreative.modalManagerDidFinishPop(state)
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }

    func testModalManagerDidLeaveApp() {
        logToFile = .init()
        let state = PBMModalState(view: PBMWebView(), adConfiguration:AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        pbmAbstractCreative.modalManagerDidLeaveApp(state)
        let log = Log.getLogFileAsString() ?? ""
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
