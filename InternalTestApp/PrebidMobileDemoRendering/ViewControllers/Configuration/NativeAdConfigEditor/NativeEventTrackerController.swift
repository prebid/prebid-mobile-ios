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
