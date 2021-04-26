//
//  NativeAdViewBox.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit
import GoogleMobileAds

class NativeAdViewBox: NativeAdViewBoxProtocol {
    let titleLabel = UILabel()
    let textLabel = UILabel()
    let brandLabel = UILabel()
    let ctaButton = UIButton(type: .system)
    let mainImage = UIImageView()
    let iconImage = UIImageView()
    let mediaView = PBMMediaView()
    
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
    
    weak var mediaViewDelegate: PBMMediaViewDelegate? {
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
        
        playMedia.addTarget(mediaView, action: #selector(PBMMediaView.play), for: .touchUpInside)
        pauseMedia.addTarget(mediaView, action: #selector(PBMMediaView.pause), for: .touchUpInside)
        resumeMedia.addTarget(mediaView, action: #selector(PBMMediaView.resume), for: .touchUpInside)
        muteMedia.addTarget(mediaView, action: #selector(PBMMediaView.mute), for: .touchUpInside)
        unmuteMedia.addTarget(mediaView, action: #selector(PBMMediaView.unmute), for: .touchUpInside)
        
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
    
    private func setDesiredImageSize(imageView: UIImageView, nativeImageInfo: PBMNativeAdImage) {
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
    func renderNativeAd(_ nativeAd: PBMNativeAd) {
        textLabel.text = nativeAd.text
        ctaButton.setTitle(nativeAd.callToAction, for: .normal) 
        brandLabel.text = nativeAd.dataObjects(of: .sponsored).first?.value ?? ""
        titleLabel.text = nativeAd.title
        iconImage.image = imageFromUrlString(nativeAd.iconURL)
        mainImage.image = imageFromUrlString(nativeAd.imageURL)
        
        textLabel.numberOfLines = 0
        
        if let iconInfo = nativeAd.images(of: .icon).first {
            setDesiredImageSize(imageView: iconImage, nativeImageInfo: iconInfo)
        }
        if let imageInfo = nativeAd.images(of: .main).first {
            setDesiredImageSize(imageView: mainImage, nativeImageInfo: imageInfo)
        }
        if let mediaData = nativeAd.videoAd?.mediaData {
            mediaViewContainer.isHidden = false
            mediaView.loadMedia(mediaData)
        }
     }
    
    func registerViews(_ nativeAd: PBMNativeAd) {
        nativeAd.register(contentView, clickableViews: [])
        nativeAd.registerClick(ctaButton, nativeAdElementType: .callToAction)
        nativeAd.registerClick(iconImage, nativeAdElementType: .icon)
        if let brandAsset = nativeAd.dataObjects(of: .sponsored).first {
            nativeAd.registerClick(brandLabel, nativeAdAsset: brandAsset)
        }
        
        if let _ = nativeAd.videoAd?.mediaData {
            nativeAd.registerClick(mediaView, nativeAdElementType: .videoAd)
        }
    }
    
    private func imageFromUrlString(_ urlString: String) -> UIImage? {
        guard let url = URL(string: urlString), let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}

extension NativeAdViewBox {
    func renderCustomTemplateAd(_ customTemplateAd: GADNativeCustomTemplateAd) {
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
