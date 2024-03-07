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
        
        XCTAssertNil(request.getAppContent())
        XCTAssertNil(request.getUserData())
        XCTAssertTrue(request.getExtData().isEmpty)
        XCTAssertTrue(request.getExtKeywords().isEmpty)
    }
    
    // MARK: - adunit ext data aka inventory data (imp[].ext.data)
    
    func testAddExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        
        let request = PrebidRequest()
        
        //when
        request.addExtData(key: key1, value: value1)
        let dictionary = request.getExtData()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        
        let request = PrebidRequest()
        request.updateExtData(key: key1, value: set)
        
        //when
        let dictionary = request.getExtData()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        
        let request = PrebidRequest()
        request.addExtData(key: key1, value: value1)
        
        //when
        request.removeExtData(forKey: key1)
        let dictionary = request.getExtData()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        
        let request = PrebidRequest()
        request.addExtData(key: key1, value: value1)
        
        //when
        request.clearExtData()
        let dictionary = request.getExtData()
        
        //then
        XCTAssertEqual(0, dictionary.count)
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
    
    // MARK: - global context data aka inventory data (app.content.data)
    
    func testSetAppContent() {
        //given
        let request = PrebidRequest()
        
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
        request.setAppContent(appContent)
        let resultAppContent = request.getAppContent()!

        //then
        XCTAssertEqual(2, resultAppContent.data!.count)
        XCTAssertEqual(resultAppContent.data!.first, appDataObject1)
        XCTAssertEqual(appContent, resultAppContent)
    }
    
    func testClearAppContent() {
        //given
        let request = PrebidRequest()
        
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
        request.setAppContent(appContent)
        
        let resultAppContent1 = request.getAppContent()
        XCTAssertNotNil(resultAppContent1)
        request.clearAppContent()
        let resultAppContent2 = request.getAppContent()
        XCTAssertNil(resultAppContent2)
    }
    
    func testAddAppContentDataObject() {
        //given
        let request = PrebidRequest()
        
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        //when
        request.addAppContentData([appDataObject1, appDataObject2])
        let objects = request.getAppContent()!.data!

        //then
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, appDataObject1)
    }

    func testRemoveAppContentDataObjects() {
        let request = PrebidRequest()
        
        let appDataObject = PBMORTBContentData()
        appDataObject.id = "data id"
        appDataObject.name = "test name"

        request.addAppContentData([appDataObject])
        let objects1 = request.getAppContent()!.data!

        XCTAssertEqual(1, objects1.count)

        request.removeAppContentData(appDataObject)
        let objects2 = request.getAppContent()!.data!

        XCTAssertEqual(0, objects2.count)
    }
    
    func testClearAppContentDataObjects() {
        let request = PrebidRequest()
        
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        request.addAppContentData([appDataObject1, appDataObject2])
        let objects1 = request.getAppContent()!.data!
        
        XCTAssertEqual(2, objects1.count)
        request.clearAppContentData()
        
        let objects2 = request.getAppContent()!.data!
        XCTAssertEqual(0, objects2.count)
    }
    
    // MARK: - global user data aka visitor data (user.data)

    func testAddUserDataObjects() {
        //given
        let request = PrebidRequest()
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        //when
        request.addUserData([userDataObject1, userDataObject2])
        let objects = request.getUserData()!

        //then
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
    }
    
    func testRemoveUserDataObjects() {
        let request = PrebidRequest()
        
        let userDataObject = PBMORTBContentData()
        userDataObject.id = "data id"
        userDataObject.name = "test name"

        request.addUserData([userDataObject])
        let objects1 = request.getUserData()!

        XCTAssertEqual(1, objects1.count)

        request.removeUserData(userDataObject)
        let objects2 = request.getUserData()!

        XCTAssertEqual(0, objects2.count)
    }

    func testClearUserDataObjects() {
        let request = PrebidRequest()
        
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        request.addUserData([userDataObject1, userDataObject2])
        let objects1 = request.getUserData()!

        XCTAssertEqual(2, objects1.count)

        request.clearUserData()
        let objects2 = request.getUserData()!
        XCTAssertEqual(0, objects2.count)
    }
}
