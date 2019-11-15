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

@objc public enum Gender: Int {
    case unknown
    case male
    case female
}

@objcMembers public class Targeting: NSObject {

    private var accessControlList = Set<String>()
    private var userDataDictionary = [String: Set<String>]()
    private var userKeywordsSet = Set<String>()
    private var contextDataDictionary = [String: Set<String>]()
    private var contextKeywordsSet = Set<String>()
    
    private var yearofbirth: Int = 0

    public var storeURL: String?
    public var domain: String?

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
    
    /**
     * This property gets the gender enum passed set by the developer
     */

    public var gender: Gender

    public var yearOfBirth: Int {
        return yearofbirth
    }
    
    /**
     * The itunes app id for targeting
     */
    public var itunesID: String?

    /**
     * The application location for targeting
     */
    public var location: CLLocation?

    /**
     * The application location precision for targeting
     */
    public var locationPrecision: Int?
    
    /**
     * The boolean value set by the user to collect user data
     */
    public var subjectToCOPPA: Bool {
        set {
            StorageUtils.setPbCoppa(value: newValue)
        }
        
        get {
            return StorageUtils.pbCoppa()
        }
    }
    
    /**
     * The boolean value set by the user to collect user data
     */
    public var subjectToGDPR: Bool? {
        set {
            StorageUtils.setPbGdprSubject(value: newValue)
        }

        get {
            var gdprConsent: Bool?

            if let pbGdpr = StorageUtils.pbGdprSubject() {
                gdprConsent = pbGdpr
            } else if let iabGdpr = StorageUtils.iabGdprSubject() {

                if (iabGdpr == "1" || iabGdpr == "true" || iabGdpr == "yes") {
                    gdprConsent = true
                } else {
                    gdprConsent = false
                }
                
            }
            
            return gdprConsent
        }
    }

    /**
     * The consent string for sending the GDPR consent
     */
    public var gdprConsentString: String? {
        set {
            StorageUtils.setPbGdprConsent(value: newValue)
        }

        get {
            var savedConsent: String?
            
            if let pbString = StorageUtils.pbGdprConsent() {
                savedConsent = pbString
            } else if let iabString = StorageUtils.iabGdprConsent() {
                savedConsent = iabString
            }
            
            return savedConsent
        }
    }
    
    // MARK: - access control list (ext.prebid.data)
    
    /**
     * This method obtains a bidder name allowed to receive global targeting
     */
    public func addBidderToAccessControlList(_ bidderName: String) {        
        accessControlList.insert(bidderName)
    }
    
    /**
     * This method allows to remove specific bidder name
     */
    public func removeBidderFromAccessControlList(_ bidderName: String) {
        accessControlList.remove(bidderName)
    }
    
    /**
     * This method allows to remove all the bidder name set
     */
    public func clearAccessControlList() {
        accessControlList.removeAll()
    }
    
    func getAccessControlList() -> Set<String> {
        Log.info("access control list is \(accessControlList)")
        return accessControlList
    }
    
    // MARK: - global user data aka visitor data (user.ext.data)
    
    /**
     * This method obtains the user data keyword & value for global user targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addUserData(key: String, value: String) {
        userDataDictionary.addValue(value, forKey: key)
    }
    
    /**
     * This method obtains the user data keyword & values set for global user targeting
     * the values if the key already exist will be replaced with the new set of values
     */
    public func updateUserData(key: String, value: Set<String>) {
        userDataDictionary.updateValue(value, forKey: key)
    }
    
    /**
     * This method allows to remove specific user data keyword & value set from global user targeting
     */
    public func removeUserData(forKey: String) {
        userDataDictionary.removeValue(forKey: forKey)
    }
    
    /**
     * This method allows to remove all user data set from global user targeting
     */
    public func clearUserData() {
        userDataDictionary.removeAll()
    }
    
    func getUserDataDictionary() -> [String: Set<String>] {
        Log.info("global user data dictionary is \(userDataDictionary)")
        return userDataDictionary
    }
    
    // MARK: - global user keywords (user.keywords)
    
    /**
     * This method obtains the user keyword for global user targeting
     * Inserts the given element in the set if it is not already present.
     */
    public func addUserKeyword(_ newElement: String) {
        userKeywordsSet.insert(newElement)
    }
    
    /**
     * This method obtains the user keyword set for global user targeting
     * Adds the elements of the given set to the set.
     */
    public func addUserKeywords(_ newElements: Set<String>) {
        userKeywordsSet.formUnion(newElements)
    }
    
    /**
     * This method allows to remove specific user keyword from global user targeting
     */
    public func removeUserKeyword(_ element: String) {
        userKeywordsSet.remove(element)
    }
    
    /**
     * This method allows to remove all keywords from the set of global user targeting
     */
    public func clearUserKeywords() {
        userKeywordsSet.removeAll()
    }
    
    func getUserKeywordsSet() -> Set<String> {
        Log.info("global user keywords set is \(userKeywordsSet)")
        return userKeywordsSet
    }
    
    // MARK: - global context data aka inventory data (app.ext.data)
    
    /**
     * This method obtains the context data keyword & value context for global context targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addContextData(key: String, value: String) {
        contextDataDictionary.addValue(value, forKey: key)
    }
    
    /**
     * This method obtains the context data keyword & values set for global context targeting.
     * the values if the key already exist will be replaced with the new set of values
     */
    public func updateContextData(key: String, value: Set<String>) {
        contextDataDictionary.updateValue(value, forKey: key)
    }
    
    /**
     * This method allows to remove specific context data keyword & values set from global context targeting
     */
    public func removeContextData(forKey: String) {
        contextDataDictionary.removeValue(forKey: forKey)
    }
    
    /**
     * This method allows to remove all context data set from global context targeting
     */
    public func clearContextData() {
        contextDataDictionary.removeAll()
    }
    
    func getContextDataDictionary() -> [String: Set<String>] {
        Log.info("gloabal context data dictionary is \(contextDataDictionary)")
        return contextDataDictionary
    }
    
    // MARK: - global context keywords (app.keywords)
    
    /**
     * This method obtains the context keyword for global context targeting
     * Inserts the given element in the set if it is not already present.
     */
    public func addContextKeyword(_ newElement: String) {
        contextKeywordsSet.insert(newElement)
    }
    
    /**
     * This method obtains the context keyword set for global context targeting
     * Adds the elements of the given set to the set.
     */
    public func addContextKeywords(_ newElements: Set<String>) {
        contextKeywordsSet.formUnion(newElements)
    }
    
    /**
     * This method allows to remove specific context keyword from global context targeting
     */
    public func removeContextKeyword(_ element: String) {
        contextKeywordsSet.remove(element)
    }
    
    /**
     * This method allows to remove all keywords from the set of global context targeting
     */
    public func clearContextKeywords() {
        contextKeywordsSet.removeAll()
    }
    
    func getContextKeywordsSet() -> Set<String> {
        Log.info("global context keywords set is \(contextKeywordsSet)")
        return contextKeywordsSet
    }
    
    // MARK: - others

    /**
     * This property gets the year of birth value set by the application developer
     */
    public func setYearOfBirth(yob: Int) throws {
        let date = Date()
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)

        if (yob <= 1900 || yob >= year) {
            throw ErrorCode.yearOfBirthInvalid
        } else {
            yearofbirth = yob
        }
    }

    /**
     * This property clears year of birth value set by the application developer
     */
    public func clearYearOfBirth() {
            yearofbirth = 0
    }

}
