//
//  OXMCreativeFactoryTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMCreativeFactoryTest: XCTestCase {

    func testNoCreativeModelsFactoryFail() {
        let expectation = self.expectation(description: "Expected creative factory failure callback")

        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        
        let creativeFactory =
            OXMCreativeFactory(serverConnection: connection, transaction: transaction, finishedCallback: {
                creatives, error in
                if error != nil {
                    expectation.fulfill()
                }
            }
        )
        
        creativeFactory.start()
        
        waitForExpectations(timeout: 5)
    }


    func testCreativeFactorySuccess() {
        let expectationSuccess = self.expectation(description: "Expected creative factory success callback")
        let expectationFail = self.expectation(description: "Creative Factory fails")
        expectationFail.isInverted = true
        
        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
        
        let creativeFactory =
            OXMCreativeFactory(serverConnection: connection, transaction: transaction, finishedCallback: {
                creatives, error in
                if error != nil {
                    expectationFail.fulfill()
                }
                if let _ = creatives?.first {
                    expectationSuccess.fulfill()
                }
        })
        
        creativeFactory.start()
        
        waitForExpectations(timeout: 5)
    }
 }
