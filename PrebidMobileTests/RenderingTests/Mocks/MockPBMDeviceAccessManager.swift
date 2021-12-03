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

@testable import PrebidMobile

typealias PBMDeviceAccessManagerCompletionHandler = (Bool, String) -> Void

class MockPBMDeviceAccessManager: PBMDeviceAccessManager {
    
    static var mock_createCalendarEventFromString_completion: ((String, PBMDeviceAccessManagerCompletionHandler) -> Void)?
    override func createCalendarEventFromString(_ eventString: String, completion: @escaping PBMDeviceAccessManagerCompletionHandler) {
        MockPBMDeviceAccessManager.mock_createCalendarEventFromString_completion?(eventString, completion)
    }
    
    static var mock_savePhotoWithUrlToAsset_completion: ((URL, PBMDeviceAccessManagerCompletionHandler) -> Void)?
    override func savePhotoWithUrlToAsset(_ url: URL, completion: @escaping PBMDeviceAccessManagerCompletionHandler) {
        MockPBMDeviceAccessManager.mock_savePhotoWithUrlToAsset_completion?(url, completion)
    }
    
    static func reset() {
        self.mock_createCalendarEventFromString_completion = nil
        self.mock_savePhotoWithUrlToAsset_completion = nil
    }
}
