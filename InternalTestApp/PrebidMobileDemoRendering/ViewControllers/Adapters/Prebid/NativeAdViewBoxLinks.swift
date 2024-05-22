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
import PrebidMobile

class NativeAdViewBoxLinks: NativeAdViewBoxProtocol {
    
    let linkRootButton = UIButton(type: .system)
    let deepLinkOkButton = UIButton(type: .system)
    
    let ratingButton = UIButton(type: .system)
    let sponsoredButton = UIButton(type: .system)
    
    let contentView: UIView
    
    init() {
        let rightStackView = UIStackView(arrangedSubviews: [linkRootButton, deepLinkOkButton])
        rightStackView.axis = .vertical
        rightStackView.spacing = 10
        
        let leftStackView = UIStackView(arrangedSubviews: [ratingButton, sponsoredButton])
        leftStackView.axis = .vertical
        leftStackView.spacing = 10
        
        let rootStackView = UIStackView(arrangedSubviews: [rightStackView, leftStackView])
        rootStackView.axis = .horizontal
        rootStackView.spacing = 50
        
        if #available(iOS 13.0, *) {
            rootStackView.backgroundColor = UIColor.systemGroupedBackground
        } else {
            rootStackView.backgroundColor = .gray
        }
        contentView = rootStackView
    }
    
    func removeFromSuperview() {
        contentView.removeFromSuperview()
    }
}

extension NativeAdViewBoxLinks {
    func setUpDummyValues() {
        linkRootButton.setTitle("TDB", for: .normal)
        deepLinkOkButton.setTitle("TDB", for: .normal)
        
        ratingButton.setTitle("TDB", for: .normal)
        sponsoredButton.setTitle("TDB", for: .normal)
    }
    
    func embedIntoView(_ view: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        view.addConstraints([
            view.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            view.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
    }
}

extension NativeAdViewBoxLinks {
    func renderNativeAd(_ nativeAd: NativeAd) {
        linkRootButton.setTitle(nativeAd.callToAction, for: .normal)
        deepLinkOkButton.setTitle(nativeAd.text, for: .normal)
        sponsoredButton.setTitle(nativeAd.sponsoredBy ?? "", for: .normal)
        ratingButton.setTitle(nativeAd.dataObjects(of: .rating).first?.value, for: .normal)
    }
    
    func registerViews(_ nativeAd: NativeAd) {
        nativeAd.registerView(view: contentView, clickableViews: [linkRootButton, deepLinkOkButton, ratingButton, sponsoredButton])
    }
}
