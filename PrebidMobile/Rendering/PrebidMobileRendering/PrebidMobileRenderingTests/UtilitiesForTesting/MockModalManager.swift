//
//  MockModalManager.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockModalManager: PBMModalManager {
    
    var mock_pushModalClosure: ((PBMModalState, UIViewController, Bool, Bool, PBMVoidBlock?) -> Void)?
    override func pushModal(_ state:PBMModalState, fromRootViewController:UIViewController, animated:Bool, shouldReplace:Bool, completionHandler:PBMVoidBlock?) -> PBMVoidBlock? {
        modalStateStack.add(state)
        mock_pushModalClosure?(state, fromRootViewController, animated, shouldReplace, completionHandler)
        return { [weak self, weak state] in
            if let self = self, let state = state {
                self.removeModal(state)
            }
        }
    }
    
    var mock_popModalClosure: (() -> Void)?
    override func popModal() {
        modalStateStack.removeLastObject()
        mock_popModalClosure?()
    }

    var mock_interstitialClosed: (() -> Void)?
    
    var mock_forceOrientation: ((UIInterfaceOrientation) -> Void)?
    override func forceOrientation(_ forcedOrientation:UIInterfaceOrientation) {
        mock_forceOrientation?(forcedOrientation)
    }
}
