//
//  MoPubNativeAdViewWithNib.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit
import MoPubSDK

class MoPubNativeAdViewWithNib: UIView,  MPNativeAdRendering {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    //MARK: - MPNativeAdRendering
    
    static func nibForAd() -> UINib {
        return UINib(nibName: "MoPubNativeAdViewWithNib", bundle: nil)
    }
    
    func nativeMainTextLabel() -> UILabel? {
        return mainTextLabel
    }

    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }

    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }

    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
}
