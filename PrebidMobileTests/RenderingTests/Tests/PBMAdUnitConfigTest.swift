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

class PBMAdUnitConfigTest: XCTestCase {
    
    let adUnitConfig = AdUnitConfig(configId: "dummy-config-id")
    
    func testSetRefreshInterval() {
        XCTAssertEqual(adUnitConfig.refreshInterval, 60)
        
        adUnitConfig.refreshInterval = 10   // less than the min value
        XCTAssertEqual(adUnitConfig.refreshInterval, 15)
        
        adUnitConfig.refreshInterval = 1000   // greater than the max value
        XCTAssertEqual(adUnitConfig.refreshInterval, 120)
    }
    
    // MARK: - [DEPRECATED API] Context data aka inventory data (imp[].ext.context.data)
    
    func testAddContextData() {
        let key1 = "key1"
        let value1 = "value1"
        
        adUnitConfig.addContextData(key: key1, value: value1)
        let dictionary = adUnitConfig.getExtData()
        
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateContextData() {
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        
        adUnitConfig.updateContextData(key: key1, value: set)
        
        let dictionary = adUnitConfig.getContextData()
        
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveContextData() {
        let key1 = "key1"
        let value1 = "value1"
        adUnitConfig.addContextData(key: key1, value: value1)
        
        adUnitConfig.removeContextData(for: key1)
        let dictionary = adUnitConfig.getContextData()
        
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearContextData() {
        let key1 = "key1"
        let value1 = "value1"
        adUnitConfig.addContextData(key: key1, value: value1)
        
        adUnitConfig.clearContextData()
        let dictionary = adUnitConfig.getContextData()
        
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - Ext Data aka inventory data (imp[].ext.data)
    
    func testAddExtData() {
        let key1 = "key1"
        let value1 = "value1"
        
        adUnitConfig.addExtData(key: key1, value: value1)
        let dictionary = adUnitConfig.getExtData()
        
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateExtData() {
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        
        adUnitConfig.updateExtData(key: key1, value: set)
        
        let dictionary = adUnitConfig.getExtData()
        
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveExtData() {
        let key1 = "key1"
        let value1 = "value1"
        adUnitConfig.addExtData(key: key1, value: value1)
        
        adUnitConfig.removeExtData(for: key1)
        let dictionary = adUnitConfig.getExtData()
        
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearExtData() {
        let key1 = "key1"
        let value1 = "value1"
        adUnitConfig.addExtData(key: key1, value: value1)
        
        adUnitConfig.clearExtData()
        let dictionary = adUnitConfig.getExtData()
        
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - [DEPRECATED API] Context keywords (imp[].ext.context.keywords)
    
    func testAddContextKeyword() {
        let element1 = "element1"
        
        adUnitConfig.addContextKeyword(element1)
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddContextKeywords() {
        let element1 = "element1"
        let inputSet: Set = [element1]
        
        adUnitConfig.addContextKeywords(inputSet)
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveContextKeyword() {
        let element1 = "element1"
        adUnitConfig.addContextKeyword(element1)
        
        adUnitConfig.removeContextKeyword(element1)
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(0, set.count)
    }
    
    func testClearContextKeywords() {
        let element1 = "element1"
        adUnitConfig.addExtKeyword(element1)
        
        adUnitConfig.clearContextKeywords()
        let set = adUnitConfig.getContextKeywords()
        
        XCTAssertEqual(0, set.count)
    }
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
    func testAddExtKeyword() {
        let element1 = "element1"
        
        adUnitConfig.addExtKeyword(element1)
        let set = adUnitConfig.getExtKeywords()
        
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddExtKeywords() {
        let element1 = "element1"
        let inputSet: Set = [element1]
        
        adUnitConfig.addExtKeywords(inputSet)
        let set = adUnitConfig.getExtKeywords()
        
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveExtKeyword() {
        let element1 = "element1"
        adUnitConfig.addExtKeyword(element1)
        
        adUnitConfig.removeExtKeyword(element1)
        let set = adUnitConfig.getExtKeywords()
        
        XCTAssertEqual(0, set.count)
    }
    
    func testClearExtKeywords() {
        let element1 = "element1"
        adUnitConfig.addExtKeyword(element1)
        
        adUnitConfig.clearExtKeywords()
        let set = adUnitConfig.getExtKeywords()
        
        XCTAssertEqual(0, set.count)
    }
    
    // MARK: - App Content (app.content.data)
    
    func testSetAppContent() {
        //given
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
        //when
        adUnitConfig.setAppContent(appContent)
        let resultAppContent = adUnitConfig.getAppContent()!

        //then
        XCTAssertEqual(2, resultAppContent.data!.count)
        XCTAssertEqual(resultAppContent.data!.first, appDataObject1)
        XCTAssertEqual(appContent, resultAppContent)
    }
    
    func testClearAppContent() {
        //given
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
        //when
        adUnitConfig.setAppContent(appContent)
        let resultAppContent1 = adUnitConfig.getAppContent()
        XCTAssertNotNil(resultAppContent1)
        adUnitConfig.clearAppContent()
        let resultAppContent2 = adUnitConfig.getAppContent()
        XCTAssertNil(resultAppContent2)
    }
    
    func testAddAppContentDataObject() {
        //given
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        //when
        adUnitConfig.addAppContentData([appDataObject1, appDataObject2])
        let objects = adUnitConfig.getAppContent()!.data!

        //then
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, appDataObject1)
    }

    func testRemoveAppContentDataObjects() {
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
    
    // MARK: - User Data (user.data)

    func testAddUserDataObjects() {
        //given
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        //when
        adUnitConfig.addUserData([userDataObject1, userDataObject2])
        let objects = adUnitConfig.getUserData()!

        //then
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
    }
    
    func testRemoveUserDataObjects() {
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
        XCTAssertNil(adUnitConfig.getPbAdSlot())
        adUnitConfig.setPbAdSlot("test-ad-slot")
        XCTAssertEqual("test-ad-slot", adUnitConfig.getPbAdSlot())
    }
}
