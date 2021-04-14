//
//  MockOXMAdLoadManager.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import UIKit

@testable import PrebidMobileRendering

class MockOXMAdLoadManagerVAST: OXMAdLoadManagerVAST {
    
    var mock_requestCompletedSuccess: ((OXMAdRequestResponseVAST) -> Void)?
    override func requestCompletedSuccess(_ adRequestResponse: OXMAdRequestResponseVAST) {
        self.mock_requestCompletedSuccess?(adRequestResponse)
    }
    
    var mock_requestCompletedFailure: ((Error) -> Void)?
    override func requestCompletedFailure(_ error: Error) {
        self.mock_requestCompletedFailure?(error)
    }
}
