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

class SampleInterstitialController: NSObject, InterstitialControllerProtocol {
    
    weak var loadingDelegate: InterstitialControllerLoadingDelegate?
    weak var interactionDelegate: InterstitialControllerInteractionDelegate?
    
    var htmlContent: String?
    
    private var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 250)))
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .blue
        return webView
    }()
    
    private var customRendererLabel: UILabel = {
        let label = UILabel()
        label.text = "Custom Renderer"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var interstitialViewController: UIViewController? = {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        
        viewController.view.addSubview(customRendererLabel)
        viewController.view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            customRendererLabel.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            customRendererLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            webView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            webView.widthAnchor.constraint(equalToConstant: 300),
            webView.heightAnchor.constraint(equalToConstant: 250),
        ])
        
        return viewController
    }()
    
    private var topViewController: UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
    
    func loadAd() {
        guard let htmlContent else {
            print("Error: HTML content is not set.")
            return
        }
        
        DispatchQueue.main.async {
            self.webView.loadHTMLString(htmlContent, baseURL: nil)
            self.loadingDelegate?.interstitialControllerDidLoadAd(self)
        }
    }
    
    func show() {
        DispatchQueue.main.async {
            guard let presentingController = self.topViewController else {
                print("Error: Unable to find a top view controller.")
                return
            }
            
            guard let viewController = self.interstitialViewController else {
                print("Error: Failed to create interstitial view controller. Make sure HTML content is set and loadAd is called.")
                return
            }
            
            presentingController.present(viewController, animated: true, completion: nil)
        }
    }
}
