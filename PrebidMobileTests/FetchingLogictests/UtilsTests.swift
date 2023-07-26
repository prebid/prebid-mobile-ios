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

import XCTest
import TestUtils
@testable import PrebidMobile

@objcMembers class DFPORequest: NSObject {
    var name: String!
    private(set) var p_customKeywords: [String: AnyObject]

    var customTargeting: [String: AnyObject] {
            return p_customKeywords
    }

    override init() {
        self.p_customKeywords = [String: AnyObject]()
    }
}

@objcMembers class DFPNRequest: NSObject {
    var name: String!
    private(set) var p_customKeywords: [String: AnyObject]

    var customTargeting: [String: AnyObject] {

        get {
            return p_customKeywords
        }

        set {
            self.p_customKeywords = newValue
        }

    }

    override init() {
        self.p_customKeywords = [String: AnyObject]()
    }
}

@objcMembers class MPAdView: NSObject {
    var name: String!
    private(set) var p_customKeywords: String = ""

    var keywords: String {

        get {
            return p_customKeywords
        }

        set {
            self.p_customKeywords = newValue
        }

    }
}

@objcMembers class InvalidMPAdView: NSObject {
    var name: String!
    private(set) var p_customKeywords: String = ""

    var keywords: String {

        get {
            return p_customKeywords
        }

        set {
            self.p_customKeywords = newValue
        }

    }
}

@objcMembers class MPNativeAdRequest: NSObject {
    
    var name: String!
    private(set) var p_customTargeting: MPNativeAdRequestTargeting

    var targeting: MPNativeAdRequestTargeting {

        get {
            return p_customTargeting
        }

        set {
            self.p_customTargeting = newValue
        }

    }

    override init() {
        self.p_customTargeting = MPNativeAdRequestTargeting()
    }
}

@objcMembers class MPNativeAdRequestTargeting: NSObject {
    var name: String!
    private(set) var p_customKeywords: String = ""

    var keywords: String {

        get {
            return p_customKeywords
        }

        set {
            self.p_customKeywords = newValue
        }

    }
}

@objcMembers class MPNativeAd: NSObject {
    
    var name: String!
    var p_customProperties: [String:AnyObject]

    var properties:  [String:AnyObject] {

        get {
            return p_customProperties
        }

        set {
            self.p_customProperties = newValue
        }

    }

    override init() {
        self.p_customProperties = [String:AnyObject]()
        self.p_customProperties["isPrebid"] = 1 as AnyObject
    }
}

class GADNativeCustomTemplateAd: UserDefaults {}

class UtilsTests: XCTestCase, NativeAdDelegate {

    var dfpAdObject: DFPNRequest?
    var invalidDfpAdObject: DFPORequest?
    var mopubObject: MPAdView?
    var invalidMopubObject: InvalidMPAdView?
    var mopubNativeObject: MPNativeAdRequest?
    var prebidNativeAdLoadedExpectation: XCTestExpectation?
    var prebidNativeAdNotFoundExpectation: XCTestExpectation?
    var prebidNativeAdNotValidExpectation: XCTestExpectation?
    var timeoutForImpbusRequest: TimeInterval = 0.0

    private var logToFile: LogToFileLock?

    override func setUp() {
        dfpAdObject = DFPNRequest()
        mopubObject = MPAdView()
        mopubNativeObject = MPNativeAdRequest()
        timeoutForImpbusRequest = 10.0
    }

    override func tearDown() {
        logToFile = nil
        prebidNativeAdLoadedExpectation = nil
        prebidNativeAdNotFoundExpectation = nil
        prebidNativeAdNotValidExpectation = nil
    }
    
    func testConvertDictToMoPubKeywords() {
        
        var dictionary = [String: String]()
        dictionary["key1"] = "value1"
        dictionary["key2"] = "value2"
        
        let result = Utils.shared.convertDictToMoPubKeywords(dict: dictionary)
        
        XCTAssertTrue(
            result == "key1:value1,key2:value2"
                || result == "key2:value2,key1:value1",
            result
        )
        
    }
    
    func testConvertDictToMoPubKeywordsEmpty() {
        
        let dictionary = [String: String]()
        
        let result = Utils.shared.convertDictToMoPubKeywords(dict: dictionary)
        
        XCTAssertEqual("", result)
    }

    func testAttachDFPKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app",
                                              "hb_bidder_appnexus": "appnexus",
                                              "hb_size_appnexus": "300x250",
                                              "hb_pb_appnexus": "0.50",
                                              "hb_env_appnexus": "mobile-app",
                                              "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
                                              "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
                                              "hb_pb": "0.50",
                                              "hb_bidder": "appnexus",
                                              "hb_size": "300x250",
                                              "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]

        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)

        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(12, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_local"] as! String, "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder"] as! String, "appnexus")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id"] as! String, "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder_appnexus"] as! String, "appnexus")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size_appnexus"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb_appnexus"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_appnexus"] as! String, "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env_appnexus"] as! String, "mobile-app")
        let prebidKeywords2: [String: String] = ["hb_env": "mobile-app",
                                               "hb_bidder_rubicon": "rubicon",
                                               "hb_size_rubicon": "300x250",
                                               "hb_pb_rubicon": "0.50",
                                               "hb_env_rubicon": "mobile-app",
                                               "hb_cache_id": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_cache_id_rubicon": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_pb": "0.50",
                                               "hb_bidder": "rubicon",
                                               "hb_size": "300x250",
                                               "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]
        let bidResponse2 = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords2)
        utils.removeHBKeywords(adObject: dfpAdObject!)
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse2)
        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(12, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_local"] as! String, "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder"] as! String, "rubicon")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id"] as! String, "ffffffff-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder_rubicon"] as! String, "rubicon")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size_rubicon"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb_rubicon"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_rubicon"] as! String, "ffffffff-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env_rubicon"] as! String, "mobile-app")
        XCTAssertNil(dfpAdObject!.customTargeting["hb_bidder_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_size_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_pb_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_cache_id_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_env_appnexus"])
    }

    func testRemoveDFPKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app",
                                              "hb_bidder_appnexus": "appnexus",
                                              "hb_size_appnexus": "300x250",
                                              "hb_pb_appnexus": "0.50",
                                              "hb_env_appnexus": "mobile-app",
                                              "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
                                              "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
                                              "hb_pb": "0.50",
                                              "hb_bidder": "appnexus",
                                              "hb_size": "300x250",
                                              "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]

        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(12, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_local"] as! String, "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder"] as! String, "appnexus")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id"] as! String, "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder_appnexus"] as! String, "appnexus")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size_appnexus"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb_appnexus"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_appnexus"] as! String, "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env_appnexus"] as! String, "mobile-app")

        utils.removeHBKeywords(adObject: dfpAdObject!)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")
        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(1, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id_local"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_size"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_bidder"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_env"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_pb"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_bidder_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_size_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_pb_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_env_appnexus"])

        let prebidKeywords2: [String: String] = ["hb_env": "mobile-app",
                                               "hb_bidder_rubicon": "rubicon",
                                               "hb_size_rubicon": "300x250",
                                               "hb_pb_rubicon": "0.50",
                                               "hb_env_rubicon": "mobile-app",
                                               "hb_cache_id": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_cache_id_rubicon": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_pb": "0.50",
                                               "hb_bidder": "rubicon",
                                               "hb_size": "300x250",
                                               "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]
        let bidResponse2 = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords2)
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse2)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")
        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(12, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_local"] as! String, "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder"] as! String, "rubicon")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id"] as! String, "ffffffff-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_bidder_rubicon"] as! String, "rubicon")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_size_rubicon"] as! String, "300x250")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_pb_rubicon"] as! String, "0.50")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_cache_id_rubicon"] as! String, "ffffffff-5ee2-4d74-ae85-e4b602b7f88d")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env_rubicon"] as! String, "mobile-app")
        XCTAssertNil(dfpAdObject!.customTargeting["hb_bidder_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_size_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_pb_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_cache_id_appnexus"])
        XCTAssertNil(dfpAdObject!.customTargeting["hb_env_appnexus"])

        utils.removeHBKeywords(adObject: dfpAdObject!)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")
        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(1, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id_local"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_size"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_bidder"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_env"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_pb"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_bidder_rubicon"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_size_rubicon"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_pb_rubicon"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id_rubicon"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_env_rubicon"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_bidder_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_size_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_pb_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_cache_id_appnexus"])
        XCTAssertNil(dfpAdObject?.customTargeting["hb_env_appnexus"])
    }

    func testDFPKeywordsAbsent() {
        let utils: Utils = Utils.shared
        let prebidKeywords: [String: String] = [:]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]
        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")
        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(1, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
    }

    func testDFPInvalidObject() {
        let utils: Utils = Utils.shared
        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250", "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]
        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)
        utils.validateAndAttachKeywords(adObject: invalidDfpAdObject as AnyObject, bidResponse: bidResponse)
        XCTAssertNil(invalidDfpAdObject?.customTargeting)

    }

    func testExistingAndRemovingPrebidKeywords() {
        let utils: Utils = Utils.shared

        var prebidKeywords: [String: String] = ["hb_env": "mobile-app"]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]

        var bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)

        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(2, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")

        prebidKeywords = ["app": "prebid"]
        bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)

        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)
        XCTAssertEqual(3, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")
        XCTAssertEqual(dfpAdObject!.customTargeting["app"] as! String, "prebid")

        utils.removeHBKeywords(adObject: dfpAdObject!)
        XCTAssertEqual(2, dfpAdObject?.customTargeting.count)
        XCTAssertNil(dfpAdObject?.customTargeting["hb_env"])
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["app"] as! String, "prebid")
    }

    func testAttachMoPubKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250"]

        let bidResponse = BidResponse(adUnitId: "test1", targetingInfo: prebidKeywords)
        mopubObject?.keywords = "test_key:test_value"
        utils.validateAndAttachKeywords(adObject: mopubObject as AnyObject, bidResponse: bidResponse)

        var keywords: String?
        var keywordsArray: [String] = []

        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        keywords = self.mopubObject?.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(11, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_appnexus:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size_appnexus:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_appnexus:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_appnexus:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_appnexus:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))

        let prebidKeywords2: [String: String] = ["hb_env": "mobile-app",
                                               "hb_bidder_rubicon": "rubicon",
                                               "hb_size_rubicon": "300x250",
                                               "hb_pb_rubicon": "0.50",
                                               "hb_env_rubicon": "mobile-app",
                                               "hb_cache_id": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_cache_id_rubicon": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_pb": "0.50",
                                               "hb_bidder": "rubicon",
                                               "hb_size": "300x250"]

        let bidResponse2 = BidResponse(adUnitId: "test2", targetingInfo: prebidKeywords2)
        utils.removeHBKeywords(adObject: self.mopubObject!)
        utils.validateAndAttachKeywords(adObject: self.mopubObject as AnyObject, bidResponse: bidResponse2)

        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)

        keywords = self.mopubObject?.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(11, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_rubicon:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size_rubicon:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_rubicon:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_rubicon:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_rubicon:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))

    }

    func testRemoveMoPubKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250"]

        let bidResponse = BidResponse(adUnitId: "test1", targetingInfo: prebidKeywords)
        mopubObject?.keywords = "test_key:test_value"
        utils.validateAndAttachKeywords(adObject: mopubObject as AnyObject, bidResponse: bidResponse)

        var keywords: String?
        var keywordsArray: [String] = []

        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        keywords = self.mopubObject?.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(11, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_appnexus:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size_appnexus:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_appnexus:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_appnexus:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_appnexus:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))

        utils.removeHBKeywords(adObject: self.mopubObject!)

        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        keywords = self.mopubObject?.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(1, keywordsArray.count)
        XCTAssertFalse(keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder_appnexus:appnexus"))
        XCTAssertFalse(keywordsArray.contains("hb_size_appnexus:300x250"))
        XCTAssertFalse(keywordsArray.contains("hb_pb_appnexus:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_env_appnexus:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id_appnexus:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_pb:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder:appnexus"))
        XCTAssertFalse(keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue(keywordsArray.contains("test_key:test_value"))

        let prebidKeywords2: [String: String] = ["hb_env": "mobile-app",
                                               "hb_bidder_rubicon": "rubicon",
                                               "hb_size_rubicon": "300x250",
                                               "hb_pb_rubicon": "0.50",
                                               "hb_env_rubicon": "mobile-app",
                                               "hb_cache_id": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_cache_id_rubicon": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_pb": "0.50",
                                               "hb_bidder": "rubicon",
                                               "hb_size": "300x250"]
        let bidResponse2 = BidResponse(adUnitId: "test2", targetingInfo: prebidKeywords2)
        utils.validateAndAttachKeywords(adObject: self.mopubObject as AnyObject, bidResponse: bidResponse2)

        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        keywords = self.mopubObject?.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(11, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_rubicon:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size_rubicon:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_rubicon:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_rubicon:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_rubicon:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))
        
        utils.removeHBKeywords(adObject: self.mopubObject!)
        
        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        keywords = self.mopubObject?.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(1, keywordsArray.count)
        XCTAssertFalse(keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder_rubicon:rubicon"))
        XCTAssertFalse(keywordsArray.contains("hb_size_rubicon:300x250"))
        XCTAssertFalse(keywordsArray.contains("hb_pb_rubicon:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_env_rubicon:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id_rubicon:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_pb:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder:rubicon"))
        XCTAssertFalse(keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue(keywordsArray.contains("test_key:test_value"))
        
    }

    func testMoPubKeywordsAbsent() {
        let utils: Utils = Utils.shared
        let prebidKeywords: [String: String] = [:]
        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)
        mopubObject?.keywords = "test_key:test_value"
        utils.validateAndAttachKeywords(adObject: mopubObject as AnyObject, bidResponse: bidResponse)
        DispatchQueue.main.async {
        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        let keywords = self.mopubObject?.keywords
        let keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(1, keywordsArray.count)
        XCTAssertTrue(keywordsArray.contains("test_key:test_value"))
        }
    }

    func testMoPubInvalidObject() {
        let utils: Utils = Utils.shared
        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250"]
        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)
        invalidMopubObject?.keywords = "test_key:test_value"
        utils.validateAndAttachKeywords(adObject: invalidMopubObject as AnyObject, bidResponse: bidResponse)
        DispatchQueue.main.async {
            XCTAssertNil(self.invalidMopubObject?.keywords)
        }
    }
    
    func testConstructAdTagURLForIMAWithPrebidKeys() {
        do {
        let utils: IMAUtils = IMAUtils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app",
                                              "hb_bidder_appnexus": "appnexus",
                                              "hb_size_appnexus": "300x250",
                                              "hb_pb_appnexus": "0.50",
                                              "hb_env_appnexus": "mobile-app",
                                              "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
                                              "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d",
                                              "hb_pb": "0.50",
                                              "hb_bidder": "appnexus",
                                              "hb_size": "300x250"]
        let bidResponse = BidResponse(adUnitId: "test", targetingInfo: prebidKeywords)
        
        
        XCTAssertThrowsError(try utils.generateInstreamUriForGAM(adUnitID: "/19968336/Punnaghai_Instream_Video1", adSlotSizes: [] ,customKeywords: bidResponse.targetingInfo))
            
        let adTagUrl = try utils.generateInstreamUriForGAM(adUnitID: "/19968336/Punnaghai_Instream_Video1", adSlotSizes: [.Size400x300] ,customKeywords: bidResponse.targetingInfo)
        
        let splitUrl = adTagUrl.components(separatedBy: "?")
        
        let rightUrl:String = String(splitUrl[1])
        
        let queryString:[String] = rightUrl.components(separatedBy: "&")
        
        let filtered = queryString.filter { $0.contains("cust_params") }
        XCTAssertNotNil(filtered)
        
        var newString:String = filtered[0] as String
        
        newString = newString.replacingOccurrences(of: "cust_params=", with: "")

        newString = newString.removingPercentEncoding!

        let extractedKeywords:[String] = newString.components(separatedBy: "&")

        for keyString in extractedKeywords {
            let keywords:[String] = keyString.components(separatedBy: "=")
            let key:String = keywords[0]
            let value:String = keywords[1]
            XCTAssertTrue((prebidKeywords[key] != nil),value)

        }
        } catch {
            
        }
        
    }
    
    func testAttachMoPubNativeKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
                                                    "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250", "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]

        let bidResponse = BidResponse(adUnitId: "test1", targetingInfo: prebidKeywords)
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeAdRequestTargeting.keywords = "test_key:test_value"
        mopubNativeObject?.targeting = mopubNativeAdRequestTargeting
        utils.validateAndAttachKeywords(adObject: mopubNativeObject as AnyObject, bidResponse: bidResponse)

        var keywords: String?
        var keywordsArray: [String] = []

        XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
        XCTAssertNotNil(self.mopubNativeObject?.targeting)
        
        XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
        XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)
        
        keywords = self.mopubNativeObject?.targeting.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(12, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_local:Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"))
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_appnexus:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size_appnexus:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_appnexus:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_appnexus:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_appnexus:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))

        let prebidKeywords2: [String: String] = ["hb_env": "mobile-app",
                                               "hb_bidder_rubicon": "rubicon",
                                               "hb_size_rubicon": "300x250",
                                               "hb_pb_rubicon": "0.50",
                                               "hb_env_rubicon": "mobile-app",
                                               "hb_cache_id": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_cache_id_rubicon": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_pb": "0.50",
                                               "hb_bidder": "rubicon",
                                               "hb_size": "300x250", "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]

        let bidResponse2 = BidResponse(adUnitId: "test2", targetingInfo: prebidKeywords2)
        utils.removeHBKeywords(adObject: self.mopubNativeObject!)
        utils.validateAndAttachKeywords(adObject: self.mopubNativeObject as AnyObject, bidResponse: bidResponse2)

        XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
        XCTAssertNotNil(self.mopubNativeObject?.targeting)
        
        XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
        XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)

        keywords = self.mopubNativeObject?.targeting.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(12, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_local:Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"))
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_rubicon:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size_rubicon:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_rubicon:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_rubicon:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_rubicon:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))

    }
    
    func testRemoveMoPubNativeKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250", "hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]

        let bidResponse = BidResponse(adUnitId: "test1", targetingInfo: prebidKeywords)
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeAdRequestTargeting.keywords = "test_key:test_value"
        mopubNativeObject?.targeting = mopubNativeAdRequestTargeting
        utils.validateAndAttachKeywords(adObject: mopubNativeObject as AnyObject, bidResponse: bidResponse)

        var keywords: String?
        var keywordsArray: [String] = []

        XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
        XCTAssertNotNil(self.mopubNativeObject?.targeting)
        
        XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
        XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)
        
        keywords = self.mopubNativeObject?.targeting.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(12, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_local:Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"))
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_appnexus:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size_appnexus:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_appnexus:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_appnexus:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_appnexus:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:appnexus"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))

        utils.removeHBKeywords(adObject: self.mopubNativeObject!)

        XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
        XCTAssertNotNil(self.mopubNativeObject?.targeting)
        
        XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
        XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)
        
        keywords = self.mopubNativeObject?.targeting.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(1, keywordsArray.count)
        XCTAssertFalse (keywordsArray.contains("hb_cache_id_local:Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"))
        XCTAssertFalse(keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder_appnexus:appnexus"))
        XCTAssertFalse(keywordsArray.contains("hb_size_appnexus:300x250"))
        XCTAssertFalse(keywordsArray.contains("hb_pb_appnexus:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_env_appnexus:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id_appnexus:d6e43a95-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_pb:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder:appnexus"))
        XCTAssertFalse(keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue(keywordsArray.contains("test_key:test_value"))

        let prebidKeywords2: [String: String] = ["hb_env": "mobile-app",
                                               "hb_bidder_rubicon": "rubicon",
                                               "hb_size_rubicon": "300x250",
                                               "hb_pb_rubicon": "0.50",
                                               "hb_env_rubicon": "mobile-app",
                                               "hb_cache_id": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_cache_id_rubicon": "ffffffff-5ee2-4d74-ae85-e4b602b7f88d",
                                               "hb_pb": "0.50",
                                               "hb_bidder": "rubicon",
                                               "hb_size": "300x250","hb_cache_id_local": "Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"]
        let bidResponse2 = BidResponse(adUnitId: "test2", targetingInfo: prebidKeywords2)
        utils.validateAndAttachKeywords(adObject: self.mopubNativeObject as AnyObject, bidResponse: bidResponse2)

        XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
        XCTAssertNotNil(self.mopubNativeObject?.targeting)
        
        XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
        XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)
        
        keywords = self.mopubNativeObject?.targeting.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(12, keywordsArray.count)
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_local:Prebid_EDE1611B-D3DB-4174-B2B6-A9E63A3EFD80"))
        XCTAssertTrue (keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder_rubicon:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size_rubicon:300x250"))
        XCTAssertTrue (keywordsArray.contains("hb_pb_rubicon:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_env_rubicon:mobile-app"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_cache_id_rubicon:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertTrue (keywordsArray.contains("hb_pb:0.50"))
        XCTAssertTrue (keywordsArray.contains("hb_bidder:rubicon"))
        XCTAssertTrue (keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue (keywordsArray.contains("test_key:test_value"))
        
        utils.removeHBKeywords(adObject: self.mopubNativeObject!)
        
        XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
        XCTAssertNotNil(self.mopubNativeObject?.targeting)
        
        XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
        XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)
        
        keywords = self.mopubNativeObject?.targeting.keywords
        keywordsArray = keywords!.components(separatedBy: ",")
        XCTAssertEqual(1, keywordsArray.count)
        XCTAssertFalse(keywordsArray.contains("hb_env:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder_rubicon:rubicon"))
        XCTAssertFalse(keywordsArray.contains("hb_size_rubicon:300x250"))
        XCTAssertFalse(keywordsArray.contains("hb_pb_rubicon:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_env_rubicon:mobile-app"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_cache_id_rubicon:ffffffff-5ee2-4d74-ae85-e4b602b7f88d"))
        XCTAssertFalse(keywordsArray.contains("hb_pb:0.50"))
        XCTAssertFalse(keywordsArray.contains("hb_bidder:rubicon"))
        XCTAssertFalse(keywordsArray.contains("hb_size:300x250"))
        XCTAssertTrue(keywordsArray.contains("test_key:test_value"))
        
    }
    
    func testMoPubNativeKeywordsAbsent() {
        let utils: Utils = Utils.shared
        let prebidKeywords: [String: String] = [:]

        let bidResponse = BidResponse(adUnitId: "test1", targetingInfo: prebidKeywords)
        let mopubNativeAdRequestTargeting = MPNativeAdRequestTargeting()
        mopubNativeAdRequestTargeting.keywords = "test_key:test_value"
        mopubNativeObject?.targeting = mopubNativeAdRequestTargeting
        utils.validateAndAttachKeywords(adObject: mopubNativeObject as AnyObject, bidResponse: bidResponse)
        
        DispatchQueue.main.async {
            XCTAssertTrue(((self.mopubNativeObject?.description) != nil), "MPNativeAdRequest")
            XCTAssertNotNil(self.mopubNativeObject?.targeting)
            
            XCTAssertTrue(((self.mopubNativeObject?.targeting.description) != nil), "MPNativeAdRequestTargeting")
            XCTAssertNotNil(self.mopubNativeObject?.targeting.keywords)
            
            let keywords = self.mopubNativeObject?.targeting.keywords
            let keywordsArray = keywords!.components(separatedBy: ",")
            XCTAssertEqual(1, keywordsArray.count)
            XCTAssertTrue(keywordsArray.contains("test_key:test_value"))
        }
    }
    
    func testfindNativeForMoPubNativeWithPrebidNativeAdLoaded() {

        prebidNativeAdLoadedExpectation = expectation(description: "\(#function)")
        let mpNativeAd = MPNativeAd()
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: "NativeAd", ofType: "json") ?? "", encoding: .utf8)
        if let cacheId = CacheManager.shared.save(content: baseResponse!), !cacheId.isEmpty{
            mpNativeAd.p_customProperties["hb_cache_id_local"] = cacheId as AnyObject
        }
        
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: mpNativeAd)
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testfindNativeForMoPubNativeWithPrebidNativeAdNotValid() {

        prebidNativeAdNotValidExpectation = expectation(description: "\(#function)")
        let mpNativeAd = MPNativeAd()
        if let cacheId = CacheManager.shared.save(content: "invalid ad"), !cacheId.isEmpty{
            mpNativeAd.p_customProperties["hb_cache_id_local"] = cacheId as AnyObject
        }
        
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: mpNativeAd)
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testfindNativeForMoPubNativeWithPrebidNativeAdNotFound() {

        prebidNativeAdNotFoundExpectation = expectation(description: "\(#function)")
        let mpNativeAd = MPNativeAd()
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: "NativeAd", ofType: "json") ?? "", encoding: .utf8)
        if let cacheId = CacheManager.shared.save(content: baseResponse!), !cacheId.isEmpty{
            mpNativeAd.p_customProperties["hb_cache_id_local"] = cacheId as AnyObject
            mpNativeAd.p_customProperties["isPrebid"] = 0 as AnyObject;
        }
        
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: mpNativeAd)
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testfindNativeForDFPNativeWithPrebidNativeAdLoaded() {
        
        prebidNativeAdLoadedExpectation = expectation(description: "\(#function)")
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: "NativeAd", ofType: "json") ?? "", encoding: .utf8)
        if let cacheId = CacheManager.shared.save(content: baseResponse!), !cacheId.isEmpty{
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(cacheId, forKey: "hb_cache_id_local")
        }

        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testfindNativeForDFPNativeWithPrebidNativeAdNotValid() {

        prebidNativeAdNotValidExpectation = expectation(description: "\(#function)")
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        if let cacheId = CacheManager.shared.save(content: "invalid ad"), !cacheId.isEmpty{
            gadNativeCustomTemplateAd.setValue("1", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(cacheId, forKey: "hb_cache_id_local")
        }
        
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }

    func testfindNativeForDFPNativeWithPrebidNativeAdNotFound() {

        prebidNativeAdNotFoundExpectation = expectation(description: "\(#function)")
        let gadNativeCustomTemplateAd = GADNativeCustomTemplateAd()
        let currentBundle = Bundle(for: TestUtils.PBHTTPStubbingManager.self)
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: "NativeAd", ofType: "json") ?? "", encoding: .utf8)
        if let cacheId = CacheManager.shared.save(content: baseResponse!), !cacheId.isEmpty{
            gadNativeCustomTemplateAd.setValue("0", forKey: "isPrebid")
            gadNativeCustomTemplateAd.setValue(cacheId, forKey: "hb_cache_id_local")
        }
        
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: gadNativeCustomTemplateAd)
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
    }
    
    func testGetDictionaryFromAnyValue() {
        let jsonString = "{\"assets\":[{\"required\":1,\"title\":{\"text\":\"OpenX (Title)\"}},{\"required\":1,\"img\":{\"type\":1,\"url\":\"https://www.saashub.com/images/app/service_logos/5/1df363c9a850/large.png?1525414023\"}},{\"required\":1,\"img\":{\"type\":3,\"url\":\"https://ssl-i.cdn.openx.com/mobile/demo-creatives/mobile-demo-banner-640x100.png\"}},{\"required\":1,\"data\":{\"type\":1,\"value\":\"OpenX (Brand)\"}},{\"required\":1,\"data\":{\"type\":2,\"value\":\"Learn all about this awesome story of someone using out OpenX SDK.\"}},{\"required\":1,\"data\":{\"type\":12,\"value\":\"Click here to visit our site\"}}],\"link\":{\"url\":\"https://www.openx.com/\"}}"
        let jsonDic: [String: Any] = ["assets":[["required":1,"title":["text":"OpenX (Title)"]],["required":1,"img":["type":1,"url":"https://www.saashub.com/images/app/service_logos/5/1df363c9a850/large.png?1525414023"]],["required":1,"img":["type":3,"url":"https://ssl-i.cdn.openx.com/mobile/demo-creatives/mobile-demo-banner-640x100.png"]],["required":1,"data":["type":1,"value":"OpenX (Brand)"]],["required":1,"data":["type":2,"value":"Learn all about this awesome story of someone using out OpenX SDK."]],["required":1,"data":["type":12,"value":"Click here to visit our site"]]],"link":["url":"https://www.openx.com/"]]
        
        guard let resultDict = Utils.shared.getDictionary(from: jsonString) else {
            XCTFail()
            return
        }
        XCTAssertTrue(NSDictionary(dictionary: jsonDic).isEqual(to: resultDict))
    }

    
    func nativeAdLoaded(ad:NativeAd) {
        print("nativeAdLoaded")
        prebidNativeAdLoadedExpectation?.fulfill()
    }
    
    func nativeAdNotFound() {
        print("nativeAdNotFound")
        prebidNativeAdNotFoundExpectation?.fulfill()
    }
    
    func nativeAdNotValid() {
        print("nativeAdNotValid")
        prebidNativeAdNotValidExpectation?.fulfill()
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
       if let data = text.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
}

extension String {
    var unescaped: String {
        let entities = ["\0", "\t", "\n", "\r", "\"", "\'", "\\", "\\\'", "\\\""]
        var current = self
        for entity in entities {
            let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
            let description = String(descriptionCharacters)
            current = current.replacingOccurrences(of: description, with: entity)
        }
        return current
    }
}
