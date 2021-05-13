//
//  MoPubNativeVideoAdView.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit
import MoPubSDK

class MoPubNativeVideoAdView: UIStackView, MPNativeAdRendering {
    let callToActionLabel = UILabel()
    let mainImageView = UIImageView()
    
    let playMedia = UIButton(type: .system)
    let pauseMedia = UIButton(type: .system)
    let resumeMedia = UIButton(type: .system)
    let muteMedia = UIButton(type: .system)
    let unmuteMedia = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        playMedia.setTitle("[play]", for: .normal)
        pauseMedia.setTitle("[pause]", for: .normal)
        resumeMedia.setTitle("[resume]", for: .normal)
        muteMedia.setTitle("[mute]", for: .normal)
        unmuteMedia.setTitle("[unmute]", for: .normal)
        
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
        
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemBackground
        } else {
            backgroundColor = .white
        }

        axis = .vertical
        spacing = 5
        
        addArrangedSubview(mainImageView)
        addArrangedSubview(mediaControls)
        addArrangedSubview(callToActionLabel)
        
        setDefaultConstraints(view: mainImageView, maxSize: CGSize(width: 728, height: 240))
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupMediaControls() {
        if let mediaView = mainImageView.subviews.first as? MediaView {
            playMedia.addTarget(mediaView, action: #selector(MediaView.play), for: .touchUpInside)
            pauseMedia.addTarget(mediaView, action: #selector(MediaView.pause), for: .touchUpInside)
            resumeMedia.addTarget(mediaView, action: #selector(MediaView.resume), for: .touchUpInside)
            muteMedia.addTarget(mediaView, action: #selector(MediaView.mute), for: .touchUpInside)
            unmuteMedia.addTarget(mediaView, action: #selector(MediaView.unmute), for: .touchUpInside)
        }
    }
    
    private func setDefaultConstraints(view: UIView, maxSize: CGSize) {
        view.addConstraints([
            view.widthAnchor.constraint(equalToConstant: maxSize.width),
            view.heightAnchor.constraint(equalToConstant: maxSize.height),
        ])
    }
    
    //MARK: - MPNativeAdRendering
    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }

    func nativeCallToActionTextLabel() -> UILabel? {
        return callToActionLabel
    }
}