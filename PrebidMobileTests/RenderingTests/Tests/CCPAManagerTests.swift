//
//  CCPAManagerTests.swift
//  PrebidMobileTests
//
//  Created by Olena Stepaniuk on 06.12.2022.
//  Copyright © 2022 AppNexus. All rights reserved.
//

import XCTest
@testable import PrebidMobile

class CCPAManagerTests: XCTestCase {
    
    let usPrivacyStringNotASubject = "1---"
    let usPrivacyStringNoOptOut = "1YNN"
    
    override func tearDown() {
        super.tearDown()
        
        UserDefaults.standard.removeObject(forKey: CCPAManager.IABUSPrivacy_StringKey)
    }
    
    func testIABUSPrivacy_StringKey() {
        XCTAssertEqual("IABUSPrivacy_String", CCPAManager.IABUSPrivacy_StringKey)
    }
    
    // MARK: IABConsent_ConsentString values
    func testUSPrivacy_Unset() {
        setAndLoadPrivacyString(usPrivacyString: nil)
    }
    
    func testUSPrivacy_NotASubject() {
        setAndLoadPrivacyString(usPrivacyString: usPrivacyStringNotASubject)
    }
    
    func testUSPrivacy_NoOptOut() {
        setAndLoadPrivacyString(usPrivacyString: usPrivacyStringNoOptOut)
    }
    
    func testIABConsent_usPrivacyString_Changed() {
        self.setUSPrivacyString(val: usPrivacyStringNotASubject)
        self.assertUSPrivacyString(usPrivacyStringNotASubject)
        
        self.setUSPrivacyString(val: usPrivacyStringNoOptOut)
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertUSPrivacyString(usPrivacyStringNoOptOut)
    }
    
    func setAndLoadPrivacyString(usPrivacyString: String?, file: StaticString = #file, line: UInt = #line) {
        setUSPrivacyString(val: usPrivacyString)
        assertUSPrivacyString(usPrivacyString)
    }
    
    func setUSPrivacyString(val: String?) {
        UserDefaults.standard.set(val, forKey: CCPAManager.IABUSPrivacy_StringKey)
    }
    
    func assertUSPrivacyString(_ usPrivacyString: String?, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(CCPAManager.usPrivacyString, usPrivacyString)
    }
}
