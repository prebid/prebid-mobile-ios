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

final class ConsolidatedBannerUITest: BaseUITestCase {
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOpenSettings() {
        let settingsItem = app.buttons["⚙"]
        settingsItem.tap()
        
        let tablesQuery = app.tables
        let listItem = tablesQuery.staticTexts["Banner 320x50 (In-App)"]
        waitForExists(element: listItem, waitSeconds: 5)
        listItem.tap()
        
        Thread.sleep(forTimeInterval: 1)
        
        let autoRefreshDelayField = tablesQuery.textFields["refreshInterval_field"]
        waitForExists(element: autoRefreshDelayField, waitSeconds: 5)
        
        let loadButton = tablesQuery.buttons["load_ad"]
        XCTAssert(loadButton.isEnabled)
        loadButton.tap()
    }
}
