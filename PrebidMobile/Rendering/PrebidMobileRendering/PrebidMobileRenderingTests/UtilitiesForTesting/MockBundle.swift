//
//  MockBundle.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//
import Foundation

@testable import PrebidMobileRendering

class MockBundle : PBMBundleProtocol {
    
    var mockBundleIdentifier: String? = "Mock.Bundle.Identifier"
    var mockBundleName: String? = "MockBundleName"
    var mockBundleDisplayName: String? = "MockBundleDisplayName"
    var mockShouldNilInfoDictionary = false
    
    var bundleIdentifier: String? {
        get {
            return self.mockBundleIdentifier
        }
    }
    
    var infoDictionary: [String : Any]? {
        guard !self.mockShouldNilInfoDictionary else {
            return nil
        }

        var dict = [String: Any]()

        if let mockBundleName = mockBundleName {
            dict[PBMAppInfoParameterBuilder.bundleNameKey] = mockBundleName
        }

        if let mockBundleDisplayName = mockBundleDisplayName {
            dict[PBMAppInfoParameterBuilder.bundleDisplayNameKey] = mockBundleDisplayName
        }

        return dict
    }
    
}
