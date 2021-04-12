//
//  MockMeasurementSession.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

class MockMeasurementSession : OXMOpenMeasurementSession {
    
    var setupWebViewClosure: ((UIView) -> Void)?
    var startClosure: (() -> Void)?
    var stopClosure: (() -> Void)?
    var notifyImpressionOccurredClosure: (() -> Void)?
    
    override var eventTracker: OXMEventTrackerProtocol {
        return OXMOpenMeasurementEventTracker()
    }
    
    func setupWebView(_ webView: UIView) {
        setupWebViewClosure?(webView)
    }
    
    override func start() {
        startClosure?()
    }
    
    override func stop() {
        stopClosure?()
    }
    
    override func addFriendlyObstruction(_ view: UIView, purpose:OXMOpenMeasurementFriendlyObstructionPurpose) {
    }
}
