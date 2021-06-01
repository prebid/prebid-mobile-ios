//
//  SupportedProtocolsParameterBuilderTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import PrebidMobileRendering

class SupportedProtocolsParameterBuilderTest : XCTestCase {

    func testParameterBuilder() {
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .displayInternal
        
        //Run the Builder
        let sdkConfig = PrebidRenderingConfig.mock
        let targeting = PrebidRenderingTargeting.shared
        let builder = PBMBasicParameterBuilder(adConfiguration: adConfiguration,
                                                  sdkConfiguration: sdkConfig,
                                               sdkVersion: "MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
     
        //Test with MRAID (default)
        let supportedProtocolsParameterBuilder = PBMSupportedProtocolsParameterBuilder(sdkConfiguration: sdkConfig)
        supportedProtocolsParameterBuilder.build(bidRequest)

        PBMAssertEq(bidRequest.imp.first!.banner!.api, [3,5,6,7])
    }
}
