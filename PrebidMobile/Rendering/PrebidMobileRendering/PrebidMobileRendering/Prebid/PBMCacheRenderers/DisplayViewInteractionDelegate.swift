//
//  DisplayViewInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol DisplayViewInteractionDelegate where Self: NSObject {

    func trackImpression(for displayView:PBMDisplayView)
    
    func viewControllerForModalPresentation(from displayView: PBMDisplayView) -> UIViewController?
    
    func didLeaveApp(from displayView: PBMDisplayView)
    
    func willPresentModal(from displayView: PBMDisplayView)
    
    func didDismissModal(from displayView: PBMDisplayView)
}
