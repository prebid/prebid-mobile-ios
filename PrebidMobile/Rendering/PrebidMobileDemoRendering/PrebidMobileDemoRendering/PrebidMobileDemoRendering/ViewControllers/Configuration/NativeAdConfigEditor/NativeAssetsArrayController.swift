//
//  NativeAssetsArrayController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

class NativeAssetsArrayController : FormViewController {
    var nativeAdConfig: OXANativeAdConfiguration!
    
    private var assetsSection: MultivaluedSection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Native Assets"
        
        buildForm()
    }
    
    func buildForm() {
        let makeAssetRow: (OXANativeAsset) -> ButtonRowOf<OXANativeAsset> = { [weak self] asset in
            return ButtonRowOf<OXANativeAsset> { row in
                row.value = asset
                row.title = asset.childType
            }
            .onCellSelection { [weak self] cell, row in
                print("Edit -- \(try! asset.toJsonString())")
                guard let self = self, let navigator = self.navigationController, let editor: UIViewController = {
                    if let data = asset as? OXANativeAssetData {
                        let editor = NativeAssetDataController()
                        editor.nativeAsset = data
                        return editor
                    }
                    if let image = asset as? OXANativeAssetImage {
                        let editor = NativeAssetImageController()
                        editor.nativeAsset = image
                        return editor
                    }
                    if let title = asset as? OXANativeAssetTitle {
                        let editor = NativeAssetTitleController()
                        editor.nativeAsset = title
                        return editor
                    }
                    if let video = asset as? OXANativeAssetVideo {
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
        
        func makeAddAssetRow(title: String, asset: OXANativeAsset) -> ButtonRowOf<OXANativeAsset> {
            return ButtonRowOf<OXANativeAsset>() { row in
                row.title = title
                row.value = asset
            }
            .onCellSelection { [weak self] cell, row in
                cell.isSelected = false
                self?.assetsSection.append(makeAssetRow(row.value!.copy() as! OXANativeAsset))
            }
        }
        
        form
            +++ assetsSection
            
            +++ Section()
            <<< makeAddAssetRow(title: "Add Title", asset: OXANativeAssetTitle(length: 25))
            <<< makeAddAssetRow(title: "Add Image", asset: OXANativeAssetImage())
            <<< makeAddAssetRow(title: "Add Data", asset: OXANativeAssetData(dataType: .desc))
            <<< makeAddAssetRow(title: "Add Video", asset: OXANativeAssetVideo(mimeTypes: [],
                                                                               minDuration: 0,
                                                                               maxDuration: 60,
                                                                               protocols: []))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nativeAdConfig.assets = assetsSection.values().compactMap { $0 as? OXANativeAsset }
    }
}