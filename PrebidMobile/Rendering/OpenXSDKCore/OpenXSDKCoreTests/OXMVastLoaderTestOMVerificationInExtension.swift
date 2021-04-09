import XCTest

@testable import OpenXApolloSDK

class OXMVastLoaderTestOMVerificationInExtension: XCTestCase {
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!

    override func setUp() {
        self.continueAfterFailure = true
    }
    
    override func tearDown() {
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {

        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        //Make an OXMServerConnection and redirect its network requests to the Mock Server
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Make an OXMAdConfiguration
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
        
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.requestCompletedSuccess(vastResponse: response)
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail("\(error)")
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("vast_om_verification_from_extension.xml") {
            requester.buildAdsArray(data)
        }
                
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func requestCompletedSuccess(vastResponse: OXMAdRequestResponseVAST) {
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        OXMAssertEq(vastResponse.ads?.count, 1)
        guard let ad = vastResponse.ads?.first as? OXMVastInlineAd else {
            XCTFail()
            return;
        }
        
        XCTAssertNotNil(ad.verificationParameters)
        XCTAssertEqual(ad.verificationParameters.verificationResources.count, 1)
        
        let resource1 = ad.verificationParameters.verificationResources[0] as! OXMVideoVerificationResource
        OXMAssertEq(resource1.url, "https://company.com/omid.js")
        OXMAssertEq(resource1.vendorKey, "company.com-omid")
        OXMAssertEq(resource1.params, "parameter1=value1&parameter2=value2&parameter3=value3")
        OXMAssertEq(resource1.apiFramework, "omid")
        
        XCTAssertNotNil(resource1.trackingEvents)
        XCTAssertNotNil(resource1.trackingEvents?.trackingEvents)

        let trackingEvents = resource1.trackingEvents?.trackingEvents

        XCTAssertEqual(trackingEvents?["verificationNotExecuted"], ["https://company.com/pixel.jpg?error=[REASON]"])
        
        // Must be in the end of the method
        self.vastRequestSuccessfulExpectation.fulfill()
    }
}
