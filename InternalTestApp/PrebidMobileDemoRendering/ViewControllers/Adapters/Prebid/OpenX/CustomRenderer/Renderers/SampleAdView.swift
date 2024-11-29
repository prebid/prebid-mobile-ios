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

class SampleAdView: UIView {
    
    weak var interactionDelegate: DisplayViewInteractionDelegate?
    weak var loadingDelegate: DisplayViewLoadingDelegate?
    
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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func displayAd(_ bid: Bid) {
        if let adm = bid.adm {
            webView.loadHTMLString(adm, baseURL: nil)
            loadingDelegate?.displayViewDidLoadAd(self)
        } else {
            print("Error displaying an ad: No ADM data found in bid response.")
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
