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

class NativeAdEventTracker: NSObject {

    /// Type of event to track.
    /// See Event Types table.
    @objc public var event: NativeEventType {
        NativeEventType(rawValue: nativeAdMarkupEventTracker.event) ?? .exchangeSpecific
    }

    /// Type of tracking requested.
    /// See Event Tracking Methods table.
    @objc public var method: Int {
        nativeAdMarkupEventTracker.method
    }

    /// The URL of the image or js.
    /// Required for image or js, optional for custom.
    @objc public var url: String? {
        nativeAdMarkupEventTracker.url
    }

    /// To be agreed individually with the exchange, an array of key:value objects for custom tracking,
    /// for example the account number of the DSP with a tracking company. IE {“accountnumber”:”123”}.
    @objc public var customdata: [String : Any]? { nativeAdMarkupEventTracker.customdata }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var ext: [String : Any]? {
        nativeAdMarkupEventTracker.ext
    }
    
    var nativeAdMarkupEventTracker: PBMNativeAdMarkupEventTracker!

    // MARK: - Lifecycle

    @objc public init(nativeAdMarkupEventTracker: PBMNativeAdMarkupEventTracker) {
        self.nativeAdMarkupEventTracker = nativeAdMarkupEventTracker
    }

    // MARK: - NSObject

    @objc public override func isEqual(_ object: Any?) -> Bool {
        if !(object is Self) {
            return false
        }
        let other = object as? Self
        return self === other || nativeAdMarkupEventTracker == other?.nativeAdMarkupEventTracker
    }
    
    // MARK: - Private
    
    private override init() {
    }
}
