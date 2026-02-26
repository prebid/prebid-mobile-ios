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

@objc(PBMDeviceAccessManager)
public class DeviceAccessManager: NSObject {

    // MARK: - Properties

    @objc public var deviceMake: String { "Apple" }

    @objc public var deviceModel: String {
        UIDevice.current.model
    }

    @objc public var identifierForVendor: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    @objc public var deviceOS: String {
        UIDevice.current.systemName
    }

    @objc public var OSVersion: String {
        UIDevice.current.systemVersion
    }

    @objc public var platformString: String? {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)

        let machine = UnsafeMutablePointer<CChar>.allocate(capacity: size)
        defer { machine.deallocate() }

        sysctlbyname("hw.machine", machine, &size, nil, 0)
        return String(validatingUTF8: machine)
    }

    @objc public var userLangaugeCode: String? {
        locale.languageCode
    }

    @objc public private(set) var locale: Locale

    @objc public weak var rootViewController: UIViewController?

    // MARK: - Init

    @available(*, unavailable, message: "Use initWithRootViewController or initWithRootViewController(_:locale:) instead.")
    public override init() {
        fatalError("init() is unavailable")
    }

    @objc public init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
        self.locale = .autoupdatingCurrent
        super.init()
    }

    @objc public init(rootViewController: UIViewController?, locale: Locale) {
        self.rootViewController = rootViewController
        self.locale = locale
        super.init()
    }

    // MARK: - IDFA & Tracking

    @objc public func advertisingIdentifier() -> String {
        ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    @objc public func advertisingTrackingEnabled() -> Bool {
        ASIdentifierManager.shared().isAdvertisingTrackingEnabled
    }

    @objc public func appTrackingTransparencyStatus() -> UInt {
        guard #available(iOS 14.0, *) else {
            return 0 // ATTrackingManagerAuthorizationStatus.notDetermined
        }
        return UInt(ATTrackingManager.trackingAuthorizationStatus.rawValue)
    }

    // MARK: - Screen

    @objc public func screenSize() -> CGSize {
        UIDevice.current.screenSize
    }
    
    @objc public func screenSizeInPixels() -> CGSize {
        let toPixels = {
            Int(($0 * UIScreen.main.scale).rounded())
        }
        let size = screenSize()
        return CGSize(width: toPixels(size.width), height: toPixels(size.height))
    }
}
