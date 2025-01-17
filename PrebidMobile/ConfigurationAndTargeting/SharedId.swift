/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

class SharedId {
    
    static let sharedInstance = SharedId()
    
    private var sessionId: ExternalUserId? = nil
    
    var identifier: ExternalUserId {
        let persistentStorageAllowed = Targeting.shared.isAllowedAccessDeviceData()
        
        // If sharedId was used previously in this session, then use that id
        if let sessionId {
            if persistentStorageAllowed {
                StorageUtils.sharedId = sessionId.identifier
            }
            return sessionId
        }
        
        // Otherwise if an id is available in persistent storage, then use that id
        if persistentStorageAllowed, let storedId = StorageUtils.sharedId {
            let eid = externalUserId(from: storedId)
            sessionId = eid
            return eid
        }
        
        // Otherwise generate a new id
        let eid = externalUserId(from: UUID().uuidString)
        sessionId = eid
        if persistentStorageAllowed {
            StorageUtils.sharedId = eid.identifier
        }
        return eid
    }
    
    func resetIdentifier() {
        sessionId = nil
        StorageUtils.sharedId = nil
    }
    
    private func externalUserId(from identifier: String) -> ExternalUserId {
        ExternalUserId(source: "pubcid.org", identifier: identifier, atype: 1)
    }
}
