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
import UIKit

@testable import PrebidMobile

class PBMDeviceAccessManagerTests : XCTestCase {
    
    fileprivate var deviceAccessManager:PBMDeviceAccessManager!
    let expectationTimeout:TimeInterval = 2
    
    // strings
    fileprivate var goodEventString = "{\"description\":\"Mayan Apocalypse/End of World\",\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
    fileprivate var brokenJSONEventString = "{\"description\":\"Mayan Apocalypse/End of World\"\"location\":\"everywhere\",\"start\"\"2013-12-21T00:00-05:00\",\"end\"\"2013-12-22T00:00-05:00\"}"
    fileprivate var missingDescEventString = "{\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
    fileprivate var missingStartEventString = "{\"description\":\"Mayan Apocalypse/End of World\",\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
    fileprivate var badStartEventString = "{\"description\":\"Mayan Apocalypse/End of World\",\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
    fileprivate var badEndEventString = "{\"description\":\"Mayan Apocalypse/End of World\",\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
    
    override func setUp() {
        super.setUp()
        self.deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil)
    }

    
    //MARK: - UIAlertController Tests
    
    func testUIAlertController_ShouldAutoRotate () {
        let uiAlertController = UIAlertController()
        
        // PBMPrivate category for UIAlertController returns false
        let shouldRotate = uiAlertController.shouldAutorotate
        XCTAssert(shouldRotate == false)
    }
    
    func testUIAlertController_SupportedInterfaceOrientations() {
        let uiAlertController = UIAlertController()
        let mask = uiAlertController.supportedInterfaceOrientations
        XCTAssert(mask == .portrait)
    }
    
    //MARK: - Miscellaneous tests
    
    func testAdvertisingIdentifier() {
        let adID = deviceAccessManager.advertisingIdentifier()
        XCTAssert(adID.count > 0)
    }
    
    func testAdvertisingTrackingEnabled() {
        _ = deviceAccessManager.advertisingTrackingEnabled()
        
        // nothing to test other than running it and it doesn't crash.
        XCTAssert(true)
    }
    
    func testScreenSize() {
        let size = deviceAccessManager.screenSize()
        
        // nothing to test other than running it and it doesn't crash.
        XCTAssert(size.width > 0)
        XCTAssert(size.height > 0)
    }
    
    func testUserLanguage() {
        let localeIdentifier = "jp"
        let locale = Locale(identifier: localeIdentifier)
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, locale: locale)
        
        XCTAssertEqual(deviceAccessManager.userLangaugeCode, localeIdentifier)
    }
    
    func testNilUserLanguage() {
        let locale = Locale(identifier: "")
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, locale: locale)
        
        XCTAssertNil(deviceAccessManager.userLangaugeCode)
    }
}
