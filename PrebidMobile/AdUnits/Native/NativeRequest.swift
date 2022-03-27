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
    
    public var version: String {
        get { adUnitConfig.nativeAdConfiguration?.version ?? "1.2" }
        set { adUnitConfig.nativeAdConfiguration?.version = newValue }
    }
    
    public var context: ContextType? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.context }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.context = newValue }
    }
    
    public var contextSubType: ContextSubType? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.contextsubtype }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.contextsubtype = newValue }
    }
    
    public var placementType: PlacementType? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmttype}
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmttype = newValue }
    }
    
    public var placementCount: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmtcnt ?? 1 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.plcmtcnt = newValue }
    }
    
    public var sequence: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.seq ?? 0 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.seq = newValue }
    }
    
    public var assets: [NativeAsset]? {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.assets }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.assets = newValue }
    }
    
    public var asseturlsupport: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.aurlsupport ?? 0 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.aurlsupport = newValue }
    }
    
    public var durlsupport: Int {
        get { adUnitConfig.nativeAdConfiguration?.markupRequestObject.durlsupport ?? 0 }
        set { adUnitConfig.nativeAdConfiguration?.markupRequestObject.durlsupport = newValue }
    }
    
    public var eventtrackers: [NativeEventTracker]? {
        get { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.eventtrackers }
        set { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.eventtrackers = newValue }
    }
    
    public var privacy: Int {
        get { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.privacy ?? 0  }
        set { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.privacy = newValue }
    }
    
    public var ext: [String: Any]? {
        get { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.ext }
        set { self.adUnitConfig.nativeAdConfiguration?.markupRequestObject.ext = newValue }
    }
    
    public var configId: String {
        get { adUnitConfig.configId }
        set { adUnitConfig.configId = newValue }
    }
    
    public init(configId: String) {
        super.init(configId: configId, size: CGSize.zero)
        super.adUnitConfig.nativeAdConfiguration = NativeAdConfiguration()
        super.adUnitConfig.adFormats = [.native]
    }
    
    public convenience init(configId: String, assets: [NativeAsset]? = nil, eventTrackers: [NativeEventTracker]? = nil) {
        self.init(configId: configId)
        self.assets = assets
        self.eventtrackers = eventtrackers
    }
    
    public func addNativeAssets(_ assets: [NativeAsset]) {
        if self.assets != nil {
            self.assets?.append(contentsOf: assets)
        } else {
            self.assets = assets
        }
    }
    
    public func addNativeEventTracker(_ eventTrackers: [NativeEventTracker]) {
        if eventtrackers != nil {
            self.eventtrackers?.append(contentsOf: eventTrackers)
        } else {
            self.eventtrackers = eventTrackers
        }
    }
}
