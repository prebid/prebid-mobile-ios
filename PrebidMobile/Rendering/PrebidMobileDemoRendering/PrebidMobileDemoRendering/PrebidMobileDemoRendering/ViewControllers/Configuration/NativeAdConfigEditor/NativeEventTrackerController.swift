//
//  NativeEventTrackerController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

import UIKit
import Eureka
import PrebidMobileRendering

class NativeEventTrackerController : FormViewController, RowBuildHelpConsumer {
    var eventTracker: NativeEventTracker!
    
    var dataContainer: NativeEventTracker? {
        get { eventTracker }
        set { eventTracker = newValue }
    }
    
    let requiredPropertiesSection = Section("Required properties")
    let optionalPropertiesListSection = Section("Optional properties (list)")
    let optionalPropertiesValuesSection = Section("Optional properties (values)")
    
    var onExit: ()->() = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Tracker"
        
        buildForm()
    }
    
    private var methodsSection: MultivaluedSection!
    
    func buildForm() {
        form
            +++ requiredPropertiesSection
            +++ optionalPropertiesListSection
            +++ optionalPropertiesValuesSection
        
        requiredPropertiesSection
            <<< makeRequiredIntRow("event", keyPath: \.event)
        
        addRequiredIntArrayField(field: "methods", keyPath: \.methods)
        addExtRow(field: "ext", src: \.ext, dst: NativeEventTracker.setExt(_:))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onExit()
    }
}
