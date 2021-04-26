//
//  NativeAdViewBoxLinks.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//
import UIKit

class NativeAdViewBoxLinks: NativeAdViewBoxProtocol {
    
    let linkRootButton = UIButton(type: .system)
    let deepLinkOkButton = UIButton(type: .system)
    
    let ratingButton = UIButton(type: .system)
    let sponsoredButton = UIButton(type: .system)
    
    let contentView: UIView
    
    var showOnlyMediaView = false
    var autoPlayOnVisible = false
    
    weak var mediaViewDelegate: PBMMediaViewDelegate?
    
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
    func renderNativeAd(_ nativeAd: PBMNativeAd) {
        linkRootButton.setTitle(nativeAd.callToAction, for: .normal)
        deepLinkOkButton.setTitle(nativeAd.text, for: .normal)
        
        ratingButton.setTitle(nativeAd.dataObjects(of: .rating).first?.value ?? "", for: .normal)
        sponsoredButton.setTitle(nativeAd.dataObjects(of: .sponsored).first?.value ?? "", for: .normal)
    }
    
    func registerViews(_ nativeAd: PBMNativeAd) {
        nativeAd.register(contentView, clickableViews: [])
        nativeAd.registerClick(linkRootButton, nativeAdElementType: .callToAction)
        nativeAd.registerClick(deepLinkOkButton, nativeAdElementType: .text)
        
        if let ratingAsset = nativeAd.dataObjects(of: .rating).first {
            nativeAd.registerClick(ratingButton, nativeAdAsset: ratingAsset)
        }
        
        if let brandAsset = nativeAd.dataObjects(of: .sponsored).first {
            nativeAd.registerClick(sponsoredButton, nativeAdAsset: brandAsset)
        }
    }
}
