import XCTest

@testable import PrebidMobile

class PBMVastLoaderTestOMVerificationOneInline: XCTestCase {
    
    var vastRequestSuccessfulExpectation:XCTestExpectation!

    override func setUp() {
        self.continueAfterFailure = true
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        self.vastRequestSuccessfulExpectation = nil
    }
    
    func testRequest() {

        self.vastRequestSuccessfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        //Make an PBMServerConnection and redirect its network requests to the Mock Server
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Make an PBMAdConfiguration
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .videoInternal
        
        let adLoadManager = MockPBMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.requestCompletedSuccess(response)
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            XCTFail("\(error)")
        }
        
        let requester = PBMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("vast_om_verification_one_inline_ad.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func requestCompletedSuccess(_ vastResponse: PBMAdRequestResponseVAST) {
        
        //There should be 1 ad.
        //An Ad can be either inline or wrapper; this should be inline.
        PBMAssertEq(vastResponse.ads?.count, 1)
        guard let ad = vastResponse.ads?.first as? PBMVastInlineAd else {
            XCTFail()
            return;
        }
        
        XCTAssertNotNil(ad.verificationParameters)
        XCTAssertEqual(ad.verificationParameters.verificationResources.count, 2)
        
        let resource1 = ad.verificationParameters.verificationResources[0] as! PBMVideoVerificationResource
        PBMAssertEq(resource1.url, "https://measurement.domain.com/tag.js")
        PBMAssertEq(resource1.vendorKey, "OpenX1")
        PBMAssertEq(resource1.params, "{1}")
        PBMAssertEq(resource1.apiFramework, "omidOpenx1")
        
        let resource2 = ad.verificationParameters.verificationResources[1] as! PBMVideoVerificationResource
        PBMAssertEq(resource2.url, "https://measurement.domain.com/tag2.js")
        PBMAssertEq(resource2.vendorKey, "OpenX2")
        PBMAssertEq(resource2.params, "{2}")
        PBMAssertEq(resource2.apiFramework, "omidOpenx2")

        // Must be in the end of the method
        self.vastRequestSuccessfulExpectation.fulfill()
    }
}
