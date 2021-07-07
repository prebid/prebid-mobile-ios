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

import PrebidMobileRendering

extension NativeAsset {
    class func parse(json: [String:Any]) -> NativeAsset? {
        var asset: NativeAsset!
        var childDic: [String: Any]!
        let parsers: [String: ([String: Any])->NativeAsset?] = [
            "data": NativeAssetData.init(childJson:),
            "img": NativeAssetImage.init(childJson:),
            "title": NativeAssetTitle.init(childJson:),
            "video": NativeAssetVideo.init(childJson:),
        ]
        for (key, builder) in parsers {
            if let dic = json[key] as? [String: Any], let result = builder(dic) {
                childDic = dic
                asset = result
                break
            }
        }
        asset.assetID = json["id"] as? NSNumber
        asset.required = json["required"] as? NSNumber
        try? asset.setAssetExt(json["ext"] as! [String: Any])
        try? asset.setChildExt(childDic["ext"] as! [String: Any])
        return asset
    }
}

fileprivate extension NativeAssetTitle {
    convenience init?(childJson: [String: Any]) {
        guard let length = childJson["len"] as? NSNumber else {
            return nil
        }
        self.init(length: length.intValue)
    }
}

fileprivate extension NativeAssetData {
    convenience init?(childJson: [String: Any]) {
        guard let rawDataType = childJson["type"] as? NSNumber,
              let dataType = NativeDataAssetType(rawValue: rawDataType.intValue)
        else {
            return nil
        }
        self.init(dataType: dataType)
        length = childJson["len"] as? NSNumber
    }
}

fileprivate extension NativeAssetImage {
    convenience init?(childJson: [String: Any]) {
        self.init()
        imageType = childJson["type"] as? NSNumber
        width = childJson["w"] as? NSNumber
        height = childJson["h"] as? NSNumber
        widthMin = childJson["wmin"] as? NSNumber
        heightMin = childJson["hmin"] as? NSNumber
        mimeTypes = childJson["mimes"] as? [String]
    }
}

fileprivate extension NativeAssetVideo {
    convenience init?(childJson: [String: Any]) {
        guard let mimes = childJson["mimes"] as? [String],
              let minDuration = childJson["minDuration"] as? NSNumber,
              let maxDuration = childJson["maxDuration"] as? NSNumber,
              let protocols = childJson["protocols"] as? [NSNumber]
        else {
            return nil
        }
        self.init(mimeTypes: mimes,
                  minDuration: minDuration.intValue,
                  maxDuration: maxDuration.intValue,
                  protocols: protocols)
    }
}
