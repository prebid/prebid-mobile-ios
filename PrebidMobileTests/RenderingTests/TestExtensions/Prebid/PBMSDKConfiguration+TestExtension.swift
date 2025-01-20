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

extension Prebid {
    static let devintServerURL = "https://prebid.devint.openx.net/openrtb2/auction"
    static let devintAccountID = "4f112bad-8cd2-4c43-97d0-1ab72fd442ed"
    static let prodAccountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
    
    static var mock: Prebid {
        Prebid.reset()
        return Prebid.shared
    }
    
    static func reset() {
        Prebid.shared.prebidServerHost = PrebidHost.Custom
        Prebid.shared.prebidServerAccountId = ""
        Host.shared.reset()
        
        Prebid.shared.timeoutMillis = 2000
        
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        
        Prebid.forcedIsViewable = false
        Prebid.shared.clearCustomHeaders()
        Prebid.shared.clearStoredBidResponses()
        Prebid.shared.includeWinners = false
        Prebid.shared.includeBidderKeys = false
        
        Prebid.shared.useExternalClickthroughBrowser = false
        
        Prebid.shared.creativeFactoryTimeout = 6.0
        Prebid.shared.creativeFactoryTimeoutPreRenderContent = 30.0
        
        Prebid.shared.eventDelegate = nil
    }
    
    static var forcedIsViewable: Bool {
        get { UserDefaults.standard.bool(forKey: "forcedIsViewable") }
        set { UserDefaults.standard.setValue(newValue, forKey: "forcedIsViewable")}
    }
}
