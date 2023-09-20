/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

class PrebidJSLibraryManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        PrebidJSLibraryManager.shared.downloadLibraries()
    }
    
    override func tearDown() {
        super.tearDown()
        PrebidJSLibraryManager.shared.clearData()
    }
    
    func testMRAIDLibrary() {
        let library = PrebidJSLibraryManager.shared.mraidLibrary
        XCTAssertTrue(library.name == "mraid")
        XCTAssert(library.downloadURLString?.contains("mraid.js") == true)
    }
    
    func testOMSDKLibrary() {
        let library = PrebidJSLibraryManager.shared.omsdkLibrary
        XCTAssertTrue(library.name == "omsdk")
        XCTAssert(library.downloadURLString?.contains("omsdk.js") == true)
    }
    
    func testSaveLibrary_FetchCached() {
        let libraryName = "test"
        let contentsString = "test_content"
        
        let manager = PrebidJSLibraryManager()
        manager.saveLibrary(with: libraryName, contents: contentsString)
        
        let cachedLibraryContents = manager.getLibraryFromDisk(with: libraryName)
        XCTAssert(cachedLibraryContents == contentsString)
    }
    
    func testGetMRAIDLibrary() {
        let manager = PrebidJSLibraryManager()
        XCTAssertNotNil(manager.getMRAIDLibrary)
    }
    
    func testGetOMSDKLibrary() {
        let manager = PrebidJSLibraryManager()
        XCTAssertNotNil(manager.getOMSDKLibrary)
    }
}
