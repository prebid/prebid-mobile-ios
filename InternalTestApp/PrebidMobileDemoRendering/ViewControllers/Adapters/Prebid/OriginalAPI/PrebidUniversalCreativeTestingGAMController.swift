/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

import GoogleMobileAds

final class PrebidUniversalCreativeTestingGAMController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    GADBannerViewDelegate, WKNavigationDelegate {
    
    var refreshInterval: TimeInterval = 0
    var prebidConfigId: String = ""
    var gamAdUnitID: String = ""
    var adSize = CGSize.zero
    
    let rootController: AdapterViewController
    
    private var gamBanner: GAMBannerView!
    
    private let configIdLabel = UILabel()
    private let reloadButton = ThreadCheckingButton()
    
    init(rootController: AdapterViewController) {
        self.rootController = rootController
        super.init()
        
        setupAdapterController() 
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidBannerConfigurationController(controller: self)
    }
    
    private func setupAdapterController() {
        rootController.showButton.isHidden = true
        
        configIdLabel.isHidden = true
        rootController.actionsView.addArrangedSubview(configIdLabel)
        
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "GAM AdUnit ID: \(gamAdUnitID)"
        
        gamBanner = GAMBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gamBanner.adUnitID = gamAdUnitID
        gamBanner.rootViewController = rootController
        gamBanner.delegate = self
        
        rootController.bannerView?.addSubview(gamBanner)
        
        let gamRequest = GAMRequest()
        gamBanner.load(gamRequest)
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        let gamRequest = GAMRequest()
        gamBanner.load(gamRequest)
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        rootController.bannerView.backgroundColor = .clear
        reloadButton.isEnabled = true
        rootController.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = 300
        rootController.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = 500
        
//        let targetWebView = bannerView.allSubViewsOf(type: WKWebView.self).first
//        targetWebView?.load(URLRequest(url: URL(string: "http://192.168.0.102:9876")!))
    }
}
