//
//  PrebidRenderingTargeting.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

fileprivate let PrebidTargetingKey_AGE = "age"
fileprivate let PrebidTargetingKey_GENDER = "gen"
fileprivate let PrebidTargetingKey_USER_ID = "xid"
fileprivate let PrebidTargetingKey_PUB_PROVIDED_PREFIX = "c."

public class PrebidRenderingTargeting: NSObject {
    
    @objc public static var shared = PrebidRenderingTargeting()
    
    // MARK: - User Information
    
    /**
     Indicates the end-user's age, in years.
     */
    @objc public var userAge: NSNumber? {
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
     Integer flag indicating if this request is subject to the COPPA regulations
     established by the USA FTC, where 0 = no, 1 = yes
     */
    @objc public var coppa: NSNumber?
    
    /**
     Indicates the end-user's gender.
     */
    
    @objc public var userGender: Gender {
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
    @objc public func userGenderDescription() -> String? {
        guard let currentValue = parameterDictionary[PrebidTargetingKey_GENDER] else {
            return nil
        }
        
        return GenderDescription(rawValue: currentValue)?.rawValue
    }
    
    /**
     Indicates the customer-provided user ID, if different from the Device ID.
     */
    @objc public var userID: String? {
        get { parameterDictionary[PrebidTargetingKey_USER_ID] }
        set { parameterDictionary[PrebidTargetingKey_USER_ID] = newValue }
    }
    
    /**
     Buyer-specific ID for the user as mapped by the exchange for the buyer.
     */
    @objc public var buyerUID: String?

    /**
     Comma separated list of keywords, interests, or intent.
     */
    @objc public var keywords: String?

    /**
     Optional feature to pass bidder data that was set in the
     exchange’s cookie. The string must be in base85 cookie safe
     characters and be in any format. Proper JSON encoding must
     be used to include “escaped” quotation marks.
     */
    @objc public var userCustomData: String?
    
    /**
     Placeholder for User Identity Links.
     The data from this property will be added to usr.ext.eids
     */
    @objc public var eids: [[String : AnyHashable]]?
    
    /**
     Placeholder for exchange-specific extensions to OpenRTB.
     */
    @objc public var userExt: [String : AnyHashable]?

    
    // MARK: - Application Information
    
    /**
     This is the deep-link URL for the app screen that is displaying the ad. This can be an iOS universal link.
     */
    @objc public var contentUrl: String?
    
    @objc public var appStoreMarketURL: String? {
        get { parameterDictionary[PBMParameterKeys.APP_STORE_URL.rawValue] }
        set { parameterDictionary[PBMParameterKeys.APP_STORE_URL.rawValue] = newValue }
    }
    
    /**
     App's publisher name.
     */
    @objc public var publisherName: String?
    
    /**
     ID of publisher app in Apple’s App Store.
     */
    @objc public var sourceapp: String?

    
    // MARK: - Location and connection information
    
    /**
     CLLocationCoordinate2D.
     See CoreLocation framework documentation.
     */
    @objc public var coordinate: NSValue?

    
    // MARK: - Public Methods
    
    @objc public func resetUserAge() {
        userAge = nil
    }
    
    @objc public func addParam(_ value: String, withName: String?) {
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
    
    @objc public func setCustomParams(_ params: [String : String]?) {
        guard let params = params else {
            return
        }
        
        params.keys.forEach { key in
            if let value = params[key] {
                addCustomParam(value, withName: key)
            }
        }
    }
    
    @objc public func addCustomParam(_ value: String, withName: String?) {
        guard let name = withName else {
            return
        }
        
        let prefixedName = makeCustomParamFromName(name)
        addParam(value, withName:prefixedName)
    }
        
    // Store location in the user's section
    @objc public func setLatitude(_ latitude: Double, longitude: Double) {
        coordinate = NSValue(mkCoordinate: CLLocationCoordinate2DMake(latitude, longitude))
    }
    
    // MARK: - Access Control List
    
    @objc public func addBidder(toAccessControlList bidderName: String) {
        rawAccessControlList.insert(bidderName)
    }
    
    @objc public func removeBidder(fromAccessControlList bidderName: String) {
        rawAccessControlList.remove(bidderName)
    }

    @objc public func clearAccessControlList() {
        rawAccessControlList.removeAll()
    }
    
    @objc public var accessControlList: [String] {
        Array(rawAccessControlList)
    }
    
    // MARK: - User Data
    
    @objc public func addUserData(_ value: String, forKey key: String) {
        var values = rawUserDataDictionary[key] ?? Set<String>()
        values.insert(value)
        
        rawUserDataDictionary[key] = values
    }
    
    @objc public func updateUserData(_ value: Set<String>, forKey key: String) {
        rawUserDataDictionary[key] = value
    }
    
    @objc public func removeUserData(forKey key: String) {
        rawUserDataDictionary.removeValue(forKey: key)
    }
    
    @objc public func clearUserData() {
        rawUserDataDictionary.removeAll()
    }
    
    @objc public var userDataDictionary: [String : Set<String>] {
        rawUserDataDictionary
    }
    
    // MARK: - Context Data
    
    @objc public func addContextData(_ value: String, forKey key: String) {
        var values = rawContextDataDictionary[key] ?? Set<String>()
        values.insert(value)
        
        rawContextDataDictionary[key] = values
    }
    
    @objc public func updateContextData(_ value: Set<String>, forKey key: String) {
        rawContextDataDictionary[key] = value
    }
    
    @objc public func removeContextData(forKey key: String) {
        rawContextDataDictionary.removeValue(forKey: key)
    }
    
    @objc public func clearContextData() {
        rawContextDataDictionary.removeAll()
    }
    
    @objc public var contextDataDictionary: [String : [String]] {
        rawContextDataDictionary.mapValues { Array($0) }
    }
        
    // MARK: - Internal Properties
    
    public var parameterDictionary = [String : String]()
    
    private var rawAccessControlList = Set<String>()
    private var rawUserDataDictionary = [String : Set<String>]()
    private var rawContextDataDictionary = [String : Set<String>]()

    
    // MARK: - Internal Methods
    
    func makeCustomParamFromName(_ name: String) -> String {
        if name.hasPrefix(PrebidTargetingKey_PUB_PROVIDED_PREFIX) {
            return name
        }
        
        return PrebidTargetingKey_PUB_PROVIDED_PREFIX + name
    }
}
