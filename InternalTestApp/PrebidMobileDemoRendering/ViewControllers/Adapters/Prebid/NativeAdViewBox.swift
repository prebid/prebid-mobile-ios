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
import GoogleMobileAds

import PrebidMobile

class NativeAdViewBox: NativeAdViewBoxProtocol {
    let titleLabel = UILabel()
    let textLabel = UILabel()
    let brandLabel = UILabel()
    let ctaButton = UIButton(type: .system)
    let mainImage = UIImageView()
    let iconImage = UIImageView()
    
    let contentView: UIView
    
    init() {
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
        
        let rightStackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
        rightStackView.axis = .vertical
        rightStackView.spacing = 10
        
        let leftStackView = UIStackView(arrangedSubviews: [iconImage, UIView()])
        leftStackView.axis = .vertical
        
        let headerStackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        headerStackView.axis = .horizontal
        headerStackView.spacing = 5
        
        let mainImageStackView = UIStackView(arrangedSubviews: [UIView(), mainImage, UIView()])
        mainImageStackView.axis = .horizontal
        mainImageStackView.addConstraints([
            mainImageStackView.centerXAnchor.constraint(equalTo: mainImage.centerXAnchor),
            mainImageStackView.centerYAnchor.constraint(equalTo: mainImage.centerYAnchor),
        ])
        
        brandLabel.font = UIFont.boldSystemFont(ofSize: brandLabel.font.pointSize)
        if #available(iOS 13.0, *) {
            brandLabel.backgroundColor = .systemOrange
        } else {
            brandLabel.backgroundColor = .orange
        }
        
        let brandStackView = UIStackView(arrangedSubviews: [brandLabel, UIView()])
        brandStackView.axis = .horizontal
        
        let rootStackView = UIStackView(arrangedSubviews: [
            headerStackView,
            brandStackView,
            mainImageStackView,
            ctaButton,
        ])
        rootStackView.axis = .vertical
        rootStackView.spacing = 5
        
        if #available(iOS 13.0, *) {
            rootStackView.backgroundColor = UIColor.systemBackground
        } else {
            rootStackView.backgroundColor = .white
        }
        
        contentView = rootStackView
        
        setDefaultConstraints(imageView: iconImage, maxSize: CGSize(width: 72, height: 72))
        setDefaultConstraints(imageView: mainImage, maxSize: CGSize(width: 728, height: 72))
    }
    
    func removeFromSuperview() {
        contentView.removeFromSuperview()
    }
    
    private func setDefaultConstraints(imageView: UIImageView, maxSize: CGSize) {
        setDefaultConstraints(view: imageView, maxSize: maxSize)
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setDefaultConstraints(view: UIView, maxSize: CGSize) {
        view.addConstraints([
            view.widthAnchor.constraint(equalToConstant: maxSize.width),
            view.heightAnchor.constraint(equalToConstant: maxSize.height),
        ])
    }
}

extension NativeAdViewBox {
    func setUpDummyValues() {
        titleLabel.text = "title"
        textLabel.text = "text"
        ctaButton.setTitle("cta", for: .normal)
        brandLabel.text = "brand"
        if #available(iOS 13.0, *) {
            iconImage.image = UIImage(systemName: "bolt.car")
            mainImage.image = UIImage(systemName: "applewatch.radiowaves.left.and.right")
        }
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

extension NativeAdViewBox {
    func renderNativeAd(_ nativeAd: NativeAd) {
        textLabel.text = nativeAd.text
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        brandLabel.text = nativeAd.sponsoredBy
        titleLabel.text = nativeAd.title
        if let iconUrl = nativeAd.iconUrl {
            iconImage.imageFromServerURL(iconUrl, placeHolder: nil)
        }
        
        if let imageUrl = nativeAd.imageUrl {
            mainImage.imageFromServerURL(imageUrl, placeHolder: nil)
        }
        
        textLabel.numberOfLines = 0
    }
    
    func registerViews(_ nativeAd: NativeAd) {
        nativeAd.registerView(view: contentView, clickableViews: [ctaButton, iconImage, brandLabel])
    }
}

extension NativeAdViewBox {
    func renderCustomTemplateAd(_ customTemplateAd: GADCustomNativeAd) {
        textLabel.text = customTemplateAd.string(forKey: "text")
        ctaButton.setTitle(customTemplateAd.string(forKey: "cta"), for: .normal)
        brandLabel.text = customTemplateAd.string(forKey: "sponsoredBy")
        titleLabel.text = customTemplateAd.string(forKey: "title")
        
        if let imageUrl = customTemplateAd.string(forKey: "imgUrl") {
            mainImage.imageFromServerURL(imageUrl, placeHolder: nil)
        }
        
        if let iconUrl = customTemplateAd.string(forKey: "iconUrl") {
            iconImage.imageFromServerURL(iconUrl, placeHolder: nil)
        }
        
        textLabel.numberOfLines = 0
    }
}
