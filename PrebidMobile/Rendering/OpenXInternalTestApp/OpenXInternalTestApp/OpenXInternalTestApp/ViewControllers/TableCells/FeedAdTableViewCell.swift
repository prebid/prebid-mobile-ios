//
//  FeedAdTableViewCell.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit

class FeedAdTableViewCell: UITableViewCell {
    @IBOutlet weak var bannerView: UIView!
    weak var adView: UIView?
    var nativeAd: OXANativeAd?
}
