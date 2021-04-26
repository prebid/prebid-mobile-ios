//
//  MockViewController.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
import UIKit
import XCTest

//Serves as a root view controller to present from.
class MockViewController : UIViewController {
    
    var expectationDidPresentViewController:XCTestExpectation?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        if flag {
            //Wait 1 second to simulate the VC animating into place
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
                completion?()
                self.expectationDidPresentViewController?.fulfill()
            })
        } else {
            completion?()
            self.expectationDidPresentViewController?.fulfill()
        }
    }
}

class MockPresentedViewController: MockViewController {
    var presentVC: UIViewController?
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentVC = viewControllerToPresent
    }
    
    override var presentedViewController: UIViewController? {
        return presentVC
    }
}
