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
    
    public init(isRequired: Bool) {
        super.init()
        required = isRequired
    }
    
    func getAssetObject() -> [AnyHashable: Any] {
        var asset: [AnyHashable: Any] = [:]
        
        //asset["id"] = Int.random(in: 0...1000)
        asset["required"] = Int(truncating: NSNumber(value: required))
        
        if let titleObject = self as? NativeAssetTitle {
            asset["title"] = titleObject.getTitleObject()
        } else  if let imageObject = self as? NativeAssetImage {
            asset["img"] = imageObject.getImageObject()
        } else if let dataObject = self as? NativeAssetData {
            asset["data"] = dataObject.getDataObject()
        }
        return asset
    }
    
}

@objcMembers public class NativeAssetTitle: NativeAsset {
    
    var length: NSInteger! = 25
    
    public var ext: AnyObject?
    
    public required init(length: NSInteger, required: Bool) {
        super.init(isRequired: required)
        self.length = length
    }
    
    func getTitleObject() -> [AnyHashable: Any] {
        var title: [AnyHashable: Any] = [:]
        
        title["len"] = length
        title["ext"] = ext
        
        return title
    }
    
}

@objcMembers public class NativeAssetImage: NativeAsset {
    
    public var type: ImageAsset?
    public var width: Int?
    public var widthMin: Int?
    public var height: Int?
    public var heightMin: Int?
    public var mimes: Array<String>?
    public var ext: AnyObject?
    
    public convenience init(minimumWidth: Int, minimumHeight: Int, required: Bool) {
        self.init(isRequired: required)
        self.widthMin = minimumWidth
        self.heightMin = minimumHeight
    }
    
    public override init(isRequired: Bool) {
        super.init(isRequired: isRequired)
    }
    
    func getImageObject() -> [AnyHashable: Any] {
        
        var image: [AnyHashable: Any] = [:]
        
        image["type"] = type?.value
        image["w"] = width
        image["wmin"] = widthMin
        image["h"] = height
        image["hmin"] = heightMin
        image["mimes"] = mimes
        image["ext"] = ext
        
        return image
    }
    
}

@objcMembers public class NativeAssetData: NativeAsset {
    var type: DataAsset?
    public var length: Int?
    public var ext: AnyObject?
    
    public required init(type: DataAsset, required: Bool) {
        super.init(isRequired: required)
        self.type = type
    }
    
    func getDataObject() -> [AnyHashable: Any]{
        var data: [AnyHashable: Any] = [:]
        
        data["type"] = type?.rawValue
        data["len"] = length
        data["ext"] = ext

        return data
    }
}

public class ImageAsset: SingleContainerInt {
    
    @objc
    public static let Icon = ImageAsset(1)
    
    @objc
    public static let Main = ImageAsset(3)
    
    @objc
    public static let Custom = ContextType(500)
    
}


@objc public enum DataAsset: Int {
    case sponsored = 1
    case description = 2
    case rating = 3
    case likes = 4
    case downloads = 5
    case price = 6
    case saleprice = 7
    case phone = 8
    case address = 9
    case description2 = 10
    case displayurl = 11
    case ctatext = 12
    case Custom
    
    private static var customValue = 500
        
        public var exchangeID:Int {
            get {
                switch self {
                case .Custom:
                    return DataAsset.customValue
                default:
                    return self.rawValue
                }
            }
            set {
                DataAsset.customValue = newValue
            }
            
        }
}
