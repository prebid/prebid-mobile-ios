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

public protocol OriginalAdUnitConfigurationProtocol {
    
    // MARK: - Properties
    
    var configId: String { get set }
    var adSize: CGSize { get set }
    var additionalSizes: [CGSize]? { get set }
    
    // MARK: - Context Data (imp[].ext.context.data)
    
    func addContextData(key: String, value: String)
    func updateContextData(key: String, value: Set<String>)
    func removeContextData(for key: String)
    func clearContextData()
    func getContextData() -> [String: [String]]
    
    // MARK: - Context keywords (imp[].ext.context.keywords)
    
    func addContextKeyword(_ newElement: String)
    func addContextKeywords(_ newElements: Set<String>)
    func removeContextKeyword(_ element: String)
    func clearContextKeywords()
    func getContextKeywords() -> Set<String>
    
    // MARK: - App Content (app.data)
    
    func setAppContent(_ appContent: PBMORTBAppContent)
    func getAppContent() -> PBMORTBAppContent?
    func clearAppContent()
    func addAppContentData(_ dataObjects: [PBMORTBContentData])
    func removeAppContentData(_ dataObject: PBMORTBContentData)
    func clearAppContentData()
    
    // MARK: - User Data (user.data)
    
    func getUserData() -> [PBMORTBContentData]?
    func addUserData(_ userDataObjects: [PBMORTBContentData])
    func removeUserData(_ userDataObject: PBMORTBContentData)
    func clearUserData()
    
    // MARK: - The Prebid Ad Slot
    
    func setPbAdSlot(_ newElement: String?)
    func getPbAdSlot() -> String?
}
