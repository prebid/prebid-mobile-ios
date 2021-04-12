//
//  MockOXMDeviceAccessManager.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

typealias OXMDeviceAccessManagerCompletionHandler = (Bool, String) -> Void

class MockOXMDeviceAccessManager: OXMDeviceAccessManager {

    static var mock_createCalendarEventFromString_completion: ((String, OXMDeviceAccessManagerCompletionHandler) -> Void)?
    override func createCalendarEventFromString(_ eventString: String, completion: @escaping OXMDeviceAccessManagerCompletionHandler) {
        MockOXMDeviceAccessManager.mock_createCalendarEventFromString_completion?(eventString, completion)
    }

    static var mock_savePhotoWithUrlToAsset_completion: ((URL, OXMDeviceAccessManagerCompletionHandler) -> Void)?
    override func savePhotoWithUrlToAsset(_ url: URL, completion: @escaping OXMDeviceAccessManagerCompletionHandler) {
        MockOXMDeviceAccessManager.mock_savePhotoWithUrlToAsset_completion?(url, completion)
    }

    static func reset() {
        self.mock_createCalendarEventFromString_completion = nil
        self.mock_savePhotoWithUrlToAsset_completion = nil
    }

}
