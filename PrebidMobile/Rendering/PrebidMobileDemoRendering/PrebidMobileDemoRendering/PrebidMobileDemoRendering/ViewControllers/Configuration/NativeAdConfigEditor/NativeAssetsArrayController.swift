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
import PrebidMobileRendering

class NativeAssetsArrayController : FormViewController {
    var nativeAdConfig: NativeAdConfiguration!
    
    private var assetsSection: MultivaluedSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native Assets"
        
        buildForm()
    }
    
    func buildForm() {
        let makeAssetRow: (NativeAsset) -> ButtonRowOf<NativeAsset> = { [weak self] asset in
            return ButtonRowOf<NativeAsset> { row in
                row.value = asset
                row.title = asset.name
            }
            .onCellSelection { [weak self] cell, row in
                print("Edit -- \(try! asset.toJsonString())")
                guard let self = self, let navigator = self.navigationController, let editor: UIViewController = {
                    if let data = asset as? NativeAssetData {
                        let editor = NativeAssetDataController()
                        editor.nativeAsset = data
                        return editor
                    }
                    if let image = asset as? NativeAssetImage {
                        let editor = NativeAssetImageController()
                        editor.nativeAsset = image
                        return editor
                    }
                    if let title = asset as? NativeAssetTitle {
                        let editor = NativeAssetTitleController()
                        editor.nativeAsset = title
                        return editor
                    }
                    if let video = asset as? NativeAssetVideo {
                        let editor = NativeAssetVideoController()
                        editor.nativeAsset = video
                        return editor
                    }
                    // <- Place to add new cases
                    let baseEditor = BaseNativeAssetController()
                    baseEditor.nativeAsset = asset
                    return baseEditor
                }() else {
                    return
                }
                navigator.pushViewController(editor, animated: true)
            }
        }
        
        assetsSection = MultivaluedSection(multivaluedOptions: [.Reorder, .Delete],
                                               header: "assets",
                                               footer: ".Insert adds a 'Add Item' (Add New Tag) button row as last cell.") { section in
            for nextAsset in nativeAdConfig.assets {
                section <<< makeAssetRow(nextAsset)
            }
        }
        
        func makeAddAssetRow(title: String, asset: NativeAsset) -> ButtonRowOf<NativeAsset> {
            return ButtonRowOf<NativeAsset>() { row in
                row.title = title
                row.value = asset
            }
            .onCellSelection { [weak self] cell, row in
                cell.isSelected = false
                self?.assetsSection.append(makeAssetRow(row.value!.copy() as! NativeAsset))
            }
        }
        
        form
            +++ assetsSection
            
            +++ Section()
            <<< makeAddAssetRow(title: "Add Title", asset: NativeAssetTitle(length: 25))
            <<< makeAddAssetRow(title: "Add Image", asset: NativeAssetImage())
            <<< makeAddAssetRow(title: "Add Data", asset: NativeAssetData(dataType: .desc))
            <<< makeAddAssetRow(title: "Add Video", asset: NativeAssetVideo(mimeTypes: [],
                                                                               minDuration: 0,
                                                                               maxDuration: 60,
                                                                               protocols: []))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nativeAdConfig.assets = assetsSection.values().compactMap { $0 as? NativeAsset }
    }
}
