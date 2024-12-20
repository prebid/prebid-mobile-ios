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
import SafariServices

class SampleAdView: UIView, PrebidMobileDisplayViewProtocol {
    
    enum SampleError: LocalizedError {
        case noAdm
        
        var errorDescription: String? {
            switch self {
            case .noAdm:
                return "Renderer did fail - there is no ADM in the response."
            }
        }
    }
    
    weak var interactionDelegate: DisplayViewInteractionDelegate?
    weak var loadingDelegate: DisplayViewLoadingDelegate?
    
    var bid: Bid?
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let customRendererLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Custom Renderer"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        webView.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        webView.navigationDelegate = self
    }
    
    func loadAd() {
        DispatchQueue.main.async {
            if let adm = self.bid?.adm {
                self.webView.loadHTMLString(adm, baseURL: nil)
                self.loadingDelegate?.displayViewDidLoadAd(self)
            } else {
                self.loadingDelegate?.displayView(self, didFailWithError: SampleError.noAdm)
            }
        }
    }
    
    private func setupView() {
        addSubview(webView)
        addSubview(customRendererLabel)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            customRendererLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            customRendererLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            customRendererLabel.heightAnchor.constraint(equalToConstant: 40),
            customRendererLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension SampleAdView: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @MainActor @Sendable @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url,
              navigationAction.navigationType == .linkActivated else {
            decisionHandler(.allow)
            return
        }
        
        guard let presentingVC = interactionDelegate?
            .viewControllerForModalPresentation(fromDisplayView: self) else {
            decisionHandler(.allow)
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        interactionDelegate?.willPresentModal(from: self)
        presentingVC.present(safariVC, animated: true) { [weak self] in
            guard let self = self else { return }
            self.interactionDelegate?.didDismissModal(from: self)
        }
        
        decisionHandler(.cancel)
    }
}

extension SampleAdView: SFSafariViewControllerDelegate {
    
    func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
        interactionDelegate?.didLeaveApp(from: self)
    }
}
