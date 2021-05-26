//
//  BaseUITestCase.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest

class BaseUITestCase: XCTestCase {
    var useMockServerOnSetup = false
    
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
        
        appLifebox = constructApp(useMockServer: useMockServerOnSetup)
    }
    
    override func tearDown() {
        useMockServerOnSetup = false
        appLifebox = nil
        super.tearDown()
    }
    
    func switchToMockServerIfNeeded () {
        let useMockServerButton = app.switches["useMockServerSwitch"]
        waitForHittable(element: useMockServerButton, waitSeconds: 6)
        if !useMockServerButton.isOn {
            useMockServerButton.tap()
        }
    }
    
    func switchToPrebidXServerIfNeeded() {
        let useMockServerButton = app.switches["useMockServerSwitch"]
        waitForHittable(element: useMockServerButton, waitSeconds: 6)
        if useMockServerButton.isOn {
            useMockServerButton.tap()
        }
    }
}

