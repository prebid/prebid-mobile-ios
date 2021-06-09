//
//  PrebidMRAIDResizeUITest.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

class PrebidMRAIDResizeUITest: RepeatedUITestCase {

    private let waitingTimeout = 8.0
    
    enum MRAIDCommand: String, CaseIterable {
        case openURL = "Open URL"
        case clickToMap = "Click to Map"
        case clickToApp = "Click to App"
        case playVideo = "Play Video"
        case sms = "SMS"
        case storePicture = "Store Picture"
        case calendarEvent = "Create Calendar Event"
        case clickToCall = "Click to Call"
    }
    private let title = "MRAID 2.0: Resize (In-App)"
    
    override func setUp() {
        useMockServerOnSetup = true
        super.setUp()
    }
    
    func testBasic() {
        repeatTesting(times: 7) {
            showResizedView()
            closeResizedView()
        }
    }
    
    func testResizeHittableButtons() {
        
        showResizedView()
        
        MRAIDCommand.allCases.forEach {
            let link = app.staticTexts[$0.rawValue]
            waitForHittable(element: link, waitSeconds: 5)
        }
    }
    
    func testResizeOpenUrl() {
        showResizedView()
        tapThenCloseMRAIDCommand(command: .openURL)
        closeResizedView()
    }
    
    func testVerifyResizeCommands() {
        showResizedView()
        
        MRAIDCommand.allCases.forEach {

            switch $0 {
            case .openURL, .clickToMap:
                tapThenCloseMRAIDCommand(command: $0)
            case .clickToApp:
                // Clickthrough should follow the redirect chain to the App Store deep link.
                // As App Store is not present on Simulators, Clickthrough will not appear.
                // Thus need to verify the command results effectively in no changes at all.
                
                tapMRAIDCommand(command: $0)
                
                Thread.sleep(forTimeInterval: 3) // wait for any harmful changes
                closeResizedView() // check if still expanded
                resizeMMRAIDView() // expand back
            case .sms, .clickToCall:
                print ("Do not support on Simulator")
            case .storePicture:
                tapMRAIDCommand(command: $0)
                // Tap in UIAlertAction dialog to "No"
                let noButton = app.alerts["Save Image?"].buttons["No"]
                waitForHittable(element: noButton, waitSeconds: 7)
                noButton.tap()
            case .calendarEvent:
                tapMRAIDCommand(command: $0)
                
                // Fix for Calendar alert permission
                Thread.sleep(forTimeInterval: 3)
                let systemAlerts = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts
                if systemAlerts.count > 0 {
                    let calendarAlert = systemAlerts.element(boundBy: 0)
                    calendarAlert.buttons["OK"].tap()
                }
                
                // Check EKEventEditViewController for exists
                let eventController = app.navigationBars["New Event"]
                waitForExists(element: eventController, waitSeconds: 7)
                // Cancel and close EKEventEditViewController
                eventController.buttons["Cancel"].tap()
            case .playVideo:
                // Play video...
                tapMRAIDCommand(command: $0)
                // Close button should be present
                closeResizedView()
            }
        }
    }
    
    func testBackButtonAction() {
        
        showResizedView()
        
        let mraidView = app.otherElements["PBMWebView"]
        waitForExists(element: mraidView, waitSeconds: 5)
        waitForHittable(element: mraidView, waitSeconds: 5)
        waitForEnabled(element: mraidView, waitSeconds: 5)

        // Press back button
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        waitForHittable(element: backButton, waitSeconds: 5)
        backButton.tap()
        
        // MRAID view should not be visible
        // after returning to the main list of examples
        waitForNotExist(element: mraidView, waitSeconds: 5)
    }
    
    // MARK: - Private methods
    private func showResizedView() {
        navigateToExamplesSection()
        navigateToExample(title)
        
        waitAd()
        
        resizeMMRAIDView()
    }
    
    private func waitAd() {
        let adReceivedButton = app.buttons["adViewDidReceiveAd called"]
        let adFailedToLoadButton = app.buttons["adViewDidFailToLoadAd called"]
        waitForEnabled(element: adReceivedButton, failElement: adFailedToLoadButton, waitSeconds: waitingTimeout)
    }
    
    private func resizeMMRAIDView() {
        let bannerView = app.descendants(matching: .other)["PrebidBannerView"]
        bannerView.tap()
        waitForEnabled(element: app.buttons["adViewWillPresentScreen called"], waitSeconds: waitingTimeout)
    }
    
    private func closeResizedView() {
        let closeBtn = app.buttons["PBMCloseButton"]
        waitForHittable(element: closeBtn, waitSeconds: 10)
        closeBtn.tap()
        waitForEnabled(element: app.buttons["adViewDidDismissScreen called"], waitSeconds: waitingTimeout)
    }
    
    private func tapMRAIDCommand(command: MRAIDCommand) {
        let link = app.staticTexts[command.rawValue]
        waitForHittable(element: link, waitSeconds: 5)
        link.tap()
    }
    
    func tapThenCloseMRAIDCommand(command: MRAIDCommand) {
        
        // Press MRAID command
        tapMRAIDCommand(command: command)
        
        // Wait for the close button, then press it.
        Thread.sleep(forTimeInterval: 3)
        let browserCloseButton = app.buttons["PBMCloseButtonClickThroughBrowser"]
        waitForHittable(element: browserCloseButton, waitSeconds: waitingTimeout)
        browserCloseButton.tap()
        
        let bannerAdView = app.buttons["PBMAdView"]
        waitForExists(element: bannerAdView, waitSeconds: 5)
    }

}
