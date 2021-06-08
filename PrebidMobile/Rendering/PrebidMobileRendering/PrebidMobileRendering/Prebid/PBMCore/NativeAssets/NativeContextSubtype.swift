//
//  NativeContextSubtype.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum NativeContextSubtype : Int {
    case undefined          = 0
    case generalOrMixed     = 10 /// General or mixed content.
    case article            = 11 /// Primarily article content (which of course could include images etc as part of the article)
    case video              = 12 /// Primarily video content
    case audio              = 13 /// Primarily audio content
    case image              = 14 /// Primarily image content
    case userGenerated      = 15 /// User-generated content - forums comments etc
    
    case social             = 20 /// General social content such as a general social network
    case email              = 21 /// Primarily email content
    case chat               = 22 /// Primarily chat/IM content
    
    case sellingProducts    = 30 /// Content focused on selling products whether digital or physical
    case applicationStore   = 31 /// Application store/marketplace
    case productReviews     = 32 /// Product reviews site primarily (which may sell product secondarily)
    
    case exchangeSpecific   = 500 /// To be defined by the exchange.
}
