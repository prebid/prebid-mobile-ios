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
import CoreLocation
import UIKit

// The ObjC original formatted every object argument with `%@`, which prints `(null)` for `nil`. The parameters that
// surviving ObjC callers could pass as `nil` are optional here for the same reason (playbook S3.1-H, S5.2-C).
@objc(PBMMRAIDJavascriptCommands)
@_spi(PBMInternal) public class MRAIDJavascriptCommands: NSObject {

    private static let nullDescription = "(null)"

    // MARK: - command functions

    @objc(isEnabled)
    public static func isEnabled() -> String {
        "typeof mraid !== 'undefined'"
    }

    @objc(nativeCallComplete)
    public static func nativeCallComplete() -> String {
        "mraid.nativeCallComplete();"
    }

    // MARK: - SDK state change functions

    @objc(onReady)
    public static func onReady() -> String {
        "mraid.onReady();"
    }

    @objc(onReadyExpanded)
    public static func onReadyExpanded() -> String {
        "mraid.onReadyExpanded();"
    }

    @objc(onViewableChange:)
    public static func onViewableChange(_ isViewable: Bool) -> String {
        "mraid.onViewableChange(\(isViewable ? "true" : "false"));"
    }

    @objc(onExposureChange:)
    public static func onExposureChange(_ viewExposure: ViewExposure?) -> String {
        let serialized = viewExposure?.serialize(withFormatter: floatFormatter) ?? nullDescription
        return "mraid.onExposureChange(\"\(serialized)\");"
    }

    @objc(onSizeChange:)
    public static func onSizeChange(_ newSize: CGSize) -> String {
        "mraid.onSizeChange(\(formatFloat(newSize.width)),\(formatFloat(newSize.height)));"
    }

    @objc(onStateChange:)
    public static func onStateChange(_ newState: MRAIDState?) -> String {
        "mraid.onStateChange('\(newState?.description ?? nullDescription)');"
    }

    @objc(onAudioVolumeChange:)
    public static func onAudioVolumeChange(_ volumePercentage: NSNumber?) -> String {
        let volume = volumePercentage.map { formatFloat(CGFloat($0.floatValue)) } ?? "null"
        return "mraid.onAudioVolumeChange(\(volume));"
    }

    // MARK: - update Ad data

    @objc(updateSupportedFeatures)
    public static func updateSupportedFeatures() -> String {
        "mraid.allSupports = \(supportedFeatureString());"
    }

    /// `type` is one of the `PBMMRAIDPlacementType` string constants (`NS_TYPED_ENUM`, not visible to this target).
    @objc(updatePlacementType:)
    public static func updatePlacementType(_ type: String?) -> String {
        "mraid.placementType = '\(type ?? nullDescription)';"
    }

    @objc(updateMaxSize:)
    public static func updateMaxSize(_ newMaxSize: CGSize) -> String {
        "mraid.setMaxSize(\(formatFloat(newMaxSize.width)),\(formatFloat(newMaxSize.height)));"
    }

    @objc(updateCurrentAppOrientation:locked:)
    public static func updateCurrentAppOrientation(_ orientation: String?, locked: Bool) -> String {
        "mraid.setCurrentAppOrientation('\(orientation ?? nullDescription)', \(locked ? "true" : "false"));"
    }

    @objc(updateScreenSize:)
    public static func updateScreenSize(_ newScreenSize: CGSize) -> String {
        let width = "\(MRAIDParseKeys.WIDTH):\(formatFloat(newScreenSize.width))"
        let height = "\(MRAIDParseKeys.HEIGHT):\(formatFloat(newScreenSize.height))"

        return "mraid.screenSize = {\(width),\(height)};"
    }

    @objc(updateDefaultPosition:)
    public static func updateDefaultPosition(_ position: CGRect) -> String {
        "mraid.defaultPosition = \(rectString(position));"
    }

    @objc(updateCurrentPosition:)
    public static func updateCurrentPosition(_ position: CGRect) -> String {
        "mraid.currentPosition = \(rectString(position));"
    }

    @objc(updateLocation:accuracy:timeStamp:)
    public static func updateLocation(_ coordinate: CLLocationCoordinate2D,
                                      accuracy: CLLocationAccuracy,
                                      timeStamp: TimeInterval) -> String {
        let latitude = formatFloat(CGFloat(coordinate.latitude))
        let longitude = formatFloat(CGFloat(coordinate.longitude))
        return "mraid.setLocation(\(latitude),\(longitude),\(formatFloat(CGFloat(accuracy))),\(formatFloat(CGFloat(timeStamp))));"
    }

    // MARK: - get data from Ad

    @objc(getCurrentPosition)
    public static func getCurrentPosition() -> String {
        "JSON.stringify(mraid.getCurrentPosition());"
    }

    @objc(getOrientationProperties)
    public static func getOrientationProperties() -> String {
        "JSON.stringify(mraid.getOrientationProperties());"
    }

    @objc(getExpandProperties)
    public static func getExpandProperties() -> String {
        "JSON.stringify(mraid.getExpandProperties());"
    }

    @objc(getResizeProperties)
    public static func getResizeProperties() -> String {
        "JSON.stringify(mraid.getResizeProperties());"
    }

    // MARK: - error

    /// `action` is one of the `PBMMRAIDAction` string constants (`NS_TYPED_ENUM`, not visible to this target).
    @objc(onErrorWithMessage:action:)
    public static func onError(_ message: String?, action: String?) -> String {
        "mraid.onError('\(message ?? nullDescription)','\(action ?? nullDescription)');"
    }

    // MARK: - Internal methods

    private static func supportedFeatureString() -> String {

        // Same strings as the `PBMMRAIDFeature*` constants. Not built as a Swift `Dictionary`: the key order of the
        // serialized JSON must stay that of the `NSDictionary` the ObjC original serialized.
        let supports = NSDictionary(dictionary: [
            "sms": true,
            "tel": true,
            "calendar": false,
            "storePicture": false,
            "inlineVideo": true,
            "location": true,
            "vpaid": false
        ])

        guard let data = try? JSONSerialization.data(withJSONObject: supports, options: []) else {
            Log.error("Could not generate support string")
            return ""
        }

        return String(data: data, encoding: .utf8) ?? nullDescription
    }

    private static func rectString(_ position: CGRect) -> String {
        let originX = "\(MRAIDParseKeys.X):\(formatFloat(position.origin.x))"
        let originY = "\(MRAIDParseKeys.Y):\(formatFloat(position.origin.y))"
        let width = "\(MRAIDParseKeys.WIDTH):\(formatFloat(position.size.width))"
        let height = "\(MRAIDParseKeys.HEIGHT):\(formatFloat(position.size.height))"

        return "{\(originX), \(originY), \(width), \(height)}"
    }

    private static let floatFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 4
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."
        return formatter
    }()

    private static func formatFloat(_ value: CGFloat) -> String {
        floatFormatter.string(from: NSNumber(value: Double(value))) ?? nullDescription
    }
}
