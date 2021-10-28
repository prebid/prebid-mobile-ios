//
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

fileprivate let appnexusURL = "https://prebid.adnxs.com/pbs/v1/openrtb2/auction"
fileprivate let rubiconURL = "https://prebid-server.rubiconproject.com/openrtb2/auction"

@objc
public class PBRHost: NSObject {
    
    // MARK: - Public Properties
    
    @objc public static var shared = PBRHost()
    
    // MARK: - Private Properties
    
    private var customHostURL: URL?
    
    // MARK: - Public Methods
    
    @objc public func setCustomHostURL(_ url: URL?) {
        customHostURL = url
    }
    
    @objc public func getHostURL(for host: PBRPrebidHost) throws -> String {
        switch(host) {
        case .appnexus: return appnexusURL
        case .rubicon:  return rubiconURL
            
        case .custom:
            guard let url = customHostURL else {
                throw PBMError.prebidServerURLInvalid("")
            }
            
            return url.absoluteString
        }
    }
}
