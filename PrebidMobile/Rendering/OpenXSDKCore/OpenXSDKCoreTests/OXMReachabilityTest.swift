//
//  OXMReachabilityTest.swift
//  OpenXSDKCoreTests
//
//  Created by Gene Dahilig on 2/22/18.
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXSDKCore

class OXMReachabilityTest: XCTestCase {
    
    func testConnected() {
        // the Reachability request is a sync call, expectations not needed. bool flag used instead.
        var requestHandlerCalled = false
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()

        //Set up MockServer
        let rule = MockServerRule(urlNeedle: "google.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: "dummy response")
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            requestHandlerCalled = true
        }
        MockServer.singleton().resetRules([rule])
        
        let isConnected = Reachability.isConnectedToNetwork(ServerConnection: connection)

        XCTAssert(isConnected == true)
        XCTAssert(requestHandlerCalled == true)
    }
    
    func testNotConnected() {
        // the Reachability request is a sync call, expectations not needed. bool flag used instead.
        
        //Set up MockServer
        MockServer.singleton().reset()
        MockServer.singleton().notFoundRule.willRespond = false
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        let isConnected = Reachability.isConnectedToNetwork(ServerConnection: connection)
        
        XCTAssert(isConnected == false)
    }
}
