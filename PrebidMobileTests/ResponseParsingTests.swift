//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import XCTest
@testable import PrebidMobile

class ResponseParsingTests: XCTestCase {
    
    struct JSON {
        
        static func bidResponse() -> [String : Any] {
            [
                "id" : "_id",
                "seatbid" : [seatBid()],
                "bidid" : "_bidid",
                "cur" : "_cur",
                "customdata" : "_customdata",
                "nbr" : 1,
                "ext" : bidResponseExt(),
            ]
        }
        
        static func seatBid() -> [String : Any] {
            [
                "bid" : [bid()],
                "seat" : "_seat",
                "group" : 1,
            ]
        }
        
        static func bid() -> [String : Any] {
            [
                "ext" : bidExt(),
                "id" : "_id",
                "impid" : "_impid",
                "price" : 1,
                "nurl" : "_nurl",
                "burl" : "_burl",
                "lurl" : "_lurl",
                "adm" : "_adm",
                "adid" : "_adid",
                "adomain" : "_adomain",
                "bundle" : "_bundle",
                "iurl" : "_iurl",
                "cid" : "_cid",
                "crid" : "_crid",
                "tactic" : "_tactic",
                "cat" : ["cat_str", 1],
                "attr" : ["attr_str", 1],
                "api" : 2,
                "protocol" : 3,
                "qagmediarating" : 4,
                "language" : "_language",
                "dealid" : "_dealid",
                "w" : 5,
                "h" : 6,
                "wratio" : 7,
                "hratio" : 8,
                "exp" : 9,
            ]
        }
        
        static func adConfiguration() -> [String : Any] {
            [
                "maxvideoduration" : 1,
                "ismuted" : 2,
                "closebuttonarea" : 3,
                "closebuttonposition" : "_closebuttonposition",
                "skipbuttonarea" : 4,
                "skipbuttonposition" : "_skipbuttonposition",
                "skipdelay" : 5,
            ]
        }
        
        static func bidExt() -> [String : Any] {
            [
                "bidder" : ["bidder_k1" : "bidder_str", "bidder_k2" : 1],
                "prebid" : bidExtPrebid(),
                "skadn" : bidExtSkadn(),
            ]
        }
        
        static func bidExtPrebid() -> [String : Any] {
            [
                "cache" : bidExtPrebidCache(),
                "targeting" : ["targeting_k1" : "targeting_str"],
                "meta" : ["meta_k1" : "meta_str", "meta_k2" : 1],
                "type" : "_type",
                "passthrough" : [extPrebidPassthrough()],
                "events" : extPrebidEvents(),
            ]
        }
        
        static func bidExtPrebidCache() -> [String : Any] {
            [
                "key" : "_key",
                "url" : "_url",
                "bids" : bidExtPrebidCacheBids()
            ]
        }
        
        static func bidExtPrebidCacheBids() -> [String : Any] {
            [
                "url" : "_url",
                "cacheId" : "_cacheId",
            ]
        }
        
        static func bidExtSkadn() -> [String : Any] {
            [
                "version" : "_version",
                "network" : "_network",
                "campaign" : 1,
                "itunesitem" : 2,
                "sourceapp" : 3,
                "sourceidentifier" : "_sourceidentifier",
                "fidelities" : [skadnFidelity()],
                "skoverlay" : bidExtSkadnSKOverlay(),
            ]
        }
        
        static func bidExtSkadnSKOverlay() -> [String : Any] {
            [
                "delay" : 1,
                "endcarddelay" : 2,
                "dismissible" : 3,
                "pos" : 4,
            ]
        }
        
        static func bidResponseExt() -> [String : Any] {
            [
                "responsetimemillis" : ["responsetimemillis_k1" : 1],
                "tmaxrequest" : 1,
                "prebid": bidResponseExtPrebid(),
            ]
        }
        
        static func bidResponseExtPrebid() -> [String : Any] {
            [
                "passthrough" : [extPrebidPassthrough()]
            ]
        }
        
        static func extPrebidEvents() -> [String : Any] {
            [
                "win" : "_win",
                "imp" : "_imp",
            ]
        }
        
        static func extPrebidPassthrough() -> [String : Any] {
            [
                "type" : "_type",
                "adconfiguration" : adConfiguration(),
                "sdkconfiguration" : sdkConfiguration(),
                "rwdd" : rewardedConfiguration(),
            ]
        }
        
        static func rewardedClose() -> [String : Any] {
            [
                "postrewardtime" : 1,
                "action" : "_action",
            ]
        }
        
        static func rewardedCompletion() -> [String : Any] {
            [
                "banner" : rewardedCompletionBanner(),
                "video" : rewardedCompletionVideo(),
            ]
        }
        
        static func rewardedCompletionBanner() -> [String : Any] {
            [
                "time" : 1,
                "event" : "_event",
            ]
        }
        
        static func rewardedCompletionVideo() -> [String : Any] {
            [
                "time" : 1,
                "playbackevent" : "_playbackevent",
                "endcard" : rewardedCompletionVideoEndcard(),
            ]
        }
        
        static func rewardedCompletionVideoEndcard() -> [String : Any] {
            [
                "time" : 1,
                "event" : "_event",
            ]
        }
        
        static func rewardedConfiguration() -> [String : Any] {
            [
                "reward" : rewardedReward(),
                "completion" : rewardedCompletion(),
                "close" : rewardedClose(),
            ]
        }
        
        static func rewardedReward() -> [String : Any] {
            [
                "type" : "_type",
                "count" : 1,
                "ext" : ["ext_k1" : "ext_str", "ext_k2" : 1],
            ]
        }
        
        static func sdkConfiguration() -> [String : Any] {
            [
                "cftbanner" : 1,
                "cftprerender" : 2,
            ]
        }
        
        static func skadnFidelity() -> [String : Any] {
            [
                "fidelity" : 1,
                "nonce" : "12345678-ABCD-1234-ABCD-1234567890AB",
                "timestamp" : 2,
                "signature" : "_signature",
            ]
        }
    }
    
    func testAdConfiguration() {
        let json = JSON.adConfiguration()
        let entity = ORTBAdConfiguration(jsonDictionary: json)
        XCTAssertEqual(entity.maxVideoDuration, 1)
        XCTAssertEqual(entity.isMuted, 2)
        XCTAssertEqual(entity.closeButtonArea, 3)
        XCTAssertEqual(entity.skipButtonArea, 4)
        XCTAssertEqual(entity.skipButtonPosition, "_skipbuttonposition")
        XCTAssertEqual(entity.skipDelay, 5)
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidExt() {
        let json = JSON.bidExt()
        let entity = ORTBBidExt(jsonDictionary: json)
        XCTAssertEqual(entity.bidder as NSDictionary?,
                       ["bidder_k1" : "bidder_str", "bidder_k2" : 1] as NSDictionary)
        XCTAssertTrue(compare(entity.prebid, JSON.bidExtPrebid()))
        XCTAssertTrue(compare(entity.skadn, JSON.bidExtSkadn()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtPrebid() {
        let json = JSON.bidExtPrebid()
        let entity = ORTBBidExtPrebid(jsonDictionary: json)
        XCTAssertNotNil(entity.cache)
        XCTAssertEqual(entity.targeting as NSDictionary?,
                       ["targeting_k1" : "targeting_str"] as NSDictionary)
        XCTAssertEqual(entity.meta as NSDictionary?, ["meta_k1" : "meta_str", "meta_k2" : 1] as NSDictionary)
        XCTAssertEqual(entity.type, "_type")
        XCTAssertTrue(compare(entity.passthrough, [JSON.extPrebidPassthrough()]))
        XCTAssertTrue(compare(entity.events, JSON.extPrebidEvents()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtPrebidWithPassthroughObject() {
        // Test with "passthrough" as an object, as opposed to an array which is
        // out-of-spec but handled for legacy reasons
        let json = JSON.bidExtPrebid()
        
        var modifiedJson = json
        modifiedJson["passthrough"] = JSON.extPrebidPassthrough()
        
        let entity = ORTBBidExtPrebid(jsonDictionary: modifiedJson)
        XCTAssertTrue(compare(entity.passthrough, [JSON.extPrebidPassthrough()]))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }

    func testBidExtPrebidCache() {
        let json = JSON.bidExtPrebidCache()
        let entity = ORTBBidExtPrebidCache(jsonDictionary: json)
        XCTAssertEqual(entity.key, "_key")
        XCTAssertEqual(entity.url, "_url")
        XCTAssertTrue(compare(entity.bids, JSON.bidExtPrebidCacheBids()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtPrebidCacheBids() {
        let json = JSON.bidExtPrebidCacheBids()
        let entity = ORTBBidExtPrebidCacheBids(jsonDictionary: json)
        XCTAssertEqual(entity.url, "_url")
        XCTAssertEqual(entity.cacheId, "_cacheId")
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtSkadn() {
        let json = JSON.bidExtSkadn()
        let entity = ORTBBidExtSkadn(jsonDictionary: json)
        XCTAssertEqual(entity.version, "_version")
        XCTAssertEqual(entity.network, "_network")
        XCTAssertEqual(entity.campaign, 1)
        XCTAssertEqual(entity.itunesitem, 2)
        XCTAssertEqual(entity.sourceapp, 3)
        XCTAssertEqual(entity.sourceidentifier, "_sourceidentifier")
        XCTAssertTrue(compare(entity.fidelities, [JSON.skadnFidelity()]))
        XCTAssertTrue(compare(entity.skoverlay, JSON.bidExtSkadnSKOverlay()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtSkadnSKOverlay() {
        let json = JSON.bidExtSkadnSKOverlay()
        let entity = ORTBBidExtSkadnSKOverlay(jsonDictionary: json)
        XCTAssertEqual(entity.delay, 1)
        XCTAssertEqual(entity.endcarddelay, 2)
        XCTAssertEqual(entity.dismissible, 3)
        XCTAssertEqual(entity.pos, 4)
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidResponseExt() {
        let json = JSON.bidResponseExt()
        let entity = ORTBBidResponseExt(jsonDictionary: json)
        XCTAssertEqual(entity.responsetimemillis, ["responsetimemillis_k1" : 1])
        XCTAssertEqual(entity.tmaxrequest, 1)
        XCTAssertTrue(compare(entity.extPrebid, JSON.bidResponseExtPrebid()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testBidResponseExtPrebidWithPassthroughObject() {
        // Test with "passthrough" as an object, as opposed to an array which is
        // out-of-spec but handled for legacy reasons
        let json = JSON.bidResponseExtPrebid()
        
        var modifiedJson = json
        modifiedJson["passthrough"] = JSON.extPrebidPassthrough()
        
        let entity = ORTBBidExtPrebid(jsonDictionary: modifiedJson)
        XCTAssertTrue(compare(entity.passthrough, [JSON.extPrebidPassthrough()]))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testExtPrebidEvents() {
        let json = JSON.extPrebidEvents()
        let entity = ORTBExtPrebidEvents(jsonDictionary: json)
        XCTAssertEqual(entity.win, "_win")
        XCTAssertEqual(entity.imp, "_imp")
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testExtPrebidPassthrough() {
        let json = JSON.extPrebidPassthrough()
        let entity = ORTBExtPrebidPassthrough(jsonDictionary: json)
        XCTAssertEqual(entity.type, "_type")
        XCTAssertTrue(compare(entity.adConfiguration, JSON.adConfiguration()))
        XCTAssertTrue(compare(entity.sdkConfiguration, JSON.sdkConfiguration()))
        XCTAssertTrue(compare(entity.rewardedConfiguration, JSON.rewardedConfiguration()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedClose() {
        let json = JSON.rewardedClose()
        let entity = ORTBRewardedClose(jsonDictionary: json)
        XCTAssertEqual(entity.postrewardtime, 1)
        XCTAssertEqual(entity.action, "_action")
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletion() {
        let json = JSON.rewardedCompletion()
        let entity = ORTBRewardedCompletion(jsonDictionary: json)
        XCTAssertTrue(compare(entity.banner, JSON.rewardedCompletionBanner()))
        XCTAssertTrue(compare(entity.video, JSON.rewardedCompletionVideo()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletionBanner() {
        let json = JSON.rewardedCompletionBanner()
        let entity = ORTBRewardedCompletionBanner(jsonDictionary: json)
        XCTAssertEqual(entity.time, 1)
        XCTAssertEqual(entity.event, "_event")
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletionVideo() {
        let json = JSON.rewardedCompletionVideo()
        let entity = ORTBRewardedCompletionVideo(jsonDictionary: json)
        XCTAssertEqual(entity.time, 1)
        XCTAssertEqual(entity.playbackevent, "_playbackevent")
        XCTAssertTrue(compare(entity.endcard, JSON.rewardedCompletionVideoEndcard()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletionVideoEndcard() {
        let json = JSON.rewardedCompletionVideoEndcard()
        let entity = ORTBRewardedCompletionVideoEndcard(jsonDictionary: json)
        XCTAssertEqual(entity.time, 1)
        XCTAssertEqual(entity.event, "_event")
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedConfiguration() {
        let json = JSON.rewardedConfiguration()
        let entity = ORTBRewardedConfiguration(jsonDictionary: json)
        XCTAssertTrue(compare(entity.reward, JSON.rewardedReward()))
        XCTAssertTrue(compare(entity.completion, JSON.rewardedCompletion()))
        XCTAssertTrue(compare(entity.close, JSON.rewardedClose()))
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedReward() {
        let json = JSON.rewardedReward()
        let entity = ORTBRewardedReward(jsonDictionary: json)
        XCTAssertEqual(entity.type, "_type")
        XCTAssertEqual(entity.count, 1)
        XCTAssertEqual(entity.ext as NSDictionary?,
                       ["ext_k1" : "ext_str", "ext_k2" : 1] as NSDictionary)
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func testSDKConfiguration() {
        let json = JSON.sdkConfiguration()
        let entity = ORTBSDKConfiguration(jsonDictionary: json)
        XCTAssertEqual(entity.cftBanner, 1)
        XCTAssertEqual(entity.cftPreRender, 2)
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
        
    }
    
    func testSkadnFidelity() {
        let json = JSON.skadnFidelity()
        let entity = ORTBSkadnFidelity(jsonDictionary: json)
        XCTAssertEqual(entity.fidelity, 1)
        XCTAssertEqual(entity.nonce, UUID(uuidString: "12345678-ABCD-1234-ABCD-1234567890AB"))
        XCTAssertEqual(entity.timestamp, 2)
        XCTAssertEqual(entity.signature, "_signature")
        
        XCTAssertEqual(entity.jsonDictionary as NSDictionary, json as NSDictionary)
    }
    
    func compare(_ entity: PBMJsonEncodable?, _ object: [String : Any]) -> Bool {
        guard let entity else {
            return false
        }
        return entity.jsonDictionary as NSDictionary == object as NSDictionary
    }
    
    func compare(_ entities: [PBMJsonEncodable]?, _ array: [[String : Any]]) -> Bool {
        guard let entities else {
            return false
        }
        
        return entities.map { $0.jsonDictionary as NSDictionary } == array.map { $0 as NSDictionary }
    }
    
    func testInstantiatesCustomModelObjects() {
        registerCustomClasses()
        
        defer {
            unregisterCustomClasses()
        }
        
        let bidResponse = BidResponse(jsonDictionary: JSON.bidResponse())
        let bidExt = bidResponse.allBids![0].bid.ext!
        let bidResponseExt = bidResponse.ext!
        let passthrough = bidExt.prebid!.passthrough![0]
        
        XCTAssertTrue(passthrough.adConfiguration is CustomAdConfiguration)
        XCTAssertTrue(bidExt.skadn is CustomBidExtSkadn)
        XCTAssertTrue(bidExt.skadn!.skoverlay is CustomBidExtSkadnSKOverlay)
        XCTAssertTrue(bidResponseExt is CustomBidResponseExt)
        XCTAssertTrue(bidResponseExt.extPrebid is CustomBidResponseExtPrebid)
        XCTAssertTrue(bidExt.prebid?.events is CustomExtPrebidEvents)
        XCTAssertTrue(passthrough is CustomExtPrebidPassthrough)
        XCTAssertTrue(passthrough.rewardedConfiguration!.close is CustomRewardedClose)
        XCTAssertTrue(passthrough.rewardedConfiguration!.completion is CustomRewardedCompletion)
        XCTAssertTrue(passthrough.rewardedConfiguration!.completion!.banner is CustomRewardedCompletionBanner)
        XCTAssertTrue(passthrough.rewardedConfiguration!.completion!.video is CustomRewardedCompletionVideo)
        XCTAssertTrue(passthrough.rewardedConfiguration!.completion!.video?.endcard is CustomRewardedCompletionVideoEndcard)
        XCTAssertTrue(passthrough.rewardedConfiguration is CustomRewardedConfiguration)
        XCTAssertTrue(passthrough.rewardedConfiguration!.reward is CustomRewardedReward)
        XCTAssertTrue(passthrough.sdkConfiguration is CustomSDKConfiguration)
        XCTAssertTrue(bidExt.skadn!.fidelities![0] is CustomSkadnFidelity)
    }
}
