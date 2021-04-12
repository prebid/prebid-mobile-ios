//
//  MockAlertAction.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit

class MockAlertAction: UIAlertAction {
    var handler : ((UIAlertAction) -> Swift.Void)?

     init(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.handler = handler
        super.init()
    }
}
