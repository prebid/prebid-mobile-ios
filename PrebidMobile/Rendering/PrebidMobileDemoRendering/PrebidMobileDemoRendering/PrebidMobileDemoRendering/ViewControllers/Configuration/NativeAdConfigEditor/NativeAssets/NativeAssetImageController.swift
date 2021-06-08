//
//  NativeAssetImageController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

import PrebidMobileRendering

class NativeAssetImageController: BaseNativeAssetController<NativeAssetImage> {
    override func buildForm() {
        super.buildForm()
        
        addOptionalInt("imageType", keyPath: \.imageType)
        addOptionalInt("width", keyPath: \.width)
        addOptionalInt("widthMin", keyPath: \.widthMin)
        addOptionalInt("height", keyPath: \.height)
        addOptionalInt("heightMin", keyPath: \.heightMin)
        
        addOptionalStringArrayField(field: "mimeTypes", keyPath: \.mimeTypes)
    }
}
