//
//  NativeDataAssetType.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum NativeDataAssetType : Int {
    case undefined  = 0
    case sponsored  = 1 /// Sponsored By message where response should contain the brand name of the sponsor.
    case desc       = 2 /// Descriptive text associated with the product or service being advertised. Longer length of text in response may be truncated or ellipsed by the exchange.
    case rating     = 3 /// Rating of the product being offered to the user. For example an app’s rating in an app store from 0-5.
    case likes      = 4 /// Number of social ratings or “likes” of the product being offered to the user.
    case downloads  = 5 /// Number downloads/installs of this product
    case price      = 6 /// Price for product / app / in-app purchase. Value should include currency symbol in localised format.
    case salePrice  = 7 /// Sale price that can be used together with price to indicate a discounted price compared to a regular price. Value should include currency symbol in localised format.
    case phone      = 8 /// Phone number
    case address    = 9 /// Address
    case desc2      = 10 /// Additional descriptive text associated text with the product or service being advertised
    case displayURL = 11 /// Display URL for the text ad. To be used when sponsoring entity doesn’t own the content. IE sponsored by BRAND on SITE (where SITE is transmitted in this field).
    case ctaText    = 12 /// CTA description - descriptive text describing a ‘call to action’ button for the destination URL.
    
    case custom     = 500 /// Reserved for Exchange specific usage numbered above 500
}
