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

class InternalUserConsentDataManagerTests: XCTestCase {
    
    let usPrivacyStringNotASubject = "1---"
    let usPrivacyStringNoOptOut = "1YNN"
    
    override func tearDown() {
        super.tearDown()
        
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABUSPrivacy_StringKey)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABGPP_HDR_GppString)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABGPP_GppSID)
    }
    
    func testIABUSPrivacy_StringKey() {
        XCTAssertEqual("IABUSPrivacy_String", InternalUserConsentDataManager.IABUSPrivacy_StringKey)
    }
    
    func testIABGPP_GppStringKey() {
        XCTAssertEqual("IABGPP_HDR_GppString", InternalUserConsentDataManager.IABGPP_HDR_GppString)
    }
    
    func testIABGPP_GppSIDKey() {
        XCTAssertEqual("IABGPP_GppSID", InternalUserConsentDataManager.IABGPP_GppSID)
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
    
    func testIABGPP_Unset() {
        assertIABGPPString(nil)
    }
    
    func testIABGPP_withString() {
        let gpp = "test_gpp_string"
        
        setIABGPPString(val: gpp)
        assertIABGPPString(gpp)
    }
    
    func testIABGPPSID_Unset() {
        assertIABGPPString(nil)
    }
    
    func testIABGPPSID_withString() {
        let gppSID = "2_3_4_5"
        
        setIABGPPSIDString(val: gppSID)
        assertIABGPPSID([2, 3, 4, 5])
    }
    
    func setAndLoadPrivacyString(usPrivacyString: String?, file: StaticString = #file, line: UInt = #line) {
        setUSPrivacyString(val: usPrivacyString)
        assertUSPrivacyString(usPrivacyString)
    }
    
    func setUSPrivacyString(val: String?) {
        UserDefaults.standard.set(val, forKey: InternalUserConsentDataManager.IABUSPrivacy_StringKey)
    }
    
    func assertUSPrivacyString(_ usPrivacyString: String?, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(InternalUserConsentDataManager.usPrivacyString, usPrivacyString)
    }
    
    func setIABGPPString(val: String?) {
        UserDefaults.standard.set(val, forKey: InternalUserConsentDataManager.IABGPP_HDR_GppString)
    }
    
    func setIABGPPSIDString(val: String?) {
        UserDefaults.standard.set(val, forKey: InternalUserConsentDataManager.IABGPP_GppSID)
    }
    
    func assertIABGPPString(_ gppString: String?) {
        XCTAssertEqual(InternalUserConsentDataManager.gppHDRString, gppString)
    }
    
    func assertIABGPPSID(_ gppSID: NSMutableArray?) {
        XCTAssertEqual(InternalUserConsentDataManager.gppSID, gppSID)
    }
}
