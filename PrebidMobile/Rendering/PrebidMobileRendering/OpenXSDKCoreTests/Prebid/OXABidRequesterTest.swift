//
//  OXABidRequesterTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXABidRequesterTest: XCTestCase {
    private var sdkConfiguration: OXASDKConfiguration!
    private let targeting = OXATargeting.withDisabledLock
    
    override func setUp() {
        super.setUp()
        sdkConfiguration = OXASDKConfiguration()
        sdkConfiguration.serverURL = OXASDKConfiguration.devintServerURL
        sdkConfiguration.accountID = OXASDKConfiguration.devintAccountID
    }

    override func tearDown() {
        sdkConfiguration = nil
        super.tearDown()
    }
    
    func testBanner_300x250() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(OXABidResponseTransformer.someValidResponse)
            }])
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        requester.requestBids { (bidResponse, error) in
            exp.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAccountID_noRequest() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection()
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        sdkConfiguration.accountID = " \t \t  "
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, OXAError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAccountID_rejectedByServer() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let accountID = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(OXABidResponseTransformer.invalidAccountIDResponse(accountID: accountID))
            }])
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        sdkConfiguration.accountID = accountID
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, OXAError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidConfigID_noRequest() {
        let adUnitConfig = OXAAdUnitConfig(configId: " \t \t  ", size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection()
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, OXAError.invalidConfigId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidConfigID_rejectedByServer() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(OXABidResponseTransformer.invalidConfigIdResponse(configId: configId))
            }])
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, OXAError.invalidConfigId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidSize() {
        let adUnitConfig = OXAAdUnitConfig(configId: "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4", size: CGSize(width: -300, height: 250))
        let connection = MockServerConnection()
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAdditionalSize() {
        let adUnitConfig = OXAAdUnitConfig(configId: "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4", size: CGSize(width: 300, height: 250))
        adUnitConfig.additionalSizes = [NSValue(cgSize: CGSize(width: -320, height: 50))]
        
        let connection = MockServerConnection()
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_requestInProgress() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = OXAAdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                callback(OXABidResponseTransformer.someValidResponse)
            }
            }])
        let requester = OXABidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp_ok = expectation(description: "exp_ok")
        let exp_fail = expectation(description: "exp_fail")
        
        requester.requestBids { (bidResponse, error) in
            exp_ok.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp_fail.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
