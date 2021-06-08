//
//  NativeContextType.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum NativeContextType : Int {
    case undefined          = 0
    case contentCentric     = 1 /// Content-centric context such as newsfeed, article, image gallery, video gallery, or similar.
    case socialCentric      = 2 /// Social-centric context such as social network feed, email, chat, or similar.
    case product            = 3 /// Product context such as product listings, details, recommendations, reviews, or similar.
    
    case exchangeSpecific   = 500 /// To be defined by the exchange.
};
