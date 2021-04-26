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

@testable import PrebidMobileRendering

class ParameterBuilderServiceTest : XCTestCase {

    var sdkVersion: String { return Bundle(for: PBMBannerView.self).infoDictionary!["CFBundleShortVersionString"] as! String }
        
    func testBuildParamsDict() {
        let url = "https://openx.com"
        let publisherName = "Publisher"
    
        let adConfiguration = PBMAdConfiguration()
        
        let oxbTargeting = PBMTargeting.withDisabledLock
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
        
        let sdkConfiguration = PBMSDKConfiguration()
        
        let mockBundle = MockBundle()
        let mockDeviceAccessManager = MockDeviceAccessManager(rootViewController: nil)
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .authorized
        }
        let mockLocationManagerSuccessful = MockLocationManagerSuccessful.singleton
        let mockCTTelephonyNetworkInfo = MockCTTelephonyNetworkInfo()
        let mockReachability = MockReachability.forInternetConnection()!

        let mockUserDefaults = MockUserDefaults()
        let pbmUserConsentManager = PBMUserConsentDataManager(userDefaults: mockUserDefaults)

        let paramsDict = PBMParameterBuilderService.buildParamsDict(
            with: adConfiguration,
            bundle:mockBundle,
            pbmLocationManager: mockLocationManagerSuccessful,
            pbmDeviceAccessManager: mockDeviceAccessManager,
            ctTelephonyNetworkInfo: mockCTTelephonyNetworkInfo,
            reachability: mockReachability,
            sdkConfiguration: sdkConfiguration,
            sdkVersion: "MOCK_SDK_VERSION",
            pbmUserConsentManager: pbmUserConsentManager,
            targeting: oxbTargeting,
            extraParameterBuilders: nil
        )
        
        //Create a new PBMORTBBidRequest based off of the json string in the params dict
        guard let strORTB = paramsDict[PBMParameterKeys.OPEN_RTB.rawValue] else {
            XCTFail("No ORTB string in parameter keys")
            return
        }
        
        let bidRequest: PBMORTBBidRequest
        do {
            bidRequest = try PBMORTBBidRequest.from(jsonString:strORTB)
        } catch {
            XCTFail("\(error)")
            return
        }

        //Verify PBMBasicParameterBuilder
        PBMAssertEq(bidRequest.imp.count, 1)
        PBMAssertEq(bidRequest.imp.first?.displaymanager, "prebid")
        PBMAssertEq(bidRequest.imp.first?.displaymanagerver, "MOCK_SDK_VERSION")
        PBMAssertEq(bidRequest.imp.first?.secure, 1)

        //Verify GeoLocationParameterBuilder
        PBMAssertEq(bidRequest.device.geo.type, 1)
        PBMAssertEq(bidRequest.device.geo.lat!.doubleValue, mockLocationManagerSuccessful.coordinates.latitude)
        PBMAssertEq(bidRequest.device.geo.lon!.doubleValue, mockLocationManagerSuccessful.coordinates.longitude)

        //Verify PBMAppInfoParameterBuilder
        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
        PBMAssertEq(bidRequest.app.bundle, mockBundle.mockBundleIdentifier)
        PBMAssertEq(bidRequest.app.publisher?.name, publisherName)

        //Verify DeviceInfoParameterBuilder
        PBMAssertEq(bidRequest.device.w!.intValue, Int(mockDeviceAccessManager.screenSize().width))
        PBMAssertEq(bidRequest.device.h!.intValue, Int(mockDeviceAccessManager.screenSize().height))
        PBMAssertEq(bidRequest.device.ifa, MockDeviceAccessManager.mockAdvertisingIdentifier)
        PBMAssertEq(bidRequest.device.lmt, 0)


        //Verify NetworkParameterBuilder
        let expectedMccmnc = "\(mockCTTelephonyNetworkInfo.subscriberCellularProvider!.mobileCountryCode!)-\(mockCTTelephonyNetworkInfo.subscriberCellularProvider!.mobileNetworkCode!)"
        PBMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
        PBMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
        PBMAssertEq(bidRequest.device.carrier, MockCTCarrier.mockCarrierName)
        PBMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)

        //Verify SupportedProtocolsParameterBuilder
        PBMAssertEq(bidRequest.imp.count, 1)
        PBMAssertEq(bidRequest.imp.first?.banner?.api, [3,5,6,7])

        //Verify ORTBParameterBuilder
        guard #available(iOS 11.0, *) else {
            PBMLog.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }

        let yob = PBMAgeUtils.yob(forAge:oxbTargeting.userAge)
        let omidVersion = PBMFunctions.omidVersion()
        var deviceExt = ""
        if #available(iOS 14.0, *) {
            deviceExt = "\"ext\":{\"atts\":3},"
        }
        
        let expectedOrtb = """
        {\"app\":{\"bundle\":\"Mock.Bundle.Identifier\",\"name\":\"MockBundleDisplayName\",\"publisher\":{\"name\":\"Publisher\"},\"storeurl\":\"https:\\/\\/openx.com\"},\"device\":{\"carrier\":\"MOCK_CARRIER_NAME\",\"connectiontype\":2,\(deviceExt)\"geo\":{\"lat\":34.149335,\"lon\":-118.1328249,\"type\":1},\"h\":200,\"ifa\":\"abc123\",\"language\":\"ml\",\"lmt\":0,\"make\":\"MockMake\",\"mccmnc\":\"123-456\",\"model\":\"MockModel\",\"os\":\"MockOS\",\"osv\":\"1.2.3\",\"w\":100},\"imp\":[{\"banner\":{\"api\":[3,5,6,7]},\"clickbrowser\":0,\"displaymanager\":\"prebid\",\"displaymanagerver\":\"MOCK_SDK_VERSION\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":1}],\"regs\":{\"coppa\":1,\"ext\":{\"gdpr\":0}},\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"user\":{\"buyeruid\":\"buyerUID\",\"customdata\":\"customDataString\",\"ext\":{\"consent\":\"consentstring\"},\"gender\":\"M\",\"keywords\":\"keyword1,keyword2\",\"yob\":\(yob)}}
        """
        PBMAssertEq(strORTB, expectedOrtb)
    }
}
