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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNativeAssetTitle() {
        let asset = NativeAsset()
        XCTAssertNil(asset.title)
        XCTAssertNil(asset.ext)
        asset.title = NativeAssetTitle(length:25)
        XCTAssertTrue(asset.title!.length == 25)
        let ext = ["key" : "value"]
        asset.ext = ext as AnyObject
        if let data = asset.ext as? [String : String], let value = data["key"] {
            XCTAssertTrue(value == "value")
        }
    }
    
    func testNativeAssetImage() {
        let asset = NativeAsset()
        XCTAssertNil(asset.image)
        asset.image = NativeAssetImage(minimumWidth: 20, minimumHeight: 30)
        asset.image?.type = .Icon
        asset.image?.width = 100
        asset.image?.height = 200
        asset.image?.mimes = ["png"]
        asset.image?.ext = ["key" : "value"] as AnyObject
        XCTAssertTrue(asset.image!.widthMin == 20)
        XCTAssertTrue(asset.image!.heightMin == 30)
        XCTAssertTrue(asset.image!.width == 100)
        XCTAssertTrue(asset.image!.height == 200)
        XCTAssertTrue(asset.image!.type == .Icon)
        if let mimes = asset.image?.mimes{
            if mimes.count == 1 {
                let value = mimes[0]
                XCTAssertTrue(value == "png")
            }
        }
        if let ext = asset.image?.ext as? [String : String], let value = ext["key"] {
            XCTAssertTrue(value == "value")
        }
    }
    
    func testNativeAssetVideo() {
        let asset = NativeAsset()
        XCTAssertNil(asset.video)
        asset.video = NativeAssetVideo(mimes: ["png"], protocols: [1], minduration: 10, maxduration: 100)
        asset.video?.ext = ["key" : "value"] as AnyObject
        XCTAssertTrue(asset.video!.minDuration == 10)
        XCTAssertTrue(asset.video!.maxDuration == 100)
        if let mimes = asset.video?.mimes{
            if mimes.count == 1 {
                let value = mimes[0]
                XCTAssertTrue(value == "png")
            }
        }
        if let protocols = asset.video?.protocols{
                  if protocols.count == 1 {
                      let value = protocols[0]
                      XCTAssertTrue(value == 1)
                  }
              }
        if let ext = asset.video?.ext as? [String : String], let value = ext["key"] {
            XCTAssertTrue(value == "value")
        }
    }
    
    func testNativeAssetData() {
         let asset = NativeAsset()
         XCTAssertNil(asset.data)
         asset.data = NativeAssetData(type: 1)
         asset.data?.ext = ["key" : "value"] as AnyObject
         XCTAssertTrue(asset.data!.type == 1)
         if let ext = asset.video?.ext as? [String : String], let value = ext["key"] {
             XCTAssertTrue(value == "value")
         }
     }
    
    func testNativeAssetIdAndRequiredFileds() {
        let asset = NativeAsset()
        XCTAssertNil(asset.id)
        XCTAssertFalse(asset.required)
        asset.id = 100
        asset.required = true
        XCTAssertTrue(asset.id == 100)
        XCTAssertTrue(asset.required)
    }
}
