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

@objcMembers
public class UserConsentDataManager: NSObject {
    
    public static let shared = UserConsentDataManager()
    
    // COPPA
    let PB_COPPAKey = "kPBCoppaSubjectToConsent"
    
    // GDPR - publisher set local
    let PBConsent_SubjectToGDPRKey = "kPBGdprSubjectToConsent"
    let PBConsent_ConsentStringKey = "kPBGDPRConsentString"
    let PBConsent_PurposeConsentsStringKey = "kPBGDPRPurposeConsents"
    
    // TCF 2.0
    let IABTCF_ConsentString = "IABTCF_TCString"
    let IABTCF_SubjectToGDPR = "IABTCF_gdprApplies"
    let IABTCF_PurposeConsents = "IABTCF_PurposeConsents"

    // CCPA
    static let IABUSPrivacy_StringKey = "IABUSPrivacy_String"
    
    private override init() {
        super.init()
    }
    
    // MARK: - COPPA
        
    /**
     Integer flag indicating if this request is subject to the COPPA regulations
     established by the USA FTC, where 0 = no, 1 = yes
     */
    public var subjectToCOPPA: Bool? {
        set { UserDefaults.standard.set(newValue, forKey: PB_COPPAKey) }
        get { UserDefaults.standard.object(forKey: PB_COPPAKey) != nil ? UserDefaults.standard.bool(forKey: PB_COPPAKey) : nil }
    }
    
    // MARK: - GDPR
    
    /**
     * The boolean value set by the user to collect user data
     */
    public var subjectToGDPR: Bool? {
        set { UserDefaults.standard.set(newValue, forKey: PBConsent_SubjectToGDPRKey) }

        get {
            var gdprSubject: Bool?
           
            if let pbGdpr: Bool? = UserDefaults.standard.getObjectFromUserDefaults(forKey: PBConsent_SubjectToGDPRKey) {
                gdprSubject = pbGdpr
            } else if let iabGdpr = iabGDPRSubject() {
                gdprSubject = iabGdpr
            }
            
            return gdprSubject
        }
    }
    
    public func setSubjectToGDPR(_ newValue: NSNumber?) {
        subjectToGDPR = newValue?.boolValue
    }
    
    public func getSubjectToGDPR() -> NSNumber? {
        return subjectToGDPR as NSNumber?
    }
    
    // MARK: - GDPR Consent
    
    /**
     * The consent string for sending the GDPR consent
     */

    public var gdprConsentString: String? {
        set { UserDefaults.standard.set(newValue, forKey: PBConsent_ConsentStringKey) }

        get {
            var savedConsent: String?
            
            if let pbString: String? = UserDefaults.standard.getObjectFromUserDefaults(forKey: PBConsent_ConsentStringKey) {
                savedConsent = pbString
            } else if let iabString: String? = UserDefaults.standard.getObjectFromUserDefaults(forKey: IABTCF_ConsentString) {
                savedConsent = iabString
            }
            
            return savedConsent
        }
    }
    
    // MARK: - TCFv2

    public var purposeConsents: String? {
        set { UserDefaults.standard.set(newValue, forKey: PBConsent_PurposeConsentsStringKey) }

        get {
            var savedPurposeConsents: String?
            
            if let pbString: String? = UserDefaults.standard.getObjectFromUserDefaults(forKey: PBConsent_PurposeConsentsStringKey) {
               savedPurposeConsents = pbString
            } else if let iabString: String? = UserDefaults.standard.getObjectFromUserDefaults(forKey: IABTCF_PurposeConsents) {
                savedPurposeConsents = iabString
            }

            return savedPurposeConsents
        }
    }

    /*
     Purpose 1 - Store and/or access information on a device
     */
    public func getDeviceAccessConsent() -> Bool? {
        return getPurposeConsent(index: 0)
    }
    
    public func getDeviceAccessConsentObjc() -> NSNumber? {
        return getDeviceAccessConsent() as NSNumber?
    }

    public func getPurposeConsent(index: Int) -> Bool? {
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
    public func isAllowedAccessDeviceData() -> Bool {
        let deviceAccessConsent = getDeviceAccessConsent()
        
        if ((deviceAccessConsent == nil && (subjectToGDPR == nil || subjectToGDPR == false)) || deviceAccessConsent == true) {
            return true
        }
        
        return false
    }
    
    // MARK: - Private
    
    private func iabGDPRSubject() -> Bool? {
        var gdprSubject: Bool? = nil

        if let gdprSubjectTcf2: NSNumber? = UserDefaults.standard.getObjectFromUserDefaults(forKey: IABTCF_SubjectToGDPR) {
            if gdprSubjectTcf2 == 1 {
                gdprSubject = true
            } else if gdprSubjectTcf2 == 0 {
                gdprSubject = false
            }
        }

        return gdprSubject
    }
}
