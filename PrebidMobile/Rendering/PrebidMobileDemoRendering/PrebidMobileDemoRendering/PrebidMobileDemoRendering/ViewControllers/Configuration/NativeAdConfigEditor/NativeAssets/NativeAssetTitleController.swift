//
//  NativeAssetTitleController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

class NativeAssetTitleController: BaseNativeAssetController<PBMNativeAssetTitle> {
    override func buildForm() {
        super.buildForm()
        
        requiredPropertiesSection
            <<< makeRequiredIntRow("length", keyPath: \.length)
    }
}
