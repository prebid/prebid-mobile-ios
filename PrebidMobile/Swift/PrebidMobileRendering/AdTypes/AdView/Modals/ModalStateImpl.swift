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

class ModalStateImpl: NSObject, ModalState {

    let adConfiguration: AdConfiguration?
    let displayProperties: InterstitialDisplayProperties?
    let view: UIView?

    var mraidState: MRAIDState = .notEnabled

    let onStatePopFinished: ModalStatePopHandler?
    let onStateHasLeftApp: ModalStateAppLeavingHandler?

    let nextOnStatePopFinished: ModalStatePopHandler?
    let nextOnStateHasLeftApp: ModalStateAppLeavingHandler?

    var onModalPushedBlock: VoidBlock?

    var isRotationEnabled: Bool {
        guard let webView = view?.subviews.last as? WebView else {
            return true
        }
        return webView.rotationEnabled
    }

    required init(
        view: UIView,
        adConfiguration: AdConfiguration?,
        displayProperties: InterstitialDisplayProperties?,
        onStatePopFinished: ModalStatePopHandler?,
        onStateHasLeftApp: ModalStateAppLeavingHandler?,
        nextOnStatePopFinished: ModalStatePopHandler?,
        nextOnStateHasLeftApp: ModalStateAppLeavingHandler?,
        onModalPushedBlock: VoidBlock?
    ) {
        self.view = view
        self.adConfiguration = adConfiguration
        self.displayProperties = displayProperties
        self.onStatePopFinished = onStatePopFinished
        self.onStateHasLeftApp = onStateHasLeftApp
        self.nextOnStatePopFinished = nextOnStatePopFinished
        self.nextOnStateHasLeftApp = nextOnStateHasLeftApp
        self.onModalPushedBlock = onModalPushedBlock
        super.init()
    }
}
