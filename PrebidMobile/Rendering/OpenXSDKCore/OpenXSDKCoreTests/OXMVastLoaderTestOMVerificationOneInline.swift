import XCTest

@testable import OpenXApolloSDK

class OXMVastLoaderTestOMVerificationOneInline: XCTestCase {
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!

    override func setUp() {
        self.continueAfterFailure = true
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
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
            self.requestCompletedSuccess(response)
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail("\(error)")
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("vast_om_verification_one_inline_ad.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func requestCompletedSuccess(_ vastResponse: OXMAdRequestResponseVAST) {
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        OXMAssertEq(vastResponse.ads?.count, 1)
        guard let ad = vastResponse.ads?.first as? OXMVastInlineAd else {
            XCTFail()
            return;
        }
        
        XCTAssertNotNil(ad.verificationParameters)
        XCTAssertEqual(ad.verificationParameters.verificationResources.count, 2)
        
        let resource1 = ad.verificationParameters.verificationResources[0] as! OXMVideoVerificationResource
        OXMAssertEq(resource1.url, "https://measurement.domain.com/tag.js")
        OXMAssertEq(resource1.vendorKey, "OpenX1")
        OXMAssertEq(resource1.params, "{1}")
        OXMAssertEq(resource1.apiFramework, "omidOpenx1")
        
        let resource2 = ad.verificationParameters.verificationResources[1] as! OXMVideoVerificationResource
        OXMAssertEq(resource2.url, "https://measurement.domain.com/tag2.js")
        OXMAssertEq(resource2.vendorKey, "OpenX2")
        OXMAssertEq(resource2.params, "{2}")
        OXMAssertEq(resource2.apiFramework, "omidOpenx2")

        // Must be in the end of the method
        self.vastRequestSuccessfulExpectation.fulfill()
    }
}
