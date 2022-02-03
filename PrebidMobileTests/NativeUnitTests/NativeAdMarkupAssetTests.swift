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

import Foundation
import XCTest
@testable import PrebidMobile

import Foundation
import XCTest

class NativeAdMarkupAssetTests: XCTestCase {
    func testInitFromJson() {
        let imageDict: [String: Any] = [
            "type": 1,
            "url": "test url",
            "w": 320,
            "h": 50,
            "ext": ["la": "ks"]
        ]

        let imageAssetDict: [String: Any] = [
            "id": 1,
            "required": 1,
            "img": imageDict,
            "ext": ["la": "ks"]
        ]
        
        let expectedImageAsset = NativeAdMarkupAsset()
        expectedImageAsset.id = 1
        expectedImageAsset.required = 1
        let expectedImage = NativeImage()
        expectedImage.type = 1
        expectedImage.url = "test url"
        expectedImage.width = 320
        expectedImage.height = 50
        expectedImage.ext = ["la": "ks"]
        expectedImageAsset.img = expectedImage
        expectedImageAsset.ext = ["la": "ks"]

        let titleDic: [String: Any] = [
            "text": "test text",
            "len": 9,
            "ext": ["la": "ks"]
        ]

        let titleAssetDict: [String: Any] = [
            "id": 1,
            "required": 1,
            "title": titleDic,
            "ext": ["la": "ks"]
        ]
        
        let expectedTitleAsset = NativeAdMarkupAsset()
        expectedTitleAsset.id = 1
        expectedTitleAsset.required = 1
        let expectedTitle = NativeTitle()
        expectedTitle.text = "test text"
        expectedTitle.length = 9
        expectedTitle.ext = ["la": "ks"]
        expectedTitleAsset.title = expectedTitle
        expectedTitleAsset.ext = ["la": "ks"]
        
        let dataDict: [String: Any] = [
            "type": 1,
            "len": 5,
            "value": "hello",
            "ext": ["la": "ks"]
        ]
        
        let dataAssetDict: [String: Any] = [
            "id": 1,
            "required": 1,
            "data": dataDict,
            "ext": ["la": "ks"]
        ]
        
        let expectedDataAsset = NativeAdMarkupAsset()
        expectedDataAsset.id = 1
        expectedDataAsset.required = 1
        let expectedData = NativeData()
        expectedData.type = 1
        expectedData.length = 5
        expectedData.value = "hello"
        expectedData.ext = ["la": "ks"]
        expectedDataAsset.data = expectedData
        expectedDataAsset.ext = ["la": "ks"]

        let titleAsset = NativeAdMarkupAsset(jsonDictionary: titleAssetDict)
        let imageAsset = NativeAdMarkupAsset(jsonDictionary: imageAssetDict)
        let dataAsset = NativeAdMarkupAsset(jsonDictionary: dataAssetDict)
        
        XCTAssertTrue(expectedTitleAsset == titleAsset)
        XCTAssertTrue(expectedImageAsset == imageAsset)
        XCTAssertTrue(expectedDataAsset == dataAsset)
    }
    
    func testMultipleAssetsInOne() {
        let imageDict: [String: Any] = [
            "type": 1,
            "url": "test url",
            "w": 320,
            "h": 50,
            "ext": ["la": "ks"]
        ]

        let titleDic: [String: Any] = [
            "text": "test text",
            "len": 9,
            "ext": ["la": "ks"]
        ]
        
        let dataDict: [String: Any] = [
            "type": 1,
            "len": 5,
            "value": "hello",
            "ext": ["la": "ks"]
        ]
        
        let testAssetDict1: [String: Any] = [
            "id": 1,
            "required": 1,
            "title": titleDic,
            "img": imageDict,
            "data": dataDict,
            "ext": ["la": "ks"]
        ]
        
        let testAsset1 = NativeAdMarkupAsset(jsonDictionary: testAssetDict1)
        
        XCTAssertNil(testAsset1.img)
        XCTAssertNil(testAsset1.data)
        
        let testAssetDict2: [String: Any] = [
            "id": 1,
            "required": 1,
            "img": imageDict,
            "data": dataDict,
            "ext": ["la": "ks"]
        ]
        
        let testAsset2 = NativeAdMarkupAsset(jsonDictionary: testAssetDict2)
        
        XCTAssertNil(testAsset2.title)
        XCTAssertNil(testAsset2.data)
        
        let testAssetDict3: [String: Any] = [
            "id": 1,
            "required": 1,
            "data": dataDict,
            "ext": ["la": "ks"]
        ]
        
        let testAsset3 = NativeAdMarkupAsset(jsonDictionary: testAssetDict3)
        
        XCTAssertNil(testAsset3.title)
        XCTAssertNil(testAsset3.img)
    }
}

extension NativeAdMarkupAsset {
    static func ==(lhs: NativeAdMarkupAsset, rhs: NativeAdMarkupAsset) -> Bool {
        return lhs.id == rhs.id &&
        lhs.required == rhs.required &&
        lhs.title?.text == rhs.title?.text &&
        lhs.title?.length == rhs.title?.length &&
        NSDictionary(dictionary: lhs.title?.ext ?? [:]).isEqual(to: rhs.title?.ext ?? [:]) &&
        lhs.img?.type == rhs.img?.type &&
        lhs.img?.url == rhs.img?.url &&
        lhs.img?.width == rhs.img?.width &&
        lhs.img?.height == rhs.img?.height &&
        NSDictionary(dictionary: lhs.img?.ext ?? [:]).isEqual(to: rhs.img?.ext ?? [:]) &&
        lhs.data?.type == rhs.data?.type &&
        lhs.data?.value == rhs.data?.value &&
        lhs.data?.length == rhs.data?.length &&
        NSDictionary(dictionary: lhs.data?.ext ?? [:]).isEqual(to: rhs.data?.ext ?? [:]) &&
        lhs.link?.url == rhs.link?.url &&
        lhs.link?.clicktrackers == rhs.link?.clicktrackers &&
        lhs.link?.fallback == rhs.link?.fallback &&
        NSDictionary(dictionary: lhs.link?.ext ?? [:]).isEqual(to: rhs.link?.ext ?? [:]) &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
