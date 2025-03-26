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
        let entity = PBMORTBAdConfiguration(jsonDictionary: json)!
        XCTAssertEqual(entity.maxVideoDuration, 1)
        XCTAssertEqual(entity.isMuted, 2)
        XCTAssertEqual(entity.closeButtonArea, 3)
        XCTAssertEqual(entity.skipButtonArea, 4)
        XCTAssertEqual(entity.skipButtonPosition, "_skipbuttonposition")
        XCTAssertEqual(entity.skipDelay, 5)
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidExt() {
        let json = JSON.bidExt()
        let entity = PBMORTBBidExt(jsonDictionary: json)!
        XCTAssertEqual(entity.bidder as NSDictionary?,
                       ["bidder_k1" : "bidder_str", "bidder_k2" : 1] as NSDictionary)
        XCTAssertTrue(compare(entity.prebid, JSON.bidExtPrebid()))
        XCTAssertTrue(compare(entity.skadn, JSON.bidExtSkadn()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtPrebid() {
        let json = JSON.bidExtPrebid()
        let entity = PBMORTBBidExtPrebid(jsonDictionary: json)!
        XCTAssertNotNil(entity.cache)
        XCTAssertEqual(entity.targeting as NSDictionary?,
                       ["targeting_k1" : "targeting_str"] as NSDictionary)
        XCTAssertEqual(entity.meta as NSDictionary?, ["meta_k1" : "meta_str", "meta_k2" : 1] as NSDictionary)
        XCTAssertEqual(entity.type, "_type")
        XCTAssertTrue(compare(entity.passthrough, [JSON.extPrebidPassthrough()]))
        XCTAssertTrue(compare(entity.events, JSON.extPrebidEvents()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtPrebidWithPassthroughObject() {
        // Test with "passthrough" as an object, as opposed to an array which is
        // out-of-spec but handled for legacy reasons
        let json = JSON.bidExtPrebid()
        
        var modifiedJson = json
        modifiedJson["passthrough"] = JSON.extPrebidPassthrough()
        
        let entity = PBMORTBBidExtPrebid(jsonDictionary: modifiedJson)!
        XCTAssertTrue(compare(entity.passthrough, [JSON.extPrebidPassthrough()]))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }

    func testBidExtPrebidCache() {
        let json = JSON.bidExtPrebidCache()
        let entity = PBMORTBBidExtPrebidCache(jsonDictionary: json)!
        XCTAssertEqual(entity.key, "_key")
        XCTAssertEqual(entity.url, "_url")
        XCTAssertTrue(compare(entity.bids, JSON.bidExtPrebidCacheBids()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtPrebidCacheBids() {
        let json = JSON.bidExtPrebidCacheBids()
        let entity = PBMORTBBidExtPrebidCacheBids(jsonDictionary: json)!
        XCTAssertEqual(entity.url, "_url")
        XCTAssertEqual(entity.cacheId, "_cacheId")
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtSkadn() {
        let json = JSON.bidExtSkadn()
        let entity = PBMORTBBidExtSkadn(jsonDictionary: json)!
        XCTAssertEqual(entity.version, "_version")
        XCTAssertEqual(entity.network, "_network")
        XCTAssertEqual(entity.campaign, 1)
        XCTAssertEqual(entity.itunesitem, 2)
        XCTAssertEqual(entity.sourceapp, 3)
        XCTAssertEqual(entity.sourceidentifier, "_sourceidentifier")
        XCTAssertTrue(compare(entity.fidelities, [JSON.skadnFidelity()]))
        XCTAssertTrue(compare(entity.skoverlay, JSON.bidExtSkadnSKOverlay()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidExtSkadnSKOverlay() {
        let json = JSON.bidExtSkadnSKOverlay()
        let entity = PBMORTBBidExtSkadnSKOverlay(jsonDictionary: json)!
        XCTAssertEqual(entity.delay, 1)
        XCTAssertEqual(entity.endcarddelay, 2)
        XCTAssertEqual(entity.dismissible, 3)
        XCTAssertEqual(entity.pos, 4)
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidResponseExt() {
        let json = JSON.bidResponseExt()
        let entity = PBMORTBBidResponseExt(jsonDictionary: json)!
        XCTAssertEqual(entity.responsetimemillis, ["responsetimemillis_k1" : 1])
        XCTAssertEqual(entity.tmaxrequest, 1)
        XCTAssertTrue(compare(entity.extPrebid, JSON.bidResponseExtPrebid()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testBidResponseExtPrebidWithPassthroughObject() {
        // Test with "passthrough" as an object, as opposed to an array which is
        // out-of-spec but handled for legacy reasons
        let json = JSON.bidResponseExtPrebid()
        
        var modifiedJson = json
        modifiedJson["passthrough"] = JSON.extPrebidPassthrough()
        
        let entity = PBMORTBBidExtPrebid(jsonDictionary: modifiedJson)!
        XCTAssertTrue(compare(entity.passthrough, [JSON.extPrebidPassthrough()]))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testExtPrebidEvents() {
        let json = JSON.extPrebidEvents()
        let entity = PBMORTBExtPrebidEvents(jsonDictionary: json)!
        XCTAssertEqual(entity.win, "_win")
        XCTAssertEqual(entity.imp, "_imp")
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testExtPrebidPassthrough() {
        let json = JSON.extPrebidPassthrough()
        let entity = PBMORTBExtPrebidPassthrough(jsonDictionary: json)!
        XCTAssertEqual(entity.type, "_type")
        XCTAssertTrue(compare(entity.adConfiguration, JSON.adConfiguration()))
        XCTAssertTrue(compare(entity.sdkConfiguration, JSON.sdkConfiguration()))
        XCTAssertTrue(compare(entity.rewardedConfiguration, JSON.rewardedConfiguration()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedClose() {
        let json = JSON.rewardedClose()
        let entity = PBMORTBRewardedClose(jsonDictionary: json)!
        XCTAssertEqual(entity.postrewardtime, 1)
        XCTAssertEqual(entity.action, "_action")
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletion() {
        let json = JSON.rewardedCompletion()
        let entity = PBMORTBRewardedCompletion(jsonDictionary: json)!
        XCTAssertTrue(compare(entity.banner, JSON.rewardedCompletionBanner()))
        XCTAssertTrue(compare(entity.video, JSON.rewardedCompletionVideo()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletionBanner() {
        let json = JSON.rewardedCompletionBanner()
        let entity = PBMORTBRewardedCompletionBanner(jsonDictionary: json)!
        XCTAssertEqual(entity.time, 1)
        XCTAssertEqual(entity.event, "_event")
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletionVideo() {
        let json = JSON.rewardedCompletionVideo()
        let entity = PBMORTBRewardedCompletionVideo(jsonDictionary: json)!
        XCTAssertEqual(entity.time, 1)
        XCTAssertEqual(entity.playbackevent, "_playbackevent")
        XCTAssertTrue(compare(entity.endcard, JSON.rewardedCompletionVideoEndcard()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedCompletionVideoEndcard() {
        let json = JSON.rewardedCompletionVideoEndcard()
        let entity = PBMORTBRewardedCompletionVideoEndcard(jsonDictionary: json)!
        XCTAssertEqual(entity.time, 1)
        XCTAssertEqual(entity.event, "_event")
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedConfiguration() {
        let json = JSON.rewardedConfiguration()
        let entity = PBMORTBRewardedConfiguration(jsonDictionary: json)!
        XCTAssertTrue(compare(entity.reward, JSON.rewardedReward()))
        XCTAssertTrue(compare(entity.completion, JSON.rewardedCompletion()))
        XCTAssertTrue(compare(entity.close, JSON.rewardedClose()))
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testRewardedReward() {
        let json = JSON.rewardedReward()
        let entity = PBMORTBRewardedReward(jsonDictionary: json)!
        XCTAssertEqual(entity.type, "_type")
        XCTAssertEqual(entity.count, 1)
        XCTAssertEqual(entity.ext as NSDictionary?,
                       ["ext_k1" : "ext_str", "ext_k2" : 1] as NSDictionary)
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    func testSDKConfiguration() {
        let json = JSON.sdkConfiguration()
        let entity = PBMORTBSDKConfiguration(jsonDictionary: json)!
        XCTAssertEqual(entity.cftBanner, 1)
        XCTAssertEqual(entity.cftPreRender, 2)
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
        
    }
    
    func testSkadnFidelity() {
        let json = JSON.skadnFidelity()
        let entity = PBMORTBSkadnFidelity(jsonDictionary: json)!
        XCTAssertEqual(entity.fidelity, 1)
        XCTAssertEqual(entity.nonce, UUID(uuidString: "12345678-ABCD-1234-ABCD-1234567890AB"))
        XCTAssertEqual(entity.timestamp, 2)
        XCTAssertEqual(entity.signature, "_signature")
        
        XCTAssertEqual(entity.toJsonDictionary() as NSDictionary, json as NSDictionary)
    }
    
    @objc(compareObj::)
    func compare(_ entity: PBMORTBAbstract?, _ object: [String : Any]) -> Bool {
        guard let entity else {
            return false
        }
        return entity.toJsonDictionary() as NSDictionary == object as NSDictionary
    }
    
    @objc(compareArray::)
    func compare(_ entities: [PBMORTBAbstract]?, _ array: [[String : Any]]) -> Bool {
        guard let entities else {
            return false
        }
        
        return entities.map { $0.toJsonDictionary() as NSDictionary } == array.map { $0 as NSDictionary }
    }
    
}
