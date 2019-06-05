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
    public var timeoutMillis: Int = .PB_Request_Timeout
    var timeoutUpdated: Bool = false

    public var prebidServerAccountId: String! = ""

    /**
    * This property is set by the developer when he is willing to share the location for better ad targeting
    **/
    private var geoLocation: Bool = false
    public var shareGeoLocation: Bool {
        get {
           return geoLocation
        }

        set {
            geoLocation = newValue
            if (geoLocation == true) {
                Location.shared.startCapture()
            } else {
                Location.shared.stopCapture()
            }
        }
    }

    public var prebidServerHost: PrebidHost = PrebidHost.Custom {
        didSet {
            timeoutMillis = .PB_Request_Timeout
            timeoutUpdated = false
        }
    }

    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Prebid()

    /**
     * The initializer that needs to be created only once
     */
    private override init() {
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
}
