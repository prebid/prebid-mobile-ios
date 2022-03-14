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
import CoreLocation
import MapKit

fileprivate let PrebidTargetingKey_AGE = "age"
fileprivate let PrebidTargetingKey_GENDER = "gen"
fileprivate let PrebidTargetingKey_USER_ID = "xid"
fileprivate let PrebidTargetingKey_PUB_PROVIDED_PREFIX = "c."

@objcMembers
public class Targeting: NSObject {
    
    public static var shared = Targeting()
    
    // MARK: - OMID Partner
    
    public var omidPartnerName: String?
    
    public var omidPartnerVersion: String?
    
    // MARK: - User Information
    
    /**
     Indicates the end-user's age, in years.
     */
    public var userAge: NSNumber? {
        get {
            guard let stringValue = parameterDictionary[PrebidTargetingKey_AGE] else {
                return nil
            }
            
            return Int(stringValue) as NSNumber?
        }
        
        set {
            guard let value = newValue else {
                parameterDictionary.removeValue(forKey: PrebidTargetingKey_AGE)
                return
            }
            
            parameterDictionary[PrebidTargetingKey_AGE] = value.stringValue
        }
    }
    
    /**
     Indicates user birth year.
     */
    public var yearOfBirth: Int {
        get { yearofbirth }
        set { setYearOfBirth(yob: newValue) }
    }
    
    /**
     * This method set the year of birth value
     */
    public func setYearOfBirth(yob: Int) {
        if PBMAgeUtils.isYOBValid(yob) {
            yearofbirth = yob
        } else {
            Log.error("Incorrect birth year. It will be ignored.")
        }
    }
    
    /**
     * This method clears year of birth value set by the application developer
     */
    public func clearYearOfBirth() {
        yearofbirth = 0
    }
    
    /**
     Indicates the end-user's gender.
     */
    public var userGender: Gender {
        get {
            guard let currentValue = parameterDictionary[PrebidTargetingKey_GENDER] else {
                return .unknown
            }
                        
            return GenderFromDescription(currentValue)
        }
        
        set {
            parameterDictionary[PrebidTargetingKey_GENDER] = DescriptionOfGender(newValue)
        }
    }
    
    /**
     String representation of the users gender,
     where “M” = male, “F” = female, “O” = known to be other (i.e., omitted is unknown)
     */
    public func userGenderDescription() -> String? {
        guard let currentValue = parameterDictionary[PrebidTargetingKey_GENDER] else {
            return nil
        }
        
        return GenderDescription(rawValue: currentValue)?.rawValue
    }
    
    /**
     Indicates the customer-provided user ID, if different from the Device ID.
     */
    public var userID: String? {
        get { parameterDictionary[PrebidTargetingKey_USER_ID] }
        set { parameterDictionary[PrebidTargetingKey_USER_ID] = newValue }
    }
    
    /**
     Buyer-specific ID for the user as mapped by the exchange for the buyer.
     */
    public var buyerUID: String?

    /**
     Comma separated list of keywords, interests, or intent.
     */
    public var keywords: String?

    /**
     Optional feature to pass bidder data that was set in the
     exchange’s cookie. The string must be in base85 cookie safe
     characters and be in any format. Proper JSON encoding must
     be used to include “escaped” quotation marks.
     */
    public var userCustomData: String?
    
    /**
     Placeholder for User Identity Links.
     The data from this property will be added to usr.ext.eids
     */
    public var eids: [[String : AnyHashable]]?
    
    /**
     Placeholder for exchange-specific extensions to OpenRTB.
     */
    public var userExt: [String : AnyHashable]?
    
    // MARK: - COPPA
    /**
     Integer flag indicating if this request is subject to the COPPA regulations
     established by the USA FTC, where 0 = no, 1 = yes
     */
    public var coppa: NSNumber?
    
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
    
    // MARK: - GDPR
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
    
    public func getDeviceAccessConsentObjc() -> NSNumber? {
        let deviceAccessConsent = getDeviceAccessConsent()
        return deviceAccessConsent as NSNumber?
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
    
    // MARK: - External User Ids
    
    public var externalUserIds = [ExternalUserId]()
    
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
    
    // MARK: - Application Information
    
    /**
     This is the deep-link URL for the app screen that is displaying the ad. This can be an iOS universal link.
     */
    public var contentUrl: String?
    
    public var appStoreMarketURL: String? {
        get { parameterDictionary[PBMParameterKeys.APP_STORE_URL.rawValue] }
        set { parameterDictionary[PBMParameterKeys.APP_STORE_URL.rawValue] = newValue }
    }
    
    /**
     App's publisher name.
     */
    public var publisherName: String?
    
    /**
     ID of publisher app in Apple’s App Store.
     */
    public var sourceapp: String?
    
    public var storeURL: String?
    
    public var domain: String?
    
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
    
    public func setLocationPrecision(_ newValue: NSNumber?) {
        locationPrecision = newValue?.intValue
    }
    
    public func getLocationPrecision() -> NSNumber? {
        return locationPrecision as NSNumber?
    }

    // MARK: - Location and connection information
    
    /**
     CLLocationCoordinate2D.
     See CoreLocation framework documentation.
     */
    public var coordinate: NSValue?

    
    // MARK: - Public Methods
    
    public func resetUserAge() {
        userAge = nil
    }
    
    public func addParam(_ value: String, withName: String?) {
        guard let name = withName else {
            PBMLog.error("Invalid user parameter.")
            return
        }
        
        if value.isEmpty {
            parameterDictionary.removeValue(forKey: name)
        } else {
            parameterDictionary[name] = value
        }
    }
    
    public func setCustomParams(_ params: [String : String]?) {
        guard let params = params else {
            return
        }
        
        params.keys.forEach { key in
            if let value = params[key] {
                addCustomParam(value, withName: key)
            }
        }
    }
    
    public func addCustomParam(_ value: String, withName: String?) {
        guard let name = withName else {
            return
        }
        
        let prefixedName = makeCustomParamFromName(name)
        addParam(value, withName:prefixedName)
    }
        
    // Store location in the user's section
    public func setLatitude(_ latitude: Double, longitude: Double) {
        coordinate = NSValue(mkCoordinate: CLLocationCoordinate2DMake(latitude, longitude))
    }
    
    // MARK: - Access Control List (ext.prebid.data)
    
    public func addBidderToAccessControlList(_ bidderName: String) {
        rawAccessControlList.insert(bidderName)
    }
    
    public func removeBidderFromAccessControlList(_ bidderName: String) {
        rawAccessControlList.remove(bidderName)
    }

    public func clearAccessControlList() {
        rawAccessControlList.removeAll()
    }
    
    public func getAccessControlList() -> [String] {
        Array(rawAccessControlList)
    }
    
    public var accessControlList: [String] {
        Array(rawAccessControlList)
    }
    
    // MARK: - Global User Data (user.ext.data)
    
    public func addUserData(key: String, value: String) {
        var values = rawUserDataDictionary[key] ?? Set<String>()
        values.insert(value)
        
        rawUserDataDictionary[key] = values
    }
    
    public func updateUserData(key: String, value: Set<String>) {
        rawUserDataDictionary[key] = value
    }
     
    public func removeUserData(for key: String) {
        rawUserDataDictionary.removeValue(forKey: key)
    }
    
    public func clearUserData() {
        rawUserDataDictionary.removeAll()
    }
    
    public func getUserData() -> [String: [String]] {
        rawUserDataDictionary.mapValues { Array($0) }
    }
    
    public var userDataDictionary: [String : [String]] {
        rawUserDataDictionary.mapValues { Array($0) }
    }
    
    // MARK: - Global User Keywords (user.keywords)
    
    public func addUserKeyword(_ newElement: String) {
        userKeywordsSet.insert(newElement)
    }
    
    public func addUserKeywords(_ newElements: Set<String>) {
        userKeywordsSet.formUnion(newElements)
    }
  
    public func removeUserKeyword(_ element: String) {
        userKeywordsSet.remove(element)
    }
    
    public func clearUserKeywords() {
        userKeywordsSet.removeAll()
    }
    
    public func getUserKeywords() -> [String] {
        Log.info("global user keywords set is \(userKeywordsSet)")
        return Array(userKeywordsSet)
    }
    
    public var userKeywords: [String] {
        Array(userKeywordsSet)
    }
    
    // MARK: - Global Context Data (app.ext.data)
    
    public func addContextData(key: String, value: String) {
        var values = rawContextDataDictionary[key] ?? Set<String>()
        values.insert(value)
        
        rawContextDataDictionary[key] = values
    }
    
    public func updateContextData(key: String, value: Set<String>) {
        rawContextDataDictionary[key] = value
    }
    
    public func removeContextData(for key: String) {
        rawContextDataDictionary.removeValue(forKey: key)
    }
    
    public func clearContextData() {
        rawContextDataDictionary.removeAll()
    }
    
    public func getContextData() -> [String : [String]] {
        Log.info("gloabal context data dictionary is \(contextDataDictionary)")
        return contextDataDictionary.mapValues { Array($0) }
    }
    
    public var contextDataDictionary: [String : [String]] {
        rawContextDataDictionary.mapValues { Array($0) }
    }
    
    // MARK: - Global Context Keywords (app.keywords)
    
    public func addContextKeyword(_ newElement: String) {
        contextKeywordsSet.insert(newElement)
    }
    
    public func addContextKeywords(_ newElements: Set<String>) {
        contextKeywordsSet.formUnion(newElements)
    }
    
    public func removeContextKeyword(_ element: String) {
        contextKeywordsSet.remove(element)
    }
    
    public func clearContextKeywords() {
        contextKeywordsSet.removeAll()
    }
    
    public func getContextKeywords() -> [String] {
        Log.info("global context keywords set is \(contextKeywordsSet)")
        return Array(contextKeywordsSet)
    }
    
    public var contextKeywords: [String] {
        Array(contextKeywordsSet)
    }
        
    // MARK: - Internal Properties
    
    public var parameterDictionary = [String : String]()
    
    private var userKeywordsSet = Set<String>()
    private var contextKeywordsSet = Set<String>()
    
    private var rawAccessControlList = Set<String>()
    private var rawUserDataDictionary = [String : Set<String>]()
    private var rawContextDataDictionary = [String : Set<String>]()

    private var yearofbirth = 0
    
    // MARK: - Internal Methods
    
    func makeCustomParamFromName(_ name: String) -> String {
        if name.hasPrefix(PrebidTargetingKey_PUB_PROVIDED_PREFIX) {
            return name
        }
        
        return PrebidTargetingKey_PUB_PROVIDED_PREFIX + name
    }
}
