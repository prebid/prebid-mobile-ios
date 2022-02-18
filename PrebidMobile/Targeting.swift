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

    private lazy var accessControlList = Set<String>()
    private lazy var userDataDictionary = [String: Set<String>]()
    private lazy var userKeywordsSet = Set<String>()
    private lazy var contextDataDictionary = [String: Set<String>]()
    private lazy var contextKeywordsSet = Set<String>()
    private lazy var userDataObjects = [ContentDataObject]()
    private lazy var appContentData = [ContentDataObject]()
    
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
    
    public var omidPartnerName: String?
    
    public var omidPartnerVersion: String?
    
    //Objective-C Api
    @available(swift, obsoleted: 1.0)
    public func setLocationPrecision(_ newValue: NSNumber?) {
        locationPrecision = newValue?.intValue
    }
    
    @available(swift, obsoleted: 1.0)
    public func getLocationPrecision() -> NSNumber? {
        return locationPrecision as NSNumber?
    }
    
    // MARK: - Year Of Birth
    //TODO refactor
    public var yearOfBirth: Int {
        return yearofbirth
    }

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
    
    // MARK: - COPPA
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
    
    // MARK: - GDPR Subject
    /**
     * The boolean value set by the user to collect user data
     */
    public var subjectToGDPR: Bool? {
        set {
            StorageUtils.setPbGdprSubject(value: newValue)
        }

        get {
            var gdprSubject: Bool?

            if let pbGdpr = StorageUtils.pbGdprSubject() {
                gdprSubject = pbGdpr
            } else if let iabGdpr = StorageUtils.iabGdprSubject() {
                gdprSubject = iabGdpr
            }
            
            return gdprSubject
        }
    }
    
    //Objective-C Api
    @available(swift, obsoleted: 1.0)
    public func setSubjectToGDPR(_ newValue: NSNumber?) {
        subjectToGDPR = newValue?.boolValue
    }
    
    @available(swift, obsoleted: 1.0)
    public func getSubjectToGDPR() -> NSNumber? {
        return subjectToGDPR as NSNumber?
    }

    // MARK: - GDPR Consent
    /**
     * The consent string for sending the GDPR consent
     */
    public var gdprConsentString: String? {
        set {
            StorageUtils.setPbGdprConsent(value: newValue)
        }

        get {
            var savedConsent: String?
            
            if let iabString = StorageUtils.iabGdprConsent() {
                savedConsent = iabString
            } else if let pbString = StorageUtils.pbGdprConsent() {
                savedConsent = pbString
            }
            
            return savedConsent
        }
    }
    
    // MARK: - External UserIds
    var externalUserIds = [ExternalUserId]()
    /**
     * This method allows to save External User Id in the User Defaults
     */
    public func storeExternalUserId(_ externalUserId: ExternalUserId) {
        if let index = externalUserIds.firstIndex(where: {$0.source == externalUserId.source}) {
            externalUserIds[index] = externalUserId
        }else{
            externalUserIds.append(externalUserId)
        }
        StorageUtils.setExternalUserIds(value: externalUserIds)
        
    }
    /**
     * This method allows to get All External User Ids from User Defaults 
     */
    public func fetchStoredExternalUserIds()->[ExternalUserId]? {
        return StorageUtils.getExternalUserIds()
    }
    /**
     * This method allows to get External User Id from User Defaults by passing respective 'source' string as param
     */
    public func fetchStoredExternalUserId(_ source : String)->ExternalUserId? {
        guard let array = StorageUtils.getExternalUserIds(), let externalUserId = array.first(where: {$0.source == source}) else{
            return nil
        }
        return externalUserId
    }
    /**
     * This method allows to remove specific External User Id from User Defaults by passing respective 'source' string as param
     */
    public func removeStoredExternalUserId(_ source : String) {
        if let index = externalUserIds.firstIndex(where: {$0.source == source}) {
            externalUserIds.remove(at: index)
            StorageUtils.setExternalUserIds(value: externalUserIds)
        }
    }
    /**
     * This method allows to remove all the External User Ids from User Defaults 
     */
    public func removeStoredExternalUserIds() {
        if var arrayExternalUserIds = StorageUtils.getExternalUserIds(){
            arrayExternalUserIds.removeAll()
            StorageUtils.setExternalUserIds(value: arrayExternalUserIds)
        }
    }
    
    
    // MARK: - TCFv2

    public var purposeConsents: String? {
        set {
            StorageUtils.setPbPurposeConsents(value: newValue)
        }

        get {
            var savedPurposeConsents: String?

            if let iabString = StorageUtils.iabPurposeConsents() {
                savedPurposeConsents = iabString
            } else if let pbString = StorageUtils.pbPurposeConsents() {
                savedPurposeConsents = pbString
            }

            return savedPurposeConsents

        }
    }

    /*
     Purpose 1 - Store and/or access information on a device
     */
    public func getDeviceAccessConsent() -> Bool? {
        let deviceAccessConsentIndex = 0
        return getPurposeConsent(index: deviceAccessConsentIndex)
    }
    
    //Objective-C Api
    @available(swift, obsoleted: 1.0)
    public func getDeviceAccessConsent() -> NSNumber? {
        let deviceAccessConsent = getDeviceAccessConsent()
        return deviceAccessConsent as NSNumber?
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
    
    // MARK: - global user data aka visitor data (user.data)
    
    /**
     * This method obtains the user data keyword & value for global user targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    @available(*, deprecated, message: "This method will be removed soon. Please, use setUserDataObjects(_:[DataObjects]) or addUserDataObject(_:DataObject).")
    public func addUserData(key: String, value: String) {
        userDataDictionary.addValue(value, forKey: key)
    }
    
    /**
     * This method obtains the user data keyword & values set for global user targeting
     * the values if the key already exist will be replaced with the new set of values
     */
    @available(*, deprecated, message: "This method will be removed soon.")
    public func updateUserData(key: String, value: Set<String>) {
        userDataDictionary.updateValue(value, forKey: key)
    }
    
    /**
     * This method allows to remove specific user data keyword & value set from global user targeting
     */
    @available(*, deprecated, message: "This method will be removed soon.")
    public func removeUserData(forKey: String) {
        userDataDictionary.removeValue(forKey: forKey)
    }
    
    /**
     * This method allows to remove all user data set from global user targeting
     */
    @available(*, deprecated, message: "This method will be removed soon. Please, use clearUserDataObjects().")
    public func clearUserData() {
        userDataDictionary.removeAll()
    }
    
    @available(*, deprecated, message: "This method will be removed soon. Please, use getUserDataObjects().")
    func getUserDataDictionary() -> [String: Set<String>] {
        Log.info("global user data dictionary is \(userDataDictionary)")
        return userDataDictionary
    }
    
    /**
     * This method allows to setup array of user data objects.
     */
    public func setUserDataObjects(_ userDataObjects: [ContentDataObject]) {
        self.userDataObjects = userDataObjects
    }
    
    /**
     * This method allows to add a single user data object.
     */
    public func addUserDataObject(_ userDataObject: ContentDataObject) {
        userDataObjects.append(userDataObject)
    }
    
    /**
     * This method allows to get user data objects array.
     */
    func getUserDataObjects() -> [ContentDataObject] {
        return userDataObjects
    }
    
    /**
     * This method allows to remove all occurances of specific object in user data array.
     */
    public func removeUserDataObject(_ userDataObject: ContentDataObject) {
        if userDataObjects.contains(userDataObject) {
            userDataObjects.removeAll { $0 == userDataObject }
        }
    }
    
    /**
     * This method allows to clear user data objects array.
     */
    public func clearUserDataObjects() {
        userDataObjects.removeAll()
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
    
    // MARK: - global context data aka inventory data (app.content.data)
    
    /**
     * This method obtains the context data keyword & value context for global context targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    @available(*, deprecated, message: "This method will be removed soon. Please, use setAppDataObjects(_:[DataObjects]) or addAppDataObject(_:DataObject).")
    public func addContextData(key: String, value: String) {
        contextDataDictionary.addValue(value, forKey: key)
    }
    
    /**
     * This method obtains the context data keyword & values set for global context targeting.
     * the values if the key already exist will be replaced with the new set of values
     */
    @available(*, deprecated, message: "This method will be removed soon.")
    public func updateContextData(key: String, value: Set<String>) {
        contextDataDictionary.updateValue(value, forKey: key)
    }
    
    /**
     * This method allows to remove specific context data keyword & values set from global context targeting
     */
    @available(*, deprecated, message: "This method will be removed soon.")
    public func removeContextData(forKey: String) {
        contextDataDictionary.removeValue(forKey: forKey)
    }
    
    /**
     * This method allows to remove all context data set from global context targeting
     */
    @available(*, deprecated, message: "This method will be removed soon.")
    public func clearContextData() {
        contextDataDictionary.removeAll()
    }
    
    @available(*, deprecated, message: "This method will be removed soon. Please, use getAppDataObjects().")
    func getContextDataDictionary() -> [String: Set<String>] {
        Log.info("gloabal context data dictionary is \(contextDataDictionary)")
        return contextDataDictionary
    }
    
    /**
     * This method allows to setup array of app content data objects.
     */
    public func setAppDataObjects(_ dataObjects: [ContentDataObject]) {
        self.appContentData = dataObjects
    }
    
    /**
     * This method allows to add a single app content data object.
     */
    public func addAppDataObject(_ dataObject: ContentDataObject) {
        self.appContentData.append(dataObject)
    }

    /**
     * This method allows to remove all occurances of specific object in app content data array.
     */
    public func removeAppDataObject(_ dataObject: ContentDataObject) {
        if appContentData.contains(dataObject) {
            appContentData.removeAll(where: { $0 == dataObject })
        }
    }
    
    /**
     * This method allows to clear app content data objects array.
     */
    public func clearAppDataObjects() {
        appContentData.removeAll()
    }
    
    /**
     * This method allows to get app content data objects array.
     */
    func getAppDataObjects() -> [ContentDataObject] {
        return appContentData
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

}
