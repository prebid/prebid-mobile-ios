//
//  OpenXSDKCoreTests
//
//  Created by Gene Dahilig on 5/3/18.
//  Copyright © 2018 OpenX. All rights reserved.
//

@testable import OpenXSDKCore
import XCTest

class PBMAdRequesterVastTests: XCTestCase, PBMAdRequestDelegate {
    
    var successfulExpectation:XCTestExpectation!
    var failedExpectation:XCTestExpectation!
    var vastServerResponse: PBMAdRequestResponseAbstract?

    func testSuccess() {
        
        self.successfulExpectation = self.expectation(description: "Expected Vast Load to be successful")
        vastServerResponse = nil

        MockServer.singleton().reset()
        var rule = MockServerRule(urlNeedle: "foo.com/inline/vast", mimeType: MockServerMimeType.XML.rawValue, fileName: "document_with_one_inline_ad.xml")
        MockServer.singleton().add(rule)
        
        rule = MockServerRule(urlNeedle: "foo.com/wrapper/vast", mimeType: MockServerMimeType.XML.rawValue, fileName: "document_with_one_wrapper_ad.xml")
        MockServer.singleton().add(rule)
        
        let conn = PBMServerConnection()
        conn.protocolClasses.add(MockServerURLProtocol.self)
        
        let adConfiguration = AdConfiguration()
        adConfiguration.vastURL = "foo.com/wrapper/vast"
        
        let requester = PBMAdRequesterVast(oxmServerConnection:conn, adConfiguration: adConfiguration)
        requester.adRequestDelegate = self
        requester.load()
        
        self.wait(for: [successfulExpectation], timeout: 2)
        
        XCTAssertNotNil(vastServerResponse)
        
        self.waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testFailed() {
        
        self.failedExpectation = self.expectation(description: "Expected Vast Load to be failed")
        vastServerResponse = nil
        
        MockServer.singleton().reset()
        let conn = PBMServerConnection()
        conn.protocolClasses.add(MockServerURLProtocol.self)
        
        let adConfiguration = AdConfiguration()
        
        let requester = PBMAdRequesterVast(oxmServerConnection:conn, adConfiguration: adConfiguration)
        requester.adRequestDelegate = self
        requester.load()
        
        self.wait(for: [failedExpectation], timeout: 2)
        
        XCTAssertNil(vastServerResponse)
        
        self.waitForExpectations(timeout: 3, handler: nil)
    }
    
    // MARK: PBMAdRequestDelegate
    
    func requestCompletedSuccess(_ mediatedAdResult: PBMAdRequestResponseAbstract) {
        self.vastServerResponse = mediatedAdResult
        successfulExpectation.fulfill()
    }
    
    func requestCompletedFailure(_ error: Error) {
        failedExpectation.fulfill()
    }
}
