//
//  PrebidGAMNativeAdFeedController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit
import GoogleMobileAds

import PrebidMobileGAMEventHandlers

class PrebidGAMNativeAdFeedController: NSObject, PrebidConfigurableNativeAdCompatibleController {
    
    var prebidConfigId = ""
    
    var gamAdUnitId = ""
    var gamCustomTemplateIDs: [String] = []
    var adTypes: [GADAdLoaderAdType] = []
    
    var nativeAdConfig = PBMNativeAdConfiguration?.none
    
    private var adLoadingAllowed = false
    private var onAdLoadingAllowed: (()->())?
    
    private weak var rootTableViewController: PrebidFeedTableViewController?
    
    required init(rootTableViewController: PrebidFeedTableViewController) {
        self.rootTableViewController = rootTableViewController
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidNativeAdRenderingConfigurationController(controller: self)
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
            TestCaseManager.createDummyTableCell(for: tableView),
            
            TestCaseForTableCell(configurationClosureForTableCell: { [weak self, weak tableView] cell in
                guard let self = self else {
                    return
                }
                
                guard let adViewCell = tableView?.dequeueReusableCell(withIdentifier: "FeedGAMAdTableViewCell") as? FeedGAMAdTableViewCell else {
                    return
                }
                cell = adViewCell
                
                guard let nativeAdConfig = self.nativeAdConfig else {
                    return
                }
                adViewCell.gamCustomTemplateIDs = self.gamCustomTemplateIDs
                adViewCell.loadAd(configID: self.prebidConfigId,
                                  nativeAdConfig: nativeAdConfig,
                                  GAMAdUnitID: self.gamAdUnitId,
                                  rootViewController: self.rootTableViewController!,
                                  adTypes: self.adTypes)
            }),
            ]
    }
    
}


