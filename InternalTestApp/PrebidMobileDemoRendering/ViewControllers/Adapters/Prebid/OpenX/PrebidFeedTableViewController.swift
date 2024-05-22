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
import PrebidMobile

class PrebidFeedTableViewController: UITableViewController, ConfigurableViewController, BannerViewDelegate {
    
    var showConfigurationBeforeLoad = false
    var testCases: [TestCaseForTableCell] = []
    
    var adapter: PrebidConfigurableController?
    
    var loadAdClosure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIView()
        tableView.backgroundView?.backgroundColor = UIColor.lightGray

        tableView.register(UINib(nibName: "DummyTableViewCell", bundle: nil), forCellReuseIdentifier: "DummyTableViewCell")
        tableView.register(UINib(nibName: "FeedAdTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedAdTableViewCell")
        tableView.register(UINib(nibName: "FeedGAMAdTableViewCell", bundle: nil), forCellReuseIdentifier: "FeedGAMAdTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showConfigurationBeforeLoad, let configurationController = adapter?.configurationController() {
            showConfigurationBeforeLoad = false
            let navigator = UINavigationController(rootViewController: configurationController)
            present(navigator, animated: true, completion: nil)

            configurationController.loadAd = loadAdClosure
        } else {
            self.loadAdClosure?()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?

        let testCase = testCases[indexPath.row % self.testCases.count]
        
        testCase.configurationClosureForTableCell?(&cell)
       
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 305;
    }
    
    // MARK: - BannerViewDelegate
    
    func bannerViewPresentationController() -> UIViewController? {
        return self
    }
    
    func bannerView(_ bannerView: BannerView, didReceiveAdWithAdSize adSize: CGSize) {
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
    }
    
    func bannerViewWillPresentModal(_ bannerView: BannerView) {
    }
    
    //TODO: do we need this ??
    func bannerViewWillDismissModal(_ bannerView: BannerView) {
    }
    
    func bannerViewDidDismissModal(_ bannerView: BannerView) {
    }
    
    func bannerViewWillLeaveApplication(_ bannerView: BannerView) {
    }
}
