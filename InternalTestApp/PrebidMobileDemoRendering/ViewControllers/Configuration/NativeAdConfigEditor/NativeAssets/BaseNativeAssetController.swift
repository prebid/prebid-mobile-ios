/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import Eureka
import PrebidMobile

class BaseNativeAssetController<T: PBRNativeAsset> : FormViewController, RowBuildHelpConsumer {
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
        
        addExtRow(field: "assetExt", src: \.assetExt, dst: PBRNativeAsset.setAssetExt)
        addExtRow(field: "\(nativeAsset.name)Ext",
                  src: \.childExt,
                  dst: PBRNativeAsset.setChildExt)
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
