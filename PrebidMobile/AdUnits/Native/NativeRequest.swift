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

/// A class representing a native request for original type of integration.
public class NativeRequest: AdUnit {
    
    /// The version of the native ad specification being used. Defaults to "1.2" if not set.
    public var version: String {
        get { adUnitConfig.nativeAdConfiguration?.version ?? "1.2" }
        set { adUnitConfig.nativeAdConfiguration?.version = newValue }
    }
    
    /// The context in which the ad appears. See `ContextType` for possible values.
    public var context: ContextType? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.context }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.context = newValue }
    }
    
    /// A more detailed context in which the ad appears. See `ContextSubType` for possible values.
    public var contextSubType: ContextSubType? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.contextsubtype }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.contextsubtype = newValue }
    }
    
    /// The design/format/layout of the ad unit being offered. See `PlacementType` for possible values.
    public var placementType: PlacementType? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmttype }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmttype = newValue }
    }
    
    /// The number of identical placements in the ad layout. Defaults to 1 if not set.
    public var placementCount: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmtcnt ?? 1 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmtcnt = newValue }
    }
    
    /// The sequence number of the ad. Defaults to 0 if not set.
    public var sequence: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.seq ?? 0 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.seq = newValue }
    }
    
    /// An array of `NativeAsset` objects representing the assets required for the native ad request.
    public var assets: [NativeAsset]? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.assets }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.assets = newValue }
    }
    
    /// Indicates whether the supply source/impression supports returning an `assetsurl` instead of an asset object.
    /// Defaults to 0 if not set.
    public var asseturlsupport: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.aurlsupport ?? 0 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.aurlsupport = newValue }
    }
    
    /// Indicates whether the supply source/impression supports returning a `dco` URL instead of an asset object.
    /// Defaults to 0 if not set.
    public var durlsupport: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.durlsupport ?? 0 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.durlsupport = newValue }
    }
    
    /// An array of `NativeEventTracker` objects specifying the event tracking settings for the native ad.
    public var eventtrackers: [NativeEventTracker]? {
        get { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.eventtrackers }
        set { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.eventtrackers = newValue }
    }
    
    /// Indicates whether the native ad supports a buyer-specific privacy notice. Defaults to 0 if not set.
    public var privacy: Int {
        get { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.privacy ?? 0  }
        set { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.privacy = newValue }
    }
    
    /// A placeholder for custom JSON agreed to by the parties to support flexibility beyond the standard specification.
    public var ext: [String: Any]? {
        get { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.ext }
        set { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.ext = newValue }
    }
    
    /// The configuration ID for the ad unit.
    public var configId: String {
        get { adUnitConfig.configId }
        set { adUnitConfig.configId = newValue }
    }
    
    /// Initializes a `NativeRequest` with a specified configuration ID.
    ///
    /// - Parameter configId: The configuration ID for the ad unit.
    public init(configId: String) {
        super.init(configId: configId, size: CGSize.zero, adFormats: [.native])
        super.adUnitConfig.nativeAdConfiguration = NativeAdConfiguration()
    }
    
    /// Initializes a `NativeRequest` with a specified configuration ID, assets, and event trackers.
    ///
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - assets: An optional array of `NativeAsset` objects.
    ///   - eventTrackers: An optional array of `NativeEventTracker` objects.
    public convenience init(configId: String, assets: [NativeAsset]? = nil, eventTrackers: [NativeEventTracker]? = nil) {
        self.init(configId: configId)
        self.assets = assets
        self.eventtrackers = eventTrackers
    }
    
    /// Adds an array of native assets to the request. If assets already exist, they will be appended.
    ///
    /// - Parameter assets: An array of `NativeAsset` objects to add.
    public func addNativeAssets(_ assets: [NativeAsset]) {
        if self.assets != nil {
            self.assets?.append(contentsOf: assets)
        } else {
            self.assets = assets
        }
    }
    
    /// Adds an array of native event trackers to the request. If event trackers already exist, they will be appended.
    ///
    /// - Parameter eventTrackers: An array of `NativeEventTracker` objects to add.
    public func addNativeEventTracker(_ eventTrackers: [NativeEventTracker]) {
        if eventtrackers != nil {
            self.eventtrackers?.append(contentsOf: eventTrackers)
        } else {
            self.eventtrackers = eventTrackers
        }
    }
    
    /// Retrieves the native request object as a JSON dictionary.
    ///
    /// - Returns: A dictionary representation of the native request object, or `nil` if an error occurs.
    public func getNativeRequestObject() -> [AnyHashable: Any]? {
        guard let markup = try? adUnitConfig.nativeAdConfiguration?.markupRequestObject.toJsonString() else {
            return nil
        }
        
        let native = PBMORTBNative()
        
        native.request = markup
        
        if let ver = adUnitConfig.nativeAdConfiguration?.version {
            native.ver = ver;
        }
        
        return native.toJsonDictionary()
    }
}
