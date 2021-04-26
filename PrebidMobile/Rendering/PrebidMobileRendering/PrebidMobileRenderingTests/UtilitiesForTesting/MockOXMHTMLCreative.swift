//
//  MockPBMHTMLCreative.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockPBMHTMLCreative: PBMHTMLCreative {
    var mockUIApplication: PBMUIApplicationProtocol?
    
    override func getApplication() -> PBMUIApplicationProtocol {
        return mockUIApplication ?? MockUIApplication()
    }
}
