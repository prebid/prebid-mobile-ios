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

@objc(PBMNonModalViewController) @objcMembers
final class NonModalViewController: ModalViewController {
    
    var modalAnimator: ModalAnimator?
    
    init(frameOfPresentedView: CGRect) {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .clear
        
        self.modalAnimator = ModalAnimator(frameOfPresentedView: frameOfPresentedView)
        self.transitioningDelegate = modalAnimator
        
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Override display view layout
    override func configureDisplayView() {
        let props = displayProperties
        
        contentView?.backgroundColor = props?.contentViewColor
        displayView?.backgroundColor = .clear
        
        let size = props?.contentFrame.size ?? .zero
        let contentFrame = CGRect(origin: .zero, size: size)
        displayView?.addConstraints(from: contentFrame)
    }
}
