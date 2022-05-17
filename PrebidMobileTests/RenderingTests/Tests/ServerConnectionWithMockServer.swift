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

class ServerConnectionWithMockServer: XCTestCase {
    
    let strResponse = "{\"foo\":\"bar\"}"
    let testNeedle1 = "foo.com"
    let testNeedle2 = "bar.com"
    
    // Checks that 'resetRules' leads to execution of different rules with the same needle and same connectionID
    func testResetRules() {
        let exp1 = expectation(description: "exp1")
        let exp2 = expectation(description: "exp2")
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        let rule1 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule1.mockServerReceivedRequestHandler = { _ in
            exp1.fulfill()
        }
        
        MockServer.shared.resetRules([rule1])
        
        connection.fireAndForget(testNeedle1)
        wait(for: [exp1], timeout: 1)
        
        // Reset and new call
        let rule2 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule2.mockServerReceivedRequestHandler = { _ in
            exp2.fulfill()
        }
        
        MockServer.shared.resetRules([rule2])
        
        connection.fireAndForget(testNeedle1)
        
        wait(for: [exp2], timeout: 1)
    }
    
    // Negative use case. Checks that rules with the same needle and with the same connectionID works incorect
    // Only one rule will be triggered
    func testRulesWithSameConnectionID() {
        let exp1 = expectation(description: "exp1")
        exp1.expectedFulfillmentCount = 2
        
        let exp2 = expectation(description: "exp2")
        exp2.isInverted = true
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        let rule1 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule1.mockServerReceivedRequestHandler = { _ in
            exp1.fulfill()
        }
        
        let rule2 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule2.mockServerReceivedRequestHandler = { _ in
            exp2.fulfill()
        }
        
        MockServer.shared.resetRules([rule1, rule2])
        
        connection.fireAndForget(testNeedle1)
        connection.fireAndForget(testNeedle1)
        
        waitForExpectations(timeout: 1)
    }
    
    // Checks that rules with the same needle but with different connectionID are triggered independently
    func testRulesWithDifferentConnectionID() {
        let exp1 = expectation(description: "exp1")
        let exp2 = expectation(description: "exp2")
        
        let connection1 = UtilitiesForTesting.createConnectionForMockedTest()
        let connection2 = UtilitiesForTesting.createConnectionForMockedTest()
        
        let rule1 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection1.internalID, strResponse: strResponse)
        rule1.mockServerReceivedRequestHandler = { _ in
            exp1.fulfill()
        }
        
        let rule2 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection2.internalID, strResponse: strResponse)
        rule2.mockServerReceivedRequestHandler = { _ in
            exp2.fulfill()
        }
        
        MockServer.shared.resetRules([rule1, rule2])
        
        connection1.fireAndForget(testNeedle1)
        connection2.fireAndForget(testNeedle1)
        
        waitForExpectations(timeout: 1)
    }
    
    // Checks that rules with the different needle and with different connectionID are triggered independently
    func testRulesWithDifferentNeedlesAndConnectionID() {
        let exp1 = expectation(description: "exp1")
        let exp2 = expectation(description: "exp2")
        
        let connection1 = UtilitiesForTesting.createConnectionForMockedTest()
        let connection2 = UtilitiesForTesting.createConnectionForMockedTest()
        
        let rule1 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection1.internalID, strResponse: strResponse)
        rule1.mockServerReceivedRequestHandler = { _ in
            exp1.fulfill()
        }
        
        let rule2 = MockServerRule(urlNeedle: testNeedle2, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection2.internalID, strResponse: strResponse)
        rule2.mockServerReceivedRequestHandler = { _ in
            exp2.fulfill()
        }
        
        MockServer.shared.resetRules([rule1, rule2])
        
        connection1.fireAndForget(testNeedle1)
        connection2.fireAndForget(testNeedle2)
        
        waitForExpectations(timeout: 1)
    }
    
    // Checks that rules with the different needles but with the same connectionID are triggered independently
    func testRulesWithDifferentNeedlesAndSaveConnectionID() {
        let exp1 = expectation(description: "exp1")
        let exp2 = expectation(description: "exp2")
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        let rule1 = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule1.mockServerReceivedRequestHandler = { _ in
            exp1.fulfill()
        }
        
        let rule2 = MockServerRule(urlNeedle: testNeedle2, mimeType:  MockServerMimeType.JS.rawValue, connectionID: connection.internalID, strResponse: strResponse)
        rule2.mockServerReceivedRequestHandler = { _ in
            exp2.fulfill()
        }
        
        MockServer.shared.resetRules([rule1, rule2])
        
        connection.fireAndForget(testNeedle1)
        connection.fireAndForget(testNeedle2)
        
        waitForExpectations(timeout: 1)
    }
    
    // Checks that rule with the different connectionID will not fire for particular needle
    func testRuleWithDifferentConnectionID() {
        let exp = expectation(description: "exp1")
        exp.isInverted = true
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        let rule = MockServerRule(urlNeedle: testNeedle1, mimeType:  MockServerMimeType.JS.rawValue, connectionID: UUID(), strResponse: strResponse)
        rule.mockServerReceivedRequestHandler = { _ in
            exp.fulfill()
        }
        
        MockServer.shared.resetRules([rule])
        
        connection.fireAndForget(testNeedle1)
        
        waitForExpectations(timeout: 1)
    }
}
