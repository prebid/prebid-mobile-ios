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
import Eureka

protocol PrebidConfigurableController: AnyObject {
    var prebidConfigId: String {get set}
    func configurationController() -> BaseConfigurationController?
}

class BaseConfigurationController : FormViewController {
    
    var prebidConfigId: String?
    
    weak var controller: PrebidConfigurableController?
    
    var loadAd: (() -> Void)?
    
    init(controller: PrebidConfigurableController) {
        self.controller = controller

        super.init(nibName: nil, bundle: nil)
        title = "Example Configuration"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        buildForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         let row = self.form.rowBy(tag: "config-id") as? TextRow
         row?.cell.textField.becomeFirstResponder()
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        onConfigurationFinished()
    }
    
    func setupView() {
        guard let controller = self.controller  else {
            assertionFailure()
            return
        }
        
        prebidConfigId = controller.prebidConfigId
    }
    
    func buildForm() {
        form
            +++ loadSection
    }
    
    func onConfigurationFinished() {
        controller?.prebidConfigId = prebidConfigId!
    }
    
    var loadSection: Section {
        return Section() { section in
            var footer = HeaderFooterView<UIButton>(.class)
            footer.height = {44}
            footer.onSetupView = { button, _ in
                button.setTitle("Load the Ad", for: .normal)
                button.setTitleColor(.darkGray, for: .normal)
                button.setTitleColor(.lightGray, for: .highlighted)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                button.addTarget(self, action: #selector(self.onLoad(_:)), for: .touchUpInside)
                button.accessibilityIdentifier = "load_ad"
            }
            
            section.footer = footer
        }
        <<< rowConfigId
    }
    
    var rowConfigId : TextRow {
        return TextRow("config-id") { row in
                row.title = "Config Id"
                row.value = prebidConfigId
                row.cell.accessibilityIdentifier = "configId"
                row.cell.textField.isAccessibilityElement = true
                row.cell.textField.accessibilityIdentifier = "configId_field"
            }
            .onChange { row in
                self.prebidConfigId = row.value
            }
    }
    
    @objc func onLoad(_ sender: Any) {
        dismiss(animated: true, completion: loadAd)
    }
}
