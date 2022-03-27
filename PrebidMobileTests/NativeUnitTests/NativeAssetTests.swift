/*   Copyright 2018-2019 Prebid.org, Inc.

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

class NativeAssetTests: XCTestCase {
    
    func testNativeAssetTitle() {
        let assettitle = NativeAssetTitle(length:25, required: true)
        XCTAssertTrue(assettitle.length == 25)
        let ext = ["key" : "value"]
        assettitle.ext = ext as AnyObject
        if let data = assettitle.ext as? [String : String], let value = data["key"] {
            XCTAssertTrue(value == "value")
        }
    }
    
    func testNativeAssetImage() {
        let assetImage = NativeAssetImage(minimumWidth: 20, minimumHeight: 30, required: true)
        assetImage.type = .Icon
        assetImage.width = 100
        assetImage.height = 200
        assetImage.mimes = ["png"]
        assetImage.ext = ["key" : "value"] as AnyObject
        XCTAssertTrue(assetImage.widthMin == 20)
        XCTAssertTrue(assetImage.heightMin == 30)
        XCTAssertTrue(assetImage.width == 100)
        XCTAssertTrue(assetImage.height == 200)
        XCTAssertTrue(assetImage.type == .Icon)
        if let mimes = assetImage.mimes{
            if mimes.count == 1 {
                let value = mimes[0]
                XCTAssertTrue(value == "png")
            }
        }
        if let ext = assetImage.ext as? [String : String], let value = ext["key"] {
            XCTAssertTrue(value == "value")
        }
    }
    
    func testNativeAssetData() {
        let assetData = NativeAssetData(type: DataAsset.description, required: true)
         assetData.ext = ["key" : "value"] as AnyObject
        XCTAssertTrue(assetData.type == DataAsset.description)
         if let ext = assetData.ext as? [String : String], let value = ext["key"] {
             XCTAssertTrue(value == "value")
         }
     }
    
    func testNativeAssetIdAndRequiredFileds() {
        let asset = NativeAsset(isRequired: false)
        XCTAssertNil(asset.id)
        XCTAssertFalse(asset.required)
        asset.id = 100
        asset.required = true
        XCTAssertTrue(asset.id == 100)
        XCTAssertTrue(asset.required)
    }
}
