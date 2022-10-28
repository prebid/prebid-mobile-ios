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
import XCTest

import GoogleMobileAds
import PrebidMobile
@testable import PrebidMobileAdMobAdapters

class AdMobMediationUtilsTest: XCTestCase {
    func testCorrectBannerAdObjectSetUp() {
        let gadRequest = GADRequest()
        let testInitialKeywords = ["existingKey:existingValue"]
        
        gadRequest.keywords = testInitialKeywords
        let mediationDelegate = AdMobMediationBannerUtils(gadRequest: gadRequest, bannerView: GADBannerView())
        let mediationValues: [String: Any] = [PBMMediationConfigIdKey: "testConfigId",
                                         PBMMediationTargetingInfoKey: ["test":"test"],
                                             PBMMediationAdUnitBidKey: "testExtrasObjectKey"]
        
        guard mediationDelegate.setUpAdObject(with: mediationValues) else {
            XCTFail()
            return
        }
        
        testInitialKeywords.forEach { keyword in
            if !mediationDelegate.gadRequest.keywords!.contains(where: { value in
                return value == keyword
            }) {
                XCTFail()
            }
        }
    }
    
    func testCorrectInterstitialAdObjectSetUp() {
        let gadRequest = GADRequest()
        let testInitialKeywords = ["existingKey:existingValue"]
        
        gadRequest.keywords = testInitialKeywords
        let mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: gadRequest)
        let mediationValues: [String: Any] = [PBMMediationConfigIdKey: "testConfigId",
                                         PBMMediationTargetingInfoKey: ["test":"test"],
                                             PBMMediationAdUnitBidKey: "testExtrasObjectKey"]
        guard mediationDelegate.setUpAdObject(with: mediationValues) else {
            XCTFail()
            return
        }
        
        testInitialKeywords.forEach { keyword in
            if !mediationDelegate.gadRequest.keywords!.contains(where: { value in
                return value == keyword
            }) {
                XCTFail()
            }
        }
    }
    
    func testCorrectRewardedAdObjectSetUp() {
        let gadRequest = GADRequest()
        let testInitialKeywords = ["existingKey:existingValue"]
        
        gadRequest.keywords = testInitialKeywords
        let mediationDelegate = AdMobMediationRewardedUtils(gadRequest: gadRequest)
        let mediationValues: [String: Any] = [PBMMediationConfigIdKey: "testConfigId",
                                         PBMMediationTargetingInfoKey: ["test":"test"],
                                             PBMMediationAdUnitBidKey: "testExtrasObjectKey"]
        
        guard mediationDelegate.setUpAdObject(with: mediationValues) else {
            XCTFail()
            return
        }
        
        testInitialKeywords.forEach { keyword in
            if !mediationDelegate.gadRequest.keywords!.contains(where: { value in
                return value == keyword
            }) {
                XCTFail()
            }
        }
    }
    
    func testCorrectNativeAdObjectSetUp() {
        let gadRequest = GADRequest()
        let testInitialKeywords = ["existingKey:existingValue"]
        
        gadRequest.keywords = testInitialKeywords
        let mediationDelegate = AdMobMediationNativeUtils(gadRequest: gadRequest)
        let mediationValues: [String: Any] = [PBMMediationConfigIdKey: "testConfigId",
                                         PBMMediationTargetingInfoKey: ["test": "test"],
                                      PBMMediationAdNativeResponseKey: "testExtrasObjectKey"]
        
        guard mediationDelegate.setUpAdObject(with: mediationValues) else {
            XCTFail()
            return
        }
        
        testInitialKeywords.forEach { keyword in
            if !mediationDelegate.gadRequest.keywords!.contains(where: { value in
                return value == keyword
            }) {
                XCTFail()
            }
        }
    }
}
