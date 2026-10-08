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

// ObjC name preserved for the bridge; no ObjC caller remains (AdViewManagerImpl calls it from Swift)
@objc(PBMInterstitialLayoutConfigurator) @_spi(PBMInternal) public
class InterstitialLayoutConfigurator: NSObject {

    @objc(configurePropertiesWithAdConfiguration:displayProperties:)
    public static func configureProperties(
        with adConfiguration: AdConfiguration,
        displayProperties: InterstitialDisplayProperties
    ) {
        let layout = adConfiguration.interstitialLayout
        if layout != .undefined {
            displayProperties.interstitialLayout = layout
            return
        }

        displayProperties.interstitialLayout = calculateLayout(from: adConfiguration.size)
    }

    @objc(calculateLayoutFromSize:)
    public static func calculateLayout(from size: CGSize) -> InterstitialLayout {
        if isPortrait(size) {
            return .portrait
        }

        if isLandscape(size) {
            return .landscape
        }

        return .aspectRatio
    }

    @objc(isPortrait:)
    public static func isPortrait(_ size: CGSize) -> Bool {
        portraitSizes.contains(size)
    }

    @objc(isLandscape:)
    public static func isLandscape(_ size: CGSize) -> Bool {
        landscapeSizes.contains(size)
    }

    private static let portraitSizes: [CGSize] = [
        CGSize(width: 270, height: 480),
        CGSize(width: 300, height: 1050),
        CGSize(width: 320, height: 480),
        CGSize(width: 360, height: 480),
        CGSize(width: 360, height: 640),
        CGSize(width: 480, height: 640),
        CGSize(width: 576, height: 1024),
        CGSize(width: 720, height: 1280),
        CGSize(width: 768, height: 1024),
        CGSize(width: 960, height: 1280),
        CGSize(width: 1080, height: 1920),
        CGSize(width: 1440, height: 1920)
    ]

    private static let landscapeSizes: [CGSize] = [
        CGSize(width: 480, height: 320),
        CGSize(width: 480, height: 360),
        CGSize(width: 1024, height: 768)
    ]
}
