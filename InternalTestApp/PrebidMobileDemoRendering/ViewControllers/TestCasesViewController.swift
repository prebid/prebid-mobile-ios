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
import CoreLocation
import PrebidMobile

class TestCasesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var examples: [TestCase] = []                   // Initial list
    private var displayedExamples: [TestCase] = []  // Displayed filtered list
    
    private var filterTags: [TestCaseTag] = []
    private var filterText = ""
    private var shouldBeConfigured = false
    
    var clLocationManager:CLLocationManager!
 
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayedExamples = self.examples
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //Change Back button text to "Back"
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        self.navigationItem.backBarButtonItem = backItem
        
        let configButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.showConfig(sender:)))
        configButton.accessibilityIdentifier = "AppConfigButton"
        
        self.navigationItem.rightBarButtonItem = configButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Each TestCasesViewController in the tab bar controller uses a segue to embed a TestCasesSectionsViewController
        // which needs to be provided what options will be available on its UI.
        
        if (segue.identifier == "showTestCasesSections") {
            if let testCasesSectionsVC = segue.destination as? TestCasesSectionsViewController {
                //Get all the tags from all examples on this TestCasesViewController
                let tags = self.examples.flatMap { $0.tags }
                testCasesSectionsVC.setup(with: tags,
                                          callback: self.onFilterTagsChanged,
                                          configureCallback: self.onConfigureChanged)
            }
        }
    }
    
    // MARK - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterText = searchBar.text ?? ""
        filterTestCases()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterText = searchBar.text ?? ""
        filterTestCases()
        searchBar.endEditing(true)
    }
    
    // MARK - UITableViewDelegate, UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedExamples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = displayedExamples[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        searchBar.endEditing(true)
        
        //Create and configure the ViewController
        let example = displayedExamples[indexPath.row]
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: example.exampleVCStoryboardID)
        vc.view.backgroundColor = UIColor.white
        vc.title = example.title
        
        //Set up the default account id here
        //as it can be changed in any test cases
        Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try? Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        
        example.configurationClosure?(vc)
        
        if shouldBeConfigured, var configurableVC = vc as? ConfigurableViewController {
            configurableVC.showConfigurationBeforeLoad = true
        }
            
        navigationController?.pushViewController(vc, animated: true)
        
        //A small hack to request location permissions only for the manual getlocation test
        if (example.title == "MRAID OX: Test Properties 3.0" || example.title == "MRAID OX: Test Properties 3.0 (In-App)") {
            clLocationManager = CLLocationManager()
            clLocationManager.delegate = self as CLLocationManagerDelegate
            clLocationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Prebid.shared.locationUpdatesEnabled = (status == .authorizedAlways) || (status == .authorizedWhenInUse)
    }
    
    // MARK: - Private Methods
    
    @objc private func showConfig(sender: UIBarButtonItem) {
        let configViewController = PrebidMobileXSDKConfigurationController()
        
        navigationController?.pushViewController(configViewController, animated: true)
    }
    
    private func onFilterTagsChanged(_ tags: [TestCaseTag]) {
        searchBar.endEditing(true)
        
        filterTags = tags
        filterTestCases()
    }
    
    private func onConfigureChanged(_ shouldConfigure: Bool) {
        self.shouldBeConfigured = shouldConfigure
    }
    
    private func filterTestCases() {
        let filterAppearances = TestCaseTag.extractAppearances(from: filterTags)
        let filterIntegrations = TestCaseTag.extractIntegrations(from: filterTags)
        let filterConnections = TestCaseTag.extractConnections(from: filterTags)
        
        // FILTER initial list:
        // 1. By Tags:
        //   $0.tags.intersection(filterXXX).count > 0
        //   Means that particular test has tags selected by the user. So we should show it.
        // 2. By search text:
        //   Test's title should contain text from the search bar
        displayedExamples = examples
            .filter { $0.tags.intersection(filterAppearances).count > 0 }
            .filter { $0.tags.intersection(filterIntegrations).count > 0 }
            .filter { $0.tags.intersection(filterConnections).count > 0 }
            .filter { filterText.isEmpty || $0.title.range(of: filterText, options: .caseInsensitive) != nil }
        
        tableView.reloadData()
    }
}
