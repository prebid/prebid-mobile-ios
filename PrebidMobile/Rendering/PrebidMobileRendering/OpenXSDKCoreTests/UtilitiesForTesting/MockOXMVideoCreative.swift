//
//  MockOXMVideoCreative.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockOXMVideoCreative: OXMVideoCreative {
    
    var closurePause: (() -> Void)?
    var closureResume: (() -> Void)?
    
    override func pause() {
        closurePause?()
    }

    override func resume() {
        closureResume?()
    }
}
