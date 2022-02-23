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
    
    let adUnitConfig = AdUnitConfig(configID: "dummy-config-id")
    
    func testSetRefreshInterval() {
        XCTAssertEqual(adUnitConfig.refreshInterval, 60)
        
        adUnitConfig.refreshInterval = 10   // less than the min value
        XCTAssertEqual(adUnitConfig.refreshInterval, 15)
        
        adUnitConfig.refreshInterval = 1000   // greater than the max value
        XCTAssertEqual(adUnitConfig.refreshInterval, 120)
    }
    
    // MARK: - global context data aka inventory data (app.content.data)
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
    
//    // MARK: - global user data aka visitor data (user.data)

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
}
