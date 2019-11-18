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

import UIKit

public class NativeAsset: NSObject {
    
    var id: NSInteger!
    public var required: Bool = false
    public var assetObject:AnyObject?
    
    public required init?(isRequired: Bool, nativeObject:AnyObject) {
        super.init()
        required = isRequired
        var containsAssetType = true
        
        switch nativeObject {
            case let nativeObject as NativeAssetImage:
                self.assetObject = nativeObject
            case is NativeAssetTitle:
                self.assetObject = nativeObject
            case is NativeAssetData:
                self.assetObject = nativeObject
            default: containsAssetType = false
        }
        
        if(containsAssetType == false){
            return nil
        }
    }
    
    func getAssetObject() -> [AnyHashable: Any] {
        var asset: [AnyHashable: Any] = [:]
        
        //asset["id"] = Int.random(in: 0...1000)
        asset["required"] = Int(truncating: NSNumber(value: required))
        
        if let titleObject = assetObject as? NativeAssetTitle {
            asset["title"] = titleObject.getTitleObject()
        } else  if let imageObject = assetObject as? NativeAssetImage {
            asset["img"] = imageObject.getImageObject()
        } else if let dataObject = assetObject as? NativeAssetData {
            asset["data"] = dataObject.getDataObject()
        }
        return asset
    }
    
}

@objcMembers public class NativeAssetTitle: NSObject {
    
    var length: NSInteger! = 25
    
    public var ext: AnyObject?
    
    public required init(length: NSInteger) {
        super.init()
        self.length = length
    }
    
    func getTitleObject() -> [AnyHashable: Any] {
        var title: [AnyHashable: Any] = [:]
        
        title["len"] = length
        title["ext"] = ext
        
        return title
    }
    
}

public class NativeAssetImage: NSObject {
    
    public var type: ImageAsset?
    public var width: Int?
    public var widthMin: Int?
    public var height: Int?
    public var heightMin: Int?
    public var mimes: Array<String>?
    public var ext: AnyObject?
    
    public convenience init(minimumWidth: Int, minimumHeight: Int){
        self.init()
        self.widthMin = minimumWidth
        self.heightMin = minimumHeight
    }
    
    func getImageObject() -> [AnyHashable: Any] {
        
        var image: [AnyHashable: Any] = [:]
        
        image["type"] = type?.rawValue
        image["w"] = width
        image["wmin"] = widthMin
        image["h"] = height
        image["hmin"] = heightMin
        image["mimes"] = mimes
        image["ext"] = ext
        
        return image
    }
    
}

public class NativeAssetData: NSObject {
    var type: Int
    public var length: Int?
    public var ext: AnyObject?
    
    required public init(type: Int) {
        self.type = type
        
        super.init()
    }
    
    func getDataObject() -> [AnyHashable: Any]{
        var data: [AnyHashable: Any] = [:]
        
        data["type"] = type
        data["len"] = length
        data["ext"] = ext

        return data
    }
}

@objc public enum ImageAsset: Int {
    case Icon = 1
    case Main = 3
    case Custom = 500
}
