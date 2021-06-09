//
//  ConsolidatedBannerUITest.swift
//
//  Copyright © 2017 OpenX. All rights reserved.
//

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
