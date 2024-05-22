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

import AppTrackingTransparency
import UIKit
import Eureka

import PrebidMobile

class UtilitiesViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Utilities"
        buildForm()
    }
    
    private func buildForm() {
        form
            +++ Section()
            <<< makeActionRow(title: "PrebidMobile Configuration", action: { AboutViewController() }) {
                $0.accessoryType = .detailDisclosureButton
            }
            <<< makeActionRow(title: "IAB Consent Settings", action: { IABConsentViewController() })
            <<< makeActionRow(title: "Command Line Args", action: { CommandArgsViewController() })
            <<< makeActionRow(title: "App Settings", action: { SettingsViewController() })
        
        if #available(iOS 14, *) {
            form.last! <<< attRequestButton
        }
    }
    
    private func makeActionRow(title: String,
                               action: @escaping ()->UIViewController?,
                               extraCellSetup: ((Cell<String>)->())? = nil) -> BaseRow
    {
        return LabelRow() { row in
            row.title = title
        }
        .cellSetup { cell, row in
            cell.accessoryType = .disclosureIndicator
            extraCellSetup?(cell)
        }
        .onCellSelection { [weak self] cell, row in
            if let vc = action(), let navigator = self?.navigationController {
                navigator.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    lazy var attRequestButton = ButtonRow() {
        $0.title = "Request Tracking Authorization"
    }
    .onCellSelection { [weak self] cell, row in
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                var dialogMessage = UIAlertController(title: "AT Tracking",
                                                      message: "Authorization status: \(status.rawValue)",
                                                      preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                dialogMessage.addAction(ok)
                DispatchQueue.main.async { [weak self] in
                    self?.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }
}
