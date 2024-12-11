/*   Copyright 2019-2023 Prebid.org, Inc.
 
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

/// Class that contains properties and methods to configure Prebid request.
@objcMembers
public class PrebidRequest: NSObject {
    
    // MARK: - Public properties
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition = .undefined
    
    // MARK: - Internal properties
    
    private(set) var bannerParameters: BannerParameters?
    private(set) var videoParameters: VideoParameters?
    private(set) var nativeParameters: NativeParameters?
    
    private(set) var isInterstitial = false
    private(set) var isRewarded = false
    
    private(set) var gpid: String?
    private var impORTBConfig: String?
    
    // MARK: - Private properties
    
    private var extData = [String: Set<String>]()
    private var appContent: PBMORTBAppContent?
    private var userData: [PBMORTBContentData]?
    private var extKeywords = Set<String>()
    
    /// Initializes a new `PrebidRequest` with the given parameters.
    /// - Parameters:
    ///   - bannerParameters: The banner parameters for the ad request.
    ///   - videoParameters: The video parameters for the ad request.
    ///   - nativeParameters: The native parameters for the ad request.
    ///   - isInterstitial: Indicates if the request is for an interstitial ad.
    ///   - isRewarded: Indicates if the request is for a rewarded ad.
    public init(
        bannerParameters: BannerParameters? = nil,
        videoParameters: VideoParameters? = nil,
        nativeParameters: NativeParameters? = nil,
        isInterstitial: Bool = false,
        isRewarded: Bool = false
    ) {
        self.bannerParameters = bannerParameters
        self.videoParameters = videoParameters
        self.nativeParameters = nativeParameters
        self.isInterstitial = isInterstitial
        self.isRewarded = isRewarded
        
        super.init()
    }
    
    // MARK: GPID
    
    /// Sets the GPID for the ad request.
    /// - Parameter gpid: The GPID to set.
    public func setGPID(_ gpid: String?) {
        self.gpid = gpid
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        self.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        impORTBConfig
    }
    
    // MARK: - adunit ext data aka inventory data (imp[].ext.data)
    
    
    /// This method obtains the ext data keyword & value for adunit targeting
    /// if the key already exists the value will be appended to the list. No duplicates will be added
    public func addExtData(key: String, value: String) {
        if extData[key] == nil {
            extData[key] = Set<String>()
        }
        
        extData[key]?.insert(value)
    }
    
    
    /// This method obtains the ext data keyword & values for adunit targeting
    /// the values if the key already exist will be replaced with the new set of values
    public func updateExtData(key: String, value: Set<String>) {
        extData[key] = value
    }
    
    /// This method allows to remove specific ext data keyword & values set from adunit targeting
    public func removeExtData(forKey: String) {
        extData.removeValue(forKey: forKey)
    }
    
    /// This method allows to remove all ext data set from adunit targeting
    public func clearExtData() {
        extData.removeAll()
    }
    
    func getExtData() -> [String: Set<String>] {
        extData
    }
    
    // MARK: - adunit ext keywords (imp[].ext.keywords)
    
    /// This method obtains the keyword for adunit targeting
    /// Inserts the given element in the set if it is not already present.
    public func addExtKeyword(_ newElement: String) {
        extKeywords.insert(newElement)
    }
    
    /// This method obtains the keyword set for adunit targeting
    /// Adds the elements of the given set to the set.
    public func addExtKeywords(_ newElements: Set<String>) {
        extKeywords.formUnion(newElements)
    }
    
    /// This method allows to remove specific keyword from adunit targeting
    public func removeExtKeyword(_ element: String) {
        extKeywords.remove(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit targeting
    public func clearExtKeywords() {
        extKeywords.removeAll()
    }
    
    func getExtKeywords() -> Set<String> {
        extKeywords
    }
    
    // MARK: - App Content (app.content.data)
    
    /// Sets the app content for the ad request.
    /// - Parameter appContentObject: The `PBMORTBAppContent` to set.
    public func setAppContent(_ appContentObject: PBMORTBAppContent) {
        self.appContent = appContentObject
    }
    
    /// Clears the app content for the ad request.
    public func clearAppContent() {
        appContent = nil
    }
    
    /// Adds data to the app content.
    /// - Parameter dataObjects: The array of `PBMORTBContentData` to add.
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        if appContent == nil {
            appContent = PBMORTBAppContent()
        }
        
        if appContent?.data == nil {
            appContent?.data = [PBMORTBContentData]()
        }
        
        appContent?.data?.append(contentsOf: dataObjects)
    }
    
    /// Removes specific data from the app content.
    /// - Parameter dataObject: The `PBMORTBContentData` to remove.
    public func removeAppContentData(_ dataObject: PBMORTBContentData) {
        if let appContentData = appContent?.data, appContentData.contains(dataObject) {
            appContent?.data?.removeAll(where: { $0 == dataObject })
        }
    }
    
    /// Clears all data from the app content.
    public func clearAppContentData() {
        appContent?.data?.removeAll()
    }
    
    func getAppContent() -> PBMORTBAppContent? {
        appContent
    }
    
    // MARK: - User Data (user.data)
    
    /// Adds user data to the ad request.
    /// - Parameter userDataObjects: The array of `PBMORTBContentData` to add.
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        if userData == nil {
            userData = [PBMORTBContentData]()
        }
        
        userData?.append(contentsOf: userDataObjects)
    }
    
    /// Removes specific user data from the ad request.
    /// - Parameter userDataObject: The `PBMORTBContentData` to remove.
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        if let userData = userData, userData.contains(userDataObject) {
            self.userData?.removeAll { $0 == userDataObject }
        }
    }
    
    /// Clears all user data from the ad request.
    public func clearUserData() {
        userData?.removeAll()
    }
    
    func getUserData() -> [PBMORTBContentData]? {
        userData
    }
}
