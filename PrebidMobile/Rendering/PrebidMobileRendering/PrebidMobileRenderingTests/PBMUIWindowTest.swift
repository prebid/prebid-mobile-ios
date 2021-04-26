//
//  PBMUIWindowTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

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
