/*   Copyright 2018-2021 Prebid.org, Inc.

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

// MARK: - PBMMRAIDParseKeys

class MRAIDParseKeys: NSObject {
    static let X               = "x"
    static let Y               = "y"
    static let WIDTH           = "width"
    static let HEIGHT          = "height"
    static let X_OFFSET        = "offsetX"
    static let Y_OFFSET        = "offsetY"
    static let ALLOW_OFFSCREEN = "allowOffscreen"
    static let FORCE_ORIENTATION = "forceOrientation"
}

// MARK: - PBMMRAIDValues

class MRAIDValues: NSObject {
    static let LANDSCAPE = "landscape"
    static let PORTRAIT  = "portrait"
}

// MARK: - PBMMRAIDCloseButtonPosition

class MRAIDCloseButtonPosition: NSObject {
    static let BOTTOM_CENTER = "bottom-center"
    static let BOTTOM_LEFT   = "bottom-left"
    static let BOTTOM_RIGHT  = "bottom-right"
    static let CENTER        = "center"
    static let TOP_CENTER    = "top-center"
    static let TOP_LEFT      = "top-left"
    static let TOP_RIGHT     = "top-right"
}

// MARK: - PBMMRAIDCloseButtonSize

class MRAIDCloseButtonSize: NSObject {
    static let WIDTH: Float  = 50
    static let HEIGHT: Float = 50
}

// MARK: - PBMMRAIDExpandProperties  (NS_SWIFT_NAME = MRAIDExpandProperties)


class MRAIDExpandProperties: NSObject {
    var width: Int = 0
    var height: Int = 0

    override init() { super.init() }
    init(width: Int, height: Int) {
        self.width  = width
        self.height = height
        super.init()
    }
}

// MARK: - PBMMRAIDResizeProperties  (NS_SWIFT_NAME = MRAIDResizeProperties)


class MRAIDResizeProperties: NSObject {
    var width: Int = 0
    var height: Int = 0
    var offsetX: Int = 0
    var offsetY: Int = 0
    var allowOffscreen: Bool = false

    override init() { super.init() }
    init(width: Int, height: Int, offsetX: Int, offsetY: Int, allowOffscreen: Bool) {
        self.width          = width
        self.height         = height
        self.offsetX        = offsetX
        self.offsetY        = offsetY
        self.allowOffscreen = allowOffscreen
        super.init()
    }
}

// MARK: - PBMMRAIDConstants

class MRAIDConstants: NSObject {
    static let mraidURLScheme = "mraid:"

    // String values match the `MRAIDAction` constants below
    static var allCases: [String] {
        ["open", "expand", "resize", "close", "playVideo",
         "log", "onOrientationPropertiesChanged", "unload"]
    }
}

// MARK: - MRAID typed string constants
// Ported from the `NS_TYPED_ENUM` groups of PBMMRAIDConstants.h (S2.1-A residue). No ObjC consumer remains,
// so these are plain Swift `RawRepresentable` structs (Strings on the wire, `.rawValue` to read them).

/// MRAID command names (`PBMMRAIDAction`).
struct MRAIDAction: RawRepresentable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    // Debug
    static let log = MRAIDAction(rawValue: "log")
    // MRAID 1
    static let open = MRAIDAction(rawValue: "open")
    static let close = MRAIDAction(rawValue: "close")
    static let expand = MRAIDAction(rawValue: "expand")
    // MRAID 2
    static let resize = MRAIDAction(rawValue: "resize")
    static let storePicture = MRAIDAction(rawValue: "storepicture")
    static let createCalendarEvent = MRAIDAction(rawValue: "createCalendarevent")
    static let playVideo = MRAIDAction(rawValue: "playVideo")
    static let onOrientationPropertiesChanged = MRAIDAction(rawValue: "onOrientationPropertiesChanged")
    // MRAID 3
    static let unload = MRAIDAction(rawValue: "unload")
}

/// MRAID placement types (`PBMMRAIDPlacementType`).
struct MRAIDPlacementType: RawRepresentable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let inline = MRAIDPlacementType(rawValue: "inline")
    static let interstitial = MRAIDPlacementType(rawValue: "interstitial")
}

/// MRAID supported features (`PBMMRAIDFeature`).
struct MRAIDFeature: RawRepresentable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    static let sms = MRAIDFeature(rawValue: "sms")
    static let phone = MRAIDFeature(rawValue: "tel")
    static let calendar = MRAIDFeature(rawValue: "calendar")
    static let savePicture = MRAIDFeature(rawValue: "storePicture")
    static let inlineVideo = MRAIDFeature(rawValue: "inlineVideo")
    static let location = MRAIDFeature(rawValue: "location")
    static let vpaid = MRAIDFeature(rawValue: "vpaid")
}
