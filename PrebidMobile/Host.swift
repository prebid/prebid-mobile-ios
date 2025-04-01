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
import AppTrackingTransparency

/// A singleton class that manages the Prebid server URL, including a custom URL.
@objcMembers
public class Host: NSObject {

    private var customHostURL: URL? {
        get {
            guard nonTrackingURL != nil else {
                return trackingURL
            }
            
            guard #available(iOS 14.0, *) else {
                return deviceManager.advertisingTrackingEnabled() ? trackingURL : nonTrackingURL
            }
            let isAutorized = deviceManager.appTrackingTransparencyStatus() == ATTrackingManager.AuthorizationStatus.authorized.rawValue
            return isAutorized ? trackingURL : nonTrackingURL
        }
    }
    
    private var trackingURL: URL?
    private var nonTrackingURL: URL?
    
    private var deviceManager = PBMDeviceAccessManager(rootViewController: nil)

    /// The class is created as a singleton object & used
    public static let shared = Host()

    override init() {}
    
    convenience init(deviceManager: PBMDeviceAccessManager) {
        self.init()
        self.deviceManager = deviceManager
    }

    @objc public func setHostURL(_ urlString: String?, nonTrackingURLString: String?) throws {
        guard let trackingURL = URL.urlWithoutEncoding(from: urlString) else {
            throw ErrorCode.prebidServerURLInvalid(urlString ?? "")
        }
        
        if let nonTrackingURLString {
            guard let nonTrackingURL = URL.urlWithoutEncoding(from: nonTrackingURLString) else {
                throw ErrorCode.prebidServerURLInvalid(nonTrackingURLString)
            }
            self.nonTrackingURL = nonTrackingURL
        }
        
        self.trackingURL = trackingURL
    }
    
    public func getHostURL() throws -> String {
        guard let customHostURL else {
            throw ErrorCode.prebidServerURLInvalid("")
        }
        return customHostURL.absoluteString
    }

    /// This function verifies if the prebid server URL is in the url format
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
    
    /// This function used for unit testing to reset `customHostURL`.
    /// nternal only.
    func reset() {
        trackingURL = nil
        nonTrackingURL = nil
    }
}
