//
//  MockOXMWebView.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

typealias MockMRAIDResizeHandler = (MRAIDResizeProperties?) -> Void
typealias MockMRAIDExpandHandler = (MRAIDExpandProperties?) -> Void

class MockOXMWebView: OXMWebView {

    var mock_loadHTML: ((String, URL?, Bool) -> Void)?
    override func loadHTML(_ html: String, baseURL: URL?, injectMraidJs: Bool) {
        self.mock_loadHTML?(html, baseURL, injectMraidJs)
    }

    var mock_changeToMRAIDState: ((OXMMRAIDState) -> Void)?
    override func changeToMRAIDState(_ state: OXMMRAIDState) {
        self.mock_changeToMRAIDState?(state)
    }

    override func prepareForMRAID(withRootViewController: UIViewController) {
        self.isViewable = true
    }

    var mock_OXMAddCropAndCenterConstraints: ((CGFloat, CGFloat) -> Void)?
    override func OXMAddCropAndCenterConstraints(initialWidth: CGFloat, initialHeight: CGFloat) {
        self.mock_OXMAddCropAndCenterConstraints?(initialWidth, initialHeight)
    }

    var mock_MRAID_error: ((String, OXMMRAIDAction) -> Void)?
    override func MRAID_error(_ message: String, action: OXMMRAIDAction) {
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
