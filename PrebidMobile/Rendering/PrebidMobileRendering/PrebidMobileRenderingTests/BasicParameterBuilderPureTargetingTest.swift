
import UIKit
import XCTest

@testable import PrebidMobileRendering

class BasicParameterBuilderPureTargetingTest: XCTestCase {
    
    func testParameterBuilderNoUserAgeNoCoppa() {
        let targeting = PrebidRenderingTargeting.shared
        let builder = PBMBasicParameterBuilder(adConfiguration:PBMAdConfiguration(),
                                                  sdkConfiguration:PrebidRenderingConfig.mock,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
}
