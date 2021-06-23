import Foundation
import XCTest

@testable import PrebidMobile

//TODO: Refactor to use MockServer

class CreativeModelTest: XCTestCase {
 
    var fireAndForgetExpectation:XCTestExpectation!
    
    func testTrackEvent() {
        
        self.fireAndForgetExpectation = self.expectation(description: "Expected PBMServerConnection to talk to the server")
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Set Up Mock Server
        let rule = MockServerRule(urlNeedle: "bar.com", mimeType:  MockServerMimeType.JSON.rawValue, connectionID: connection.internalID, strResponse: "TEST")
        rule.statusCode = 123
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.fireAndForgetExpectation.fulfill()
        }
        MockServer.shared.resetRules([rule])

        //Track an event
        let creativeModel = PBMCreativeModel(adConfiguration:PBMAdConfiguration())
        creativeModel.trackingURLs[PBMTrackingEventDescription.getDescription(PBMTrackingEvent.impression)] = ["foo://bar.com"]

        let eventTracker = PBMAdModelEventTracker(creativeModel: creativeModel, serverConnection: connection)
        eventTracker.trackEvent(PBMTrackingEvent.impression)
        //Wait up to 5 seconds for mockTrackingManager to call fireEventTrackingURL
        self.waitForExpectations(timeout: 5, handler:nil)
    }
}
