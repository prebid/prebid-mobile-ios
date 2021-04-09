
import UIKit
import XCTest
@testable import OpenXApolloSDK

class BasicParameterBuilderPureTargetingTest: XCTestCase {
    
    func testParameterBuilderNoUserAgeNoCoppa() {
        let targeting = OXATargeting.withDisabledLock
        let builder = OXMBasicParameterBuilder(adConfiguration:OXMAdConfiguration(),
                                                  sdkConfiguration:OXASDKConfiguration(),
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
}
