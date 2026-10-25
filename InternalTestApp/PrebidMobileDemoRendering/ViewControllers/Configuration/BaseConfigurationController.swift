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

protocol PrebidConfigurableController: AnyObject {
    var prebidConfigId: String { get set }
    func configurationController() -> BaseConfigurationController?
}

class BaseConfigurationController: FormTableViewController {
    var prebidConfigId: String?
    weak var controller: PrebidConfigurableController?
    var loadAd: (() -> Void)?

    init(controller: PrebidConfigurableController) {
        self.controller = controller
        super.init()
        title = "Example Configuration"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        buildForm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        focusTextRow(identifier: "configId")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onConfigurationFinished()
    }

    func setupView() {
        prebidConfigId = controller?.prebidConfigId
    }

    func buildForm() {
        sections = [loadSection]
    }

    func onConfigurationFinished() {
        controller?.prebidConfigId = prebidConfigId ?? ""
    }

    var loadSection: FormSection {
        FormSection(rows: [rowConfigId], footer: makeLoadButton())
    }

    var rowConfigId: FormRow {
        let row = FormRow("Config Id", kind: .text, value: prebidConfigId)
        row.identifier = "configId"
        row.controlIdentifier = "configId_field"
        row.onTextChange = { [weak self] in self?.prebidConfigId = $0 }
        return row
    }

    func makeLoadButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Load the Ad", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.accessibilityIdentifier = "load_ad"
        button.addTarget(self, action: #selector(onLoad(_:)), for: .touchUpInside)
        return button
    }

    @objc func onLoad(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: loadAd)
    }
}
