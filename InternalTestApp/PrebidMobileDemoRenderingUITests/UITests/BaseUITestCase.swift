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

class BaseUITestCase: XCTestCase {
    
    private var appLifebox: AppLifebox!
    
    var app: XCUIApplication! {
        return appLifebox.app
    }
    
    var appBundleID: String {
        return "\(app.description.split(separator: "'")[1])"
    }
    
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        appLifebox = constructApp()
    }
    
    override func tearDown() {
        appLifebox = nil
        super.tearDown()
    }
    
    
    
    func disableGDPRIfNeeded() {
        let enableGDPRButton = app.switches["GDPRSwitch"]
        waitForHittable(element: enableGDPRButton, waitSeconds: 10)
        if enableGDPRButton.isOn {
            enableGDPRButton.tap()
        }
    }
    
    func enableGDPRIfNeeded() {
        let enableGDPRButton = app.switches["GDPRSwitch"]
        waitForHittable(element: enableGDPRButton, waitSeconds: 10)
        if !enableGDPRButton.isOn {
            enableGDPRButton.tap()
        }
    }
}

