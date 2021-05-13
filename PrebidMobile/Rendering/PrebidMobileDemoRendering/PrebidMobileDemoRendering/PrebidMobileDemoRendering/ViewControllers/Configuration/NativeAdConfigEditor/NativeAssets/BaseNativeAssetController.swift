//
//  BaseNativeAssetController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

class BaseNativeAssetController<T: NativeAsset> : FormViewController, RowBuildHelpConsumer {
    var nativeAsset: T!
    
    var dataContainer: T? {
        get { nativeAsset }
        set { nativeAsset = newValue }
    }
    
    let requiredPropertiesSection = Section("Required properties")
    let optionalPropertiesListSection = Section("Optional properties (list)")
    let optionalPropertiesValuesSection = Section("Optional properties (values)")
    
    var onExit: ()->() = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildForm()
        
        addExtRow(field: "assetExt", src: \.assetExt, dst: NativeAsset.setAssetExt)
        addExtRow(field: "\(nativeAsset.name)Ext",
                  src: \.childExt,
                  dst: NativeAsset.setChildExt)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onExit()
    }
    
    func buildForm() {
        form
            +++ requiredPropertiesSection
            +++ optionalPropertiesListSection
            +++ optionalPropertiesValuesSection
        
        addOptionalInt("assetID", keyPath: \.assetID)
        addOptionalInt("required", keyPath: \.required)
    }
}
