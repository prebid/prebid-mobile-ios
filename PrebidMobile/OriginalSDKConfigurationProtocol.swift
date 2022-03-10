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

public protocol OriginalSDKConfigurationProtocol {
    
    static var bidderNameAppNexus: String { get }
    static var bidderNameRubiconProject: String { get }
    
    var bidRequestTimeoutMillis: Int { get set }
    var bidRequestTimeoutDynamic: NSNumber? { get set }
    var timeoutUpdated: Bool { get set }
    var prebidServerAccountId: String { get set }
    var storedAuctionResponse: String? { get set }
    var customHeaders: [String: String] { get set }
    var storedBidResponses: [String: String] { get set }
    var pbsDebug: Bool { get set }
    
    var shouldAssignNativeAssetID : Bool { get set }
    var shareGeoLocation: Bool { get set }
    var prebidServerHost: PrebidHost { get set }
    var logLevel: LogLevel { get set }
    var externalUserIdArray: [ExternalUserId] { get set }
    
    func setLogLevel(_ logLevel: LogLevel_)
    func setCustomPrebidServer(url: String) throws
    func addStoredBidResponse(bidder: String, responseId: String)
    func clearStoredBidResponses()
    func addCustomHeader(name: String, value: String)
    func clearCustomHeaders()
}
