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

@testable import PrebidMobile

class NativeAdConfigurationTest: XCTestCase {
    
    func testSetupConfig() {
        let desc = PBRNativeAssetData(dataType: .desc)
        let nativeAdConfig = NativeAdConfiguration.init(assets:[desc])
        
        nativeAdConfig.context = NativeContextType.socialCentric.rawValue
        nativeAdConfig.contextsubtype = NativeContextSubtype.applicationStore.rawValue
        nativeAdConfig.plcmttype = NativePlacementType.feedGridListing.rawValue
        nativeAdConfig.seq = 1
        
        let nativeMarkupObject = nativeAdConfig.markupRequestObject
        
        XCTAssertEqual(nativeMarkupObject.context, NativeContextType.socialCentric.rawValue)
        XCTAssertEqual(nativeMarkupObject.contextsubtype, NativeContextSubtype.applicationStore.rawValue)
        XCTAssertEqual(nativeMarkupObject.plcmttype, NativePlacementType.feedGridListing.rawValue)
        XCTAssertEqual(nativeMarkupObject.seq, 1)
        
        nativeAdConfig.context = NativeContextType.undefined.rawValue
        nativeAdConfig.contextsubtype = NativeContextSubtype.undefined.rawValue
        nativeAdConfig.plcmttype = NativePlacementType.undefined.rawValue
        nativeAdConfig.seq = -1
        
        XCTAssertNil(nativeMarkupObject.context)
        XCTAssertNil(nativeMarkupObject.contextsubtype)
        XCTAssertNil(nativeMarkupObject.plcmttype)
        XCTAssertNil(nativeMarkupObject.seq)
    }
}
