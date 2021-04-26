//
//  MockMeasurementSession.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockMeasurementSession : PBMOpenMeasurementSession {
    
    var setupWebViewClosure: ((UIView) -> Void)?
    var startClosure: (() -> Void)?
    var stopClosure: (() -> Void)?
    var notifyImpressionOccurredClosure: (() -> Void)?
    
    override var eventTracker: PBMEventTrackerProtocol {
        return PBMOpenMeasurementEventTracker()
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
    
    override func addFriendlyObstruction(_ view: UIView, purpose:PBMOpenMeasurementFriendlyObstructionPurpose) {
    }
}
