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
import UIKit

public let refreshIntervalMin: TimeInterval  = 15
public let refreshIntervalMax: TimeInterval = 120
public let refreshIntervalDefault: TimeInterval  = 60

public class AdUnitConfig: NSObject, NSCopying {
    
    // MARK: - Properties
       
    @objc public var configID: String
    
    @objc public let adConfiguration = PBMAdConfiguration();
    
    @objc public var adFormat: AdFormat {
        didSet {
            updateAdFormat()
        }
    }
    
    // The feature is not available. Use original Prebid Native API
    // TODO: Merge Native engine from original SDK and rendering codebase
    var _nativeAdConfiguration: NativeAdConfiguration?
    var nativeAdConfiguration: NativeAdConfiguration? {
        get { _nativeAdConfiguration }
        set {
            _nativeAdConfiguration = newValue?.copy() as? NativeAdConfiguration
            adConfiguration.isNative = _nativeAdConfiguration != nil;
            updateAdFormat()
        }
    }
    
    @objc public var adSize: CGSize
    @objc public var minSizePerc: NSValue?
    
    @objc public var adPosition = AdPosition.undefined
    
    @objc public var contextDataDictionary: [String : [String]] {
        extensionData.mapValues { Array($0) }
    }
    
    public var appContent: PBMORTBAppContent?
    
    // MARK: - Computed Properties
    
    @objc public var additionalSizes: [CGSize]? {
        get { sizes }
        set { sizes = newValue }
    }
    
    var _refreshInterval: TimeInterval = refreshIntervalDefault
    @objc public var refreshInterval: TimeInterval {
        get { _refreshInterval }
        set {
            if adFormat == .video {
                PBMLog.warn("'refreshInterval' property is not assignable for Outstream Video ads")
                return
            }
            
            if newValue < 0 {
                _refreshInterval  = 0
            } else {
                let lowerClamped = max(newValue, refreshIntervalMin);
                let doubleClamped = min(lowerClamped, refreshIntervalMax);
                
                _refreshInterval = doubleClamped;
                
                if self.refreshInterval != newValue {
                    PBMLog.warn("The value \(newValue) is out of range [\(refreshIntervalMin);\(refreshIntervalMax)]. The value \(_refreshInterval) will be used")
                }
            }
        }
    }
    
    @objc public var isInterstitial: Bool {
        get { adConfiguration.isInterstitialAd }
        set { adConfiguration.isInterstitialAd = newValue }
    }
        
    @objc public var isOptIn: Bool {
        get { adConfiguration.isOptIn }
        set { adConfiguration.isOptIn = newValue }
    }
    
    @objc public var videoPlacementType: PBMVideoPlacementType {
        get { adConfiguration.videoPlacementType }
        set { adConfiguration.videoPlacementType = newValue }
    }
    
    // MARK: - Public Methods
    
    @objc public convenience init(configID: String) {
        self.init(configID: configID, size: CGSize.zero)
    }
    
    @objc public init(configID: String, size: CGSize) {
        self.configID = configID
        self.adSize = size
        
        adFormat = .display
        
        adConfiguration.autoRefreshDelay = 0
        adConfiguration.size = adSize
    }
    
    @objc
    public func setAppContent(appContent: PBMORTBAppContent) {
        self.appContent = appContent
    }
    
    @objc
    public func getAppContent() -> PBMORTBAppContent? {
        return self.appContent
    }
    
    @objc public func addContextData(_ data: String, forKey key: String) {
        if extensionData[key] == nil {
            extensionData[key] = Set<String>()
        }
        
        extensionData[key]?.insert(data)
    }
    
    @objc public  func updateContextData(_ data: Set<String>, forKey key: String) {
        extensionData[key] = data
    }
    
    @objc public  func removeContextData(forKey key: String) {
        extensionData.removeValue(forKey: key)
    }
    
    @objc public func clearContextData() {
        extensionData.removeAll()
    }
    
    // MARK: - Private Properties
    
    var extensionData = [String : Set<String>]()
    
    var sizes: [CGSize]?
    
    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let clone = AdUnitConfig(configID: self.configID, size: self.adSize)
        
        clone.adFormat = self.adFormat
        clone.adConfiguration.adFormat = self.adConfiguration.adFormat
        clone.adConfiguration.isInterstitialAd = self.adConfiguration.isInterstitialAd
        clone.adConfiguration.isOptIn = self.adConfiguration.isOptIn
        clone.adConfiguration.videoPlacementType = self.adConfiguration.videoPlacementType
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.sizes = sizes
        clone.refreshInterval = self.refreshInterval
        clone.minSizePerc = self.minSizePerc
        clone.extensionData = self.extensionData.merging(clone.extensionData) { $1 }
        clone.adPosition = self.adPosition
        
        return clone
    }
    
    // MARK: - Private Methods
    
    private func getInternalAdFormat() -> PBMAdFormatInternal {
        if let _ = nativeAdConfiguration {
            return .nativeInternal
        } else {
            switch adFormat {
                case .display   : return .displayInternal
                case .video     : return .videoInternal
            }
        }
    }
    
    private func updateAdFormat() {
        let newAdFormat = getInternalAdFormat()
        if adConfiguration.adFormat == newAdFormat {
            return
        }
        
        self.adConfiguration.adFormat = newAdFormat
        self.refreshInterval = ((newAdFormat == .videoInternal) ? 0 : refreshIntervalDefault);
    }
}
