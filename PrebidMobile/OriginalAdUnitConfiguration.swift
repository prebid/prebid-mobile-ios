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

import UIKit

@objcMembers
public class OriginalAdUnitConfiguration: NSObject, OriginalAdUnitConfigurationProtocol {
   
    // MARK: - Public properties
    
    public var configId: String
    public var adSize: CGSize 
    public var additionalSizes: [CGSize]?
    
    // MARK: - Private Properties
    
    private var contextDataDictionary = [String: Set<String>]()
    private var appContent: PBMORTBAppContent?
    private var userData: [PBMORTBContentData]?
    private var contextKeywords = Set<String>()
    private var pbAdSlot: String?
    
    // MARK: - Initialization
    
    public convenience init(configId: String) {
        self.init(configId: configId, size: CGSize.zero)
    }
    
    public init(configId: String, size: CGSize) {
        self.configId = configId
        self.adSize = size
    }
    
    // MARK: - Context Data (imp[].ext.context.data)
    
    public func addContextData(key: String, value: String) {
        if contextDataDictionary[key] == nil {
            contextDataDictionary[key] = Set<String>()
        }
        
        contextDataDictionary[key]?.insert(value)
    }
    
    public func updateContextData(key: String, value: Set<String>) {
        contextDataDictionary[key] = value
    }
    
    public func removeContextData(for key: String) {
        contextDataDictionary.removeValue(forKey: key)
    }
    
    public func clearContextData() {
        contextDataDictionary.removeAll()
    }
    
    public func getContextDataDictionary() -> [String : [String]] {
        contextDataDictionary.mapValues { Array($0) }
    }
    
    // MARK: - Context keywords (imp[].ext.context.keywords)
    
    public func addContextKeyword(_ newElement: String) {
        contextKeywords.insert(newElement)
    }

    public func addContextKeywords(_ newElements: Set<String>) {
        contextKeywords.formUnion(newElements)
    }
    
    public func removeContextKeyword(_ element: String) {
        contextKeywords.remove(element)
    }
    
    public func clearContextKeywords() {
        contextKeywords.removeAll()
    }
    
    public func getContextKeywords() -> Set<String> {
        contextKeywords
    }
    
    // MARK: - App Content
    
    public func setAppContent(_ appContent: PBMORTBAppContent) {
        self.appContent = appContent
    }
    
    public func getAppContent() -> PBMORTBAppContent? {
        appContent
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
    
    // MARK: - User Data (user.ext.data)
    
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        if userData == nil {
            userData = [PBMORTBContentData]()
        }
        userData?.append(contentsOf: userDataObjects)
    }
    
    public func getUserData() -> [PBMORTBContentData]? {
        userData
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
    
    public func setPbAdSlot(_ newElement: String) {
        pbAdSlot = newElement
    }
    
    public func getPbAdSlot() -> String? {
        return pbAdSlot
    }
    
    public func clearAdSlot() {
        pbAdSlot = nil
    }
}
