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

@objc(PBMMRAIDParseKeys)
public class MRAIDParseKeys: NSObject {
    @objc public static let X               = "x"
    @objc public static let Y               = "y"
    @objc public static let WIDTH           = "width"
    @objc public static let HEIGHT          = "height"
    @objc public static let X_OFFSET        = "offsetX"
    @objc public static let Y_OFFSET        = "offsetY"
    @objc public static let ALLOW_OFFSCREEN = "allowOffscreen"
    @objc public static let FORCE_ORIENTATION = "forceOrientation"
}

// MARK: - PBMMRAIDValues

@objc(PBMMRAIDValues)
public class MRAIDValues: NSObject {
    @objc public static let LANDSCAPE = "landscape"
    @objc public static let PORTRAIT  = "portrait"
}

// MARK: - PBMMRAIDCloseButtonPosition

@objc(PBMMRAIDCloseButtonPosition)
public class MRAIDCloseButtonPosition: NSObject {
    @objc public static let BOTTOM_CENTER = "bottom-center"
    @objc public static let BOTTOM_LEFT   = "bottom-left"
    @objc public static let BOTTOM_RIGHT  = "bottom-right"
    @objc public static let CENTER        = "center"
    @objc public static let TOP_CENTER    = "top-center"
    @objc public static let TOP_LEFT      = "top-left"
    @objc public static let TOP_RIGHT     = "top-right"
}

// MARK: - PBMMRAIDCloseButtonSize

@objc(PBMMRAIDCloseButtonSize)
public class MRAIDCloseButtonSize: NSObject {
    @objc public static let WIDTH: Float  = 50
    @objc public static let HEIGHT: Float = 50
}

// MARK: - PBMMRAIDExpandProperties  (NS_SWIFT_NAME = MRAIDExpandProperties)

@objc(PBMMRAIDExpandProperties)
public class MRAIDExpandProperties: NSObject {
    @objc public var width: Int = 0
    @objc public var height: Int = 0

    public override init() { super.init() }

    @objc(initWithWidth:height:)
    public init(width: Int, height: Int) {
        self.width  = width
        self.height = height
        super.init()
    }
}

// MARK: - PBMMRAIDResizeProperties  (NS_SWIFT_NAME = MRAIDResizeProperties)

@objc(PBMMRAIDResizeProperties)
public class MRAIDResizeProperties: NSObject {
    @objc public var width: Int = 0
    @objc public var height: Int = 0
    @objc public var offsetX: Int = 0
    @objc public var offsetY: Int = 0
    @objc public var allowOffscreen: Bool = false

    public override init() { super.init() }

    @objc(initWithWidth:height:offsetX:offsetY:allowOffscreen:)
    public init(width: Int, height: Int, offsetX: Int, offsetY: Int, allowOffscreen: Bool) {
        self.width          = width
        self.height         = height
        self.offsetX        = offsetX
        self.offsetY        = offsetY
        self.allowOffscreen = allowOffscreen
        super.init()
    }
}

// MARK: - PBMMRAIDConstants

@objc(PBMMRAIDConstants)
public class MRAIDConstants: NSObject {
    @objc public static let mraidURLScheme = "mraid:"

    // String values match PBMMRAIDAction* constants in PBMMRAIDConstants.h
    @objc public static var allCases: [String] {
        ["open", "expand", "resize", "close", "playVideo",
         "log", "onOrientationPropertiesChanged", "unload"]
    }
}
