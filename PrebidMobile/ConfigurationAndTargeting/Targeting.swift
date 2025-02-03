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

import AdSupport
import AppTrackingTransparency
import Foundation
import CoreLocation
import MapKit

fileprivate let PrebidTargetingKey_AGE = "age"
fileprivate let PrebidTargetingKey_GENDER = "gen"
fileprivate let PrebidTargetingKey_USER_ID = "xid"
fileprivate let PrebidTargetingKey_PUB_PROVIDED_PREFIX = "c."


/// A class that manages targeting information for ads.
///
/// This class provides properties and methods for setting and retrieving
/// user-specific targeting information, such as user ID, gender, and custom
/// data. It also includes details for OMID (Open Measurement Interface Definition)
/// partner and supports managing user identity links and custom extensions.
///
@objcMembers
public class Targeting: NSObject {
    
    /// A shared instance of the `Targeting` class.
    public static var shared = Targeting()
    
    // MARK: - OMID Partner
    
    /// The name of the OMID partner.
    public var omidPartnerName: String?
    
    /// The version of the OMID partner.
    public var omidPartnerVersion: String?
    
    // MARK: - User Information
    
    /**
     Indicates user birth year.
     */
    @available(*, deprecated, message: "Deprecated by ORTB")
    public var yearOfBirth: Int {
        get { yearofbirth }
        set { setYearOfBirth(yob: newValue) }
    }
    
    /**
     * This method set the year of birth value
     */
    @available(*, deprecated, message: "Deprecated by ORTB")
    public func setYearOfBirth(yob: Int) {
        if AgeUtils.isYOBValid(yob) {
            yearofbirth = yob
        } else {
            Log.error("Incorrect birth year. It will be ignored.")
        }
    }
    
    // Objective C API
    @available(*, deprecated, message: "Deprecated by ORTB")
    public func getYearOfBirth() -> NSNumber {
        NSNumber(value: yearOfBirth)
    }
    
    /// This method clears year of birth value set by the application developer
    public func clearYearOfBirth() {
        yearofbirth = 0
    }
    
    /**
     Indicates the end-user's gender.
     */
    @available(*, deprecated, message: "Deprecated by ORTB")
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
    
    /// String representation of the users gender,
    /// where “M” = male, “F” = female, “O” = known to be other (i.e., omitted is unknown)
    public func userGenderDescription() -> String? {
        guard let currentValue = parameterDictionary[PrebidTargetingKey_GENDER] else {
            return nil
        }
        
        return GenderDescription(rawValue: currentValue)?.rawValue
    }
    
    /// Indicates the customer-provided user ID, if different from the Device ID.
    public var userID: String? {
        get { parameterDictionary[PrebidTargetingKey_USER_ID] }
        set { parameterDictionary[PrebidTargetingKey_USER_ID] = newValue }
    }
    
    /// Buyer-specific ID for the user as mapped by the exchange for the buyer.
    /// Deprecated.
    @available(*, deprecated, message: "This property is deprecated. In the upcoming major release, the property will be removed.")
    public var buyerUID: String?
    
    /**
     Optional feature to pass bidder data that was set in the
     exchange’s cookie. The string must be in base85 cookie safe
     characters and be in any format. Proper JSON encoding must
     be used to include “escaped” quotation marks.
     */
    @available(*, deprecated, message: "This property is deprecated.  This is an exchange-specific property.")
    public var userCustomData: String?
    
    /// Placeholder for User Identity Links.
    /// The data from this property will be added to usr.ext.eids
    @available(*, deprecated, message: "Deprecated. This property will be removed in future releases. Please, use Targeting.setExternalUserIds(_:) instead.")
    public var eids: [[String : AnyHashable]]?
    
    /// Placeholder for exchange-specific extensions to OpenRTB.
    public var userExt: [String : AnyHashable]?
    
    // MARK: - COPPA
    
    /// Objective C analog of subjectToCOPPA
    public var coppa: NSNumber? {
        set { UserConsentDataManager.shared.subjectToCOPPA = newValue.boolValue }
        get { UserConsentDataManager.shared.subjectToCOPPA.nsNumberValue }
    }
    
    /// Integer flag indicating if this request is subject to the COPPA regulations
    /// established by the USA FTC, where 0 = no, 1 = yes
    public var subjectToCOPPA: Bool? {
        set { UserConsentDataManager.shared.subjectToCOPPA = newValue}
        get { UserConsentDataManager.shared.subjectToCOPPA }
    }
    
    // MARK: - GDPR
    
    /// The boolean value set by the user to collect user data
    public var subjectToGDPR: Bool? {
        set { UserConsentDataManager.shared.subjectToGDPR = newValue }
        
        get { UserConsentDataManager.shared.subjectToGDPR }
    }
    
    /// Objective-C API
    public func setSubjectToGDPR(_ newValue: NSNumber?) {
        UserConsentDataManager.shared.subjectToGDPR = newValue?.boolValue
    }
    
    /// Objective-C API
    public func getSubjectToGDPR() -> NSNumber? {
        return UserConsentDataManager.shared.subjectToGDPR_NSNumber
    }
    
    // MARK: - GDPR Consent
    
    /// The consent string for sending the GDPR consent
    public var gdprConsentString: String? {
        set { UserConsentDataManager.shared.gdprConsentString = newValue }
        get { UserConsentDataManager.shared.gdprConsentString }
    }
    
    // MARK: - TCFv2
    
    /// The consent string for purposes consent as per TCFv2.
    public var purposeConsents: String? {
        set { UserConsentDataManager.shared.purposeConsents = newValue }
        get { UserConsentDataManager.shared.purposeConsents }
    }
    
    /// Purpose 1 - Store and/or access information on a device
    public func getDeviceAccessConsent() -> Bool? {
        UserConsentDataManager.shared.getDeviceAccessConsent()
    }
    
    /// Returns whether the user has consented to access device data as an `NSNumber`.
    public func getDeviceAccessConsentObjc() -> NSNumber? {
        UserConsentDataManager.shared.getDeviceAccessConsent() as NSNumber?
    }
    
    /// Returns the user's consent for a specific purpose by index.
    public func getPurposeConsent(index: Int) -> Bool? {
        UserConsentDataManager.shared.getPurposeConsent(index: index)
    }
    
    /// Checks if access to device data is allowed.
    public func isAllowedAccessDeviceData() -> Bool {
        UserConsentDataManager.shared.isAllowedAccessDeviceData()
    }
    
    /// This value forces SDK to choose targeting info of the winning bid
    public var forceSdkToChooseWinner : Bool = true
    
    // MARK: - External User Ids
    
    /// Sets the external user ID.
    public func setExternalUserIds(_ externalUserIds: [ExternalUserId]) {
        self.externalUserIds = externalUserIds
    }
    
    /// Retrieves the external user IDs in a dictionary format suitable for use in JSON.
    public func getExternalUserIds() -> [[String: Any]]? {
        var externalUserIdArray = [ExternalUserId]()
        
        if Prebid.shared.externalUserIdArray.count != 0 {
            externalUserIdArray = Prebid.shared.externalUserIdArray
        } else {
            externalUserIdArray = externalUserIds
        }
        
        var transformedUserIdArray = externalUserIdArray.map { $0.toJSONDictionary() }
        
        if let eids = eids {
            transformedUserIdArray.append(contentsOf: eids)
        }
        
        return transformedUserIdArray.isEmpty ? nil : transformedUserIdArray
    }
    
    /// This method allows to save External User Id
    @available(*, deprecated, message: "Deprecated. SDK doesn't support storing External User IDs in application storage. This method will be removed in future releases.")
    public func storeExternalUserId(_ externalUserId: ExternalUserId) {
        if let index = externalUserIds.firstIndex(where: {$0.source == externalUserId.source}) {
            externalUserIds[index] = externalUserId
        } else {
            externalUserIds.append(externalUserId)
        }
    }
    
    /// This method allows to get all External User Ids
    @available(*, deprecated, message: "Deprecated. SDK doesn't support storing External User IDs in application storage. This method will be removed in future releases.")
    public func fetchStoredExternalUserIds() -> [ExternalUserId]? {
        externalUserIds
    }
    
    /// This method allows to get External User Id by passing respective 'source' string as param
    @available(*, deprecated, message: "Deprecated. This method will be removed in future releases.")
    public func fetchStoredExternalUserId(_ source : String) -> ExternalUserId? {
        guard let externalUserId = externalUserIds.first(where: { $0.source == source }) else {
            return nil
        }
        
        return externalUserId
    }
    
    /// This method allows to remove specific External User Id by passing respective 'source' string as param
    @available(*, deprecated, message: "Deprecated. This method will be removed in future releases.")
    public func removeStoredExternalUserId(_ source : String) {
        if let index = externalUserIds.firstIndex(where: {$0.source == source}) {
            externalUserIds.remove(at: index)
        }
    }
    
    /// This method allows to remove all the External User Ids
    @available(*, deprecated, message: "Deprecated. This method will be removed in future releases.")
    public func removeStoredExternalUserIds() {
        externalUserIds = []
    }
    
    // MARK: - SharedId
    
    /// When true, the SharedID external user id is added to outgoing auction requests.  App developers are
    /// encouraged to consult with their legal team before enabling this feature.
    ///
    /// See `Targeting.sharedId` for details.
    public var sendSharedId: Bool = false
    
    /// A randomly generated Prebid-owned first-party identifier
    ///
    /// Unless reset, SharedID remains consistent throughout the current app session. The same id may also persist
    /// indefinitely across multiple app sessions if local storage access is allowed. SharedID values are NOT consistent
    /// across different apps on the same device.
    ///
    /// - Note: SharedId is only sent with auction requests if `Targeting.sendSharedId` is set to true.
    public var sharedId: ExternalUserId {
        SharedId.sharedInstance.identifier
    }
    
    /// Resets and clears out of local storage the existing SharedID value, after which `Targeting.sharedId` will
    /// return a new randomized value.
    public func resetSharedId() {
        SharedId.sharedInstance.resetIdentifier()
    }
    
    // MARK: - Application Information
    
    /// This is the deep-link URL for the app screen that is displaying the ad. This can be an iOS universal link.
    public var contentUrl: String?
    
    /// App's publisher name.
    public var publisherName: String?
    
    /// ID of publisher app in Apple’s App Store.
    public var sourceapp: String?
    
    /// App store URL for an installed app
    public var storeURL: String? {
        get { parameterDictionary[PBMParameterKeys.APP_STORE_URL.rawValue] }
        set { parameterDictionary[PBMParameterKeys.APP_STORE_URL.rawValue] = newValue }
    }
    
    /// Domain name of the app
    public var domain: String?
    
    /// The itunes app id for targeting
    public var itunesID: String?
    
    /// The application location for targeting
    public var location: CLLocation?
    
    /// The application location precision for targeting
    /// Deprecated.
    @available(*, deprecated, message: "This property is deprecated. In the upcoming major release, the property will be removed.")
    public var locationPrecision: Int?
    
    /// Objective-C API
    /// Deprecated.
    @available(*, deprecated, message: "This method is deprecated. In the upcoming major release, the method will be removed.")

    public func setLocationPrecision(_ newValue: NSNumber?) {
        locationPrecision = newValue?.intValue
    }
    
    /// Objective-C API
    /// Deprecated.
    @available(*, deprecated, message: "This method is deprecated. In the upcoming major release, the method will be removed.")
    public func getLocationPrecision() -> NSNumber? {
        return locationPrecision as NSNumber?
    }
    
    // MARK: - Location and connection information
    
    /// CLLocationCoordinate2D.
    /// See CoreLocation framework documentation.
    public var coordinate: NSValue?
    
    
    // MARK: - Public Methods
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the global-level OpenRTB configuration string.
    ///
    /// - Parameter ortbObject: The global-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setGlobalORTBConfig(_ ortbConfig: String?) {
        globalORTBConfig = ortbConfig
    }
    
    /// Returns the global-level OpenRTB configuration string.
    public func getGlobalORTBConfig() -> String? {
        globalORTBConfig
    }
    
    /// Adds a parameter to the parameter dictionary with a specified name.
    ///
    /// - Parameters:
    ///   - value: The value of the parameter.
    ///   - withName: The name of the parameter. If `nil`, the parameter is not added.
    public func addParam(_ value: String, withName: String?) {
        guard let name = withName else {
            Log.error("Invalid user parameter.")
            return
        }
        
        if value.isEmpty {
            parameterDictionary.removeValue(forKey: name)
        } else {
            parameterDictionary[name] = value
        }
    }
    
    /// Sets custom parameters by adding each key-value pair to the parameter dictionary.
    ///
    /// - Parameter params: A dictionary of parameters to set. If `nil`, no parameters are added.
    /// Deprecated.
    @available(*, deprecated, message: "This method is deprecated. In the upcoming major release, the method will be removed.")
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
    
    /// Adds a custom parameter to the parameter dictionary with a prefixed name.
    ///
    /// - Parameters:
    ///   - value: The value of the custom parameter.
    ///   - withName: The name of the custom parameter. If `nil`, the parameter is not added.
    /// Deprecated.
    @available(*, deprecated, message: "This method is deprecated. In the upcoming major release, the method will be removed.")
    public func addCustomParam(_ value: String, withName: String?) {
        guard let name = withName else {
            return
        }
        
        let prefixedName = makeCustomParamFromName(name)
        addParam(value, withName:prefixedName)
    }
    
    /// Store location in the user's section
    public func setLatitude(_ latitude: Double, longitude: Double) {
        coordinate = NSValue(mkCoordinate: CLLocationCoordinate2DMake(latitude, longitude))
    }
    
    // MARK: - Access Control List (ext.prebid.data)
    
    /// Adds a bidder to the access control list.
    ///
    /// - Parameter bidderName: The name of the bidder to add.
    public func addBidderToAccessControlList(_ bidderName: String) {
        rawAccessControlList.insert(bidderName)
    }
    
    /// Removes a bidder from the access control list.
    ///
    /// - Parameter bidderName: The name of the bidder to remove.
    public func removeBidderFromAccessControlList(_ bidderName: String) {
        rawAccessControlList.remove(bidderName)
    }
    
    /// Clears all bidders from the access control list.
    public func clearAccessControlList() {
        rawAccessControlList.removeAll()
    }
    
    /// Retrieves the current access control list.
    ///
    /// - Returns: An array of bidder names in the access control list.
    public func getAccessControlList() -> [String] {
        Array(rawAccessControlList)
    }
    
    /// Access control list for external use.
    ///
    /// - Returns: An array of bidder names in the access control list.
    public var accessControlList: [String] {
        Array(rawAccessControlList)
    }
    
    // MARK: - Global User Data (user.ext.data)
    
    /// Adds user data for a specified key.
    ///
    /// - Parameters:
    ///   - key: The key for the user data.
    ///   - value: The value to add for the specified key.
    public func addUserData(key: String, value: String) {
        var values = rawUserDataDictionary[key] ?? Set<String>()
        values.insert(value)
        
        rawUserDataDictionary[key] = values
    }
    
    /// Updates user data for a specified key with a new set of values.
    ///
    /// - Parameters:
    ///   - key: The key for the user data.
    ///   - value: The set of values to update for the specified key.
    public func updateUserData(key: String, value: Set<String>) {
        rawUserDataDictionary[key] = value
    }
    
    /// Removes user data for a specified key.
    ///
    /// - Parameter key: The key for the user data to remove.
    public func removeUserData(for key: String) {
        rawUserDataDictionary.removeValue(forKey: key)
    }
    
    /// Clears all user data.
    public func clearUserData() {
        rawUserDataDictionary.removeAll()
    }
    
    /// Retrieves all user data.
    ///
    /// - Returns: A dictionary mapping keys to arrays of values.
    public func getUserData() -> [String: [String]] {
        rawUserDataDictionary.mapValues { Array($0) }
    }
    
    /// User data dictionary for external use.
    ///
    /// - Returns: A dictionary mapping keys to arrays of values.
    public var userDataDictionary: [String : [String]] {
        rawUserDataDictionary.mapValues { Array($0) }
    }
    
    // MARK: - Global User Keywords (user.keywords)
    
    /// Adds a user keyword.
    ///
    /// - Parameter newElement: The keyword to add.
    public func addUserKeyword(_ newElement: String) {
        userKeywordsSet.insert(newElement)
    }
    
    /// Adds multiple user keywords.
    ///
    /// - Parameter newElements: A set of keywords to add.
    public func addUserKeywords(_ newElements: Set<String>) {
        userKeywordsSet.formUnion(newElements)
    }
    
    /// Removes a user keyword.
    ///
    /// - Parameter element: The keyword to remove.
    public func removeUserKeyword(_ element: String) {
        userKeywordsSet.remove(element)
    }
    
    /// Clears all user keywords.
    public func clearUserKeywords() {
        userKeywordsSet.removeAll()
    }
    
    /// Retrieves all user keywords.
    ///
    /// - Returns: An array of user keywords.
    public func getUserKeywords() -> [String] {
        return Array(userKeywordsSet)
    }
    
    /// Deprecated. Use `getUserKeywords` method instead.
    @available(*, deprecated, message: "This property is deprecated. Please, use getUserKeywords method instead.")
    public var userKeywords: [String] {
        Array(userKeywordsSet)
    }
    
    // MARK: - Global Data (app.ext.data)
    
    /// Deprecated. Use `addAppExtData` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use addAppExtData method instead.")
    public func addContextData(key: String, value: String) {
        addAppExtData(key: key, value: value)
    }
    
    /// Deprecated. Use `updateAppExtData` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use updateAppExtData method instead.")
    public func updateContextData(key: String, value: Set<String>) {
        updateAppExtData(key: key, value: value)
    }
    
    /// Deprecated. Use `removeAppExtData` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use removeAppExtData method instead.")
    public func removeContextData(for key: String) {
        removeAppExtData(for: key)
    }
    
    /// Deprecated. Use `clearAppExtData` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use clearAppExtData method instead.")
    public func clearContextData() {
        clearAppExtData()
    }
    
    /// Deprecated. Use `getAppExtData` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use getAppExtData method instead.")
    public func getContextData() -> [String: [String]] {
        getAppExtData()
    }
    
    /// Deprecated. Use `getAppExtData` method instead.
    @available(*, deprecated, message: "This property is deprecated. Please, use getAppExtData method instead.")
    public var contextDataDictionary: [String: [String]] {
        getAppExtData()
    }
    
    /// Adds application-specific data for a specified key.
    ///
    /// - Parameters:
    ///   - key: The key for the application data.
    ///   - value: The value to add for the specified key.
    public func addAppExtData(key: String, value: String) {
        var values = rawAppExtDataDictionary[key] ?? Set<String>()
        values.insert(value)
        
        rawAppExtDataDictionary[key] = values
    }
    
    /// Updates application-specific data for a specified key with a new set of values.
    ///
    /// - Parameters:
    ///   - key: The key for the application data.
    ///   - value: The set of values to update for the specified key.
    public func updateAppExtData(key: String, value: Set<String>) {
        rawAppExtDataDictionary[key] = value
    }
    
    /// Removes application-specific data for a specified key.
    ///
    /// - Parameter key: The key for the application data to remove.
    public func removeAppExtData(for key: String) {
        rawAppExtDataDictionary.removeValue(forKey: key)
    }
    
    /// Clears all application-specific data.
    public func clearAppExtData() {
        rawAppExtDataDictionary.removeAll()
    }
    
    /// Retrieves all application-specific data.
    ///
    /// - Returns: A dictionary mapping keys to arrays of values.
    public func getAppExtData() -> [String: [String]] {
        rawAppExtDataDictionary.mapValues { Array($0) }
    }
    
    // MARK: - Global Keywords (app.keywords)
    
    /// Deprecated. Use `addAppKeyword` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use addAppKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addAppKeyword(newElement)
    }
    
    /// Deprecated. Use `addAppKeywords` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use addAppKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addAppKeywords(newElements)
    }
    
    /// Deprecated. Use `removeAppKeyword` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use removeAppKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeAppKeyword(element)
    }
    
    /// Deprecated. Use `clearAppKeywords` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use clearAppKeywords method instead.")
    public func clearContextKeywords() {
        clearAppKeywords()
    }
    
    /// Deprecated. Use `getAppKeywords` method instead.
    @available(*, deprecated, message: "This method is deprecated. Please, use getAppKeywords method instead.")
    public func getContextKeywords() -> [String] {
        getAppKeywords()
    }
    
    /// Deprecated. Use `getAppKeywords` method instead.
    @available(*, deprecated, message: "This property is deprecated. Please, use getAppKeywords method instead.")
    public var contextKeywords: [String] {
        getAppKeywords()
    }
    
    /// Adds an application keyword.
    ///
    /// - Parameter newElement: The keyword to add.
    public func addAppKeyword(_ newElement: String) {
        appKeywordsSet.insert(newElement)
    }
    
    /// Adds multiple application keywords.
    ///
    /// - Parameter newElements: A set of keywords to add.
    public func addAppKeywords(_ newElements: Set<String>) {
        appKeywordsSet.formUnion(newElements)
    }
    
    /// Removes an application keyword.
    ///
    /// - Parameter element: The keyword to remove.
    public func removeAppKeyword(_ element: String) {
        appKeywordsSet.remove(element)
    }
    
    /// Clears all application keywords.
    public func clearAppKeywords() {
        appKeywordsSet.removeAll()
    }
    
    /// Retrieves all application keywords.
    ///
    /// - Returns: An array of application keywords.
    public func getAppKeywords() -> [String] {
        return Array(appKeywordsSet)
    }
    
    // MARK: - Internal Properties
    
    /// Dictionary of parameters.
    public var parameterDictionary = [String : String]()
    
    private var userKeywordsSet = Set<String>()
    private var appKeywordsSet = Set<String>()
    
    private var rawAccessControlList = Set<String>()
    private var rawUserDataDictionary = [String : Set<String>]()
    private var rawAppExtDataDictionary = [String : Set<String>]()
    
    private var yearofbirth = 0
    
    private var globalORTBConfig: String?
    
    /// Array of external user IDs.
    ///
    /// This property holds the external user IDs associated with the user.
    private var externalUserIds = [ExternalUserId]()
    
    // MARK: - Internal Methods
    
    func makeCustomParamFromName(_ name: String) -> String {
        if name.hasPrefix(PrebidTargetingKey_PUB_PROVIDED_PREFIX) {
            return name
        }
        
        return PrebidTargetingKey_PUB_PROVIDED_PREFIX + name
    }
}
