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

import UIKit

@objc public enum PrebidHost: Int {
    
    /**
     URL [https://prebid.adnxs.com/pbs/v1/openrtb2/auction](URL)
    */
    case Appnexus
    
    /**
     URL [https://prebid-server.rubiconproject.com/openrtb2/auction](URL)
     */
    case Rubicon
    
    case Custom

    func name () -> String {
        switch self {
        case .Appnexus: return "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
        case .Rubicon: return "https://prebid-server.rubiconproject.com/openrtb2/auction"
        case .Custom: return ""
        }
    }
}

@objcMembers
public class Host: NSObject {

    private var customHostURL: URL?

    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Host()

    override init() {

    }

    /**
     * The CustomHost property holds the URL for the custom prebid adaptor
     */
    
    @objc public func setCustomHostURL(_ urlString: String?) throws {
        guard let url = URL(string: urlString!) else {
            throw ErrorCode.prebidServerURLInvalid(urlString ?? "")
        }
        customHostURL = url
    }

    /**
     * This function retrieves the prebid server URL for the selected host
     */
    public func getHostURL(host: PrebidHost) throws -> String {
        if (host == PrebidHost.Custom) {

            if let customHostURL = customHostURL {
                return customHostURL.absoluteString
            } else {
                throw ErrorCode.prebidServerURLInvalid("")
            }
        }

        return host.name()
    }

    /**
     * This function verifies if the prebid server URL is in the url format
     */
    public func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)

            }
        }
        return false
    }

}
