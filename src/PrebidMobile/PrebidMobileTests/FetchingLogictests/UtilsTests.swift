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
import WebKit
@testable import PrebidMobile

@objcMembers public class DFPORequest: NSObject {
    var name: String!
    private(set) var p_customKeywords: [String: AnyObject]

    var customTargeting: [String: AnyObject] {
            return p_customKeywords
    }

    override init() {
        self.p_customKeywords = [String: AnyObject]()
    }
}

@objcMembers public class DFPNRequest: NSObject {
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

@objcMembers public class MPAdView: NSObject {
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

@objcMembers public class InvalidMPAdView: NSObject {
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

class UtilsTests: XCTestCase {

    var dfpAdObject: DFPNRequest?
    var invalidDfpAdObject: DFPORequest?
    var mopubObject: MPAdView?
    var invalidMopubObject: InvalidMPAdView?

    override func setUp() {
        dfpAdObject = DFPNRequest()
        mopubObject = MPAdView()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
                                              "hb_size": "300x250"]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]

        let bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])

        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(11, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
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
                                               "hb_size": "300x250"]
        let bidResponse2 = BidResponse(adId: "test", adServerTargeting: prebidKeywords2 as [String: AnyObject])
        utils.removeHBKeywords(adObject: dfpAdObject!)
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse2)
        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(11, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
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
                                              "hb_size": "300x250"]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]

        let bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])

        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(11, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
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
                                               "hb_size": "300x250"]
        let bidResponse2 = BidResponse(adId: "test", adServerTargeting: prebidKeywords2 as [String: AnyObject])
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse2)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")
        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(11, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
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
        let bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])
        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")
        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(1, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
    }

    func testDFPInvalidObject() {
        let utils: Utils = Utils.shared
        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250"]
        let bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])
        utils.validateAndAttachKeywords(adObject: invalidDfpAdObject as AnyObject, bidResponse: bidResponse)
        XCTAssertNil(invalidDfpAdObject?.customTargeting)

    }

    func testExistingAndRemovingPrebidKeywords() {
        let utils: Utils = Utils.shared

        var prebidKeywords: [String: String] = ["hb_env": "mobile-app"]
        dfpAdObject?.customTargeting = ["test_key": "test_value"] as [String: AnyObject]

        var bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])

        utils.validateAndAttachKeywords(adObject: dfpAdObject as AnyObject, bidResponse: bidResponse)

        XCTAssertTrue(((dfpAdObject?.description) != nil), "DFPNRequest")

        XCTAssertNotNil(dfpAdObject?.customTargeting)
        XCTAssertEqual(2, dfpAdObject?.customTargeting.count)
        XCTAssertEqual(dfpAdObject?.customTargeting["test_key"] as! String, "test_value")
        XCTAssertEqual(dfpAdObject!.customTargeting["hb_env"] as! String, "mobile-app")

        prebidKeywords = ["app": "prebid"]
        bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])

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

        let bidResponse = BidResponse(adId: "test1", adServerTargeting: prebidKeywords as [String: AnyObject])
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

        let bidResponse2 = BidResponse(adId: "test2", adServerTargeting: prebidKeywords2 as [String: AnyObject])
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

        let bidResponse = BidResponse(adId: "test1", adServerTargeting: prebidKeywords as [String: AnyObject])
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
        let bidResponse2 = BidResponse(adId: "test2", adServerTargeting: prebidKeywords2 as [String: AnyObject])
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
        let bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])
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
        let bidResponse = BidResponse(adId: "test", adServerTargeting: prebidKeywords as [String: AnyObject])
        invalidMopubObject?.keywords = "test_key:test_value"
        utils.validateAndAttachKeywords(adObject: invalidMopubObject as AnyObject, bidResponse: bidResponse)
        DispatchQueue.main.async {
            XCTAssertNil(self.invalidMopubObject?.keywords)
        }
    }
    
    func testRegexMatches() {
        var result = Utils.shared.matches(for: "^a", in: "aaa aaa")
        XCTAssert(result.count == 1)
        XCTAssert(result[0] == "a")
        
        result = Utils.shared.matches(for: "^b", in: "aaa aaa")
        XCTAssert(result.count == 0)
        
        result = Utils.shared.matches(for: "aaa aaa", in: "^a")
        XCTAssert(result.count == 0)
        
        result = Utils.shared.matches(for: "[0-9]+x[0-9]+", in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"1x1\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssert(result.count == 3)
        XCTAssert(result[0] == "728x90")
        XCTAssert(result[1] == "1x1")
        XCTAssert(result[2] == "300x250")
        
        result = Utils.shared.matches(for: "hb_size\\W+[0-9]+x[0-9]+", in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"1x1\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssert(result.count == 2)
        XCTAssert(result[0] == "hb_size\":[\"728x90")
        XCTAssert(result[1] == "hb_size:300x250")
    }
    
    func testRegexMatchAndCheck() {
        var result = Utils.shared.matchAndCheck(regex: "^a", text: "aaa aaa")
        
        XCTAssertNotNil(result)
        XCTAssert(result == "a")
        
        result = Utils.shared.matchAndCheck(regex: "^b", text: "aaa aaa")
        XCTAssertNil(result)
    }
    
    func testFindHbSizeValue() {
        var result = Utils.shared.findHbSizeValue(in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"728x90\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssertNotNil(result)
        XCTAssert(result == "728x90")
    }
    
    func testFindHbSizeKeyValue() {
        var result = Utils.shared.findHbSizeObject(in: "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"728x90\"],moPubResponse:\"hb_size:300x250\" \n }")
        XCTAssertNotNil(result)
        XCTAssert(result == "hb_size\":[\"728x90")
    }
    
    func testStringToCGSize() {
        var result = Utils.shared.stringToCGSize("300x250")
        XCTAssertNotNil(result)
        XCTAssert(result == CGSize(width: 300, height: 250))
        
        result = Utils.shared.stringToCGSize("300x250x1")
        XCTAssertNil(result)
        
        result = Utils.shared.stringToCGSize("ERROR")
        XCTAssertNil(result)
        
        result = Utils.shared.stringToCGSize("300x250ERROR")
        XCTAssertNil(result)
    }
    
    func testFailureFindASizeInNilJsCode() {
        findSizeInJavascriptErrorHelper(body: nil)
    }
    
    func testFailureFindASizeIfItIsNotPresent() {
        findSizeInJavascriptErrorHelper(body: "<script> \n </script>")
    }
    
    func testFailureFindASizeIfItHasTheWrongType() {
        findSizeInJavascriptErrorHelper(body: "<script> \n \"hb_size\":ERROR \n </script>")
    }
    
    func testSuccessFindASizeIfProperlyFormatted() {
        findSizeInJavascriptSuccessHelper(body: "<script> \n \"hb_size\":[\"728x90\"] \n </script>")
    }
    
    func findSizeInJavascriptErrorHelper(body: String?) {
        // given
        var result: CGSize? = nil
        var error: String? = nil
        let success: (CGSize) -> Void = { size in result = size}
        let failure: (Error) -> Void = { err in error = err.localizedDescription}
        
        // when
        Utils.shared.findSizeInHTML(body: body, success: success, failure: failure)
        
        // then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
    }
    
    func findSizeInJavascriptSuccessHelper(body: String?) {
        // given
        var result: CGSize? = nil
        var error: String? = nil
        let success: (CGSize) -> Void = { size in result = size}
        let failure: (Error) -> Void = { err in error = err.localizedDescription}
        
        // when
        Utils.shared.findSizeInHTML(body: body, success: success, failure: failure)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertNil(error)
    }
    
    func testFailureFindSizeInViewIfThereIsNoWebView() {
        
        let uiView = UIView()
        
        findSizeInViewErrorHelper(uiView, expectedError: .prebidFindSizeErrorNoWebView)
    }
    
    func testFailureFindSizeInViewIfUiWebViewWithoutHTML() {
        
        let uiWebView = UIWebView()
        
        findSizeInViewErrorHelper(uiWebView, expectedError: .prebidFindSizeErrorNoHTML)
    }
    
    func testFailureFindSizeInViewIfWkWebViewWithoutHTML() {
        
        let wkWebView = WKWebView()
        
        findSizeInViewErrorHelper(wkWebView, expectedError: .prebidFindSizeErrorNoHTML)
    }
    
    func findSizeInViewErrorHelper(_ view: UIView, expectedError: PrebidFindSizeError) {
        // given
        let loadSuccesfulException = expectation(description: "\(#function)")
        
        var result: CGSize? = nil
        var error: Error? = nil
        let success: (CGSize) -> Void = { size in
            result = size
            loadSuccesfulException.fulfill()
        }
        
        let failure: (Error) -> Void = { err in
            error = err
            loadSuccesfulException.fulfill()
        }

        // when
        Utils.shared.findPrebidCreativeSize(view, success: success, failure: failure)
        waitForExpectations(timeout: 5, handler: nil)

        // then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?._code, expectedError.errorCode)
    }
    
    class NavigationDelegate: NSObject, WKNavigationDelegate {
        let loadSuccesfulException: XCTestExpectation
        
        init(_ loadSuccesfulException: XCTestExpectation) {
            self.loadSuccesfulException = loadSuccesfulException
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.innerHTML") { innerHTML, error in
                
                if error != nil {
                    XCTFail("NavigationDelegate error: \(error)")
                }
                self.loadSuccesfulException.fulfill()
            }
        }
    }
    
    class WebViewDelegate: NSObject, UIWebViewDelegate {
        let loadSuccesfulException: XCTestExpectation
        
        init(_ loadSuccesfulException: XCTestExpectation) {
            self.loadSuccesfulException = loadSuccesfulException
        }
        
        func webViewDidFinishLoad(_ webView: UIWebView) {
            loadSuccesfulException.fulfill()
            return
        }
        
        func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
            XCTFail("NavigationDelegate error: \(error)")
            loadSuccesfulException.fulfill()
            return
            
        }
    }
    
    let successHtmlWithSize728x90 = """
                <html><body leftMargin="0" topMargin="0" marginwidth="0" marginheight="0"><script src = "https://ads.rubiconproject.com/prebid/creative.js"></script>
                <script>
                  var ucTagData = {};
                  ucTagData.adServerDomain = "";
                  ucTagData.pubUrl = "0.1.0.iphone.com.Prebid.PrebidDemo.adsenseformobileapps.com";
                  ucTagData.targetingMap = {"bidder":["rubicon"],"bidid":["ee34715d-336c-4e77-b651-ba62f9d4e026"],"hb_bidder":["rubicon"],"hb_bidder_rubicon":["rubicon"],"hb_cache_host":["prebid-cache-europe.rubiconproject.com"],"hb_cache_host_rubicon":["prebid-cache-europe.rubiconproject.com"],"hb_cache_id":["376f6334-2bba-4f58-a76b-feeb419f513a"],"hb_cache_id_rubicon":["376f6334-2bba-4f58-a76b-feeb419f513a"],"hb_cache_path":["/cache"],"hb_cache_path_rubicon":["/cache"],"hb_env":["mobile-app"],"hb_env_rubicon":["mobile-app"],"hb_pb":["1.40"],"hb_pb_rubicon":["1.40"],"hb_size":["728x90"],"hb_size_rubicon":["728x90"]};

                  try {
                    ucTag.renderAd(document, ucTagData);
                  } catch (e) {
                    console.log(e);
                  }
                </script></div><div style="bottom:0;right:0;width:100px;height:100px;background:initial !important;position:absolute !important;max-width:100% !important;max-height:100% !important;pointer-events:none !important;image-rendering:pixelated !important;background-repeat:no-repeat !important;z-index:2147483647;background-image:url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkBAMAAACCzIhnAAAABlBMVEUAAAD+AciWmZzWAAAAAnRSTlMAApidrBQAAAEZSURBVFjD7VRJksQwCIMf8P/XjgMS4OXSh7nhdKXawbEsoUjk96ExZF1aM4sh6zLhjMX19BuGP5hpbOc/3NbdgCLA8AJn3+6O4cswY7GqDnRU/bDHRoWiTxR7oyQHs4vLp8jFpRQLjFOxwNgUy2FxirsH72dEEHKxpkZ0RoxLpYTsjFLzjVEsVRDYqPhrRQbElCdBBc4ADDaBiQCTSzXezlPQRlbdJSUtxdEZI0gpxxZvyuXxNcEkvQupIMzt5GDC07L7quWAw8lSLmwekzLsy8nsiW2fBPvQ6DYna+nRnGxp1svJJvVhppNV6sN8OLnZozm5Oel28iTMJMwkzCTMJMwkzCTMJMwkzCTMJMwkzCTMJMwkzL8nzB8ivkq1hG7lNQAAAABJRU5ErkJggg==') !important;"></div><script src="https://pagead2.googlesyndication.com/omsdk/releases/live/omid_session_bin.js"></script><script type="text/javascript">(function() {var omidSession = new OmidCreativeSession([]);})();</script></body></html>
                """
    
    func testSuccessFindSizeInWkWebView() {
        
        let wkWebView = WKWebView()
        
        setHtmlIntoWkWebView(successHtmlWithSize728x90, wkWebView)
        findSizeInViewSuccessHelper(wkWebView, expectedSize: CGSize(width: 728, height: 90))
    }
    
    func testSuccessFindSizeInUiWebView() {
        let uiWebView = UIWebView()
        
        setHtmlIntoUiWebView(successHtmlWithSize728x90, uiWebView)
        findSizeInViewSuccessHelper(uiWebView, expectedSize: CGSize(width: 728, height: 90))
    }
    
    func testSuccessFindSizeInViewWithUiWebView() {

        let uiView = UIView()
        let uiWebView = UIWebView()
        uiView.addSubview(uiWebView)

        setHtmlIntoUiWebView(successHtmlWithSize728x90, uiWebView)
        findSizeInViewSuccessHelper(uiWebView, expectedSize: CGSize(width: 728, height: 90))
    }
    
    func setHtmlIntoWkWebView(_ html: String, _ wkWebView: WKWebView) {
        let loadSuccesfulException = expectation(description: "\(#function)")

        wkWebView.loadHTMLString(html, baseURL: nil)
        
        let navigationDelegate = NavigationDelegate(loadSuccesfulException)
        wkWebView.navigationDelegate = navigationDelegate
        
        waitForExpectations(timeout: 5, handler: nil)
        wkWebView.navigationDelegate = nil
    }
    
    func setHtmlIntoUiWebView(_ html: String, _ uiWebView: UIWebView) {
        let loadSuccesfulException = expectation(description: "\(#function)")
        
        uiWebView.loadHTMLString(html, baseURL: nil)
        
        let webViewDelegate = WebViewDelegate(loadSuccesfulException)
        uiWebView.delegate = webViewDelegate
        
        waitForExpectations(timeout: 5, handler: nil)
        uiWebView.delegate = nil
    }
    
    func findSizeInViewSuccessHelper(_ view: UIView, expectedSize: CGSize) {
        // given
        let loadSuccesfulException = expectation(description: "\(#function)")
        
        var result: CGSize? = nil
        var error: Error? = nil
        let success: (CGSize) -> Void = { size in
            result = size
            loadSuccesfulException.fulfill()
        }
        
        let failure: (Error) -> Void = { err in
            error = err
            loadSuccesfulException.fulfill()
        }
        
        // when
        Utils.shared.findPrebidCreativeSize(view, success: success, failure: failure)
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(expectedSize, result)
        XCTAssertNil(error)
        
    }
    
}
