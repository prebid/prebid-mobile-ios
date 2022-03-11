/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

class PBMAppInfoParameterBuilderTest: XCTestCase {
    
    let parameterDict = ["foo": "bar"]
    let publisherName = "publisherName"
    var bidRequest: PBMORTBBidRequest!
    var mockBundle: MockBundle!
    var builder: PBMAppInfoParameterBuilder!
    var targeting: Targeting!
    
    override func setUp() {
        super.setUp()
        bidRequest = PBMORTBBidRequest()
        mockBundle = MockBundle()
        targeting = Targeting.shared
        targeting.publisherName = publisherName
        
        builder = PBMAppInfoParameterBuilder(bundle: mockBundle, targeting: targeting)
    }
    
    func testAddsAppInfoToORTBBidRequest() {
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.app.bundle, mockBundle.mockBundleIdentifier)
        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
        PBMAssertEq(bidRequest.app.publisher?.name, publisherName)
        
        XCTAssertNotEqual(bidRequest.app.name, mockBundle.mockBundleName)
    }
    
    func testMissingBundleIdentifier() {
        mockBundle.mockBundleIdentifier = nil
        builder.build(bidRequest)
        
        XCTAssertNil(bidRequest.app.bundle)
    }
    
    func testMissingBundleDisplayName() {
        mockBundle.mockBundleDisplayName = nil
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleName)
    }
    
    func testMissingBundleName() {
        mockBundle.mockBundleName = nil
        builder.build(bidRequest)
        
        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
    }
    
    func testMissingAllBundleDisplayNameAndBundleName() {
        mockBundle.mockBundleDisplayName = nil
        mockBundle.mockBundleName = nil
        builder.build(bidRequest)
        
        XCTAssertNil(bidRequest.app.name)
    }
    
    func testMissingBundleInfoDictionary() {
        mockBundle.mockShouldNilInfoDictionary = true
        builder.build(bidRequest)
        
        XCTAssertNil(bidRequest.app.name)
    }
    
    func testMissingPublisherName() {
        targeting.publisherName = nil
        builder.build(bidRequest)
        
        XCTAssertNil(bidRequest.app.publisher?.name)
    }
}
