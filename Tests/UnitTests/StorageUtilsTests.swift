/*   Copyright 2018-2019 Prebid.org, Inc.

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

class StorageUtilsTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testIABUSPrivacy_StringKey() {
        XCTAssertEqual("IABUSPrivacy_String", StorageUtils.IABUSPrivacy_StringKey)
    }
    
    func testIABConsent_SubjectToGDPRKey() {
        XCTAssertEqual("IABConsent_SubjectToGDPR", StorageUtils.IABConsent_SubjectToGDPRKey)
    }
    
    func testIABConsent_ConsentStringKey() {
        XCTAssertEqual("IABConsent_ConsentString", StorageUtils.IABConsent_ConsentStringKey)
    }
    
    func testPBConsent_SubjectToGDPRKey() {
        XCTAssertEqual("kPBGdprSubjectToConsent", StorageUtils.PBConsent_SubjectToGDPRKey)
    }
    
    func testPBConsent_ConsentStringKey() {
        XCTAssertEqual("kPBGDPRConsentString", StorageUtils.PBConsent_ConsentStringKey)
    }
    
    func testPbCoppa() {
        //given
        StorageUtils.setPbCoppa(value: true)
        defer {
            StorageUtils.setPbCoppa(value: false)
        }
        
        //when
        let coppa = StorageUtils.pbCoppa()
        
        //then
        XCTAssertEqual(true, coppa)
    }
    
    func testPbGdprSubject() {
        //given
        StorageUtils.setPbGdprSubject(value: true)
        defer {
            StorageUtils.setPbGdprSubject(value: nil)
        }
        
        //when
        let pbGdprSubject = StorageUtils.pbGdprSubject()
        
        //then
        XCTAssertEqual(true, pbGdprSubject)
    }
    
    func testPbGdprSubjectNotExists() {
        //given
        StorageUtils.setPbGdprSubject(value: nil)
        
        //when
        let pbGdprSubject = StorageUtils.pbGdprSubject()
        
        //then
        XCTAssertNil(pbGdprSubject)
    }
    
    func testIabGdprSubjectNotExists() {
        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        
        //when
        let iabGdprSubject = StorageUtils.iabGdprSubject()
        
        //then
        XCTAssertNil(iabGdprSubject)
    }
    
    func testIabGdprSubjectFilled() {
        UserDefaults.standard.set("testIabGdprSubject", forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        }
        
        //when
        let iabGdprSubject = StorageUtils.iabGdprSubject()
        
        //then
        XCTAssertEqual("testIabGdprSubject", iabGdprSubject)
    }
    
    func testPbGdprConsent() {
        //given
        StorageUtils.setPbGdprConsent(value: "testPbGdprConsent")
        defer {
            StorageUtils.setPbGdprConsent(value: nil)
        }
        
        //when
        let pbGdprConsent = StorageUtils.pbGdprConsent()
        
        //then
        XCTAssertEqual("testPbGdprConsent", pbGdprConsent)
    }
    
    func testPbGdprConsentNotExists() {
        //given
        StorageUtils.setPbGdprConsent(value: nil)
        
        //when
        let pbGdprConsent = StorageUtils.pbGdprConsent()
        
        //then
        XCTAssertNil(pbGdprConsent)
    }
    
    func testIabGdprConsentNotExists() {
        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_ConsentStringKey)
        
        //when
        let iabGdprConsent = StorageUtils.iabGdprConsent()
        
        //then
        XCTAssertNil(iabGdprConsent)
    }
    
    func testIabGdprConsentFilled() {
        UserDefaults.standard.set("testIabGdprConsentFilled", forKey: StorageUtils.IABConsent_ConsentStringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_ConsentStringKey)
        }
        
        //when
        let iabGdprConsent = StorageUtils.iabGdprConsent()
        
        //then
        XCTAssertEqual("testIabGdprConsentFilled", iabGdprConsent)
    }
    
    func testIabCcpaNotExist() {
        
        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        
        //when
        let ccpa = StorageUtils.iabCcpa()
        
        //then
        XCTAssertNil(ccpa)
    }
    
    func testIabCcpaFilled() {
        
        //given
        UserDefaults.standard.set("testCCPA", forKey: StorageUtils.IABUSPrivacy_StringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        }
        
        //when
        let ccpa = StorageUtils.iabCcpa()
        
        //then
        XCTAssertEqual("testCCPA", ccpa)
    }
    
    func testIabCcpaEmpry() {
        
        //given
        UserDefaults.standard.set("", forKey: StorageUtils.IABUSPrivacy_StringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        }
        
        //when
        let ccpa = StorageUtils.iabCcpa()
        
        //then
        XCTAssertEqual("", ccpa)
    }
    
}
