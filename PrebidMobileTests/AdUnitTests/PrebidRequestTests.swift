/*   Copyright 2019-2023 Prebid.org, Inc.
 
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

final class PrebidRequestTests: XCTestCase {

    func testDefault() {
        let request = PrebidRequest()
        
        XCTAssertNil(request.bannerParameters)
        XCTAssertNil(request.videoParameters)
        XCTAssertNil(request.nativeParameters)
        
        XCTAssertFalse(request.isInterstitial)
        XCTAssertFalse(request.isRewarded)
        
        XCTAssertTrue(request.getExtKeywords().isEmpty)
    }
    
    // MARK: - adunit ext keywords (imp[].ext.keywords)
    
    func testAddExtKeyword() {
        //given
        let element1 = "element1"
        let request = PrebidRequest()
        
        //when
        request.addExtKeyword(element1)
        let set = request.getExtKeywords()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddExtKeywords() {
        //given
        let element1 = "element1"
        let inputSet: Set = [element1]
        let request = PrebidRequest()
        
        //when
        request.addExtKeywords(inputSet)
        let set = request.getExtKeywords()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveExtKeyword() {
        //given
        let element1 = "element1"
        let request = PrebidRequest()
        request.addExtKeyword(element1)
        
        //when
        request.removeExtKeyword(element1)
        let set = request.getExtKeywords()
        
        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearExtKeywords() {
        //given
        let element1 = "element1"
        let request = PrebidRequest()
        request.addExtKeyword(element1)
        
        //when
        request.clearExtKeywords()
        let set = request.getExtKeywords()
        
        //then
        XCTAssertEqual(0, set.count)
    }
}
