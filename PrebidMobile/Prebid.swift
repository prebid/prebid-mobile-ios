/*   Copyright 2018-2019 Prebid.org, Inc.

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

@objcMembers public class Prebid: NSObject {
    
    public static let bidderNameAppNexus = "appnexus"
    public static let bidderNameRubiconProject = "rubicon"
    
    public var timeoutMillis: Int = .PB_Request_Timeout {
        didSet {
            timeoutMillisDynamic = timeoutMillis
        }
    }
    
    var timeoutMillisDynamic: Int
    var timeoutUpdated: Bool = false

    public var prebidServerAccountId: String = ""
    
    public var storedAuctionResponse: String = ""
    
    public var pbsDebug: Bool = false
    
    var storedBidResponses: [String: String] = [:]

    
    
    /**
    * This property is set by the developer when he is willing to assign the assetID for Native ad.
    **/
    public var shouldAssignNativeAssetID : Bool = false

    
    
    /**
    * This property is set by the developer when he is willing to share the location for better ad targeting
    **/
    public var shareGeoLocation = false

    public var prebidServerHost: PrebidHost = PrebidHost.Custom {
        didSet {
            timeoutMillisDynamic = timeoutMillis
            timeoutUpdated = false
        }
    }

    /**
     * Set the desidered verbosity of the logs
     */
    public var logLevel: LogLevel = .debug
    
    /**
     * Array  containing objects that hold External UserId parameters.
     */
    public var externalUserIdArray = [ExternalUserId]()
    
    /**
     * Set the desidered verbosity of the logs
     */
    //Objective-C Api
    @available(swift, obsoleted: 1.0)
    public func setLogLevel(_ logLevel: LogLevel_) {
        self.logLevel = logLevel.getPrimary()
    }

    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Prebid()

    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        timeoutMillisDynamic = timeoutMillis
        
        super.init()
        if (RequestBuilder.myUserAgent == "") {
            RequestBuilder.UserAgent {(userAgentString) in
                Log.info(userAgentString)
                RequestBuilder.myUserAgent = userAgentString
            }
        }
    }

    public func setCustomPrebidServer(url: String) throws {

        if (Host.shared.verifyUrl(urlString: url) == false) {
            throw ErrorCode.prebidServerURLInvalid(url)
        } else {
            prebidServerHost = PrebidHost.Custom
            Host.shared.setHostURL = url
        }
    }
    
    public func addStoredBidResponse(bidder: String, responseId: String) {
        storedBidResponses[bidder] = responseId
    }
    
    public func clearStoredBidResponses() {
        storedBidResponses.removeAll()
    }
}
