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
import WebKit
import PrebidMobile

class SampleInterstitialController: NSObject, PrebidMobileInterstitialControllerProtocol {
    
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
    
    private var webView: WKWebView {
        interstitialViewController.webView
    }
    
    private lazy var interstitialViewController: SampleModalViewController = {
        let viewController = SampleModalViewController()
        
        viewController.onDismiss = { [weak self] in
            guard let self else { return }
            self.interactionDelegate?.interstitialControllerDidCloseAd(self)
        }
        
        return viewController
    }()
    
    private var topViewController: UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
    
    override init() {
        super.init()
        webView.navigationDelegate = self
    }
    
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
            guard let presentingController = self.topViewController else {
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

extension SampleInterstitialController: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url,
              navigationAction.navigationType == .linkActivated else {
            decisionHandler(.allow)
            return
        }
        
        interactionDelegate?.interstitialControllerDidClickAd(self)
        
        guard UIApplication.shared.canOpenURL(url) else {
            decisionHandler(.allow)
            return
        }
        
        interactionDelegate?.interstitialControllerDidLeaveApp(self)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        decisionHandler(.cancel)
    }
}
