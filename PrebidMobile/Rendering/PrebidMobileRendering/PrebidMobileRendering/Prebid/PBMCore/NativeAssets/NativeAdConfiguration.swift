//
//  NativeAdConfiguration.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class NativeAdConfiguration: NSObject, NSCopying {

    /// Version of the Native Markup version in use.
    @objc public var version: String? {
        get {
            markupRequestObject.version
        }
        set {
            markupRequestObject.version = newValue
        }
    }
    
    /// [Recommended]
    /// [Integer]
    /// The context in which the ad appears.
    @objc public var context: PBMNativeContextType {
        get {
            //such lines will be simplified in task https://openxtechinc.atlassian.net/browse/MOBILE-7034
            PBMNativeContextType(rawValue: (markupRequestObject.context?.intValue) ??
                                    PBMNativeContextType.undefined.rawValue) ?? .undefined
        }
        set {
            markupRequestObject.context = newValue == .undefined ? nil : NSNumber(value: newValue.rawValue)
        }
    }

    /// [Integer]
    /// A more detailed context in which the ad appears.
    @objc public var contextsubtype: PBMNativeContextSubtype {
        get {
            PBMNativeContextSubtype(rawValue: (markupRequestObject.contextsubtype?.intValue) ??
                                        PBMNativeContextSubtype.undefined.rawValue) ?? .undefined
        }
        set {
            markupRequestObject.contextsubtype = newValue == .undefined ? nil : NSNumber(value: newValue.rawValue)
        }
    }
    
    /// [Recommended]
    /// [Integer]
    /// The design/format/layout of the ad unit being offered.
    @objc public var plcmttype: PBMNativePlacementType {
        get {
            PBMNativePlacementType(rawValue: markupRequestObject.plcmttype?.intValue ??
                                    PBMNativePlacementType.undefined.rawValue) ?? .undefined
        }
        set {
            markupRequestObject.plcmttype = newValue == .undefined ? nil : NSNumber(value: newValue.rawValue)
        }
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
            markupRequestObject.seq
        }
        set {
            markupRequestObject.seq = (newValue?.intValue ?? 0) >= 0 ? newValue : nil
        }
    }

    /// [Required]
    /// An array of Asset Objects. Any objects bid response must comply with the array of elements
    /// expressed in the bid request.
    @objc public var assets: [NativeAsset] {
        get {
            markupRequestObject.assets
        }
        set {
            markupRequestObject.assets = newValue
        }
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
    @objc public var eventtrackers: [PBMNativeEventTracker]? {
        get {
            markupRequestObject.eventtrackers
        }
        set {
            markupRequestObject.eventtrackers = newValue
        }
    }

    /// [Recommended]
    /// [Integer]
    /// Set to 1 when the native ad supports buyer-specific privacy notice. Set to 0 (or field absent)
    /// when the native ad doesn’t support custom privacy links or if support is unknown.
    @objc public var privacy: NSNumber? {
        get {
            markupRequestObject.privacy
        }
        set {
            markupRequestObject.privacy = newValue
        }
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
    
    @objc public var markupRequestObject: PBMNativeMarkupRequestObject

    @objc public required init(assets: [NativeAsset]) {
        markupRequestObject = PBMNativeMarkupRequestObject(assets: assets)
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
    
    private init(markupRequestObject: PBMNativeMarkupRequestObject) {
        self.markupRequestObject = markupRequestObject.copy() as! PBMNativeMarkupRequestObject
    }
}
