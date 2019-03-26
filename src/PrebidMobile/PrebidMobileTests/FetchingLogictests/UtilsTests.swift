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

        DispatchQueue.main.async {
            XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
            XCTAssertNotNil(self.mopubObject?.keywords)
            let keywords = self.mopubObject?.keywords
            let keywordsArray = keywords!.components(separatedBy: ",")
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

        }
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

            DispatchQueue.main.async {
            XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
            XCTAssertNotNil(self.mopubObject?.keywords)
            let keywords = self.mopubObject?.keywords
            let keywordsArray = keywords!.components(separatedBy: ",")
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

    }

    func testRemoveMoPubKeywords() {
        let utils: Utils = Utils.shared

        let prebidKeywords: [String: String] = ["hb_env": "mobile-app", "hb_bidder_appnexus": "appnexus", "hb_size_appnexus": "300x250", "hb_pb_appnexus":
            "0.50", "hb_env_appnexus": "mobile-app", "hb_cache_id": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_cache_id_appnexus": "d6e43a95-5ee2-4d74-ae85-e4b602b7f88d", "hb_pb": "0.50", "hb_bidder": "appnexus", "hb_size": "300x250"]

        let bidResponse = BidResponse(adId: "test1", adServerTargeting: prebidKeywords as [String: AnyObject])
        mopubObject?.keywords = "test_key:test_value"
        utils.validateAndAttachKeywords(adObject: mopubObject as AnyObject, bidResponse: bidResponse)

        DispatchQueue.main.async {

        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        let keywords = self.mopubObject?.keywords
        let keywordsArray = keywords!.components(separatedBy: ",")
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
        }

        utils.removeHBKeywords(adObject: self.mopubObject!)
        DispatchQueue.main.async {
        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        let keywords = self.mopubObject?.keywords
        let keywordsArray = keywords!.components(separatedBy: ",")
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
        }
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
        DispatchQueue.main.async {
        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        let keywords = self.mopubObject?.keywords
        let keywordsArray = keywords!.components(separatedBy: ",")
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
        utils.removeHBKeywords(adObject: self.mopubObject!)
        DispatchQueue.main.async {
        XCTAssertTrue(((self.mopubObject?.description) != nil), "MPAdView")
        XCTAssertNotNil(self.mopubObject?.keywords)
        let keywords = self.mopubObject?.keywords
        let keywordsArray = keywords!.components(separatedBy: ",")
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
}
