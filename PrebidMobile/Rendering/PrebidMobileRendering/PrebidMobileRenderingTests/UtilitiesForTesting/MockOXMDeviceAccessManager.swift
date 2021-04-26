//
//  MockPBMDeviceAccessManager.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

typealias PBMDeviceAccessManagerCompletionHandler = (Bool, String) -> Void

class MockPBMDeviceAccessManager: PBMDeviceAccessManager {

    static var mock_createCalendarEventFromString_completion: ((String, PBMDeviceAccessManagerCompletionHandler) -> Void)?
    override func createCalendarEventFromString(_ eventString: String, completion: @escaping PBMDeviceAccessManagerCompletionHandler) {
        MockPBMDeviceAccessManager.mock_createCalendarEventFromString_completion?(eventString, completion)
    }

    static var mock_savePhotoWithUrlToAsset_completion: ((URL, PBMDeviceAccessManagerCompletionHandler) -> Void)?
    override func savePhotoWithUrlToAsset(_ url: URL, completion: @escaping PBMDeviceAccessManagerCompletionHandler) {
        MockPBMDeviceAccessManager.mock_savePhotoWithUrlToAsset_completion?(url, completion)
    }

    static func reset() {
        self.mock_createCalendarEventFromString_completion = nil
        self.mock_savePhotoWithUrlToAsset_completion = nil
    }

}
