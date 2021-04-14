//
//  MockAlertController.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit
@testable import PrebidMobileRendering

class MockAlertController: UIAlertController {
    var successResult = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func present(_ viewControllerToPresent: UIViewController,
                                      animated flag: Bool,
                                         completion: (() -> Void)? = nil) {
        // get the first action and perform it's completion method.
        if (self.actions.count > 0) {
            let action = self.actions[0] as! MockAlertAction
            action.handler!(action)

        }
        if (completion != nil) {
            completion!()
        }
    }
    
}
