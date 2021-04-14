//
//  MockOXMHTMLCreative.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockOXMHTMLCreative: OXMHTMLCreative {
    var mockUIApplication: OXMUIApplicationProtocol?
    
    override func getApplication() -> OXMUIApplicationProtocol {
        return mockUIApplication ?? MockUIApplication()
    }
}
