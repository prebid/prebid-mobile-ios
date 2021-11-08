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

class NativeAdConfiguration: NSObject, NSCopying {

    /// Version of the Native Markup version in use.
    @objc public var version: String? {
        get { markupRequestObject.version }
        set { markupRequestObject.version = newValue }
    }
    
    /// [Recommended]
    /// [Integer]
    /// The context in which the ad appears.
    /// See NativeContextType
    @objc public var context: Int {
        get { markupRequestObject.context ?? NativeContextType.undefined.rawValue }
        set { markupRequestObject.context = newValue == NativeContextType.undefined.rawValue ? nil : newValue}
    }

    /// [Integer]
    /// A more detailed context in which the ad appears.
    /// See NativeContextSubtype
    @objc public var contextsubtype: Int {
        get { markupRequestObject.contextsubtype ?? NativeContextSubtype.undefined.rawValue }
        set { markupRequestObject.contextsubtype = newValue == NativeContextSubtype.undefined.rawValue ? nil : newValue }
    }
    
    /// [Recommended]
    /// [Integer]
    /// The design/format/layout of the ad unit being offered.
    /// NativePlacementType
    @objc public var plcmttype: Int {
        get { markupRequestObject.plcmttype ?? NativePlacementType.undefined.rawValue }
        set { markupRequestObject.plcmttype = newValue == NativePlacementType.undefined.rawValue ? nil : newValue }
    }
    
    // NOT SUPPORTED:
    // /// [Integer]
    // /// The number of identical placements in this Layout. Refer Section 8.1 Multiplacement Bid Requests for further detail.
    // var plcmtcnt: NSNumber?

    /// [Integer]
    /// 0 for the first ad, 1 for the second ad, and so on.
    /// Note this would generally NOT be used in combination with plcmtcnt -
    /// either you are auctioning multiple identical placements (in which case plcmtcnt>1, seq=0)
    /// or you are holding separate auctions for distinct items in the feed (in which case plcmtcnt=1, seq=>=1)
    @objc public var seq: NSNumber? {
        get {
            guard let value = markupRequestObject.seq else {
                return nil
            }
            
            return NSNumber(value: value)
        }
        set {
            guard let value = newValue?.intValue,
                  value >= 0 else {
                markupRequestObject.seq = nil
                return
            }
            
            markupRequestObject.seq = value
        }
    }

    /// [Required]
    /// An array of Asset Objects. Any objects bid response must comply with the array of elements
    /// expressed in the bid request.
    @objc public var assets: [PBRNativeAsset] {
        get { markupRequestObject.assets }
        set { markupRequestObject.assets = newValue }
    }
    
    // NOT SUPPORTED:
    // /// [Integer]
    // /// Whether the supply source / impression supports returning an assetsurl instead of an asset object.
    // /// 0 or the absence of the field indicates no such support.
    //var aurlsupport: NSNumber?

    // NOT SUPPORTED:
    // /// [Integer]
    // /// Whether the supply source / impression supports returning a dco url instead of an asset object.
    // ///0 or the absence of the field indicates no such support.
    //var durlsupport: NSNumber?

    /// Specifies what type of event objects tracking is supported - see Event Trackers Request Object
    @objc public var eventtrackers: [PBRNativeEventTracker]? {
        get { markupRequestObject.eventtrackers }
        set { markupRequestObject.eventtrackers = newValue }
    }

    /// [Recommended]
    /// [Integer]
    /// Set to 1 when the native ad supports buyer-specific privacy notice. Set to 0 (or field absent)
    /// when the native ad doesn’t support custom privacy links or if support is unknown.
    @objc public var privacy: NSNumber? {
        get {
            guard let value = markupRequestObject.privacy else {
                return nil
            }
            
            return NSNumber(value: value)
        }
        set { markupRequestObject.privacy = newValue?.intValue }
    }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var ext: [String : Any]? {
        markupRequestObject.ext
    }
    
    /// A custom template for a native style creative.
    /// This is an html code with a special placeholders and macroses.
    /// Macroses will be popultade by the SDK
    /// %%PATTERN:TARGETINGMAP%% - will be replaced by the json-representation of the targeting map
    /// %%PATTERN:hb_key%% - will be replaced by the value of an item in the targeting map with the key `hb_key`
    /// If a macros contains a key absent in the targeting map it will be replaced by `null`

    /// See https://docs.prebid.org/dev-docs/show-native-ads.html#how-native-ads-work
    @objc public var nativeStylesCreative: String?
    
    @objc public var markupRequestObject: NativeMarkupRequestObject

    @objc public required init(assets: [PBRNativeAsset]) {
        markupRequestObject = NativeMarkupRequestObject(assets: assets)
    }

    @objc public func setExt(_ ext: [String : Any]?) throws {
        try markupRequestObject.setExt(ext)
    }

    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let clone = NativeAdConfiguration(markupRequestObject:markupRequestObject)
        clone.nativeStylesCreative = nativeStylesCreative
        return clone
    }
    
    // MARK: - Private
    @available(*, unavailable)
    private override init() {
        fatalError("Init is unavailable.")
    }
    
    private init(markupRequestObject: NativeMarkupRequestObject) {
        self.markupRequestObject = markupRequestObject.copy() as! NativeMarkupRequestObject
    }
}
