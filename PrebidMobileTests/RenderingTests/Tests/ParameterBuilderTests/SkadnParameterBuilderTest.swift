//
//  SkadnParameterBuilderTest.swift
//  PrebidMobileTests
//
//  Created by Olena Stepaniuk on 19.01.2023.
//  Copyright © 2023 AppNexus. All rights reserved.
//

import XCTest
@testable import PrebidMobile

fileprivate let skAdNetworkIdsMock = ["cstr6suwn9.skadnetwork", "4fzdc2evr5.skadnetwork"]
fileprivate let sourceappMock = "MockTestApp"

class MockSKAdNetworksParameterBuilder: PBMSKAdNetworksParameterBuilder {
    override func skAdNetworkIds() -> [String] {
        return skAdNetworkIdsMock
    }
}

class SkadnParameterBuilderTest: XCTestCase {
    
    func testParameterBuilder_DefaultValues() {
        let adConfiguration = AdConfiguration()
        let mockTargeting = Targeting()
        
        let basicBuilder = PBMBasicParameterBuilder(adConfiguration: adConfiguration, sdkConfiguration: Prebid.shared, sdkVersion: "mock-version", targeting: mockTargeting)
        let skadnBuilder = PBMSKAdNetworksParameterBuilder(bundle: Bundle.main, targeting: mockTargeting, adConfiguration: adConfiguration)
        
        let bidRequest = PBMORTBBidRequest()
        
        basicBuilder.build(bidRequest)
        skadnBuilder.build(bidRequest)
        
        bidRequest.imp.forEach({ imp in
            XCTAssert(imp.extSkadn.skadnetids == [])
            XCTAssert(imp.extSkadn.sourceapp == nil)
        })
    }
    
    func testParameterBuilder() {
        let adConfiguration = AdConfiguration()
        let mockTargeting = Targeting()
        
        mockTargeting.sourceapp = sourceappMock
        
        let basicBuilder = PBMBasicParameterBuilder(adConfiguration: adConfiguration, sdkConfiguration: Prebid.shared, sdkVersion: "mock-version", targeting: mockTargeting)
        let skadnBuilder = MockSKAdNetworksParameterBuilder(bundle: Bundle.main, targeting: mockTargeting, adConfiguration: adConfiguration)
        
        let bidRequest = PBMORTBBidRequest()
        
        basicBuilder.build(bidRequest)
        skadnBuilder.build(bidRequest)
        
        bidRequest.imp.forEach({ imp in
            XCTAssert(imp.extSkadn.skadnetids == skAdNetworkIdsMock)
            XCTAssert(imp.extSkadn.sourceapp == sourceappMock)
        })
    }
}
