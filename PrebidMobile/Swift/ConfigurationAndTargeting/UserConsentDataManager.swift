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

/**
 @c UserConsentDataManager is responsible retrieving user consent according to the
 IAB Transparency & Consent Framework
 
 The design of the framework is that a publisher integrated Consent Management
 Platform (CMP) is responsible for storing user consent applicability and data
 in @c UserDefaults. All advertising SDKs are to query this data regularly for
 updates and pass that data downstream and act accordingly.
 */

@objcMembers
class UserConsentDataManager: NSObject {
    
    static let shared = UserConsentDataManager()
        
    // TCF 2.0
    let IABTCF_ConsentString = "IABTCF_TCString"
    let IABTCF_SubjectToGDPR = "IABTCF_gdprApplies"
    let IABTCF_PurposeConsents = "IABTCF_PurposeConsents"
    
    private override init() {
        super.init()
    }
    
    // MARK: - COPPA
    
    /**
     Integer flag indicating if this request is subject to the COPPA regulations
     established by the USA FTC, where 0 = no, 1 = yes
     */
    var subjectToCOPPA: Bool?
    
    // MARK: - GDPR
    
    /**
     * The boolean value set by the user to collect user data
     */
    
    var _subjectToGDPR: Bool?
    
    var subjectToGDPR: Bool? {
        set { _subjectToGDPR = newValue }
        get {
            if let _subjectToGDPR = _subjectToGDPR {
                return _subjectToGDPR
            }
            
            if let iabValue = UserDefaults.standard.string(forKey: IABTCF_SubjectToGDPR) {
                return NSString(string: iabValue).boolValue
            }
            
            return nil
        }
    }
    
    var subjectToGDPR_NSNumber: NSNumber? {
        if let subjectToGDPR = subjectToGDPR {
            return NSNumber(integerLiteral: subjectToGDPR ? 1 : 0)
        }
        
        return nil
    }
    
    // MARK: - GDPR Consent
    
    /**
     * The consent string for sending the GDPR consent
     */
    
    var _gdprConsentString: String?
    
    var gdprConsentString: String? {
        set { _gdprConsentString = newValue }
        get { _gdprConsentString ?? UserDefaults.standard.getObjectFromUserDefaults(forKey: IABTCF_ConsentString) }
    }
    
    // MARK: - TCFv2
    
    var _purposeConsents: String?
    
    var purposeConsents: String? {
        set { _purposeConsents = newValue }
        get { _purposeConsents ?? UserDefaults.standard.getObjectFromUserDefaults(forKey: IABTCF_PurposeConsents) }
    }
    
    /*
     Purpose 1 - Store and/or access information on a device
     */
    func getDeviceAccessConsent() -> Bool? {
        return getPurposeConsent(index: 0)
    }
    
    func getPurposeConsent(index: Int) -> Bool? {
        var purposeConsent: Bool? = nil
        
        if let savedPurposeConsents = purposeConsents, index >= 0, index < savedPurposeConsents.count {
            let char = savedPurposeConsents[savedPurposeConsents.index(savedPurposeConsents.startIndex, offsetBy: index)]
            
            if char == "1" {
                purposeConsent = true
            } else if char == "0" {
                purposeConsent = false
            } else {
                Log.warn("invalid char:\(char)")
            }
        }
        
        return purposeConsent
    }
    
    //fetch advertising identifier based TCF 2.0 Purpose1 value
    //truth table
    /*
                        deviceAccessConsent=true  deviceAccessConsent=false  deviceAccessConsent undefined
     gdprApplies=false        Yes, read IDFA       No, don’t read IDFA           Yes, read IDFA
     gdprApplies=true         Yes, read IDFA       No, don’t read IDFA           No, don’t read IDFA
     gdprApplies=undefined    Yes, read IDFA       No, don’t read IDFA           Yes, read IDFA
     */
    func isAllowedAccessDeviceData() -> Bool {
        let deviceAccessConsent = getDeviceAccessConsent()
        
        // deviceAccess undefined and gdprApplies undefined
        if deviceAccessConsent == nil && subjectToGDPR == nil {
            return true
        }
        
        // deviceAccess undefined and gdprApplies false
        if deviceAccessConsent == nil && subjectToGDPR == false {
            return true
        }
        
        // gdprApplies = true
        // deviceAccess is set (true/false) or still is nil (i.e. false)
        return deviceAccessConsent ?? false
    }
}
