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
    let mediaView = MediaView()
    
    let contentView: UIView
    private let mediaViewContainer: UIView
    
    var showOnlyMediaView: Bool = false {
        didSet {
            let onlyMediaModeAssets = [
                mediaViewContainer,
                ctaButton,
            ]
            
            contentView
                .subviews
                .filter { !onlyMediaModeAssets.contains($0) }
                .forEach { $0.isHidden = showOnlyMediaView }
        }
    }
    
    var autoPlayOnVisible: Bool {
        get {
            mediaView.autoPlayOnVisible
        }
        set {
            mediaView.autoPlayOnVisible = newValue
        }
    }
    
    weak var mediaViewDelegate: MediaViewDelegate? {
        get { mediaView.delegate }
        set { mediaView.delegate = newValue }
    }
    
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
        
        let playMedia = UIButton(type: .system)
        let pauseMedia = UIButton(type: .system)
        let resumeMedia = UIButton(type: .system)
        let muteMedia = UIButton(type: .system)
        let unmuteMedia = UIButton(type: .system)
        
        playMedia.addTarget(mediaView, action: #selector(MediaView.play), for: .touchUpInside)
        pauseMedia.addTarget(mediaView, action: #selector(MediaView.pause), for: .touchUpInside)
        resumeMedia.addTarget(mediaView, action: #selector(MediaView.resume), for: .touchUpInside)
        muteMedia.addTarget(mediaView, action: #selector(MediaView.mute), for: .touchUpInside)
        unmuteMedia.addTarget(mediaView, action: #selector(MediaView.unmute), for: .touchUpInside)
        
        playMedia.setTitle("[play]", for: .normal)
        pauseMedia.setTitle("[pause]", for: .normal)
        resumeMedia.setTitle("[resume]", for: .normal)
        muteMedia.setTitle("[mute]", for: .normal)
        unmuteMedia.setTitle("[unmute]", for: .normal)
        
        playMedia.accessibilityLabel = "playMedia"
        pauseMedia.accessibilityLabel = "pauseMedia"
        resumeMedia.accessibilityLabel = "resumeMedia"
        muteMedia.accessibilityLabel = "muteMedia"
        unmuteMedia.accessibilityLabel = "unmuteMedia"
        
        let leadingSpacer = UIView()
        let trailingSpacer = UIView()
        
        let mediaControls = UIStackView(arrangedSubviews: [
            leadingSpacer,
            playMedia,
            pauseMedia,
            resumeMedia,
            muteMedia,
            unmuteMedia,
            trailingSpacer,
        ])
        mediaControls.axis = .horizontal
        
        mediaControls.addConstraint(leadingSpacer.widthAnchor.constraint(equalTo: trailingSpacer.widthAnchor))
        mediaControls.spacing = 16
        
        let mediaContainerView = UIStackView(arrangedSubviews: [
            mediaView,
            mediaControls,
        ])
        
        mediaContainerView.axis = .vertical
        mediaContainerView.isHidden = true
        
        [playMedia, pauseMedia, resumeMedia, muteMedia, unmuteMedia].forEach {
            $0.isEnabled = true
        }
        
        let rootStackView = UIStackView(arrangedSubviews: [
            headerStackView,
            brandStackView,
            mainImageStackView,
            mediaContainerView,
            ctaButton,
        ])
        rootStackView.axis = .vertical
        rootStackView.spacing = 5
        
        if #available(iOS 13.0, *) {
            rootStackView.backgroundColor = UIColor.systemBackground
        } else {
            rootStackView.backgroundColor = .white
        }
        
        mediaViewContainer = mediaContainerView
        contentView = rootStackView
        
        setDefaultConstraints(imageView: iconImage, maxSize: CGSize(width: 72, height: 72))
        setDefaultConstraints(imageView: mainImage, maxSize: CGSize(width: 728, height: 72))
        setDefaultConstraints(view: mediaView, maxSize: CGSize(width: 728, height: 240))
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
            iconImage.image = imageFromUrlString(iconUrl)
        }
        
        if let imageUrl = nativeAd.imageUrl {
            mainImage.image = imageFromUrlString(imageUrl)
        }

        textLabel.numberOfLines = 0
     }
    
    func registerViews(_ nativeAd: NativeAd) {
        nativeAd.registerView(view: contentView, clickableViews: [ctaButton, iconImage, brandLabel])
    }
    
    private func imageFromUrlString(_ urlString: String) -> UIImage? {
        guard let url = URL(string: urlString), let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}

extension NativeAdViewBox {
    func renderCustomTemplateAd(_ customTemplateAd: GADCustomNativeAd) {
        textLabel.text = customTemplateAd.string(forKey: "text")
        ctaButton.setTitle(customTemplateAd.string(forKey: "cta"), for: .normal)
        brandLabel.text = customTemplateAd.string(forKey: "sponsoredBy")
        titleLabel.text = customTemplateAd.string(forKey: "title")
        if let imageUrl = customTemplateAd.string(forKey: "imgUrl") {
            mainImage.image = imageFromUrlString(imageUrl)
        }
        if let iconUrl = customTemplateAd.string(forKey: "iconUrl") {
            iconImage.image = imageFromUrlString(iconUrl)
        }
        
        textLabel.numberOfLines = 0
     }
}
