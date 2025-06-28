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

@objc(PBMInterstitialDisplayProperties)
public class InterstitialDisplayProperties: NSObject, Copyable {
    
    @objc public var closeDelay: TimeInterval = 0
    
    // The time interval that left from @closeDelay in case of interruption
    @objc public var closeDelayLeft: TimeInterval = 0
    
    @objc public var contentFrame: CGRect = .infinite
    @objc public var contentViewColor: UIColor = .clear
    @objc public var interstitialLayout: InterstitialLayout = .undefined
    
    @objc(rotationEnabled)
    public var isRotationEnabled: Bool {
        interstitialLayout == .aspectRatio
    }
    
    @objc public func setButtonImageHidden() {
        closeButtonImage = UIImage()
    }
    
    public override init() {
        super.init()
        
        setupCloseButtonAccessibility()
    }
    
    var _closeButtonImage: UIImage? = PrebidImagesRepository.closeButton.base64DecodedImage
    var closeButtonImage: UIImage? {
        get { _closeButtonImage }
        set {
            guard let newValue else {
                return
            }
            _closeButtonImage = newValue
            setupCloseButtonAccessibility()
        }
    }
    
    private func setupCloseButtonAccessibility() {
        //Explicitly set the accessibility identifier every time the close button image is set.
        //This prevents the file name from informing the identifier.
        _closeButtonImage?.accessibilityIdentifier = PrebidConstants.ACCESSIBILITY_CLOSE_BUTTON_IDENTIFIER
        _closeButtonImage?.accessibilityLabel = PrebidConstants.ACCESSIBILITY_CLOSE_BUTTON_LABEL
    }
    
    @objc public func getCloseButtonImage() -> UIImage? {
        closeButtonImage
    }
    
    public override func copy() -> Any {
        let ret = InterstitialDisplayProperties()
        ret.closeDelay = closeDelay
        ret.closeButtonImage = closeButtonImage
        ret.closeDelayLeft = closeDelayLeft
        ret.contentFrame = contentFrame
        ret.contentViewColor = contentViewColor
        ret.interstitialLayout = interstitialLayout
        return ret
    }
}
