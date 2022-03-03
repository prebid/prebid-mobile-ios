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
@testable import PrebidMobile
import XCTest

class OriginalAdUnitConfigurationTests: XCTestCase {
    
    var adUnitConfig: OriginalAdUnitConfigurationProtocol?
    
    override func setUp() {
        super.setUp()
        adUnitConfig = OriginalAdUnitConfiguration(configId: "test", size: CGSize(width: 320, height: 50))
    }
    
    // MARK: - Context data aka inventory data (imp[].ext.context.data)
    
    func testAddContextData() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let key1 = "key1"
        let value1 = "value1"
        
        adUnitConfig.addContextData(key: key1, value: value1)
        let dictionary = adUnitConfig.getContextDataDictionary()
        
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateContextData() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        
        adUnitConfig.updateContextData(key: key1, value: set)
        
        let dictionary = adUnitConfig.getContextDataDictionary()
        
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveContextData() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let key1 = "key1"
        let value1 = "value1"
        adUnitConfig.addContextData(key: key1, value: value1)
        
        adUnitConfig.removeContextData(for: key1)
        let dictionary = adUnitConfig.getContextDataDictionary()
        
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearContextData() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let key1 = "key1"
        let value1 = "value1"
        adUnitConfig.addContextData(key: key1, value: value1)
        
        adUnitConfig.clearContextData()
        let dictionary = adUnitConfig.getContextDataDictionary()
        
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - Context keywords (imp[].ext.context.keywords)
    
    func testAddContextKeyword() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let element1 = "element1"
        
        adUnitConfig.addContextKeyword(element1)
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddContextKeywords() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let element1 = "element1"
        let inputSet: Set = [element1]
        
        adUnitConfig.addContextKeywords(inputSet)
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveContextKeyword() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let element1 = "element1"
        adUnitConfig.addContextKeyword(element1)
        
        adUnitConfig.removeContextKeyword(element1)
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(0, set.count)
    }
    
    func testClearContextKeywords() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let element1 = "element1"
        adUnitConfig.addContextKeyword(element1)
        
        adUnitConfig.clearContextKeywords()
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(0, set.count)
    }
    
    
    // MARK: - global context data aka inventory data (app.content.data)
    
    func testSetAppContent() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"
        
        let appContent = PBMORTBAppContent()
        appContent.album = "test album"
        appContent.embeddable = 1
        appContent.data = [appDataObject1, appDataObject2]

        adUnitConfig.setAppContent(appContent)
        let resultAppContent = adUnitConfig.getAppContent()!

        XCTAssertEqual(2, resultAppContent.data!.count)
        XCTAssertEqual(resultAppContent.data!.first, appDataObject1)
        XCTAssertEqual(appContent, resultAppContent)
    }
    
    func testClearAppContent() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"
        
        let appContent = PBMORTBAppContent()
        appContent.album = "test album"
        appContent.embeddable = 1
        appContent.data = [appDataObject1, appDataObject2]
        
        adUnitConfig.setAppContent(appContent)
        
        let resultAppContent1 = adUnitConfig.getAppContent()
        XCTAssertNotNil(resultAppContent1)
        adUnitConfig.clearAppContent()
        let resultAppContent2 = adUnitConfig.getAppContent()
        XCTAssertNil(resultAppContent2)
    }
    
    func testAddAppContentDataObject() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
         
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        adUnitConfig.addAppContentData([appDataObject1, appDataObject2])
        let objects = adUnitConfig.getAppContent()!.data!

        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, appDataObject1)
    }

    func testRemoveAppContentDataObjects() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let appDataObject = PBMORTBContentData()
        appDataObject.id = "data id"
        appDataObject.name = "test name"

        adUnitConfig.addAppContentData([appDataObject])
        let objects1 = adUnitConfig.getAppContent()!.data!

        XCTAssertEqual(1, objects1.count)

        adUnitConfig.removeAppContentData(appDataObject)
        let objects2 = adUnitConfig.getAppContent()!.data!

        XCTAssertEqual(0, objects2.count)
    }
    
    func testClearAppContentDataObjects() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        adUnitConfig.addAppContentData([appDataObject1, appDataObject2])
        let objects1 = adUnitConfig.getAppContent()!.data!
        
        XCTAssertEqual(2, objects1.count)
        adUnitConfig.clearAppContentData()
        let objects2 = adUnitConfig.getAppContent()!.data!
        XCTAssertEqual(0, objects2.count)
    }
    
    // MARK: - global user data aka visitor data (user.data)

    func testAddUserDataObjects() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        adUnitConfig.addUserData([userDataObject1, userDataObject2])
        let objects = adUnitConfig.getUserData()!

        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
    }
    
    func testRemoveUserDataObjects() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let userDataObject = PBMORTBContentData()
        userDataObject.id = "data id"
        userDataObject.name = "test name"

        adUnitConfig.addUserData([userDataObject])
        let objects1 = adUnitConfig.getUserData()!

        XCTAssertEqual(1, objects1.count)

        adUnitConfig.removeUserData(userDataObject)
        let objects2 = adUnitConfig.getUserData()!

        XCTAssertEqual(0, objects2.count)
    }

    func testClearUserDataObjects() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        adUnitConfig.addUserData([userDataObject1, userDataObject2])
        let objects1 = adUnitConfig.getUserData()!

        XCTAssertEqual(2, objects1.count)

        adUnitConfig.clearUserData()
        let objects2 = adUnitConfig.getUserData()!
        XCTAssertEqual(0, objects2.count)
    }
    
    // MARK: - The Prebid Ad Slot
    
    func testSetPbAdSlot() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        
        XCTAssertNil(adUnitConfig.getPbAdSlot())
        adUnitConfig.setPbAdSlot("test-ad-slot")
        XCTAssertEqual("test-ad-slot", adUnitConfig.getPbAdSlot())
    }
    
    func testClearPbAdSlot() {
        guard let adUnitConfig = adUnitConfig else {
            XCTFail()
            return
        }
        XCTAssertNil(adUnitConfig.getPbAdSlot())
        adUnitConfig.setPbAdSlot("test-ad-slot")
        XCTAssertNotNil(adUnitConfig.getPbAdSlot())
        adUnitConfig.clearAdSlot()
        XCTAssertNil(adUnitConfig.getPbAdSlot())
    }
}
