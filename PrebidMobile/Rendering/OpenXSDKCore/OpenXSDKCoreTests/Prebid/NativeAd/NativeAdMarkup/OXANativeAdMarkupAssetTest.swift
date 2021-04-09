//
//  OXANativeAdMarkupAssetTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdMarkupAssetTest: XCTestCase {
    func testInitFromJson() {
        let dataDic: [String: Any] = [
            "len": 15,
            "value": "some data value",
            "type": OXADataAssetType.desc.rawValue,
            "ext": ["da": "db"],
        ]
        let imageDic: [String: Any] = [
            "w": 320,
            "h": 240,
            "type": OXAImageAssetType.main.rawValue,
            "url": "image url",
            "ext": ["ia": "ib"],
        ]
        let titleDic: [String: Any] = [
            "text": "Some long title text",
            "len": 20,
            "ext": ["ta": "tb"],
        ]
        let videoDic: [String: Any] = [
            "vasttag": "video vast tag"
        ]
        
        let linkDic: [String: Any] = [
            "fallback": "fallback-url",
            "clicktrackers": ["first-clicktracker", "Last Clicktracker"],
            "url": "link url",
            "ext": ["la": "lb"],
        ]
        
        let optionalProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupAsset>] = [
            JSONDecoding.OptionalPropertyCheck(value: 19546, dicKey: "id", keyPath: \.assetID),
            JSONDecoding.OptionalPropertyCheck(value: true, dicKey: "required", keyPath: \.required),
            JSONDecoding.OptionalPropertyCheck(value: try! OXANativeAdMarkupData(jsonDictionary: dataDic),
                                               writer: { json, data in json["data"] = dataDic },
                                               reader: { $0.data }),
            JSONDecoding.OptionalPropertyCheck(value: try! OXANativeAdMarkupImage(jsonDictionary: imageDic),
                                               writer: { json, image in json["img"] = imageDic },
                                               reader: { $0.img }),
            JSONDecoding.OptionalPropertyCheck(value: try! OXANativeAdMarkupTitle(jsonDictionary: titleDic),
                                               writer: { json, title in json["title"] = titleDic },
                                               reader: { $0.title }),
            JSONDecoding.OptionalPropertyCheck(value: try! OXANativeAdMarkupVideo(jsonDictionary: videoDic),
                                               writer: { json, video in json["video"] = videoDic },
                                               reader: { $0.video }),
            JSONDecoding.OptionalPropertyCheck(value: try! OXANativeAdMarkupLink(jsonDictionary: linkDic),
                                               writer: { json, link in json["link"] = linkDic },
                                               reader: { $0.link }),
            JSONDecoding.OptionalPropertyCheck(value: ["q": "z"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let tester = JSONDecoding.Tester(generator: OXANativeAdMarkupAsset.init(jsonDictionary:),
                                         requiredPropertyChecks: [],
                                         optionalPropertyChecks: optionalProperties)
        tester.run()
    }
    
    func testIsEqual() {
        func checkEquality<Q>(source: @escaping @autoclosure ()->Q, generator: @escaping (Q)->OXANativeAdMarkupAsset) {
            let tester: Equality.Tester<OXANativeAdMarkupAsset> =
                Equality.Tester(template: generator(source()), checks: [
                    Equality.Check(values: 102, 907, keyPath: \.assetID),
                    Equality.Check(values: 0, 1, keyPath: \.required),
                    Equality.Check(values: OXANativeAdMarkupTitle(text: "t1"), OXANativeAdMarkupTitle(text: "T."),
                                   keyPath: \.title),
                    Equality.Check(values: OXANativeAdMarkupImage(url: "url"), OXANativeAdMarkupImage(url: "zURL"),
                                   keyPath: \.img),
                    Equality.Check(values: OXANativeAdMarkupVideo(vastTag: "v"), OXANativeAdMarkupVideo(vastTag: "W"),
                                   keyPath: \.video),
                    Equality.Check(values: OXANativeAdMarkupData(value: "q25"), OXANativeAdMarkupData(value: "tGs"),
                                   keyPath: \.data),
                    Equality.Check(values: OXANativeAdMarkupLink(url: "url"), OXANativeAdMarkupLink(url: "zURL"),
                                   keyPath: \.link),
                    Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
                ])
            tester.run()
        }
        checkEquality(source: OXANativeAdMarkupTitle(text: ""), generator: OXANativeAdMarkupAsset.init)
        checkEquality(source: OXANativeAdMarkupImage(url: ""), generator: OXANativeAdMarkupAsset.init)
        checkEquality(source: OXANativeAdMarkupVideo(vastTag: ""), generator: OXANativeAdMarkupAsset.init)
        checkEquality(source: OXANativeAdMarkupData(value: ""), generator: OXANativeAdMarkupAsset.init)
    }
}
