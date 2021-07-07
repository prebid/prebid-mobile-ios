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
@testable import PrebidMobileRendering

class PBMNativeFunctionsTest: XCTestCase {


    func testPopulateTemplateTargetingMap() {
        let nativeTemplate = """
html code
pbNativeTagData.targetingMap = %%PATTERN:TARGETINGMAP%%;
""";
        let targeting = [
            "hb_cache_path": "/cache/path"
        ];
        
        let expectedResult = """
html code
pbNativeTagData.targetingMap = {"hb_cache_path":"\\/cache\\/path"};
""";
        
        let result = try! PBMNativeFunctions.populateNativeAdTemplate(nativeTemplate, withTargeting: targeting)
        
        XCTAssertEqual(expectedResult, result)
    }
    
    func testPopulateTemplateKeys() {
        let nativeTemplate = """
html code
pbNativeTagData.cachePath = "%%PATTERN:hb_cache_path%%";
pbNativeTagData.absent_key = %%PATTERN:absent_key%%;
pbNativeTagData.quoted_absent_key = "%%PATTERN:q_absent_key%%";
pbNativeTagData.hbPb = %%PATTERN:hb_pb%%;
pbNativeTagData.hbPb10 = %%PATTERN:hb_pb%%*10;
var t = "Some text: %%PATTERN:absent_key2%%";
""";
        let targeting = [
            "hb_cache_path": "/cache/path",
            "hb_pb": "0.2"
        ];
        
        let expectedResult = """
html code
pbNativeTagData.cachePath = \"/cache/path\";
pbNativeTagData.absent_key = null;
pbNativeTagData.quoted_absent_key = null;
pbNativeTagData.hbPb = 0.2;
pbNativeTagData.hbPb10 = 0.2*10;
var t = "Some text: null";
""";
        
        let result = try! PBMNativeFunctions.populateNativeAdTemplate(nativeTemplate, withTargeting: targeting)
        
        XCTAssertEqual(expectedResult, result)
    }

}
