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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileGAMEventHandlers

class PrebidGAMNativeAdFeedController: NSObject, PrebidConfigurableController {
    
    var prebidConfigId = ""
    
    var gamAdUnitId = ""
    var gamCustomTemplateIDs: [String] = []
    var adTypes: [GADAdLoaderAdType] = []
    
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private var adLoadingAllowed = false
    private var onAdLoadingAllowed: (()->())?
    
    private weak var rootTableViewController: PrebidFeedTableViewController?
    
    required init(rootTableViewController: PrebidFeedTableViewController) {
        self.rootTableViewController = rootTableViewController
    }
  
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    func allowLoadingAd() {
        adLoadingAllowed = true
        if let onAdLoadingAllowed = onAdLoadingAllowed {
            self.onAdLoadingAllowed = nil
            onAdLoadingAllowed()
        }
    }
    
    func createCells() {
        guard let tableView = self.rootTableViewController?.tableView else {
            return
        }
        
        self.rootTableViewController?.testCases = [
            TestCaseManager.createDummyTableCell(for: tableView),
            TestCaseManager.createDummyTableCell(for: tableView),
            TestCaseManager.createDummyTableCell(for: tableView),
            
            TestCaseForTableCell(configurationClosureForTableCell: { [weak self, weak tableView] cell in
                guard let self = self else {
                    return
                }
                
                guard let adViewCell = tableView?.dequeueReusableCell(withIdentifier: "FeedGAMAdTableViewCell") as? FeedGAMAdTableViewCell else {
                    return
                }
                cell = adViewCell
                adViewCell.nativeAssets = self.nativeAssets
                adViewCell.eventTrackers = self.eventTrackers
                adViewCell.gamCustomTemplateIDs = self.gamCustomTemplateIDs
                adViewCell.loadAd(configID: self.prebidConfigId,
                                  GAMAdUnitID: self.gamAdUnitId,
                                  rootViewController: self.rootTableViewController!,
                                  adTypes: self.adTypes)
            }),
        ]
    }
}
