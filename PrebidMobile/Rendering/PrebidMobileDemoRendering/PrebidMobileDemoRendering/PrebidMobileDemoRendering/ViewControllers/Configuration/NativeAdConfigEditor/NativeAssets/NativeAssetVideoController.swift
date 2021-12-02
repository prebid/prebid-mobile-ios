//
//  NativeAssetVideoController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

class NativeAssetVideoController: BaseNativeAssetController<OXANativeAssetVideo> {
    override func buildForm() {
        super.buildForm()
        
        addRequiredStringArrayField(field: "mimeTypes", keyPath: \.mimeTypes)
        
        requiredPropertiesSection
            <<< makeRequiredIntRow("minDuration", keyPath: \.minDuration)
            <<< makeRequiredIntRow("maxDuration", keyPath: \.maxDuration)
        
        addRequiredIntArrayField(field: "protocols", keyPath: \.protocols)
    }
}
