//
//  MockPBMWebView.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

typealias MockMRAIDResizeHandler = (MRAIDResizeProperties?) -> Void
typealias MockMRAIDExpandHandler = (MRAIDExpandProperties?) -> Void

class MockPBMWebView: PBMWebView {

    var mock_loadHTML: ((String, URL?, Bool) -> Void)?
    override func loadHTML(_ html: String, baseURL: URL?, injectMraidJs: Bool) {
        self.mock_loadHTML?(html, baseURL, injectMraidJs)
    }

    var mock_changeToMRAIDState: ((PBMMRAIDState) -> Void)?
    override func changeToMRAIDState(_ state: PBMMRAIDState) {
        self.mock_changeToMRAIDState?(state)
    }

    override func prepareForMRAID(withRootViewController: UIViewController) {
        self.isViewable = true
    }

    var mock_PBMAddCropAndCenterConstraints: ((CGFloat, CGFloat) -> Void)?
    override func PBMAddCropAndCenterConstraints(initialWidth: CGFloat, initialHeight: CGFloat) {
        self.mock_PBMAddCropAndCenterConstraints?(initialWidth, initialHeight)
    }

    var mock_MRAID_error: ((String, PBMMRAIDAction) -> Void)?
    override func MRAID_error(_ message: String, action: PBMMRAIDAction) {
        self.mock_MRAID_error?(message, action)
    }

    var mock_MRAID_getResizeProperties: ((MockMRAIDResizeHandler) -> Void)?
    override func MRAID_getResizeProperties(completionHandler: @escaping MockMRAIDResizeHandler) {
        self.mock_MRAID_getResizeProperties?(completionHandler)
    }

    var mock_MRAID_getExpandProperties: ((MockMRAIDExpandHandler) -> Void)?
    override func MRAID_getExpandProperties(completionHandler: @escaping MockMRAIDExpandHandler) {
        self.mock_MRAID_getExpandProperties?(completionHandler)
    }

}
