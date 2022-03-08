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

public protocol OriginalTargetingProtocol {
    
    // MARK: - Public properties
    
    var yearOfBirth: Int { get set }
    var subjectToGDPR: Bool? { get set }
    
    // MARK: - Year Of Birth
    
    func setYearOfBirth(yob: Int)
    func clearYearOfBirth()
    
    // MARK: - COPPA
    
    func setSubjectToGDPR(_ newValue: NSNumber?)
    func getSubjectToGDPR() -> NSNumber?
    
    // MARK: - External User Ids
    
    func storeExternalUserId(_ externalUserId: ExternalUserId)
    func fetchStoredExternalUserIds() -> [ExternalUserId]?
    func fetchStoredExternalUserId(_ source : String) -> ExternalUserId?
    func removeStoredExternalUserId(_ source : String)
    func removeStoredExternalUserIds()
     
    // MARK: - Access control list (ext.prebid.data)
    
    func addBidderToAccessControlList(_ bidderName: String)
    func removeBidderFromAccessControlList(_ bidderName: String)
    func clearAccessControlList()
    func getAccessControlList() -> [String]
    
    // MARK: - Global user data aka visitor data (user.ext.data)
    
    func addUserData(key: String, value: String)
    func updateUserData(key: String, value: Set<String>)
    func removeUserData(for key: String)
    func clearUserData()
    func getUserData() -> [String: [String]]
    
    // MARK: - Global user keywords (user.keywords)
    
    func addUserKeyword(_ newElement: String)
    func addUserKeywords(_ newElements: Set<String>)
    func removeUserKeyword(_ element: String)
    func clearUserKeywords()
    func getUserKeywords() -> [String]
    
    // MARK: - Global context data aka inventory data (app.ext.data)
    
    func addContextData(key: String, value: String)
    func updateContextData(key: String, value: Set<String>)
    func removeContextData(for key: String)
    func clearContextData()
    func getContextData() -> [String: [String]]
    
    // MARK: - Global context keywords (app.keywords)
    
    func addContextKeyword(_ newElement: String)
    func addContextKeywords(_ newElements: Set<String>)
    func removeContextKeyword(_ element: String)
    func clearContextKeywords()
    func getContextKeywords() -> [String]
}
