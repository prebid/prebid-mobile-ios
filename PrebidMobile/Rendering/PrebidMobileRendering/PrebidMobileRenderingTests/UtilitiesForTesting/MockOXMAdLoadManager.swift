//
//  MockPBMAdLoadManager.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import UIKit

@testable import PrebidMobileRendering

class MockPBMAdLoadManagerVAST: PBMAdLoadManagerVAST {
    
    var mock_requestCompletedSuccess: ((PBMAdRequestResponseVAST) -> Void)?
    override func requestCompletedSuccess(_ adRequestResponse: PBMAdRequestResponseVAST) {
        self.mock_requestCompletedSuccess?(adRequestResponse)
    }
    
    var mock_requestCompletedFailure: ((Error) -> Void)?
    override func requestCompletedFailure(_ error: Error) {
        self.mock_requestCompletedFailure?(error)
    }
}
