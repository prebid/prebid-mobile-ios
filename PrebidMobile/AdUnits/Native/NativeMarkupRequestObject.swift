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

/// Represents a request object for native markup, including details about the ad's context, placement, and supported features.
@objc(PBMNativeMarkupRequestObject) @objcMembers
public class NativeMarkupRequestObject: NSObject, NSCopying, PBMJsonCodable {
    
    /// [Recommended]
    /// [Integer]
    /// The context in which the ad appears.
    /// See NativeContextType
    public var context: ContextType?
    
    /// [Integer]
    /// A more detailed context in which the ad appears.
    /// See NativeContextSubtype
    public var contextsubtype: ContextSubType?
    
    /// [Recommended]
    /// [Integer]
    /// The design/format/layout of the ad unit being offered.
    /// See NativePlacementType
    public var plcmttype: PlacementType?
    
    /// [Integer]
    /// The number of identical placements in this Layout. Refer Section 8.1 Multiplacement Bid Requests for further detail.
    public var plcmtcnt = 1
    
    /// [Integer]
    /// 0 for the first ad, 1 for the second ad, and so on.
    /// Note this would generally NOT be used in combination with plcmtcnt -
    /// either you are auctioning multiple identical placements (in which case plcmtcnt>1, seq=0)
    /// or you are holding separate auctions for distinct items in the feed (in which case plcmtcnt=1, seq=>=1)
    public var seq = 0
    
    /// [Required]
    /// An array of Asset Objects. Any objects bid response must comply with the array of elements expressed in the bid request.
    public var assets: [NativeAsset]?
    
    /// [Integer]
    /// Whether the supply source / impression supports returning an assetsurl instead of an asset object. 0 or the absence of the field indicates no such support.
    public var aurlsupport = 0
    
    /// [Integer]
    /// Whether the supply source / impression supports returning a dco url instead of an asset object. 0 or the absence of the field indicates no such support.
    /// Beta feature.
    public var durlsupport: Int = 0
    
    /// Specifies what type of event objects tracking is supported - see Event Trackers Request Object
    public var eventtrackers: [NativeEventTracker]?
    
    /// [Recommended]
    /// [Integer]
    /// Set to 1 when the native ad supports buyer-specific privacy notice. Set to 0 (or field absent) when the native ad doesn’t support custom privacy links or if support is unknown.
    public var privacy = 0
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    public var ext: [String : Any]?
    
    /// Initializes a `NativeMarkupRequestObject` with default values.
    public override init() {
        super.init()
    }
    
    init(nativeParameters: NativeParameters) {
        assets = nativeParameters.assets
        eventtrackers = nativeParameters.eventtrackers
        context = nativeParameters.context
        contextsubtype = nativeParameters.contextSubType
        plcmttype = nativeParameters.placementType
        plcmtcnt = nativeParameters.placementCount
        seq = nativeParameters.sequence
        aurlsupport = nativeParameters.asseturlsupport
        durlsupport = nativeParameters.durlsupport
        privacy = nativeParameters.privacy
        ext = nativeParameters.ext
        
        super.init()
    }
    
    // MARK: - NSCopying
    
    /// Creates a copy of the current `NativeMarkupRequestObject` instance.
    ///
    /// - Parameter zone: An optional zone for the copy operation.
    /// - Returns: A copy of the `NativeMarkupRequestObject` instance.
    public func copy(with zone: NSZone? = nil) -> Any {
        let clone = NativeMarkupRequestObject()
        
        clone.context = context
        clone.contextsubtype = contextsubtype
        clone.plcmttype = plcmttype
        clone.plcmtcnt = plcmtcnt
        clone.seq = seq
        clone.aurlsupport = aurlsupport
        clone.durlsupport = durlsupport
        clone.eventtrackers = eventtrackers
        clone.assets = assets
        clone.privacy = privacy
        clone.ext = ext
        
        return clone;
    }
    
    // MARK: - PBMJsonCodable
    
    /// Converts the `NativeMarkupRequestObject` instance to a JSON dictionary.
    ///
    /// - Returns: A dictionary representation of the `NativeMarkupRequestObject` instance.
    public var jsonDictionary: [String : Any]? {
        var json = [String : Any]()
        
        json["context"]         = context?.value
        json["contextsubtype"]  = contextsubtype?.value
        json["plcmttype"]       = plcmttype?.value
        json["seq"]             = seq
        json["assets"]          = jsonAssets()
        json["plcmtcnt"]        = plcmtcnt
        json["aurlsupport"]     = aurlsupport
        json["durlsupport"]     = durlsupport
        json["eventtrackers"]   = jsonTrackers()
        json["privacy"]         = privacy
        json["ext"]             = ext
        
        return json
    }
    
    /// Converts the `NativeMarkupRequestObject` instance to a JSON string.
    ///
    /// - Returns: A JSON string representation of the `NativeMarkupRequestObject` instance.
    /// - Throws: An error if the conversion to JSON string fails.
    public func toJsonString() throws -> String {
        try PBMFunctions.toStringJsonDictionary(jsonDictionary ?? [:])
    }
    
    // MARK: - Private  Methods
    
    func jsonAssets() -> [[AnyHashable : Any]] {
        var idCount: Int = 0
        var assetsObjects: [[AnyHashable : Any]] = []
        if let assets = assets {
            for asset in assets {
                if Prebid.shared.shouldAssignNativeAssetID {
                    idCount += 1
                }
                assetsObjects.append(asset.getAssetObject(id: idCount))
            }
        }
        return assetsObjects
    }
    
    func jsonTrackers() -> [[AnyHashable : Any]]? {
        var res = [[AnyHashable : Any]]()
        if let eventtrackers = eventtrackers {
            for eventtracker in eventtrackers {
                res.append(eventtracker.getEventTracker())
            }
        }
        return res.count == 0 ? nil : res
    }
}
