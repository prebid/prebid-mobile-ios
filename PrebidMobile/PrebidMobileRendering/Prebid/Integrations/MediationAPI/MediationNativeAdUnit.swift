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

/// This class is responsible for making bid request and providing the winning bid and targeting keywords to mediating SDKs.
/// This class is a part of Mediation API.
@objcMembers
public class MediationNativeAdUnit : NSObject {
    
    var completion: ((ResultCode) -> Void)?
    let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Public Properties
    
    /// The native ad unit that makes native request.
    public var nativeAdUnit: NativeRequest
    
    var configID: String
    
    // MARK: - Public Methods
    
    /// Initializes a new instance of the `MediationNativeAdUnit` with the specified configuration ID and mediation delegate.
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - mediationDelegate: The delegate for mediation-related tasks.
    public init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        self.configID = configId
        self.mediationDelegate = mediationDelegate
        self.nativeAdUnit = NativeRequest(configId: configId)
    }
    
    /// Adds event trackers to the native ad unit.
    /// - Parameter eventTrackers: An array of `NativeEventTracker` objects to add.
    public func addEventTracker(_ eventTrackers: [NativeEventTracker]) {
        nativeAdUnit.addNativeEventTracker(eventTrackers)
    }
    
    /// Adds native assets to the native ad unit.
    /// - Parameter assets: An array of `NativeAsset` objects to add.
    public func addNativeAssets(_ assets: [NativeAsset]) {
        nativeAdUnit.addNativeAssets(assets)
    }
    
    /// Sets the context type for the native ad unit.
    /// - Parameter contextType: The context type to set.
    public func setContextType(_ contextType: ContextType) {
        nativeAdUnit.context = contextType
    }
    
    /// Sets the placement type for the native ad unit.
    /// - Parameter placementType: The placement type to set.
    public func setPlacementType(_ placementType: PlacementType) {
        nativeAdUnit.placementType = placementType
    }
    
    /// Sets the placement count for the native ad unit.
    /// - Parameter placementCount: The placement count to set.
    public func setPlacementCount(_ placementCount: Int) {
        nativeAdUnit.placementCount = placementCount
    }
    
    /// Sets the context subtype for the native ad unit.
    /// - Parameter contextSubType: The context subtype to set.
    public func setContextSubType(_ contextSubType: ContextSubType) {
        nativeAdUnit.contextSubType = contextSubType
    }
    
    /// Sets the sequence for the native ad unit.
    /// - Parameter sequence: The sequence to set.
    public func setSequence(_ sequence: Int) {
        nativeAdUnit.sequence = sequence
    }
    
    /// Sets the asset URL support for the native ad unit.
    /// - Parameter assetURLSupport: The asset URL support value to set.
    public func setAssetURLSupport(_ assetURLSupport: Int) {
        nativeAdUnit.asseturlsupport = assetURLSupport
    }
    
    /// Sets the DURL support for the native ad unit.
    /// - Parameter dURLSupport: The DURL support value to set.
    public func setDURLSupport(_ dURLSupport: Int) {
        nativeAdUnit.durlsupport = dURLSupport
    }
    
    /// Sets the privacy value for the native ad unit.
    /// - Parameter privacy: The privacy value to set.
    public func setPrivacy(_ privacy: Int) {
        nativeAdUnit.privacy = privacy
    }
    
    /// Sets the extended data for the native ad unit.
    /// - Parameter ext: A dictionary containing the extended data to set.
    public func setExt(_ ext: [String: Any]) {
        nativeAdUnit.ext = ext
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    @available(*, deprecated, message: "Deprecated. Use setImpORTBConfig(_:) for impression-level ORTB configuration.")
    public func setOrtbConfig(_ ortbConfig: String?) {
        nativeAdUnit.setOrtbConfig(ortbConfig)
    }
    
    @available(*, deprecated, message: "Deprecated. Use getImpORTBConfig() for impression-level ORTB configuration.")
    public func getOrtbConfig() -> String? {
        return nativeAdUnit.getOrtbConfig()
    }
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        nativeAdUnit.adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        nativeAdUnit.adUnitConfig.impORTBConfig
    }
    
    // MARK: - App Content (app.content.data)
    
    /// Sets the app content object, replacing any existing content.
    /// - Parameter appContent: The `PBMORTBAppContent` object representing the app's content.
    public func setAppContent(_ appContent: PBMORTBAppContent) {
        nativeAdUnit.setAppContent(appContent)
    }
    
    /// Clears the current app content object.
    public func clearAppContent() {
        nativeAdUnit.clearAppContent()
    }
    
    /// Adds an array of content data objects to the app content.
    /// - Parameter dataObjects: An array of `PBMORTBContentData` objects to add.
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        nativeAdUnit.addAppContentData(dataObjects)
    }

    /// Removes a specific content data object from the app content.
    /// - Parameter dataObject: The `PBMORTBContentData` object to remove.
    public func removeAppContent(_ dataObject: PBMORTBContentData) {
        nativeAdUnit.removeAppContentData(dataObject)
    }
    
    // MARK: - User Data (user.data)
    
    /// Adds an array of user data objects.
    /// - Parameter userDataObjects: An array of `PBMORTBContentData` objects to add to the user data.
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        nativeAdUnit.addUserData(userDataObjects)
    }
    
    /// Removes a specific user data object.
    /// - Parameter userDataObject: The `PBMORTBContentData` object to remove from the user data.
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        nativeAdUnit.removeUserData(userDataObject)
    }
    
    /// Clears all user data.
    public func clearUserData() {
        nativeAdUnit.clearUserData()
    }
    
    // MARK: - Ext Data (imp[].ext.data)
    
    /// This method obtains the context data keyword & value for adunit context targeting
    /// if the key already exists the value will be appended to the list. No duplicates will be added
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(key: String, value: String) {
        addExtData(key: key, value: value)
    }

    /// This method obtains the context data keyword & values for adunit context targeting
    /// the values if the key already exist will be replaced with the new set of values
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(key: String, value: Set<String>) {
        updateExtData(key: key, value: value)
    }
    
    /// This method allows to remove specific context data keyword & values set from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextData(forKey: String) {
        removeExtData(forKey: forKey)
    }
    
    /// This method allows to remove all context data set from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    /// This method obtains the ext data keyword & value for adunit targeting.
    /// If the key already exists the value will be appended to the list. No duplicates will be added
    public func addExtData(key: String, value: String) {
        nativeAdUnit.addExtData(key: key, value: value)
    }
    
    /// This method obtains the ext data keyword & values for adunit targeting.
    /// The values if the key already exist will be replaced with the new set of values
    public func updateExtData(key: String, value: Set<String>) {
        nativeAdUnit.updateExtData(key: key, value: value)
    }
    
    /// This method allows to remove specific ext data keyword & values set from adunit targeting
    public func removeExtData(forKey: String) {
        nativeAdUnit.removeExtData(forKey: forKey)
    }
    
    /// This method allows to remove all ext data set from adunit targeting
    public func clearExtData() {
        nativeAdUnit.clearExtData()
    }
    
    // MARK: - Ext keywords (imp[].ext.keywords)
    
    /// This method obtains the context keyword for adunit context targeting
    /// Inserts the given element in the set if it is not already present.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    /// This method obtains the context keyword set for adunit context targeting
    /// Adds the elements of the given set to the set.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    /// This method allows to remove specific context keyword from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    /// This method obtains the keyword for adunit targeting
    /// Inserts the given element in the set if it is not already present.
    public func addExtKeyword(_ newElement: String) {
        nativeAdUnit.addExtKeyword(newElement)
    }
    
    /// This method obtains the keyword set for adunit targeting
    /// Adds the elements of the given set to the set.
    public func addExtKeywords(_ newElements: Set<String>) {
        nativeAdUnit.addExtKeywords(newElements)
    }
    
    /// This method allows to remove specific keyword from adunit targeting
    public func removeExtKeyword(_ element: String) {
        nativeAdUnit.removeExtKeyword(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit targeting
    public func clearExtKeywords() {
        nativeAdUnit.clearExtKeywords()
    }
    
    /// Makes bid request for the native ad unit and setups mediation parameters.
    /// - Parameter completion: The completion handler to call with the result code.
    public func fetchDemand(completion: ((ResultCode)->Void)?) {
        
        self.completion = completion
        
        mediationDelegate.cleanUpAdObject()
        
        nativeAdUnit.fetchDemand { [weak self] result, kvResultDict in
            guard let self = self else {
                return
            }
            
            guard result == .prebidDemandFetchSuccess else {
                self.completeWithResult(result)
                return
            }
            
            guard let kvResultDict = kvResultDict,
                  let cacheId = kvResultDict[PrebidLocalCacheIdKey],
                  CacheManager.shared.isValid(cacheId: cacheId) else {
                      Log.error("\(String(describing: self)): no cache in kvResultDict.")
                      return
                  }
            
            guard let bidString = CacheManager.shared.get(cacheId: cacheId) else {
                Log.error("\(String(describing: self)): no bid for given cache id.")
                return
            }
            
            guard var fetchDemandInfo = Utils.shared.getDictionaryFromString(bidString) else {
                Log.error("\(String(describing: self)): parsing bid string to bid dictionary failed.")
                return
            }
            
            fetchDemandInfo[PrebidLocalCacheIdKey] = cacheId as AnyObject
            
            var fetchDemandResult = ResultCode.prebidWrongArguments
            
            let adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: self.configID,
                PBMMediationTargetingInfoKey: kvResultDict,
                PBMMediationAdNativeResponseKey: fetchDemandInfo
            ]
        
            if self.mediationDelegate.setUpAdObject(with: adObjectSetupDictionary) {
                fetchDemandResult = .prebidDemandFetchSuccess
            }
            
            self.completeWithResult(fetchDemandResult)
        }
    }
    
    // MARK: - Private Methods
    
    private func completeWithResult(_ fetchDemandResult: ResultCode) {
        guard let completion = self.completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
}
