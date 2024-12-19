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

@objcMembers
public class AdUnitConfig: NSObject, NSCopying {

    // MARK: - Public properties
       
    public var configId: String
    
    public let adConfiguration = AdConfiguration()
    
    public var adFormats: Set<AdFormat> {
        didSet {
            updateAdFormat()
        }
    }
    
    public var adSize: CGSize
    
    public var minSizePerc: NSValue?
    
    public var adPosition = AdPosition.undefined

    public var extDataDictionary: [String : [String]] {
        extensionData.mapValues { Array($0) }
    }

    public var nativeAdConfiguration: NativeAdConfiguration?

    // MARK: - Computed Properties
    
    public var additionalSizes: [CGSize]? {
        get { sizes }
        set { sizes = newValue }
    }
    
    let fingerprint = UUID().uuidString
    
    var _refreshInterval: TimeInterval = refreshIntervalDefault
    public var refreshInterval: TimeInterval {
        get { _refreshInterval }
        set {
            if adConfiguration.winningBidAdFormat == .video {
                Log.warn("'refreshInterval' property is not assignable for Outstream Video ads")
                _refreshInterval = 0
                return
            }
            if newValue < 0 {
                _refreshInterval  = 0
            } else {
                let lowerClamped = max(newValue, refreshIntervalMin);
                let doubleClamped = min(lowerClamped, refreshIntervalMax);
                
                _refreshInterval = doubleClamped;
                
                if self.refreshInterval != newValue {
                    Log.warn("The value \(newValue) is out of range [\(refreshIntervalMin);\(refreshIntervalMax)]. The value \(_refreshInterval) will be used")
                }
            }
        }
    }
    
    public var gpid: String?
    
    public var ortbConfig: String? {
        get {adConfiguration.ortbConfig}
        set {adConfiguration.ortbConfig = newValue}
    }
    
    public var impORTBConfig: String? {
        get { adConfiguration.impORTBConfig }
        set { adConfiguration.impORTBConfig = newValue }
    }

    // MARK: - Public Methods
    
    public convenience init(configId: String) {
        self.init(configId: configId, size: CGSize.zero)
    }
    
    public init(configId: String, size: CGSize) {
        self.configId = configId
        self.adSize = size
        
        adFormats = [.banner]
        
        adConfiguration.autoRefreshDelay = 0
        adConfiguration.size = adSize
    }
    
    // MARK: - Ext Data (imp[].ext.data)
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(key: String, value: String) {
        addExtData(key: key, value: value)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(key: String, value: Set<String>) {
        updateExtData(key: key, value: value)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextData(for key: String) {
        removeExtData(for: key)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use getExtData method instead.")
    public func getContextData() -> [String: [String]] {
        getExtData()
    }
    
    func setExtData(_ extData: [String: Set<String>]) {
        extensionData = extData
    }

    public func addExtData(key: String, value: String) {
        if extensionData[key] == nil {
            extensionData[key] = Set<String>()
        }
        
        extensionData[key]?.insert(value)
    }
    
    public func updateExtData(key: String, value: Set<String>) {
        extensionData[key] = value
    }
    
    public func removeExtData(for key: String) {
        extensionData.removeValue(forKey: key)
    }
    
    public func clearExtData() {
        extensionData.removeAll()
    }
    
    public func getExtData() -> [String: [String]] {
        extDataDictionary
    }

    // MARK: - Ext keywords (imp[].ext.keywords)
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    @available(*, deprecated, message: "This method is deprecated. Please, use getExtKeywords method instead.")
    public func getContextKeywords() -> Set<String> {
        getExtKeywords()
    }
    
    func setExtKeywords(_ keywords: Set<String>) {
        extKeywords = keywords
    }

    public func addExtKeyword(_ newElement: String) {
        extKeywords.insert(newElement)
    }

    public func addExtKeywords(_ newElements: Set<String>) {
        extKeywords.formUnion(newElements)
    }
    
    public func removeExtKeyword(_ element: String) {
        extKeywords.remove(element)
    }

    public func clearExtKeywords() {
        extKeywords.removeAll()
    }

    public func getExtKeywords() -> Set<String> {
        extKeywords
    }

    // MARK: - App Content (app.content.data)

    public func setAppContent(_ appContent: PBMORTBAppContent?) {
        self.appContent = appContent
    }
    
    public func getAppContent() -> PBMORTBAppContent? {
        return appContent
    }
    
    public func clearAppContent() {
        appContent = nil
    }
    
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        if appContent == nil {
            appContent = PBMORTBAppContent()
        }
        
        if appContent?.data == nil {
            appContent?.data = [PBMORTBContentData]()
        }
        
        appContent?.data?.append(contentsOf: dataObjects)
    }

    public func removeAppContentData(_ dataObject: PBMORTBContentData) {
        if let appContentData = appContent?.data, appContentData.contains(dataObject) {
            appContent?.data?.removeAll(where: { $0 == dataObject })
        }
    }
    
    public func clearAppContentData() {
        appContent?.data?.removeAll()
    }
    
    // MARK: - User Data (user.data)
    
    func setUserData(_ userData: [PBMORTBContentData]?) {
        self.userData = userData
    }
        
    public func getUserData() -> [PBMORTBContentData]? {
        return userData
    }
    
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        if userData == nil {
            userData = [PBMORTBContentData]()
        }
        userData?.append(contentsOf: userDataObjects)
    }
    
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        if let userData = userData, userData.contains(userDataObject) {
            self.userData?.removeAll { $0 == userDataObject }
        }
    }
    
    public func clearUserData() {
        userData?.removeAll()
    }
    
    // MARK: - The Prebid Ad Slot

    public func setPbAdSlot(_ newElement: String?) {
        Log.warn("Prebid SDK will stop sending `imp[].ext.data.adslot` field soon. If you still need it, add a comment to: https://github.com/prebid/prebid-mobile-android/issues/810.")
        pbAdSlot = newElement
    }

    public func getPbAdSlot() -> String? {
        return pbAdSlot
    }

    // MARK: - Private Properties
    
    private var extensionData = [String : Set<String>]()

    private var appContent: PBMORTBAppContent?

    private var userData: [PBMORTBContentData]?

    private var extKeywords = Set<String>()
    
    private var sizes: [CGSize]?

    private var pbAdSlot: String?
    
    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let clone = AdUnitConfig(configId: self.configId, size: self.adSize)
        
        clone.adFormats = self.adFormats
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.adConfiguration.bannerParameters = self.adConfiguration.bannerParameters
        clone.adConfiguration.videoParameters = self.adConfiguration.videoParameters
        clone.adConfiguration.videoControlsConfig = self.adConfiguration.videoControlsConfig
        clone.adConfiguration.winningBidAdFormat = self.adConfiguration.winningBidAdFormat
        clone.sizes = sizes
        clone.adSize = adSize
        clone.minSizePerc = self.minSizePerc
        clone.adPosition = self.adPosition
        clone.additionalSizes = self.additionalSizes
        clone.refreshInterval = self.refreshInterval
        clone.gpid = self.gpid
        clone.extensionData = self.extensionData.merging(clone.extensionData) { $1 }
        clone.appContent = self.appContent
        clone.extKeywords = self.extKeywords
        clone.userData = self.userData
        clone.adPosition = self.adPosition
        clone.pbAdSlot = self.pbAdSlot
        
        clone.adConfiguration.impORTBConfig = self.adConfiguration.impORTBConfig
        clone.adConfiguration.rewardedConfig = self.adConfiguration.rewardedConfig
        clone.adConfiguration.winningBidAdFormat = self.adConfiguration.winningBidAdFormat
        clone.adConfiguration.adFormats = self.adConfiguration.adFormats
        clone.adConfiguration.isOriginalAPI = self.adConfiguration.isOriginalAPI
        clone.adConfiguration.size = self.adConfiguration.size
        clone.adConfiguration.isBuiltInVideo = self.adConfiguration.isBuiltInVideo
        clone.adConfiguration.isInterstitialAd = self.adConfiguration.isInterstitialAd
        clone.adConfiguration.isRewarded = self.adConfiguration.isRewarded
        clone.adConfiguration.forceInterstitialPresentation = self.adConfiguration.forceInterstitialPresentation
        clone.adConfiguration.interstitialLayout = self.adConfiguration.interstitialLayout
        clone.nativeAdConfiguration = self.nativeAdConfiguration
        clone.adConfiguration.bannerParameters = self.adConfiguration.bannerParameters
        clone.adConfiguration.videoParameters = self.adConfiguration.videoParameters
        clone.adConfiguration.videoControlsConfig = self.adConfiguration.videoControlsConfig
        clone.adConfiguration.clickHandlerOverride = self.adConfiguration.clickHandlerOverride
        clone.adConfiguration.autoRefreshDelay = self.adConfiguration.autoRefreshDelay
        clone.adConfiguration.pollFrequency = self.adConfiguration.pollFrequency
        clone.adConfiguration.viewableArea = self.adConfiguration.viewableArea
        clone.adConfiguration.viewableDuration = self.adConfiguration.viewableDuration
        clone.adConfiguration.ortbConfig = self.adConfiguration.ortbConfig
        
        return clone
    }
    
    // MARK: - Private Methods

    private func updateAdFormat() {
        if adConfiguration.adFormats == adFormats {
            return
        }
        
        self.adConfiguration.adFormats = adFormats
        self.refreshInterval = (adConfiguration.winningBidAdFormat == .video) ? 0 : refreshIntervalDefault;
    }
}
