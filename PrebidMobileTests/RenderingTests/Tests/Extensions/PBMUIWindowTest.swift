/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import XCTest

@testable import PrebidMobile

class PBMUIWindowTest: XCTestCase {
    
    func testVisibleViewController() {
        
        let window = UIWindow()
        
        // Test: empty
        XCTAssertNil(window.visibleViewController())
        
        // Test: UIViewController
        let viewController = UIViewController()
        
        window.rootViewController = viewController
        
        XCTAssert(window.visibleViewController() === viewController)
        
        window.rootViewController = nil
        
        // Test: navigationController
        let navigationController = UINavigationController()
        navigationController.viewControllers = [viewController]
        
        window.rootViewController = navigationController
        
        XCTAssert(window.visibleViewController() === viewController)
        
        navigationController.viewControllers = []
        
        // Test: UITabBarController
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [viewController]
        
        window.rootViewController = tabBarController
        
        XCTAssert(window.visibleViewController() === viewController)
        tabBarController.viewControllers = []
        
        // Nested view controllers
        let parentViewController = UIViewController()
        
        parentViewController.present(viewController, animated: false)
        
        window.rootViewController = parentViewController
        
        XCTAssert(window.visibleViewController() === parentViewController)
    }
    
    func testAppVisibleViewController() {
        XCTAssertNil(UIWindow.appVisibleViewController())
    }
}
