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
import AppTrackingTransparency
import XCTest
import CoreLocation

@testable import PrebidMobile

class ParameterBuilderServiceTest : XCTestCase {
    
    override func setUp() {
        UtilitiesForTesting.resetTargeting(.shared)
        Prebid.shared.shareGeoLocation = true
    }
    
    override func tearDown() {
        UtilitiesForTesting.resetTargeting(.shared)
    }
    
    var sdkVersion: String { return Bundle(for: BannerView.self).infoDictionary!["CFBundleShortVersionString"] as! String }
    
    func testBuildParamsDict() {
        let url = "https://openx.com"
        let publisherName = "Publisher"
        
        let adConfiguration = AdConfiguration()
        
        let targeting = Targeting.shared
        targeting.parameterDictionary.removeAll()
        targeting.parameterDictionary["foo"] = "bar"
        targeting.coppa = 1
        targeting.userGender = .male
        targeting.buyerUID = "buyerUID"
        targeting.storeURL = url
        targeting.userCustomData = "customDataString"
        targeting.publisherName = publisherName
        targeting.addUserKeyword("keyword1,keyword2")
        targeting.addAppKeyword("appKeyword1,appKeyword2")
        targeting.userID = "userID"
        
        let sdkConfiguration = Prebid.mock
        
        let mockBundle = MockBundle()
        let mockDeviceAccessManager = MockDeviceAccessManager(rootViewController: nil)
        if #available(iOS 14, *) {
            MockDeviceAccessManager.mockAppTrackingTransparencyStatus = .authorized
        }
        let mockLocationManagerSuccessful = MockLocationManagerSuccessful.shared
        let mockCTTelephonyNetworkInfo = MockCTTelephonyNetworkInfo()
        let mockReachability = MockReachability.shared
        
        UserConsentDataManager.shared.gdprConsentString = "consentstring"
        UserConsentDataManager.shared.subjectToGDPR = false
        
        let paramsDict = PBMParameterBuilderService.buildParamsDict(
            with: adConfiguration,
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
        PBMAssertEq(bidRequest.imp.first?.displaymanager, "prebid-mobile")
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
        PBMAssertEq(bidRequest.device.hwv, mockDeviceAccessManager.platformString)
        
        
        if #available(iOS 16, *) {
            // do nothing - CTCarrier is deprecated
        } else {
            //Verify NetworkParameterBuilder
            let expectedMccmnc = "\(mockCTTelephonyNetworkInfo.subscriberCellularProvider!.mobileCountryCode!)-\(mockCTTelephonyNetworkInfo.subscriberCellularProvider!.mobileNetworkCode!)"
            PBMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
            PBMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
            PBMAssertEq(bidRequest.device.carrier, MockCTCarrier.mockCarrierName)
            PBMAssertEq(bidRequest.device.mccmnc, expectedMccmnc)
            
            //Verify SupportedProtocolsParameterBuilder
            PBMAssertEq(bidRequest.imp.count, 1)
            PBMAssertEq(bidRequest.imp.first?.banner?.api, nil)
        }
        
        //Verify ORTBParameterBuilder
        guard #available(iOS 11.0, *) else {
            Log.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }
        
        var deviceExt = ""
        if #available(iOS 14.0, *) {
            deviceExt = "\"ext\":{\"atts\":3},"
        }
        
        var carrier = ""
        var mccmnc = ""
        
        if #available(iOS 16, *) {
            // do nothing - CTCarrier is deprecated with no replacement
        }
        else {
            carrier = "\"carrier\":\"MOCK_CARRIER_NAME\","
            mccmnc = "\"mccmnc\":\"123-456\","
        }
        
        let expectedOrtb = """
        {\"app\":{\"bundle\":\"Mock.Bundle.Identifier\",\"keywords\":\"appKeyword1,appKeyword2\",\"name\":\"MockBundleDisplayName\",\"publisher\":{\"name\":\"Publisher\"},\"storeurl\":\"https:\\/\\/openx.com\"},\"device\":{\(carrier)\"connectiontype\":2,\(deviceExt)\"geo\":{\"lat\":34.149335,\"lon\":-118.1328249,\"type\":1},\"h\":200,\"hwv\":\"iPhone1,1\",\"ifa\":\"abc123\",\"language\":\"ml\",\"lmt\":0,\"make\":\"MockMake\",\(mccmnc)\"model\":\"MockModel\",\"os\":\"MockOS\",\"osv\":\"1.2.3\",\"w\":100},\"imp\":[{\"clickbrowser\":1,\"displaymanager\":\"prebid-mobile\",\"displaymanagerver\":\"MOCK_SDK_VERSION\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":1}],\"regs\":{\"coppa\":1,\"ext\":{\"gdpr\":0}},\"user\":{\"buyeruid\":\"buyerUID\",\"customdata\":\"customDataString\",\"ext\":{\"consent\":\"consentstring\"},\"gender\":\"M\",\"id\":\"userID\",\"keywords\":\"keyword1,keyword2\"}}
        """
        PBMAssertEq(strORTB, expectedOrtb)
    }
}
