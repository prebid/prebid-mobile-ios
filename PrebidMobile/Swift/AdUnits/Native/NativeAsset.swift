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

/// Represents a generic native ad asset which could be a title, image, or data.
public class NativeAsset: NSObject {
    
    /// Unique identifier for the asset.
    var id: NSInteger!
    
    /// Indicates whether the asset is required for the ad to be considered valid.
    public var required: Bool = false

    /// Initializes a new instance of `NativeAsset`.
    /// - Parameter isRequired: A boolean indicating whether the asset is required.
    public init(isRequired: Bool) {
        super.init()
        required = isRequired
    }
    
    /// Generates a dictionary representation of the asset object.
    /// - Parameter id: An optional identifier to be included in the asset dictionary.
    /// - Returns: A dictionary representing the asset with its properties.
    func getAssetObject(id : Int) -> [AnyHashable: Any] {
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
        if(id > 0){
            asset["id"] = id
        }
        return asset
    }
    
}

/// Represents a title asset in a native ad.
@objcMembers public class NativeAssetTitle: NativeAsset {
    
    /// Maximum length of the title.
    var length: NSInteger! = 25
    
    /// Additional custom properties for the title asset.
    public var ext: AnyObject?
    
    /// Initializes a new instance of `NativeAssetTitle`.
    /// - Parameters:
    ///   - length: The maximum length of the title.
    ///   - required: A boolean indicating whether the asset is required.
    public required init(length: NSInteger, required: Bool) {
        super.init(isRequired: required)
        self.length = length
    }
    
    /// Generates a dictionary representation of the title asset object.
    /// - Returns: A dictionary representing the title asset with its properties.
    func getTitleObject() -> [AnyHashable: Any] {
        var title: [AnyHashable: Any] = [:]
        
        title["len"] = length
        title["ext"] = ext
        
        return title
    }
}

/// Represents an image asset in a native ad.
@objcMembers public class NativeAssetImage: NativeAsset {
    
    /// The type of the image asset.
    public var type: ImageAsset?
    
    /// The width of the image asset.
    public var width: Int?
    
    /// The minimum width of the image asset.
    public var widthMin: Int?
    
    /// The height of the image asset.
    public var height: Int?
    
    /// The minimum height of the image asset.
    public var heightMin: Int?
    
    /// The MIME types supported for the image asset.
    public var mimes: Array<String>?
    
    /// Additional custom properties for the image asset.
    public var ext: AnyObject?
    
    /// Initializes a new instance of `NativeAssetImage`.
    /// - Parameters:
    ///   - minimumWidth: The minimum width of the image.
    ///   - minimumHeight: The minimum height of the image.
    ///   - required: A boolean indicating whether the asset is required.
    public convenience init(minimumWidth: Int, minimumHeight: Int, required: Bool) {
        self.init(isRequired: required)
        self.widthMin = minimumWidth
        self.heightMin = minimumHeight
    }
    
    /// Initializes a new instance of `NativeAssetImage`.
    /// - Parameters:
    ///   - isRequired: A boolean indicating whether the asset is required.
    public override init(isRequired: Bool) {
        super.init(isRequired: isRequired)
    }
    
    /// Generates a dictionary representation of the image asset object.
    /// - Returns: A dictionary representing the image asset with its properties.
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

/// Represents a data asset in a native ad.
@objcMembers public class NativeAssetData: NativeAsset {
    
    /// The type of the data asset.
    var type: DataAsset?
    
    /// The length of the data asset.
    public var length: Int?
    
    /// Additional custom properties for the data asset.
    public var ext: AnyObject?
    
    /// Initializes a new instance of `NativeAssetData`.
    /// - Parameters:
    ///   - type: The type of the data asset.
    ///   - required: A boolean indicating whether the asset is required.
    public required init(type: DataAsset, required: Bool) {
        super.init(isRequired: required)
        self.type = type
    }
    
    /// Generates a dictionary representation of the data asset object.
    /// - Returns: A dictionary representing the data asset with its properties.
    func getDataObject() -> [AnyHashable: Any]{
        var data: [AnyHashable: Any] = [:]
        
        data["type"] = type?.rawValue
        data["len"] = length
        data["ext"] = ext

        return data
    }
}

/// Native image asset type.
public class ImageAsset: SingleContainerInt {
    
    /// Represents an icon image asset.
    @objc
    public static let Icon = ImageAsset(1)
    
    /// Represents the main image asset.
    @objc
    public static let Main = ImageAsset(3)
    
    /// Represents a custom image asset.
    @objc
    public static let Custom = ImageAsset(500)
}

/// Enum representing different types of native data assets.
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
    /// Custom type for user-defined data assets
    case Custom
    
    private static var customValue = 500
    
    /// Gets or sets the exchange ID for the asset type.
    /// - Returns: The exchange ID for the asset type.
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
