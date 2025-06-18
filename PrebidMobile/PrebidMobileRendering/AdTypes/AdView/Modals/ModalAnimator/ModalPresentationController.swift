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
    

import UIKit

@objc(PBMModalPresentationController) @_spi(PBMInternal) public
class ModalPresentationController: UIPresentationController {
    
    @objc(frameOfPresentedView)
    public var objc_frameOfPresentedView: CGRect {
        get { frameOfPresentedView ?? .null }
        set { frameOfPresentedView = newValue == .null ? nil : newValue }
    }
    
    var frameOfPresentedView: CGRect?
    
    var touchForwardingView: TouchForwardingView?
    
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        if let containerView {
            touchForwardingView?.removeFromSuperview()
            
            let touchForwardingView = TouchForwardingView(frame: containerView.bounds)
            touchForwardingView.passThroughViews = [presentingViewController.view]
            self.touchForwardingView = touchForwardingView
            
            containerView.insertSubview(touchForwardingView, at: 0)
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        if let containerView {
            touchForwardingView?.frame = containerView.bounds
        }
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        frameOfPresentedView ?? super.frameOfPresentedViewInContainerView
    }
    
}
