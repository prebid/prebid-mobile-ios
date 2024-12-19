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

class SampleModalViewController: UIViewController {
    
    var onDismiss: (() -> Void)?
    
    let webView: WKWebView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(customRendererLabel)
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            customRendererLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            customRendererLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            webView.widthAnchor.constraint(equalToConstant: 300),
            webView.heightAnchor.constraint(equalToConstant: 250),
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
}
