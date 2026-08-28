/*   Copyright 2018-2025 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import XCTest
@testable import PrebidMobile

fileprivate let skAdNetworkIdsMock = ["cstr6suwn9.skadnetwork", "4fzdc2evr5.skadnetwork"]
fileprivate let sourceappMock = "MockTestApp"
fileprivate let sdkVersionMock = "1.0.0"

fileprivate class MockSKAdNetworksParameterBuilder: SKAdNetworksParameterBuilder {
    
    override func skAdNetworkIds() -> [String]? {
        skAdNetworkIdsMock
    }
}

class SkadnParameterBuilderTest: XCTestCase {
    
    func testParameterBuilder_DefaultValues() {
        let adConfiguration = AdConfiguration()
        let mockTargeting = Targeting()
        
        let basicBuilder = BasicParameterBuilder(
            adConfiguration: adConfiguration,
            sdkConfiguration: Prebid.shared,
            sdkVersion: sdkVersionMock,
            targeting: mockTargeting
        )
        
        let skadnBuilder = SKAdNetworksParameterBuilder(
            bundle: Bundle.main,
            targeting: mockTargeting,
            adConfiguration: adConfiguration
        )
        
        let bidRequest = ORTBBidRequest()
        
        basicBuilder.build(bidRequest)
        skadnBuilder.build(bidRequest)
        
        bidRequest.imp.forEach({ imp in
            XCTAssert(imp.extSkadn.skadnetids == [])
            XCTAssert(imp.extSkadn.sourceapp == nil)
            XCTAssert(imp.extSkadn.skoverlay == nil)
        })
    }
    
    func testParameterBuilder() {
        let adConfiguration = AdConfiguration()
        let mockTargeting = Targeting()
        
        mockTargeting.sourceapp = sourceappMock
        adConfiguration.supportSKOverlay = true
        
        let basicBuilder = BasicParameterBuilder(
            adConfiguration: adConfiguration,
            sdkConfiguration: Prebid.shared,
            sdkVersion: sdkVersionMock,
            targeting: mockTargeting
        )
        
        let skadnBuilder = MockSKAdNetworksParameterBuilder(
            bundle: Bundle.main,
            targeting: mockTargeting,
            adConfiguration: adConfiguration
        )
        
        let bidRequest = ORTBBidRequest()
        
        basicBuilder.build(bidRequest)
        skadnBuilder.build(bidRequest)
        
        bidRequest.imp.forEach({ imp in
            XCTAssert(imp.extSkadn.skadnetids == skAdNetworkIdsMock)
            XCTAssert(imp.extSkadn.sourceapp == sourceappMock)
            XCTAssert(imp.extSkadn.skoverlay == 1)
        })
    }

    /// Exercises the real `skAdNetworkIds()` parse — not the `MockSKAdNetworksParameterBuilder`
    /// override. The ObjC original inserted the result of `objectForKey:` unconditionally; the
    /// Swift port `compactMap`s, so an entry with a missing or wrong-type identifier is skipped
    /// instead of becoming a `nil` element.
    func testSKAdNetworkIds_SkipsMalformedEntries() {
        let identifierKey = SKAdNetworksParameterBuilder.SKAdNetworkIdentifierKey

        let mockBundle = MockBundle()
        mockBundle.mockSKAdNetworkItems = [
            [identifierKey: skAdNetworkIdsMock[0]],
            [:],
            [identifierKey: 42],
            ["SomeOtherKey": "not.an.id"],
            [identifierKey: skAdNetworkIdsMock[1]]
        ]

        let mockTargeting = Targeting()
        mockTargeting.sourceapp = sourceappMock

        let skadnBuilder = SKAdNetworksParameterBuilder(
            bundle: mockBundle,
            targeting: mockTargeting,
            adConfiguration: AdConfiguration()
        )

        XCTAssertEqual(skadnBuilder.skAdNetworkIds(), skAdNetworkIdsMock)

        let bidRequest = ORTBBidRequest()
        bidRequest.imp = [ORTBImp()]

        skadnBuilder.build(bidRequest)

        bidRequest.imp.forEach({ imp in
            XCTAssert(imp.extSkadn.skadnetids == skAdNetworkIdsMock)
            XCTAssert(imp.extSkadn.sourceapp == sourceappMock)
        })
    }

    func testSKAdNetworkIds_NilInfoDictionary() {
        let mockBundle = MockBundle()
        mockBundle.mockShouldNilInfoDictionary = true

        let skadnBuilder = SKAdNetworksParameterBuilder(
            bundle: mockBundle,
            targeting: Targeting(),
            adConfiguration: AdConfiguration()
        )

        XCTAssertNil(skadnBuilder.skAdNetworkIds())
    }
}
