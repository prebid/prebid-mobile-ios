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

import Foundation
import XCTest

@testable import PrebidMobile

//TODO: Refactor to use MockServer

class CreativeModelTest: XCTestCase {
    
    var fireAndForgetExpectation:XCTestExpectation!
    
    func testTrackEvent() {
        
        self.fireAndForgetExpectation = self.expectation(description: "Expected PrebidServerConnection to talk to the server")
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Set Up Mock Server
        let rule = MockServerRule(urlNeedle: "bar.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: "TEST")
        rule.statusCode = 123
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.fireAndForgetExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])
        
        //Track an event
        let creativeModel = PBMCreativeModel(adConfiguration:AdConfiguration())
        creativeModel.trackingURLs[PBMTrackingEventDescription.getDescription(PBMTrackingEvent.impression)] = ["foo://bar.com"]
        
        let eventTracker = PBMAdModelEventTracker(creativeModel: creativeModel, serverConnection: connection)
        eventTracker.trackEvent(PBMTrackingEvent.impression)
        //Wait up to 5 seconds for mockTrackingManager to call fireEventTrackingURL
        self.waitForExpectations(timeout: 5, handler:nil)
    }
}
