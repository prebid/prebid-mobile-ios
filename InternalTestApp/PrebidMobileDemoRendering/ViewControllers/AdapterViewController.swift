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

import Foundation
import UIKit

import SVProgressHUD

// AdapterViewController is designed to be a generic and agnostic VC for the displaying of a third party SDK's Banner or Interstitial.
// It has a UIView to display banners inside of as well as a show button to display interstitials with.
// Its setupAction(_ button: UIButton, _ name: String) method allows it to add a button representing a third party event (such as MoPub's interstitialDidExpire event)

// AdaptedController are NSObject-derived owners of:
// 1. A third party SDK object (for example, an MPAdView or an MPInterstitialController),
// 2. A collections of UIButtons representing that object's events
protocol AdaptedController {
    init(rootController:AdapterViewController)
    func loadAd()
    func configurationController() -> BaseConfigurationController?
}

extension AdaptedController {
    func configurationController() -> BaseConfigurationController? {
        return nil
    }
}

// This class is designed as a container for any other AdaptedController.
// It implements a common UI template for any adapters.
// Concrete adapters can use public methods of this class to build the particular UI.
class AdapterViewController: UIViewController, ConfigurableViewController {
    
    var showConfigurationBeforeLoad = false
    var postActionClosure: (() -> Void)?
    
    @IBOutlet var bannerView: UIView!
    @IBOutlet var actionsView: UIStackView!
    @IBOutlet var showButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var adapter: AdaptedController?
    
    private var loadAdClosure: (() -> Void)?
    
    // MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        
        loadAdClosure = { [weak self] in
            if let self = self {
                self.adapter?.loadAd()
                self.loadAdClosure = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        actionsView.backgroundColor = .white
        actionsView.alignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if showConfigurationBeforeLoad, let configurationController = adapter?.configurationController() {
            showConfigurationBeforeLoad = false
            let navigator = UINavigationController(rootViewController: configurationController)
            navigator.modalPresentationStyle = .overFullScreen
            present(navigator, animated: true, completion: nil)

            configurationController.loadAd = loadAdClosure
        } else {
            self.loadAdClosure?()
        }
        
        if (UserDefaults.standard.bool(forKey: AppSettingsKeys.showHUD)) {
            SVProgressHUD.show()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: AppSettingsKeys.showHUD)) {
            SVProgressHUD.dismiss()
        }
        
        self.postActionClosure?()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Public Methods
    
    func setup(adapter: AdaptedController) {
        self.adapter = adapter
    }
    
    func setupAction(_ eventReportContainer: EventReportContainer, _ name: String, accessibilityLabel: String? = nil) {
        actionsView.addArrangedSubview(eventReportContainer.container)

        eventReportContainer.isEnabled = false
        setupActionButton(button: eventReportContainer.button, name: name)
        
        if let accessibilityLabel = accessibilityLabel {
            eventReportContainer.button.accessibilityLabel = accessibilityLabel
            eventReportContainer.accessibilityIdentifier = accessibilityLabel
        }
    }
    
    func setupAction(_ button: UIButton, _ name: String, accessibilityLabel: String? = nil) {
        actionsView.addArrangedSubview(button)
        
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        setupActionButton(button: button, name: name)
        
        if let accessibilityLabel = accessibilityLabel {
            button.accessibilityLabel = accessibilityLabel
        }
    }
    
    private func setupActionButton(button: UIButton, name: String) {
        button.setTitle(name, for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1), for: .normal)
        button.setTitleColor(UIColor.gray.withAlphaComponent(0.5), for: .disabled)

        button.titleLabel?.font = .systemFont(ofSize: 15)
    }
}
