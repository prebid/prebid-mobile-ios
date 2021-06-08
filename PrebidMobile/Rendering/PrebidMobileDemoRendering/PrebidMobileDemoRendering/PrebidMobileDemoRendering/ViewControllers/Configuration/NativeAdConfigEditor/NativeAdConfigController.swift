//
//  NativeAdConfigController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka
import PrebidMobileRendering

class NativeAdConfigController : FormViewController, RowBuildHelpConsumer {
    var nativeAdConfig: NativeAdConfiguration?
    
    var dataContainer: NativeAdConfiguration? {
        get { nativeAdConfig }
        set { nativeAdConfig = newValue }
    }
    
    let requiredPropertiesSection = Section("Required properties")
    let optionalPropertiesListSection = Section("Optional properties (list)")
    let optionalPropertiesValuesSection = Section("Optional properties (values)")
    
    var onExit: ()->() = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NativeAdConfig"
        
        buildForm()
    }
    
    private func buildForm() {
        
        // --- Composition itself
        
        form
            +++ requiredPropertiesSection
            +++ optionalPropertiesListSection
            +++ optionalPropertiesValuesSection
        
        requiredPropertiesSection
            <<< makeArrayEditorRow("assets", keyPath: \.assets) { [weak self] in
                let assetsEditor = NativeAssetsArrayController()
                assetsEditor.nativeAdConfig = self?.nativeAdConfig
                self?.navigationController?.pushViewController(assetsEditor, animated: true)
            }
        
        addOptionalString("version", keyPath: \.version)
        addInt("context", keyPath: \.context)
        addInt("contextsubtype", keyPath: \.contextsubtype)
        addInt("plcmttype", keyPath: \.plcmttype)
//        addOptionalInt("plcmtcnt", keyPath: \.plcmtcnt)
        addOptionalInt("seq", keyPath: \.seq)
//        addOptionalInt("aurlsupport", keyPath: \.aurlsupport)
//        addOptionalInt("durlsupport", keyPath: \.durlsupport)
        addOptionalArray("eventtrackers", keyPath: \.eventtrackers) { [weak self] in
            let eventTrackersEditor = NativeEventTrackersArrayController()
            eventTrackersEditor.nativeAdConfig = self?.nativeAdConfig
            self?.navigationController?.pushViewController(eventTrackersEditor, animated: true)
        }
        addOptionalInt("privacy", keyPath: \.privacy)
        addExtRow(field: "ext", src: \.ext, dst: NativeAdConfiguration.setExt(_:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateArrayCount(field: "assets", count: nativeAdConfig?.assets.count ?? 0)
        updateArrayCount(field: "eventtrackers", count: nativeAdConfig?.eventtrackers?.count ?? 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onExit()
    }
}
