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
import RxSwift

class TestCasesSectionsViewController: UIViewController {

    //These allow the user to filter what tests are visible by type.
    @IBOutlet var sectionsControl: UISegmentedControl!
    @IBOutlet var integrationsControl: UISegmentedControl!
    @IBOutlet var configurableButton: UIButton!
    @IBOutlet var gdprSwitch: UISwitch!
    @IBOutlet var cacheSwitch: UISwitch!

    
    private var sections: [TestCaseTag] = []
    private var integrations: [TestCaseTag] = []
    private var connections: [TestCaseTag] = []
    private let disposeBag = DisposeBag()
    
    //This callback is called when the selection changes on either UISegmentedControl.
    //The collection of TestCaseTags that are now visible is passed.
    private var tagChangedCallback: (([TestCaseTag]) -> Void)?
    
    private var configCallback:((Bool) -> Void)?
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentedControl(sectionsControl, with: sections)
        setupSegmentedControl(integrationsControl, with: integrations)
        
        setupGDPRSwitch()
        setupCacheSwitch()
        DispatchQueue.main.async {
            self.tagChangedCallback?(self.collectTags())
        }
        
        
    }
    
    // MARK: - Public
    
    func setup(with tags: [TestCaseTag], callback: @escaping (([TestCaseTag]) -> Void), configureCallback: @escaping ((Bool) -> Void)) {
        //Extract which options will be in the sections segmented control (banner, interstitial, Video, and MRAID)
        sections = TestCaseTag.extractAppearances(from: tags)
        
        integrations = TestCaseTag.integrations;
        
        //Extract which options will be in the connections segmented control (MockServer or Server)
        connections = TestCaseTag.extractConnections(from: tags)
        
        tagChangedCallback = callback
        
        configCallback = configureCallback
    }
    
    // MARK: - Private Methods
    
    
    
    private func setupGDPRSwitch() {
        let currentValue = AppConfiguration.shared.isGDPREnabled
        gdprSwitch.setOn(currentValue, animated: false)
        gdprSwitch.accessibilityIdentifier = "GDPRSwitch"
    }
    private func setupCacheSwitch() {
        let currentValue = AppConfiguration.shared.isCachingEnabled
        cacheSwitch.setOn(currentValue, animated: false)
        cacheSwitch.accessibilityIdentifier = "Enable Cache Switch"
    }
    private func setupSegmentedControl(_ segmentedControl: UISegmentedControl, with tags: [TestCaseTag]) {
        segmentedControl.removeAllSegments()
        
        //Add each option
        tags.forEach {
            segmentedControl.insertSegment(withTitle: $0.rawValue, at: tags.firstIndex(of: $0)!, animated: false)
        }
        
        //Add an "All" option and select it.
        let tagsCount = tags.count
        segmentedControl.insertSegment(withTitle: "All", at: tagsCount, animated: false)
        segmentedControl.selectedSegmentIndex = tagsCount
        
        segmentedControl.addTarget(self, action: #selector(TestCasesSectionsViewController.segmentedControlAction), for: .valueChanged)
    }
    
    //Returns an array of all currently "visible" tags as selected by the UISegmentedControl
    private func collectTags() -> [TestCaseTag] {
        return
            collectTags(from: sections, for: sectionsControl.selectedSegmentIndex) +
            collectTags(from: integrations, for: integrationsControl.selectedSegmentIndex) +
            collectTags(from: connections, for: false)
    }
    
    private func collectTags(from tags: [TestCaseTag], for index: Int) -> [TestCaseTag] {
        //If "All" is selected (or we're out of bounds), return all tags.
        if (index >= tags.count) {
            return tags
        }

        //Otherwise, return the tag selected (but put it into a 1-element array)
        return [tags[index]]
    }
    
    private func collectTags(from tags: [TestCaseTag], for switchValue: Bool) -> [TestCaseTag] {
        let index = switchValue ? 0 : 1
        if (index >= tags.count) {
            return tags
        }
        return [tags[index]]
    }
    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        tagChangedCallback?(collectTags())
    }
    
    @IBAction func onConfigureTapped(_ sender: Any) {
        configurableButton.isSelected = !configurableButton.isSelected
        configCallback?(configurableButton.isSelected)
    }
    
    
    @IBAction func onGdprSwitchAction(sender: UISwitch) {
        print("GDPR: \(sender.isOn)")
        AppConfiguration.shared.isGDPREnabled = sender.isOn
    }
    @IBAction func onCacheSwitchAction(sender: UISwitch) {
        print("Cache: \(sender.isOn)")
        AppConfiguration.shared.isCachingEnabled = sender.isOn
    }
}
