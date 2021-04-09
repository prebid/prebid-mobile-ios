//
//  TabNavigationController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit

class TabNavigationController: UINavigationController {

    override var prefersStatusBarHidden: Bool {
        return AppConfiguration.shared.isAppStatusBarHidden
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return nil
    }
}
