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
    
    public var configId: String {
        adUnitConfig.configId
    }
    
    public init(configId: String) {
        super.init(configId: configId, size: CGSize.zero)   
    }
    
    public convenience init(configId: String, assets: Array<NativeAsset>? = nil, eventTrackers: Array<NativeEventTracker>? = nil) {
        self.init(configId: configId)
        self.assets = assets
        self.eventtrackers = eventtrackers
    }
    
    public func addNativeAssets(_ assets: Array<NativeAsset>) {
        if self.assets != nil {
            self.assets?.append(contentsOf: assets)
        } else {
            self.assets = assets
        }
    }
    
    public func addNativeEventTracker(_ eventTrackers: Array<NativeEventTracker>) {
        if eventtrackers != nil {
            self.eventtrackers?.append(contentsOf: eventTrackers)
        } else {
            self.eventtrackers = eventTrackers
        }
    }

    public func getNativeRequestObject() -> [AnyHashable: Any]? {
        var nativeObject: [AnyHashable:Any] = [:]
        nativeObject["ver"] = version
        var requestObject: [AnyHashable:Any] = [:]
        
        requestObject["plcmttype"] = placementType?.value
        requestObject["context"] = context?.value
        requestObject["contextsubtype"] = contextSubType?.value
        
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
        var idCount: Int = 0
        if let assets = assets {
            var assetsObjects:[Any] = []
            for asset:NativeAsset in assets {
                if(PrebidConfiguration.shared.shouldAssignNativeAssetID){
                    idCount += 1
                }
                assetsObjects.append(asset.getAssetObject(id: idCount))
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

public class ContextType: SingleContainerInt {
    
    @objc
    public static let Content = ContextType(1)
    
    @objc
    public static let Social = ContextType(2)
    
    @objc
    public static let Product = ContextType(3)
    
    @objc
    public static let Custom = ContextType(500)
    
}

public class ContextSubType: SingleContainerInt {
    @objc
    public static let General = ContextSubType(10)

    @objc
    public static let Article = ContextSubType(11)

    @objc
    public static let Video = ContextSubType(12)

    @objc
    public static let Audio = ContextSubType(13)

    @objc
    public static let Image = ContextSubType(14)

    @objc
    public static let UserGenerated = ContextSubType(15)

    @objc
    public static let Social = ContextSubType(20)

    @objc
    public static let email = ContextSubType(21)

    @objc
    public static let chatIM = ContextSubType(22)

    @objc
    public static let SellingProduct = ContextSubType(30)

    @objc
    public static let AppStore = ContextSubType(31)

    @objc
    public static let ReviewSite = ContextSubType(32)

    @objc
    public static let Custom = ContextSubType(500)
}

public class PlacementType: SingleContainerInt {
    @objc
    public static let FeedContent = PlacementType(1)

    @objc
    public static let AtomicContent = PlacementType(2)

    @objc
    public static let OutsideContent = PlacementType(3)

    @objc
    public static let RecommendationWidget = PlacementType(4)

    @objc
    public static let Custom = PlacementType(500)
}





