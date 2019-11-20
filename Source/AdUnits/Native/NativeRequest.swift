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

public class NativeRequest: AdUnit {
    
    var version: String = "1.2"
    public var context: ContextType?
    public var contextSubType: ContextSubType?
    public var placementType: PlacementType?
    public var placementCount: Int = 1
    public var sequence: Int  = 0
    public var assets: Array<NativeAsset>?
    public var asseturlsupport: Int = 0
    public var durlsupport: Int = 0
    public var eventtrackers:Array<NativeEventTracker>?
    public var privacy: Int = 0
    public var ext: AnyObject?
    
    public init(configId: String) {
        super.init(configId: configId, size:nil)
    }
    
    public convenience init(configId: String, assets: Array<NativeAsset>) {
        self.init(configId: configId)
        self.assets = assets
    }
    
    func getNativeRequestObject() -> [AnyHashable: Any]? {
        var nativeObject: [AnyHashable:Any] = [:]
        nativeObject["ver"] = version
        var requestObject: [AnyHashable:Any] = [:]
        
        requestObject["plcmttype"] = placementType?.rawValue
        requestObject["context"] = context?.rawValue
        requestObject["contextsubtype"] = contextSubType?.rawValue
        
        if (sequence > 0) {
            requestObject["seq"] = sequence
        }
        if (asseturlsupport > 0) {
            requestObject["aurlsupport"] = asseturlsupport
        }
        if (durlsupport > 0) {
            requestObject["durlsupport"] = durlsupport
        }
        if (privacy > 0) {
            requestObject["privacy"] = privacy
        }
        
        requestObject["ext"] = ext
        requestObject["plcmtcnt"] = placementCount
        
        if let assets = assets {
            var assetsObjects:[Any] = []
            for asset:NativeAsset in assets {
                assetsObjects.append(asset.getAssetObject())
            }
            
            requestObject["assets"] = assetsObjects
        }
        
        if let eventtrackers = eventtrackers, eventtrackers.count > 0 {
            var eventObjects:[Any] = []
            for event:NativeEventTracker in eventtrackers {
                eventObjects.append(event.getEventTracker())
            }
            
            requestObject["eventtrackers"] = eventObjects
        }
        
        do {
            let nativeData = try JSONSerialization.data(withJSONObject: requestObject, options: .prettyPrinted)

            let stringObject = String.init(data: nativeData, encoding: String.Encoding.utf8)
            
            nativeObject["request"] = stringObject
            
        } catch let error {
            Log.error(error.localizedDescription)
        }
        
        return nativeObject
    }

}

@objc public enum ContextType: Int {
    case Content = 1
    case Social = 2
    case Product = 3
    case Custom
    
    private static var customValue = 500
    
    public var exchangeID:Int {
        get {
            switch self {
            case .Custom:
                return ContextType.customValue
            default:
                return self.rawValue
            }
        }
        set {
            ContextType.customValue = newValue
        }
        
    }
}

@objc public enum ContextSubType: Int {
    case General = 10
    case Article = 11
    case Video = 12
    case Audio = 13
    case Image = 14
    case UserGenerated = 15
    case Social = 20
    case email = 21
    case chatIM = 22
    case SellingProduct = 30
    case AppStore = 31
    case ReviewSite = 32
    case Custom
    
    private static var customValue = 500
        
        public var exchangeID:Int {
            get {
                switch self {
                case .Custom:
                    return ContextSubType.customValue
                default:
                    return self.rawValue
                }
            }
            set {
                ContextSubType.customValue = newValue
            }
            
        }
}

@objc public enum PlacementType: Int {
    case FeedContent = 1
    case AtomicContent = 2
    case OutsideContent = 3
    case RecommendationWidget = 4
    case Custom
    
    private static var customValue = 500
        
        public var exchangeID:Int {
            get {
                switch self {
                case .Custom:
                    return PlacementType.customValue
                default:
                    return self.rawValue
                }
            }
            set {
                PlacementType.customValue = newValue
            }
            
        }
}





