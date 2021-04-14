//
//  MockViewController.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
import UIKit
import XCTest

class MockOXMModalViewController : OXMModalViewController {

    override func dismiss(animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        if flag {
            //Wait 1 second to simulate the VC animating into place
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
                completion?()
            })
        } else {
            completion?()
        }
    }
}
