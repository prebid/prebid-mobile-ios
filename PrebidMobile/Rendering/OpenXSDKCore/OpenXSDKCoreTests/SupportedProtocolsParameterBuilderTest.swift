//
//  SupportedProtocolsParameterBuilderTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import OpenXApolloSDK

class SupportedProtocolsParameterBuilderTest : XCTestCase {

    func testParameterBuilder() {
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .display
        
        //Run the Builder
        let sdkConfig = OXASDKConfiguration()
        let targeting = OXATargeting.withDisabledLock
        let builder = OXMBasicParameterBuilder(adConfiguration: adConfiguration,
                                                  sdkConfiguration: sdkConfig,
                                               sdkVersion: "MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)
     
        //Test with MRAID (default)
        let supportedProtocolsParameterBuilder = OXMSupportedProtocolsParameterBuilder(sdkConfiguration: sdkConfig)
        supportedProtocolsParameterBuilder.build(bidRequest)

        OXMAssertEq(bidRequest.imp.first!.banner!.api, [3,5,6,7])
    }
}
