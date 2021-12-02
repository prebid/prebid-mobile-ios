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
import MoPubSDK
import PrebidMobile

class MoPubNativeAdView: UIStackView, MPNativeAdRendering {
    let titleLabel = UILabel()
    let mainTextLabel = UILabel()
    let sponsoredByLabel = UILabel()
    let callToActionLabel = UILabel()
    let mainImageView = UIImageView()
    let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
        
        mainTextLabel.numberOfLines = 0
        
        let rightStackView = UIStackView(arrangedSubviews: [titleLabel, mainTextLabel])
        rightStackView.axis = .vertical
        rightStackView.spacing = 10
        
        let leftStackView = UIStackView(arrangedSubviews: [iconImageView, UIView()])
        leftStackView.axis = .vertical
        
        let headerStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        headerStackView.axis = .horizontal
        headerStackView.spacing = 5
        
        let mainImageStackView = UIStackView(arrangedSubviews: [UIView(), mainImageView, UIView()])
        mainImageStackView.axis = .horizontal
        mainImageStackView.addConstraints([
            mainImageStackView.centerXAnchor.constraint(equalTo: mainImageView.centerXAnchor),
            mainImageStackView.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor),
        ])
        
        sponsoredByLabel.font = UIFont.boldSystemFont(ofSize: sponsoredByLabel.font.pointSize)
        if #available(iOS 13.0, *) {
            sponsoredByLabel.backgroundColor = .systemOrange
        } else {
            sponsoredByLabel.backgroundColor = .orange
        }
        
        let brandStackView = UIStackView(arrangedSubviews: [sponsoredByLabel, UIView()])
        brandStackView.axis = .horizontal

        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemBackground
        } else {
            backgroundColor = .white
        }

        axis = .vertical
        spacing = 5
        
        addArrangedSubview(headerStackView)
        addArrangedSubview(brandStackView)
        addArrangedSubview(mainImageStackView)
        addArrangedSubview(callToActionLabel)
        
        setDefaultConstraints(imageView: iconImageView, maxSize: CGSize(width: 72, height: 72))
        setDefaultConstraints(imageView: mainImageView, maxSize: CGSize(width: 728, height: 72))
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - MPNativeAdRendering
    func nativeMainTextLabel() -> UILabel? {
        return mainTextLabel
    }

    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }

    func nativeCallToActionTextLabel() -> UILabel? {
        return callToActionLabel
    }

    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }

    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }

    func nativeSponsoredByCompanyTextLabel() -> UILabel? {
        return sponsoredByLabel
    }
    
    private func setDefaultConstraints(imageView: UIImageView, maxSize: CGSize) {
        imageView.addConstraints([
            imageView.widthAnchor.constraint(equalToConstant: maxSize.width),
            imageView.heightAnchor.constraint(equalToConstant: maxSize.height),
        ])
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setDesiredImageSize(imageView: UIImageView, nativeImageInfo: NativeAdImage) {
        if let h = nativeImageInfo.height {
            let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: CGFloat(h.floatValue))
            heightConstraint.priority = .defaultLow
            imageView.addConstraint(heightConstraint)
        }
        if let w = nativeImageInfo.width {
            let widthConstraint = imageView.heightAnchor.constraint(equalToConstant: CGFloat(w.floatValue))
            widthConstraint.priority = .defaultLow
            imageView.addConstraint(widthConstraint)
        }
    }
}


