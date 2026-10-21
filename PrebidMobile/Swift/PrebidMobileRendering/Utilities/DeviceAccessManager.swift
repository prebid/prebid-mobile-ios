//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit
import AdSupport
import AppTrackingTransparency


class DeviceAccessManager: NSObject {

    // MARK: - Properties

    var deviceMake: String { "Apple" }

    var deviceModel: String {
        UIDevice.current.model
    }

    var identifierForVendor: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    var deviceOS: String {
        UIDevice.current.systemName
    }

    var OSVersion: String {
        UIDevice.current.systemVersion
    }

    var platformString: String? {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)

        let machine = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        defer { machine.deallocate() }

        sysctlbyname("hw.machine", machine, &size, nil, 0)
        return String(validatingUTF8: machine)
    }

    var userLangaugeCode: String? {
        locale.languageCode
    }

    private(set) var locale: Locale

    weak var rootViewController: UIViewController?

    // MARK: - Init

    @available(*, unavailable, message: "Use initWithRootViewController or initWithRootViewController(_:locale:) instead.")
    override init() {
        fatalError("init() is unavailable")
    }

    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
        self.locale = .autoupdatingCurrent
        super.init()
    }

    init(rootViewController: UIViewController?, locale: Locale) {
        self.rootViewController = rootViewController
        self.locale = locale
        super.init()
    }

    // MARK: - IDFA & Tracking

    func advertisingIdentifier() -> String {
        let advertisingIdentifier = ASIdentifierManager.shared()
            .perform(#selector(getter: ASIdentifierManager.advertisingIdentifier))?
            .takeUnretainedValue() as? NSUUID
        return advertisingIdentifier?.uuidString ?? ""
    }

    func advertisingTrackingEnabled() -> Bool {
        ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    }

    func appTrackingTransparencyStatus() -> UInt {
        guard #available(iOS 14.0, *) else {
            return 0 // ATTrackingManagerAuthorizationStatus.notDetermined
        }
        return UInt(ATTrackingManager.trackingAuthorizationStatus.rawValue)
    }

    // MARK: - Screen

    func screenSize() -> CGSize {
        UIDevice.current.screenSize
    }
}
