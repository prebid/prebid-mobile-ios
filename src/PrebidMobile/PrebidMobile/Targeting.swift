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

import Foundation
import CoreLocation

@objc public enum Gender:Int {
    case unknown
    case male
    case female
}

@objcMembers public class Targeting :NSObject {
    
    private var yearofbirth:Int = 0;
   
    /**
     * This property gets the gender enum passed set by the developer
     */

    public var gender:Gender
    
    public var yearOfBirth: Int {
        return yearofbirth
    }
    
    /**
     * This property gets the year of birth value set by the application developer
     */
    public func setYearOfBirth(yob:Int) throws {
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        
        if(yob <= 1900 || yob >= year){
            throw ErrorCode.yearOfBirthInvalid
        } else {
            yearofbirth = yob
        }
    }
    
    /**
     * This property clears year of birth value set by the application developer
     */
    public func clearYearOfBirth()  {
            yearofbirth = 0
    }

    /**
     * This user and app inventory keyword & value for targeting
     */
    internal var customUserKeywords = [String: [String]]()

    internal var customInvKeywords = [String: [String]]()

    /**
     * The itunes app id for targeting
     */
    public var itunesID:String?
    
    /**
     * The application location for targeting
     */
    public var location:CLLocation?
    
    /**
     * The application location precision for targeting
     */
    public var locationPrecision:Int?
    
    /**
     * The boolean value set by the user to collect user data
     */
    public var subjectToGDPR:Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: .PB_GDPR_SubjectToConsent)
        }
        
        get {
            var gdprConsent:Bool = false
            
            if((UserDefaults.standard.object(forKey: .PB_GDPR_SubjectToConsent)) != nil){
                gdprConsent = UserDefaults.standard.bool(forKey: .PB_GDPR_SubjectToConsent)
            } else if((UserDefaults.standard.object(forKey: .IAB_GDPR_SubjectToConsent)) != nil){
                let stringValue :String = UserDefaults.standard.object(forKey: .IAB_GDPR_SubjectToConsent) as! String
                
                gdprConsent = Bool(stringValue)!
            }
            return gdprConsent;
        }
    }
    
    /**
     * The consent string for sending the GDPR consent
     */
    public var gdprConsentString:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: .PB_GDPR_ConsentString)
        }
        
        get {
            let pbString:String? = UserDefaults.standard.object(forKey: .PB_GDPR_ConsentString) as? String
            let iabString:String? = UserDefaults.standard.object(forKey: .IAB_GDPR_ConsentString) as? String
            
            var savedConsent :String?
            if(pbString != nil){
                savedConsent = pbString
            } else if(iabString != nil){
                savedConsent = iabString
            }
            return savedConsent
        }
    }

    /**
     * The property to access user and app inventory targetign
     */

    var userKeywords: [String: [String]] {
        Log.info("user keywords are \(customUserKeywords)")
        return customUserKeywords
    }

    var invKeywords: [String: [String]] {
        Log.info("user keywords are \(customInvKeywords)")
        return customInvKeywords
    }

    /**
     * This method obtains the user keyword & value user for targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addUserKeyword(key: String, value: String) {
        var existingValues: [String] = []
        if (customUserKeywords[key] != nil) {
            existingValues = customUserKeywords[key]!
        }
        if (!existingValues.contains(value)) {
            existingValues.append(value)
            customUserKeywords[key] = existingValues
        }
    }

    /**
     * This method obtains the inventory keyword & value for targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addInvKeyword(key: String, value: String) {
        var existingValues: [String] = []
        if (customInvKeywords[key] != nil) {
            existingValues = customInvKeywords[key]!
        }
        if (!existingValues.contains(value)) {
            existingValues.append(value)
            customInvKeywords[key] = existingValues
        }
    }

    /**
     * This method obtains the user keyword & values set for user targeting.
     * the values if the key already exist will be replaced with the new set of values
     */
    public func addUserKeywords(key: String, value: [String]) {

        customUserKeywords[key] = value

    }

    /**
     * This method obtains the inventory keyword & values set for targeting.
     * the values if the key already exist will be replaced with the new set of values
     */
    public func addInvKeywords(key: String, value: [String]) {

        customInvKeywords[key] = value

    }

    /**
     * This method allows to remove all the user keywords set for user targeting
     */
    public func clearUserKeywords() {

        if (customUserKeywords.count > 0 ) {
            customUserKeywords.removeAll()
        }

    }

    /**
     * This method allows to remove all the inventory keywords set for user targeting
     */
    public func clearInvKeywords() {

        if (customInvKeywords.count > 0 ) {
            customInvKeywords.removeAll()
        }

    }

    /**
     * This method allows to remove specific user keyword & value set from user targeting
     */
    public func removeUserKeyword(forKey: String) {
        if (customUserKeywords[forKey] != nil) {
            customUserKeywords.removeValue(forKey: forKey)
        }
    }

    /**
     * This method allows to remove specific inventory keyword & value set from user targeting
     */
    public func removeInvKeyword(forKey: String) {
        if (customInvKeywords[forKey] != nil) {
            customInvKeywords.removeValue(forKey: forKey)
        }
    }
    
    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Targeting()
    
    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        gender = Gender.unknown
    }
    
    
}
