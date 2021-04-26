//
//  MockUIApplication.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

class MockUIApplication : PBMUIApplicationProtocol {
    
    var statusBarFrame = CGRect(x: 0.0, y: 0.0, width: 1.0, height:2.0)
    var isStatusBarHidden = false
    var statusBarOrientation = UIInterfaceOrientation.portrait
    
    var openURLClosure:((URL)->Bool)?
    
    func open(_ url: URL) -> Bool {
        return self.openURLClosure?(url) ?? false
    }
    
    func open(_ url: URL, options: [String : Any]? = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
        let result = open(url)
        completion?(result)
    }
}
