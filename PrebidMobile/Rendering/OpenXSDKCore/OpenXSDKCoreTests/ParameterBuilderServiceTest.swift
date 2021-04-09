//
//  ParameterBuilderServiceTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import AppTrackingTransparency
import XCTest
import CoreLocation

@testable import OpenXApolloSDK

class ParameterBuilderServiceTest : XCTestCase {

    var sdkVersion: String { return Bundle(for: OXABannerView.self).infoDictionary!["CFBundleShortVersionString"] as! String }
        
    func testBuildParamsDict() {
        let url = "https://openx.com"
        let publisherName = "Publisher"
    
        let adConfiguration = OXMAdConfiguration()
        
        let oxbTargeting = OXATargeting.withDisabledLock
        oxbTargeting.parameterDictionary.removeAllObjects()
        oxbTargeting.parameterDictionary["foo"] = "bar"
        oxbTargeting.userAge = 10
        oxbTargeting.coppa = 1
        oxbTargeting.userGender = .male
        oxbTargeting.buyerUID = "buyerUID"
        oxbTargeting.appStoreMarketURL = url
        oxbTargeting.keywords = "keyword1,keyword2"
        oxbTargeting.userCustomData = "customDataString"
        oxbTargeting.publisherName = publisherName
        
        let sdkConfiguration = OXASDKConfiguration()
        
        let mockBundle = MockBundle()
        let mockDeviceAccessManager = MockDeviceAccessManager(rootViewController: nil)
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .authorized
        }
        let mockLocationManagerSuccessful = MockLocationManagerSuccessful.singleton
        let mockCTTelephonyNetworkInfo = MockCTTelephonyNetworkInfo()
        let mockReachability = MockReachability.forInternetConnection()!

        let mockUserDefaults = MockUserDefaults()
        let oxmUserConsentManager = OXMUserConsentDataManager(userDefaults: mockUserDefaults)

        let paramsDict = OXMParameterBuilderService.buildParamsDict(
            with: adConfiguration,
            bundle:mockBundle,
            oxmLocationManager: mockLocationManagerSuccessful,
            oxmDeviceAccessManager: mockDeviceAccessManager,
            ctTelephonyNetworkInfo: mockCTTelephonyNetworkInfo,
            reachability: mockReachability,
            sdkConfiguration: sdkConfiguration,
            sdkVersion: "MOCK_SDK_VERSION",
            oxmUserConsentManager: oxmUserConsentManager,
            targeting: oxbTargeting,
            extraParameterBuilders: nil
        )
        
        //Create a new OXMORTBBidRequest based off of the json string in the params dict
        guard let strORTB = paramsDict[OXMParameterKeys.OPEN_RTB.rawValue] else {
            XCTFail("No ORTB string in parameter keys")
            return
        }
        
        let bidRequest: OXMORTBBidRequest
        do {
            bidRequest = try OXMORTBBidRequest.from(jsonString:strORTB)
        } catch {
            XCTFail("\(error)")
            return
        }

        //Verify OXMBasicParameterBuilder
        OXMAssertEq(bidRequest.imp.count, 1)
        OXMAssertEq(bidRequest.imp.first?.displaymanager, "openx")
        OXMAssertEq(bidRequest.imp.first?.displaymanagerver, "MOCK_SDK_VERSION")
        OXMAssertEq(bidRequest.imp.first?.secure, 1)

        //Verify GeoLocationParameterBuilder
        OXMAssertEq(bidRequest.device.geo.type, 1)
        OXMAssertEq(bidRequest.device.geo.lat!.doubleValue, mockLocationManagerSuccessful.coordinates.latitude)
        OXMAssertEq(bidRequest.device.geo.lon!.doubleValue, mockLocationManagerSuccessful.coordinates.longitude)

        //Verify OXMAppInfoParameterBuilder
        OXMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
        OXMAssertEq(bidRequest.app.bundle, mockBundle.mockBundleIdentifier)
        OXMAssertEq(bidRequest.app.publisher?.name, publisherName)

        //Verify DeviceInfoParameterBuilder
        OXMAssertEq(bidRequest.device.w!.intValue, Int(mockDeviceAccessManager.screenSize().width))
        OXMAssertEq(bidRequest.device.h!.intValue, Int(mockDeviceAccessManager.screenSize().height))
        OXMAssertEq(bidRequest.device.ifa, MockDeviceAccessManager.mockAdvertisingIdentifier)
        OXMAssertEq(bidRequest.device.lmt, 0)


        //Verify NetworkParameterBuilder
        let expectedMccmnc = "\(mockCTTelephonyNetworkInfo.subscriberCellularProvider!.mobileCountryCode!)-\(mockCTTelephonyNetworkInfo.subscriberCellularProvider!.mobileNetworkCode!)"
        OXMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
        OXMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
        OXMAssertEq(bidRequest.device.carrier, MockCTCarrier.mockCarrierName)
        OXMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)

        //Verify SupportedProtocolsParameterBuilder
        OXMAssertEq(bidRequest.imp.count, 1)
        OXMAssertEq(bidRequest.imp.first?.banner?.api, [3,5,6,7])

        //Verify ORTBParameterBuilder
        guard #available(iOS 11.0, *) else {
            OXMLog.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }

        let yob = OXAAgeUtils.yob(forAge:oxbTargeting.userAge)
        let omidVersion = OXMFunctions.omidVersion()
        var deviceExt = ""
        if #available(iOS 14.0, *) {
            deviceExt = "\"ext\":{\"atts\":3},"
        }
        
        let expectedOrtb = """
        {\"app\":{\"bundle\":\"Mock.Bundle.Identifier\",\"name\":\"MockBundleDisplayName\",\"publisher\":{\"name\":\"Publisher\"},\"storeurl\":\"https:\\/\\/openx.com\"},\"device\":{\"carrier\":\"MOCK_CARRIER_NAME\",\"connectiontype\":2,\(deviceExt)\"geo\":{\"lat\":34.149335,\"lon\":-118.1328249,\"type\":1},\"h\":200,\"ifa\":\"abc123\",\"language\":\"ml\",\"lmt\":0,\"make\":\"MockMake\",\"mccmnc\":\"123-456\",\"model\":\"MockModel\",\"os\":\"MockOS\",\"osv\":\"1.2.3\",\"w\":100},\"imp\":[{\"banner\":{\"api\":[3,5,6,7]},\"clickbrowser\":0,\"displaymanager\":\"openx\",\"displaymanagerver\":\"MOCK_SDK_VERSION\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":1}],\"regs\":{\"coppa\":1,\"ext\":{\"gdpr\":0}},\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"user\":{\"buyeruid\":\"buyerUID\",\"customdata\":\"customDataString\",\"ext\":{\"consent\":\"consentstring\"},\"gender\":\"M\",\"keywords\":\"keyword1,keyword2\",\"yob\":\(yob)}}
        """
        OXMAssertEq(strORTB, expectedOrtb)
    }
}
