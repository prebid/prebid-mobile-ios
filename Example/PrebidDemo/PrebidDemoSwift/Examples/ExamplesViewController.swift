/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

fileprivate let cellID = "exampleCell"

class ExamplesViewController: UIViewController {
    
    @IBOutlet weak var integrationKindPicker: UIButton!
    @IBOutlet weak var adFormatPicker: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let testCases = IntegrationCaseManager.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let actions = IntegrationKind.allCases.map { integration in
            UIAction(title: integration.description, handler: {_ in })
        }
        
        integrationKindPicker.setupPullDown(with: actions)
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        if let settingsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settingsViewController.title = "Settings"
            navigationController?.pushViewController(settingsViewController, animated: true)
        }
    }
}

extension ExamplesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        IntegrationCaseManager.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = testCases[indexPath.row].title
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let testCase = testCases[indexPath.row]
        
        let viewController = testCase.configurationClosure()
        viewController.view.backgroundColor = .white
        viewController.title = testCase.title
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
