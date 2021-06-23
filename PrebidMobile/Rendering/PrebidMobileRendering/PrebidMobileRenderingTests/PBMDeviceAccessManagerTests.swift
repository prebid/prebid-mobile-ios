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
    
    func testInit() {
        XCTAssert(self.deviceAccessManager.defaultPlist != nil)
        XCTAssert(self.deviceAccessManager.currentCompletion == nil)
    }
    
    //MARK: - Photo Library Tests
    func testSavePicture_MissingKey_NSPhotoLibraryUsageDescription() {
        let completionCalled = self.expectation(description: "saveCompletionCalled")
        var completionResult = false as Bool
        var errorMessage = ""
        
        // load the plist from the test bundle.
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("PlistWithout_NSPhotoLibraryUsageDescription.plist")
        XCTAssert(infoPlist != nil)

        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: EKEventStore(), locale: locale)
        let photoUrl = URL(fileURLWithPath: "dummy")
        deviceAccessManager.savePhotoWithUrlToAsset(photoUrl, completion: { succeeded, message in
            completionResult = succeeded
            errorMessage = message
            completionCalled.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: self.expectationTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expected completion callback to be called within \(self.expectationTimeout) seconds")
            XCTAssert(completionResult == false, "Expected FALSE")
            XCTAssert(errorMessage.count  > 0, "Error message must not be empty")
        }
    }
    
    func testSavePicture_MissingKey_NSPhotoLibraryAddUsageDescription() {
        guard #available(iOS 11.0, *) else {
            return
        }
        
        let completionCalled = self.expectation(description: "saveCompletionCalled")
        var completionResult = false as Bool
        var errorMessage = ""
        
        // load the plist from the test bundle.
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("PlistWithout_NSPhotoLibraryAddUsageDescription.plist")
        XCTAssert(infoPlist != nil)
        
        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: EKEventStore(), locale: locale)
        let photoUrl = URL(fileURLWithPath: "dummy")
        deviceAccessManager.savePhotoWithUrlToAsset(photoUrl, completion: { succeeded, message in
            completionResult = succeeded
            errorMessage = message
            completionCalled.fulfill()
        }
        )
        
        self.waitForExpectations(timeout: self.expectationTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expected completion callback to be called within \(self.expectationTimeout) seconds")
            XCTAssert(completionResult == false, "Expected FALSE")
            XCTAssert(errorMessage.count  > 0, "Error message must not be empty")
        }
    }
    
    func testSavePicture_YesAction() {
        let completionCalled = self.expectation(description: "saveCompletionCalled")
        var completionResult = false as Bool
        var errorMessage : String?
        
        // load the plist from the test bundle.
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("PlistWith_NSPhotoLibraryUsageDescription.plist")
        XCTAssert(infoPlist != nil)

        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: EKEventStore(), locale: locale)
        let photoUrl = URL(fileURLWithPath: "dummy")
        
        let mockAlert = MockAlertController(title:"Mock title", message:"MockMessage", preferredStyle: .alert)
        
        let yesAction = MockAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            completionCalled.fulfill()
        })

        deviceAccessManager.savePhoto(url: photoUrl,
                          alertController: mockAlert,
                       rootViewController: mockAlert,
                                      yes: yesAction,
                                       no: nil,
                               completion: { succeeded, message in
                completionResult = succeeded
                errorMessage = message
                completionCalled.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: expectationTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expected completion callback to be called within \(self.expectationTimeout) seconds")
        }
        
        XCTAssert(completionResult == false, "Expected FALSE")
        if (errorMessage != nil) {
            XCTAssert((errorMessage?.lengthOfBytes(using: String.Encoding.ascii))!  > 0, "Error message must not be empty")
        }
    }
    
    func testSavePicture_NoAction() {
        let completionCalled = self.expectation(description: "saveCompletionCalled")
        var completionResult = false as Bool
        var errorMessage : String?
        
        // load the plist from the test bundle.
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("PlistWith_NSPhotoLibraryUsageDescription.plist")
        XCTAssert(infoPlist != nil)
        
        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: EKEventStore(), locale: locale)
        let photoUrl = URL(fileURLWithPath: "dummy")
        
        let mockAlert = MockAlertController(title:"Mock title", message:"MockMessage", preferredStyle: .alert)
        
        mockAlert.present(UIViewController(), animated: false)
        let noAction = MockAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            completionCalled.fulfill()
        })
        
        deviceAccessManager.savePhoto(url: photoUrl,
                                      alertController: mockAlert,
                                      rootViewController: mockAlert,
                                      yes: nil,
                                      no: noAction,
                                      completion: { succeeded, message in
                                        completionResult = succeeded
                                        errorMessage = message
                                        completionCalled.fulfill()
        }
        )
        
        self.waitForExpectations(timeout: expectationTimeout) { (error) -> Void in
            XCTAssertNil(error, "Expected completion callback to be called within \(self.expectationTimeout) seconds")
        }
        
        XCTAssert(completionResult == false, "Expected FALSE")
        if (errorMessage != nil) {
            XCTAssert((errorMessage?.lengthOfBytes(using: String.Encoding.ascii))!  > 0, "Error message must not be empty")
        }
    }
    
    func testSavePhoto_Success() {
        let completionCalled = self.expectation(description: "saveCompletionCalled")

        let bundlePath = UtilitiesForTesting.testBundle().bundlePath
        var imageUrl = URL(fileURLWithPath: bundlePath)
        imageUrl.appendPathComponent("320x50.jpg")
        
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil)
        var completionResult = false
        deviceAccessManager.savePhoto(url: imageUrl,
                                      completion: { succeeded, message in
                                        completionResult = succeeded
                                        completionCalled.fulfill()
            })
        
        self.waitForExpectations(timeout: expectationTimeout) { (error) -> Void in
            // Expect failure when user does NOT grant permission to use calendar.
            XCTAssert(completionResult==true)
        }
        
    }

    func testSavePhoto_InvalidURL() {
        let completionCalled = self.expectation(description: "saveCompletionCalled")
        
        let bundlePath = UtilitiesForTesting.testBundle().bundlePath
        var imageUrl = URL(fileURLWithPath: bundlePath)
        imageUrl.appendPathComponent("NonExistanFile.png")
        
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil)
        var completionResult = false
        var errorMessage = "No Error"
        deviceAccessManager.savePhoto(url: imageUrl,
                                      completion: { succeeded, message in
                                        completionResult = succeeded
                                        errorMessage = message!
                                        completionCalled.fulfill()
        })
        
        self.waitForExpectations(timeout: expectationTimeout) { (error) -> Void in
            // Expect failure when user does NOT grant permission to use calendar.
            XCTAssert(completionResult==false)
            XCTAssert(errorMessage.count > 0)
        }
        
    }

    //MARK: - Calendar Tests
    
    func testAddEvent() {
        
        self.deviceAccessManager.internalAddEvent(goodEventString, completion: { succeeded, message in
            XCTAssert(succeeded, "Expected to succeed")
        })
        
        self.deviceAccessManager.internalAddEvent(brokenJSONEventString, completion: { succeeded, message in
            XCTAssert(!succeeded && message == "Failed to decode event string", "Expected to fail")
        })
        
        self.deviceAccessManager.internalAddEvent(missingDescEventString, completion: { succeeded, message in
            XCTAssert(!succeeded && message == "No description found", "Expected to fail")
        })
        
        self.deviceAccessManager.internalAddEvent(missingStartEventString, completion: { succeeded, message in
            XCTAssert(!succeeded && message == "No start time found", "Expected to fail")
        })
        
        self.deviceAccessManager.internalAddEvent(badStartEventString, completion: { succeeded, message in
            XCTAssert(!succeeded && message == "Invalid start time", "Expected to fail")
        })
        
        self.deviceAccessManager.internalAddEvent(badEndEventString, completion: { succeeded, message in
            XCTAssert(!succeeded && message == "Invalid end time", "Expected to fail")
        })
        
    }
    
    func testCreateCalendarEventFromString_NoCalendarPermission() {
        let completionCalled = self.expectation(description: "completionCalled")
        var errorMessage = ""
        // load the plist from the test bundle. This plist does NOT have appropriate permissions
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("Plist_NSCalendarsUsageDescription_Without.plist")
        
        XCTAssert(infoPlist != nil)
        
        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: EKEventStore(), locale: locale)
        
        var success = false
        let eventString = "{\"description\":\"Mayan Apocalypse/End of World\",\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
        deviceAccessManager.createCalendarEventFromString(eventString,
                                                          completion: { succeeded, message in
                                                            success = succeeded
                                                            errorMessage = message
                                                            completionCalled.fulfill()
        })
        
        self.waitForExpectations(timeout: 5) { (error) -> Void in
            XCTAssert(success == false)
            XCTAssert(errorMessage.range(of:"NSCalendarsUsageDescription") != nil )
        }
        
    }
    
    func testCalendar_NSCalendarsUsageDescription_Plist() {
        let completionCalled = self.expectation(description: "completionCalled")
        
        // load the plist from the test bundle.
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("Plist_NSCalendarsUsageDescription_Without.plist")
        XCTAssert(infoPlist != nil)
        
        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: EKEventStore(), locale: locale)
        
        var success = false
        let eventString = "dummy event"
        deviceAccessManager.createCalendarEventFromString(eventString,
                                                          completion: { succeeded, message in
                                                            success = succeeded
                                                            completionCalled.fulfill()
        })
        
        self.waitForExpectations(timeout: 300) { (error) -> Void in
            // Expect failure since PLIST does NOT have NSCalendarsUsageDescription defined.
            XCTAssert(success == false)
        }
        
    }

    func testCalendar_PermissionNotGranted() {
        
        let completionCalled = self.expectation(description: "completionCalled")
        
        // load the plist from the test bundle.
        let infoPlist = UtilitiesForTesting.loadPlistAsDictFromBundle("Plist_NSCalendarsUsageDescription_With.plist")
        XCTAssert(infoPlist != nil)
        
        let mockEventStore = MockEventStore();
        mockEventStore.requestAccessGrantedResult = false
        let locale = Locale.autoupdatingCurrent
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: infoPlist!, eventStore: mockEventStore, locale: locale)

        
        var success = false
        let eventString = "{\"description\":\"Mayan Apocalypse/End of World\",\"location\":\"everywhere\",\"start\":\"2013-12-21T00:00-05:00\",\"end\":\"2013-12-22T00:00-05:00\"}"
        deviceAccessManager.createCalendarEventFromString(eventString,
                                                          completion: { succeeded, message in
                                                            success = succeeded
                                                            completionCalled.fulfill()
                                                            })

        self.waitForExpectations(timeout: 300) { (error) -> Void in
            // Expect failure when user does NOT grant permission to use calendar.
            XCTAssert(success==false)
        }

    }
    
    func testCalendar_CreateRecurrenceRuleWithDictionary_NoDict () {
        let recurrenceRule = PBMDeviceAccessManager.createRecurrenceRule(with: nil);
        XCTAssert(recurrenceRule == nil)
    }
    
    func testCalendar_CreateRecurrenceRuleWithDictionary_NoFrequency () {
        let dict = JsonDictionary()
        let recurrenceRule = PBMDeviceAccessManager.createRecurrenceRule(with: dict);
        XCTAssert(recurrenceRule == nil)
    }
    
    func testCalendar_CreateRecurrenceRuleWithDictionary_NoInterval () {
        var dict = JsonDictionary()
        dict[PBMDeviceAccessManagerKeys.frequency] = "Frequency"
        let recurrenceRule = PBMDeviceAccessManager.createRecurrenceRule(with: dict);
        XCTAssert(recurrenceRule == nil)
    }

    func testCalendar_CreateRecurrenceRuleWithDictionary_Daily () {
        var dict = JsonDictionary()
        dict[PBMDeviceAccessManagerKeys.frequency] = "daily"
        dict[PBMDeviceAccessManagerKeys.expires] = "1"
        let recurrenceRule = PBMDeviceAccessManager.createRecurrenceRule(with: dict);
        XCTAssert(recurrenceRule != nil)
        XCTAssert(recurrenceRule?.frequency == .daily)
        XCTAssert(recurrenceRule?.interval == 1)
    }

    func testCalendar_CreateRecurrenceRuleWithDictionary_Weekly () {
        var dict = JsonDictionary()
        dict[PBMDeviceAccessManagerKeys.frequency] = "weekly"
        dict[PBMDeviceAccessManagerKeys.expires] = "1"
        let recurrenceRule = PBMDeviceAccessManager.createRecurrenceRule(with: dict);
        XCTAssert(recurrenceRule != nil)
        XCTAssert(recurrenceRule?.frequency == .weekly)
        XCTAssert(recurrenceRule?.interval == 1)
    }

    func testCalendar_CreateRecurrenceRuleWithDictionary_Monthly () {
        var dict = JsonDictionary()
        dict[PBMDeviceAccessManagerKeys.frequency] = "monthly"
        dict[PBMDeviceAccessManagerKeys.expires] = "1"
        let recurrenceRule = PBMDeviceAccessManager.createRecurrenceRule(with: dict);
        XCTAssert(recurrenceRule != nil)
        XCTAssert(recurrenceRule?.frequency == .monthly)
        XCTAssert(recurrenceRule?.interval == 1)
    }
    
    func testCalendar_RecurrenceDayOfWeekArrayWithArray () {
        var daysOfTheWeek = [1, 2, 3, 5, 7]
        var ekDaysOfTheWeek = PBMDeviceAccessManager.recurrenceDayOfWeekArray(with: daysOfTheWeek as [NSNumber])
        XCTAssert(ekDaysOfTheWeek.count == 5)
        
        daysOfTheWeek = []
        ekDaysOfTheWeek = PBMDeviceAccessManager.recurrenceDayOfWeekArray(with: daysOfTheWeek as [NSNumber])
        XCTAssert(ekDaysOfTheWeek.count == 0)
    }

    func testCalendar_EKEventEditViewDelegate_UserCancel() {
        let completionCalled = self.expectation(description: "completionCalled")
        var success = false
        var message = ""
        deviceAccessManager.currentCompletion = { succeeded, msg in
            success = succeeded
            message = msg!
            completionCalled.fulfill()
        }
        
        let ekEventController = EKEventEditViewController()
        deviceAccessManager.eventEditViewController(ekEventController, didCompleteWith: EKEventEditViewAction.cancelled)
        
        self.waitForExpectations(timeout: 300) { (error) -> Void in
            // Expect failure when user does NOT grant permission to use calendar.
            XCTAssert(success==false)
            XCTAssert(message == "User cancelled")
        }
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
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: [String: Any](), eventStore: EKEventStore(), locale: locale)

        XCTAssertEqual(deviceAccessManager.userLangaugeCode, localeIdentifier)
    }

    func testNilUserLanguage() {
        let locale = Locale(identifier: "")
        let deviceAccessManager = PBMDeviceAccessManager(rootViewController: nil, plist: [String: Any](), eventStore: EKEventStore(), locale: locale)

        XCTAssertNil(deviceAccessManager.userLangaugeCode)
    }

}
