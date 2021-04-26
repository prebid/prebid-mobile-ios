//
//  PBMNativeAdMarkupAssetTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdMarkupAssetTest: XCTestCase {
    func testInitFromJson() {
        let dataDic: [String: Any] = [
            "len": 15,
            "value": "some data value",
            "type": PBMDataAssetType.desc.rawValue,
            "ext": ["da": "db"],
        ]
        let imageDic: [String: Any] = [
            "w": 320,
            "h": 240,
            "type": PBMImageAssetType.main.rawValue,
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
        
        let optionalProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupAsset>] = [
            JSONDecoding.OptionalPropertyCheck(value: 19546, dicKey: "id", keyPath: \.assetID),
            JSONDecoding.OptionalPropertyCheck(value: true, dicKey: "required", keyPath: \.required),
            JSONDecoding.OptionalPropertyCheck(value: try! PBMNativeAdMarkupData(jsonDictionary: dataDic),
                                               writer: { json, data in json["data"] = dataDic },
                                               reader: { $0.data }),
            JSONDecoding.OptionalPropertyCheck(value: try! PBMNativeAdMarkupImage(jsonDictionary: imageDic),
                                               writer: { json, image in json["img"] = imageDic },
                                               reader: { $0.img }),
            JSONDecoding.OptionalPropertyCheck(value: try! PBMNativeAdMarkupTitle(jsonDictionary: titleDic),
                                               writer: { json, title in json["title"] = titleDic },
                                               reader: { $0.title }),
            JSONDecoding.OptionalPropertyCheck(value: try! PBMNativeAdMarkupVideo(jsonDictionary: videoDic),
                                               writer: { json, video in json["video"] = videoDic },
                                               reader: { $0.video }),
            JSONDecoding.OptionalPropertyCheck(value: try! PBMNativeAdMarkupLink(jsonDictionary: linkDic),
                                               writer: { json, link in json["link"] = linkDic },
                                               reader: { $0.link }),
            JSONDecoding.OptionalPropertyCheck(value: ["q": "z"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let tester = JSONDecoding.Tester(generator: PBMNativeAdMarkupAsset.init(jsonDictionary:),
                                         requiredPropertyChecks: [],
                                         optionalPropertyChecks: optionalProperties)
        tester.run()
    }
    
    func testIsEqual() {
        func checkEquality<Q>(source: @escaping @autoclosure ()->Q, generator: @escaping (Q)->PBMNativeAdMarkupAsset) {
            let tester: Equality.Tester<PBMNativeAdMarkupAsset> =
                Equality.Tester(template: generator(source()), checks: [
                    Equality.Check(values: 102, 907, keyPath: \.assetID),
                    Equality.Check(values: 0, 1, keyPath: \.required),
                    Equality.Check(values: PBMNativeAdMarkupTitle(text: "t1"), PBMNativeAdMarkupTitle(text: "T."),
                                   keyPath: \.title),
                    Equality.Check(values: PBMNativeAdMarkupImage(url: "url"), PBMNativeAdMarkupImage(url: "zURL"),
                                   keyPath: \.img),
                    Equality.Check(values: PBMNativeAdMarkupVideo(vastTag: "v"), PBMNativeAdMarkupVideo(vastTag: "W"),
                                   keyPath: \.video),
                    Equality.Check(values: PBMNativeAdMarkupData(value: "q25"), PBMNativeAdMarkupData(value: "tGs"),
                                   keyPath: \.data),
                    Equality.Check(values: PBMNativeAdMarkupLink(url: "url"), PBMNativeAdMarkupLink(url: "zURL"),
                                   keyPath: \.link),
                    Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
                ])
            tester.run()
        }
        checkEquality(source: PBMNativeAdMarkupTitle(text: ""), generator: PBMNativeAdMarkupAsset.init)
        checkEquality(source: PBMNativeAdMarkupImage(url: ""), generator: PBMNativeAdMarkupAsset.init)
        checkEquality(source: PBMNativeAdMarkupVideo(vastTag: ""), generator: PBMNativeAdMarkupAsset.init)
        checkEquality(source: PBMNativeAdMarkupData(value: ""), generator: PBMNativeAdMarkupAsset.init)
    }
}
