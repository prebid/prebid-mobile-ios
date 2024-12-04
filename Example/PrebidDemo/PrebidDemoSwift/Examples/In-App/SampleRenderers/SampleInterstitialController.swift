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

import UIKit
import WebKit
import PrebidMobile

/// An example showcasing the implementation of the `PrebidMobileInterstitialControllerProtocol`.
/// A sample controller that is used for rendering ads.
class SampleInterstitialController:
    NSObject,
    PrebidMobileInterstitialControllerProtocol {
    
    enum SampleError: LocalizedError {
        case noAdm
        case noAvailableController
        
        var errorDescription: String? {
            switch self {
            case .noAdm:
                return "Renderer did fail - there is no ADM in the response."
            case .noAvailableController:
                return "Coudn't find a controller to present from."
            }
        }
    }
    
    weak var loadingDelegate: InterstitialControllerLoadingDelegate?
    weak var interactionDelegate: InterstitialControllerInteractionDelegate?
    
    var bid: Bid?
    
    private let webView: WKWebView = {
        let webView = WKWebView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 250)))
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .blue
        return webView
    }()
    
    private let customRendererLabel: UILabel = {
        let label = UILabel()
        label.text = "Custom Renderer"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var interstitialViewController: UIViewController = {
        let controller = UIViewController()
        
        controller.view.backgroundColor = .white
        controller.view.addSubview(customRendererLabel)
        controller.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            customRendererLabel.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            customRendererLabel.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            webView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
            webView.widthAnchor.constraint(equalToConstant: 300),
            webView.heightAnchor.constraint(equalToConstant: 250),
        ])
        
        return controller
    }()
    
    func loadAd() {
        DispatchQueue.main.async {
            guard let adm = self.bid?.adm else {
                self.loadingDelegate?.interstitialController(self, didFailWithError: SampleError.noAdm)
                return
            }
            
            self.webView.loadHTMLString(adm, baseURL: nil)
            self.loadingDelegate?.interstitialControllerDidLoadAd(self)
        }
    }
    
    func show() {
        DispatchQueue.main.async {
            guard let presentingController = UIApplication.shared.topViewController else {
                self.loadingDelegate?.interstitialController(
                    self,
                    didFailWithError: SampleError.noAvailableController
                )
                return
            }
            
            presentingController.present(
                self.interstitialViewController,
                animated: true
            )
        }
    }
}
