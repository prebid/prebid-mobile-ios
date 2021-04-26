
import UIKit
import XCTest

@testable import PrebidMobileRendering

class BasicParameterBuilderPureTargetingTest: XCTestCase {
    
    func testParameterBuilderNoUserAgeNoCoppa() {
        let targeting = PBMTargeting.withDisabledLock
        let builder = PBMBasicParameterBuilder(adConfiguration:PBMAdConfiguration(),
                                                  sdkConfiguration:PBMSDKConfiguration(),
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
}
