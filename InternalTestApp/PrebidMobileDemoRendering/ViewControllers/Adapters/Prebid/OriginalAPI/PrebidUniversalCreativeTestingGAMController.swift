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
    PrebidConfigurableBannerController {
    
    var refreshInterval: TimeInterval = 0
    var prebidConfigId: String = ""
    var gamAdUnitID: String = ""
    var adSize = CGSize.zero
    
    let rootController: AdapterViewController
    
    private var gamBanner: GAMBannerView!
    
    private let bannerViewDidReceiveAd = EventReportContainer()
    private let bannerViewDidFailToReceiveAd = EventReportContainer()
    
    private let configIdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let reloadButton = ThreadCheckingButton()
    
    init(rootController: AdapterViewController) {
        self.rootController = rootController
        super.init()
        
        setupAdapterController() 
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidBannerConfigurationController(controller: self)
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "AdUnit ID: \(gamAdUnitID)"
        
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
    
    private func setupAdapterController() {
        rootController.showButton.isHidden = true
        
        configIdLabel.isHidden = true
        rootController.actionsView.addArrangedSubview(configIdLabel)
        
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        
        setupActions()
    }
    
    private func setupActions() {
        rootController.setupAction(bannerViewDidReceiveAd, "bannerViewDidReceiveAd called", accessibilityLabel: "bannerViewDidReceiveAd called")
        rootController.setupAction(bannerViewDidFailToReceiveAd, "bannerViewDidFailToReceiveAd called")
        rootController.setupAction(reloadButton, "[Reload]")
    }
    
    private func resetEvents() {
        bannerViewDidReceiveAd.isEnabled = false
        bannerViewDidFailToReceiveAd.isEnabled = false
        reloadButton.isEnabled = true
    }
}

// MARK: - GADBannerViewDelegate

extension PrebidUniversalCreativeTestingGAMController: GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        rootController.bannerView.backgroundColor = .clear
        bannerViewDidReceiveAd.isEnabled = true
        reloadButton.isEnabled = true
        rootController.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = 300
        rootController.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = 250
        
        let targetWebView = bannerView.allSubViewsOf(type: WKWebView.self).first
        targetWebView?.navigationDelegate = self
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        resetEvents()
        bannerViewDidFailToReceiveAd.isEnabled = true
        print(error.localizedDescription)
    }
}

// MARK: - WKNavigationDelegate

extension PrebidUniversalCreativeTestingGAMController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @MainActor @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            print("Error: failed to get server trust.")
        }
    }
}
