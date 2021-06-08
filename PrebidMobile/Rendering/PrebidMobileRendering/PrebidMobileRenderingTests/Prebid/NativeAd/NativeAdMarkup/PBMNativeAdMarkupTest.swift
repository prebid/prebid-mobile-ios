//
//  PBMNativeAdMarkupTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdMarkupTest: XCTestCase {
    func testInitFromJson() {
        let linkDic: [String: Any] = [
            "fallback": "fallback-url",
            "clicktrackers": ["first-clicktracker", "Last Clicktracker"],
            "url": "link url",
            "ext": ["la": "lb"],
        ]
        
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkup>, Error)] = []
        
        let assetDic: [String: Any] = [
            "id": 45876,
            "required": true,
            "img": [
                "w": 320,
                "h": 240,
                "type": NativeImageAssetType.main.rawValue,
                "url": "image url",
                "ext": ["ia": "ib"],
            ],
            "link": [
                "fallback": "<asset> fallback-url",
                "clicktrackers": ["<asset> first-clicktracker", "<asset> Last Clicktracker"],
                "url": "<asset> link url",
                "ext": ["<asset> la": "<asset> lb"],
            ],
            "ext": ["aa": "ba"]
        ]
        let eventTrackerDic: [String: Any] = [
            "event": NativeEventType.impression.rawValue,
            "method": NativeEventTrackingMethod.img.rawValue,
            "url": "event tracker url",
            "customdata": ["g": "h"],
            "ext": ["eta": "etb"],
        ]
        
        let optionalLinkProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkup>] = [
            JSONDecoding.OptionalPropertyCheck(value: try! PBMNativeAdMarkupLink(jsonDictionary: linkDic),
                                               writer: { json, arr in json["link"] = linkDic },
                                               reader: { $0.link }),
            JSONDecoding.OptionalPropertyCheck(value: "0.6", dicKey: "ver", keyPath: \.version),
            JSONDecoding.OptionalPropertyCheck(value: [try! PBMNativeAdMarkupAsset(jsonDictionary: assetDic)],
                                               writer: { json, arr in json["assets"] = [assetDic] },
                                               reader: { $0.assets }),
            JSONDecoding.OptionalPropertyCheck(value: "a://b.c/d", dicKey: "assetsurl", keyPath: \.assetsurl),
            JSONDecoding.OptionalPropertyCheck(value: "x://n.m:l/", dicKey: "dcourl", keyPath: \.dcourl),
            JSONDecoding.OptionalPropertyCheck(value: ["the Imptracker", "fake imp-tracker"],
                                               dicKey: "imptrackers",
                                               keyPath: \.imptrackers),
            JSONDecoding.OptionalPropertyCheck(value: "s://d.f:v/", dicKey: "jstracker", keyPath: \.jstracker),
            JSONDecoding.OptionalPropertyCheck(value: [try! .init(jsonDictionary: eventTrackerDic)],
                                               writer: { json, arr in json["eventtrackers"] = [eventTrackerDic] },
                                               reader: { $0.eventtrackers }),
            JSONDecoding.OptionalPropertyCheck(value: "privacy string here", dicKey: "privacy", keyPath: \.privacy),
            JSONDecoding.OptionalPropertyCheck(value: ["?a?": "-b-"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let markupTester = JSONDecoding.Tester(generator: PBMNativeAdMarkup.init(jsonDictionary:),
                                               requiredPropertyChecks: requiredProperties,
                                               optionalPropertyChecks: optionalLinkProperties)
        
        markupTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkup> =
            Equality.Tester(template: PBMNativeAdMarkup(link: .init(url: "")), checks: [
                Equality.Check(values: "0.4", "1.2", keyPath: \.version),
                Equality.Check(values: [
                    PBMNativeAdMarkupAsset(data: .init(value: "data value")),
                ], [
                    PBMNativeAdMarkupAsset(video: .init(vastTag: "vast XML !")),
                ], keyPath: \.assets),
                Equality.Check(values: "a://b.c/d", "q://r.t:y/", keyPath: \.assetsurl),
                Equality.Check(values: "g://h.o/p", "x://n.m:l/", keyPath: \.dcourl),
                Equality.Check(values: .init(url: "alpha"), .init(url: "beta"), keyPath: \.link),
                Equality.Check(values: ["only"], ["first", "last"], keyPath: \.imptrackers),
                Equality.Check(values: "u://i.o/p", "s://d.f:v/", keyPath: \.jstracker),
                Equality.Check(values: [
                    PBMNativeAdMarkupEventTracker(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "event url 1"),
                ], [
                    PBMNativeAdMarkupEventTracker(event: NativeEventType.impression.rawValue, method: NativeEventTrackingMethod.img.rawValue, url: "event-2 url"),
                ], keyPath: \.eventtrackers),
                Equality.Check(values: "some privacy", "we are watching you", keyPath: \.privacy),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
    
    func testErrorInvalidJsonString() {
        let invalidities = [
            // "\u{12}\u{0}\u{6}\u{13}\u{0a}\u{0c}": "Invalid JSON data", // TODO: Find string to cause this error?
            "{*]": "Could not convert json data to jsonObject",
            "[2,7,13]": "Could not cast jsonObject to JsonDictionary",
        ]
        for (jsonString, errorPrefix) in invalidities {
            do {
                _ = try PBMNativeAdMarkup(jsonString: jsonString)
                XCTFail()
            } catch {
                XCTAssert(error.localizedDescription.hasPrefix(errorPrefix), "'\(jsonString)' produces: \(error.localizedDescription)")
            }
        }
    }
    
    func testInitFromJsonString() {
        let jsonString = "{\"assets\":[{\"required\":1,\"title\":{\"text\":\"OpenX (Title)\"}},{\"required\":1,\"img\":{\"type\":1,\"url\":\"https://www.saashub.com/images/app/service_logos/5/1df363c9a850/large.png?1525414023\"}},{\"required\":1,\"img\":{\"type\":3,\"url\":\"https://ssl-i.cdn.openx.com/mobile/demo-creatives/mobile-demo-banner-640x100.png\"}},{\"required\":1,\"data\":{\"type\":1,\"value\":\"OpenX (Brand)\"}},{\"required\":1,\"data\":{\"type\":2,\"value\":\"Learn all about this awesome story of someone using out OpenX SDK.\"}},{\"required\":1,\"data\":{\"type\":12,\"value\":\"Click here to visit our site\"}}],\"link\":{\"url\":\"https://www.openx.com/\"}}"
        let jsonDic: [String: Any] = ["assets":[["required":1,"title":["text":"OpenX (Title)"]],["required":1,"img":["type":1,"url":"https://www.saashub.com/images/app/service_logos/5/1df363c9a850/large.png?1525414023"]],["required":1,"img":["type":3,"url":"https://ssl-i.cdn.openx.com/mobile/demo-creatives/mobile-demo-banner-640x100.png"]],["required":1,"data":["type":1,"value":"OpenX (Brand)"]],["required":1,"data":["type":2,"value":"Learn all about this awesome story of someone using out OpenX SDK."]],["required":1,"data":["type":12,"value":"Click here to visit our site"]]],"link":["url":"https://www.openx.com/"]]
        XCTAssertEqual(try! PBMNativeAdMarkup(jsonString: jsonString), try! PBMNativeAdMarkup(jsonDictionary: jsonDic))
    }
}
