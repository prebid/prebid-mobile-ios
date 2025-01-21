//
//  SharedIdTests.swift
//  PrebidMobileTests
//
//  Created by James on 1/17/25.
//  Copyright © 2025 AppNexus. All rights reserved.
//

import XCTest
@testable import PrebidMobile

final class SharedIdTests: XCTestCase {
    
    var targeting: Targeting { .shared }

    override func setUp() {
        UtilitiesForTesting.resetTargeting(.shared)
    }

    override func tearDown() {
        UtilitiesForTesting.resetTargeting(.shared)
    }
    
    func setLocalStorageAccessAllowed(_ allowed: Bool) {
        // Set gdpr to true to make sure we are testing the purpose-1 consent
        UserDefaults.standard.set("true", forKey: UserConsentDataManager.shared.IABTCF_SubjectToGDPR)
        
        let purpose1 = allowed ? "1" : "0"
        UserDefaults.standard.set("\(purpose1)0000000", forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents)
        assert(targeting.isAllowedAccessDeviceData() == allowed)
    }
    
    func testUsesValueInLocalStorageIfAccessAllowed() {
        UserDefaults.standard.set("abc123", forKey: StorageUtils.PB_SharedIdKey)
        
        setLocalStorageAccessAllowed(true)
        
        XCTAssertEqual(targeting.sharedId.identifier, "abc123")
    }
    
    func testDoesNotUseValueInLocalStorageIfAccessNotAllowed() {
        UserDefaults.standard.set("abc123", forKey: StorageUtils.PB_SharedIdKey)
        
        setLocalStorageAccessAllowed(false)
        
        XCTAssertNotEqual(targeting.sharedId.identifier, "abc123")
    }
    
    func testGeneratedIdWrittenToLocalStorageIfAllowed() {
        setLocalStorageAccessAllowed(true)
        
        let identifier = targeting.sharedId.identifier
        XCTAssertEqual(StorageUtils.sharedId, identifier)
    }
    
    func testGeneratedIdWrittenNotToLocalStorageIfNotAllowed() {
        setLocalStorageAccessAllowed(false)
        
        let _ = targeting.sharedId.identifier // Generate an id
        XCTAssertNil(StorageUtils.sharedId)
    }
    
    func testReturnsTheSameIdentifierIfLocalStorageNotAllowed() {
        // Even if local storage is not allowed, we should persist an in-memory
        // identifier for the current app session
        setLocalStorageAccessAllowed(false)
        let originalIdentifier = targeting.sharedId.identifier
        
        XCTAssertEqual(targeting.sharedId.identifier, originalIdentifier)
    }
    
    func testReturnsTheSameIdentifierUntilReset() {
        let originalIdentifier = targeting.sharedId.identifier
        
        XCTAssertEqual(targeting.sharedId.identifier, originalIdentifier)
        
        targeting.resetSharedId()
        
        XCTAssertNotEqual(targeting.sharedId.identifier, originalIdentifier)
    }
    
    func testResettingClearsIdFromLocalStorage() {
        _ = targeting.sharedId // Generate an id
        XCTAssertNotNil(StorageUtils.sharedId)
        
        targeting.resetSharedId()
        XCTAssertNil(StorageUtils.sharedId)
    }
    
    func testSharedIdOnlySentWhenFeatureEnabled() {
        let sdkConfiguration = Prebid.mock
        
        let mockBundle = MockBundle()
        let mockDeviceAccessManager = MockDeviceAccessManager(rootViewController: nil)
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .authorized
        }
        let mockLocationManagerSuccessful = MockLocationManagerSuccessful.shared
        let mockCTTelephonyNetworkInfo = MockCTTelephonyNetworkInfo()
        let mockReachability = MockReachability.shared
        
        func constructRequestEids() -> [String : Any]? {
            let paramsDict = PBMParameterBuilderService.buildParamsDict(
                with: AdConfiguration(),
                bundle:mockBundle,
                pbmLocationManager: mockLocationManagerSuccessful,
                pbmDeviceAccessManager: mockDeviceAccessManager,
                ctTelephonyNetworkInfo: mockCTTelephonyNetworkInfo,
                reachability: mockReachability,
                sdkConfiguration: sdkConfiguration,
                sdkVersion: "MOCK_SDK_VERSION",
                targeting: targeting,
                extraParameterBuilders: nil
            )
            
            let strORTB = paramsDict[PBMParameterKeys.OPEN_RTB.rawValue]!
            let bidRequest = try! PBMORTBBidRequest.from(jsonString:strORTB)
            
            let eids = bidRequest.user.ext?["eids"] as? [[String : Any]]
            let sharedId = eids?.first { $0["source"] as? String == "pubcid.org" }
            return sharedId
        }
        
        
        targeting.sendSharedId = true
        XCTAssertEqual(constructRequestEids() as NSDictionary?, targeting.sharedId.toJSONDictionary() as NSDictionary)
        
        targeting.sendSharedId = false
        XCTAssertNil(constructRequestEids())
    }
}
