//
//  MockDeviceAccessManager.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import AppTrackingTransparency
import CoreGraphics
@testable import OpenXApolloSDK

fileprivate let advertisingTrackingEnabledDefault = true
fileprivate let defaultUserLanguageCode = "ml"

class MockDeviceAccessManager : OXMDeviceAccessManager {

    static let nullUUID = "00000000-0000-0000-0000-000000000000"
    static let mockIdentifierForVendor = "B78D99E3-5BD1-49AF-A669-0D77B464C5B9"
    static let mockAdvertisingIdentifier = "abc123"
    static var mockAdvertisingTrackingEnabled = advertisingTrackingEnabledDefault
    @available(iOS 14, *)
    static var mockAppTrackingTransparencyStatus = ATTrackingManager.AuthorizationStatus.notDetermined
    static var mockUserLanguageCode: String? = defaultUserLanguageCode
    
    override var deviceMake: String {
        get { return "MockMake" }
    }

    override var deviceModel: String {
        get { return "MockModel" }
    }

    override var deviceOS: String {
        get { return "MockOS" }
    }

    override var osVersion: String {
        get { return "1.2.3" }
    }
    
    override var identifierForVendor: String {
        get { return MockDeviceAccessManager.mockIdentifierForVendor }
    }
    
    override func appTrackingTransparencyStatus() -> UInt {
        if #available(iOS 14, *) {
            return MockDeviceAccessManager.mockAppTrackingTransparencyStatus.rawValue
        } else {
            return 0
        }
    }
    
    override var platformString: String {
        get { return "iPhone1,1" }
    }

    override var userLangaugeCode: String? {
        get { return MockDeviceAccessManager.mockUserLanguageCode }
    }

    override func advertisingIdentifier() -> String {
        if self.advertisingTrackingEnabled() {
            return MockDeviceAccessManager.mockAdvertisingIdentifier
        } else {
            return MockDeviceAccessManager.nullUUID
        }
    }
    
    override func advertisingTrackingEnabled() -> Bool {
        return MockDeviceAccessManager.mockAdvertisingTrackingEnabled
    }
    
    override func screenSize() -> CGSize {
        return CGSize(width: 100, height: 200)
    }

    class func reset() {
        self.mockAdvertisingTrackingEnabled = advertisingTrackingEnabledDefault
        self.mockUserLanguageCode = defaultUserLanguageCode
    }
}
